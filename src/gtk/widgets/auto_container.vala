using GData;

namespace GDataGtk
{
	public enum ObjectBoxEmptyStyle
	{
		NONE,
		REVEAL,
		USE_PLACEHOLDER
	}

	public delegate Gtk.Widget CreateLabelWidgetDelegate ();

	/**
	 * Provides ability to have autofilled widgets which use binding as their
	 * central point.
	 * 
	 * By default it shows all properties unless set_source_with_layout() was
	 * used
	 * 
	 * @since 0.1
	 */
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/auto_container.ui")]
	public class AutoContainer : Gtk.Box
	{
		[GtkChild] private Gtk.Revealer revealer;
		[GtkChild] private Gtk.Stack stack;
		[GtkChild] private Gtk.Box widget_box;
		[GtkChild] private Gtk.Box toolbar_frame;
		[GtkChild] private Gtk.Box toolbar_box;
		[GtkChild] private Gtk.Box placeholder_box;

		internal class AutoWidgetDescription
		{
			private StrictWeakReference<Gtk.Widget?>? _wref = null;
			public Gtk.Widget widget { 
				get { return (_wref.target); }
			}

			public bool is_container()
			{
				if (_wref.is_valid_ref() == false)
					return (false);
				return (_wref.target.get_type().is_a(AutoContainer));
			}

			public bool is_valid_ref()
			{
				return (_wref.is_valid_ref());
			}

			public string name { get; private set; }
			
			public AutoWidgetDescription (string name, Gtk.Widget widget)
			{
				this.name = name;
				_wref = new StrictWeakReference<Gtk.Widget?>(widget);
				if (_wref.is_valid_ref() == true)
					widget.set_data<string> ("property-name", name);
			}
		}

		private GLib.Array<AutoWidgetDescription> _widgets = new GLib.Array<AutoWidgetDescription>();

		private static int counter = 1;
		private int id;
		private const string _CONTRACT_STORAGE_ = "** auto-contracts **";

		private weak BindingContract _contract = new BindingContract();

		private Gtk.Widget? _placeholder_widget = null;

		private Type _set_up_with = Type.INVALID;

		private DefaultWidgets? _default_widgets = null;

		private string[] _layout = ALL_PROPERTIES;
		/**
		 * Specifies shown properties and their order
		 * 
		 * @since 0.1
		 */
		public string[] layout {
			get { return (_layout); }
			set {
				_layout = value;
				reset_view();
			}
		}

		private CreationEditMode _creation_mode = CreationEditMode.VIEW;
		public CreationEditMode creation_mode {
			get { return (_creation_mode); }
		}

		private EditMode _mode = EditMode.VIEW;
		/**
		 * Specifies auto containers edit mode
		 * 
		 * @since 0.1
		 */
		public EditMode mode {
			get { return (_mode); }
			set {
				_mode = value;
			}
		}

		/**
		 * Specifies data source which provides object with data, this can
		 * either be normal object or pointer/contract. With later ObjectBox
		 * will automatically update and rebind to new source whenever changes
		 * occur
		 * 
		 * @since 0.1
		 */
		public Object? source {
			get { return (as_contract_data(_contract); }
			set {
				if (as_contract_data(_contract) == value)
					return;
				_contract.data = value;
				reset_view();
			}
		}

		/**
		 * Sets source with layout
		public void set_source_with_layout (Object? obj, string[] layout)
		{
			_layout = layout;
			source = obj;
		}

		private Type _restrict_to = Type.INVALID;
		/**
		 * Restricts allowed source to specific type. This allows completely
		 * phasing out any rebuilds and can map widgets by type
		 * 
		 * @since 0.1
		 */
		public Type restrict_to {
			get { return (_restrict_to); }
			set {
				if (_restrict_to == value)
					return;
				Object? obj = _get_source();
				_restrict_to = value;
				if (obj != _get_source())
					reset_view();
			}
		}

		private Object? _get_source()
		{
			if (_restrict_to == Type.INVALID)
				return (source);
			if (_get_source() == null)
				return (null);
			if (_get_source().get_type().is_a(_restrict_to) == false)
				return (null);
			return (source);
		}

		private DefaultWidgets? _default_widgets = null;
		/**
		 * Sets widget creation methods
		 * 
		 * @since 0.1
		 */
		public DefaultWidgets default_widgets {
			get {
				if (_default_widgets == null)
					return (DefaultWidgets.get_default());
				return (_default_widgets);
			}
		}

		private ObjectBoxEmptyStyle _empty_style = ObjectBoxEmptyStyle.USE_PLACEHOLDER;
		/**
		 * Specifies how box should act when no data is to edit. It can use
		 * revealer, placeholder or just set sensitive property
		 * 
		 * @since 0.1
		 */
		public ObjectBoxEmptyStyle empty_style {
			get { return (_empty_style); }
			set {
				if (_empty_style == value)
					return;
				_empty_style = value;
				if (_get_source() == null)
					reset_empty();
			}
		}

		private void reset_empty()
		{
			if (_get_source() != null) {
				sensitive = true;
				revealer.reveal_child = true;
				stack.visible_child = widget_box;
			}
			else {
				if (_empty_style == ObjectBoxEmptyStyle.REVEALER) {
					sensitive = true;
					revealer.reveal_child = false;
					stack.visible_child = widget_box;
				}
				else if (_empty_style == ObjectBoxEmptyStyle.USE_PLACEHOLDER) {
					sensitive = true;
					revealer.reveal_child = true;
					stack.visible_child = placeholder_box;
				}
				else {
					stack.visible_child = widget_box;
					revealer.reveal_child = true;
					sensitive = false;
				}
			}
		}

		private void unbind_all_widgets()
		{
			for (int i=_widgets.length-1; i>=0; i--)
				if (_widgets.data[[(uint) i].widget != null)
					if (_widgets.data[(uint) i].is_container() == true)
						((AutoContainer) _widgets.data[[(uint) i].widget).unbind_all_widgets();
					else
						((AutoWidget) _widgets.data[[(uint) i].widget).unbind();
		}

		private void drop_all_widgets()
		{
			unbind_all_widgets();
			for (int i=_widgets.length-1; i>=0; i--) {
				if (_widgets.data[[(uint) i].widget != null) {
					if (_widgets.data[(uint) i].is_container() == true)
						((AutoContainer) _widgets.data[[(uint) i].widget).drop_all_widgets();
					else {
						widget_box.remove (_widgets.data[[(uint) i].widget);
						_widgets.data[[(uint) i].widget.destroy();
					}
				}
			}
		}

		private Type _resolve_type()
		{
			Type this_type = get_safe_type(as_contract_source(_contract));
			// Check type restriction
			if (restrict_to != GLib.Type.INVALID)
				if (this_type.is_a(restrict_to) == false)
					this_type = restrict_to;
			return (this_type);
		}

		private string[] get_property_list()
		{
			Type this_type = _resolve_type();
			if (this_type == GLib.Type.INVALID)
				return (new string[0]);
			// check if object supports introspection if instance is null
			InformationAvailability availability = BindingDefaults.get_transfer_information_type_for(this_type, false);
			if ((availability == InformationAvailability.DYNAMIC) && (_get_source() == nul))
				return (new string[0]);
			//TODO, bring layouting support
			GLib.Array<string> lst = new GLib.Array<string>();
			if (_layout == ALL_PROPERTIES) {
				iterate_type_properties (object_type, (pspec) => {
					lst.append_val (pspec.name());
				});
			}
			else {
				for (int i=0; i<_layout.length; i++)
					lst.append_val (_layout[i]);
			}
			string[] res = new string[lst.length];
			for (int i=lst.length-1; i>=0; i--) {
				res[i] = lst.data[i];
				lst.remove_index (i);
			}
			return (res);
		}

		/**
		 * Completely resets view if needed in cases where needed
		 * 
		 * @since 0.1
		 */
		public void reset_view()
		{
			if (_get_source() == null) {
				reset_empty();
				unbind_all_widgets();
			}
			else {
				if (_set_up_with != _get_source().get_type())
					drop_all_widgets();
				build_with_type (_resolve_type());
			}
		}

		private bool is_layout (string name)
		{
			//TODO
			return (false);
		}

		private void build_with_type (Type object_type)
		{
			string[] properties = get_property_list();
			for (int i=0; i<properties.length; i++) {
				if (is_layout(properties[i]) == true) {
					
				}
				else {
					BindingDataTransfer? tr = BindingDefaults.get_instance().get_introspection_object_for (type, properties[i]);
					if (tr != null) {
						AutoWidget widget = new AutoWidget.create_with_contract (_default_widgets, properties[i], properties[i], creation_edit_mode, _contract);
					}
				}
			}
		}

		/**
		 * Sets up placeholder widget which is shown when source is not valid
		 * In order to use it "empty_style" must be 
		 * ObjectBoxEmptyStyle.USE_PLACEHOLDER
		 * 
		 * @since 0.1
		 */
		public void set_placeholder (Gtk.Widget? widget)
		{
			if (_placeholder_widget != null) {
				placeholder_box.remove (_placeholder_widget);
				_placeholder_widget.destroy();
			}
			_placeholder_widget = (widget == null) ? new Placeholder.from_icon() : widget;
			_placeholder_widget.visible = true;
			placeholder_box.pack_start (_placeholder_widget, true, true);
		}

		~AutoContainer()
		{
			_contract.unbind_all();
			ContractStorage.get_storage(_CONTRACT_STORAGE_).remove (_contract);
		}

		/**
		 * Creates new AutoContainer
		 * 
		 * @since 0.1
		 */
		public AutoContainer.specific (string[] layout = ALL_PROPERTIES, CreationEditMode creation_mode = CreationEditMode.VIEW, DefaultWidgets? default_widgets = null)
		{
			id = (counter++);
			this._default_widgets = (default_widgets != null) ? default_widgets : DefaultWidgets.get_default();
			_contract = ContractStorage.get_storage(_CONTRACT_STORAGE_).add ("auto-container-%i".printf(id), new BindingContract());
			set_placeholder (null);
			reset_view();
		}

		/**
		 * Creates new AutoContainer
		 * 
		 * @since 0.1
		 */
		public AutoContainer()
		{
			this.specific();
		}
	}
}

