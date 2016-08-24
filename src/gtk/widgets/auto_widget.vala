using GData;
using GData.Generics;

namespace GDataGtk
{
	/**
	 * AutoWidget provides automatic widget creation trough use of 
	 * DefaultWidgets.
	 * 
	 * Note that if it is created with contract then object passed in 
	 * set_new_owner() and set_new_target() is replaced by data contract is
	 * pointing at.
	 * 
	 * @since 0.1
	 */
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/auto_widget.ui")]
	public class AutoWidget : Gtk.Alignment
	{
		[GtkChild] private Gtk.Box full_box;
		[GtkChild] private Gtk.Box label_container;
		[GtkChild] private Gtk.Stack mode_stack;
		[GtkChild] private Gtk.Alignment read_alignment;
		[GtkChild] private Gtk.Alignment write_alignment;

		private StrictWeakReference<BindingContract?>? _contract = null;

		private BindingInformationInterface? _read_binding = null;
		private BindingInformationInterface? _write_binding = null;

		private bool _initialized = false;
		private bool _mode_reset = false;
		private CreationEditMode _creation_edit_mode = CreationEditMode.FULL;

		private bool _view_available = true;
		private bool _edit_available = false;
		private string _read_property = "";
		private string _write_property = "";
		private DefaultWidgets? _default_widgets = null;

		private Gtk.Widget? _read_widget = null;
		private Gtk.Widget? _write_widget = null;
		private StrictWeakRef? _object = null;
		private Type _object_type = GLib.Type.INVALID;
		private string _property_name = "!";

		private Gtk.Widget? _label_widget = null;

		private int _spacing = -1;
		/**
		 * Specifies spacing between label and widget if label is specified.
		 * Default value is -1 which switches between 6 vertical and 8 
		 * horizontal based on orientation
		 * 
		 * @since 0.1
		 */
		public int spacing {
			get { return (_spacing); }
			set {
				_spacing = value;
				if (_spacing > -1)
					full_box.spacing = _spacing;
				else
					full_box.spacing = (full_box.orientation == Gtk.Orientation.HORIZONTAL) ? 8 : 6;
			}
		}

		private bool _use_custom_label = false;
		public bool use_custom_label {
			get { return (_use_custom_label); }
			set {
				if (_use_custom_label == value)
					return;
				_use_custom_label = value;
				notify_property ("label");
			}
		}

		private string _blurb = "";
		private string _custom_label = "";
		private string _label = "";
		public string label {
			get {
				if (_use_custom_label == true)
					return (_custom_label);
				return (_label); 
			}
			set {
				if (_custom_label == value)
					return;
				_custom_label = value;
				if (_use_custom_label == false)
					return;
			}
		}

		public bool show_label { get; set; }

		private bool _show_hints = false;
		public bool show_hints { 
			get { return (_show_hints); }
			set {
				_show_hints = value;
				if (_read_widget != null)
					_read_widget.set_tooltip_text ((_show_hints = true) ? _blurb : "");
				if (_write_widget != null)
					_write_widget.set_tooltip_text ((_show_hints = true) ? _blurb : "");
			} 
		}

		/**
		 * Specifies orientation of label and widget
		 * 
		 * @since 0.1
		 */
		public Gtk.Orientation orientation {
			get { return (full_box.orientation); }
			set {
				full_box.orientation = value;
				spacing = _spacing;
			}
		}

		private bool _can_edit = true;
		/**
		 * Specifies if contents are editable or not
		 * 
		 * @since 0.1
		 */
		public bool can_edit {
			get {
				if ((_object_type == GLib.Type.INVALID) || (_write_widget == null) || (has_set_flag(_creation_edit_mode, CreationEditMode.EDIT) == false))
					return (false);
				return (_can_edit);
			}
		}

		private bool _can_view = true;
		/**
		 * Specifies if contents are editable or not
		 * 
		 * @since 0.1
		 */
		public bool can_view {
			get {
				if ((_object_type == GLib.Type.INVALID) || (_read_widget == null) || (has_set_flag(_creation_edit_mode, CreationEditMode.VIEW) == false))
					return (false);
				return (_can_view);
			}
		}

		/**
		 * Access to viewing alignment
		 * 
		 * @since 0.1
		 */
		public Gtk.Alignment view_alignment {
			get { return (read_alignment); }
		}

		/**
		 * Access to viewing widget
		 * 
		 * @since 0.1
		 */
		public Gtk.Widget? view_widget {
			get { return (_read_widget); }
		}

		/**
		 * Access to editing alignment
		 * 
		 * @since 0.1
		 */
		public Gtk.Alignment edit_alignment {
			get { return (write_alignment); }
		}

		/**
		 * Access to editing widget
		 * 
		 * @since 0.1
		 */
		public Gtk.Widget? edit_widget {
			get { return (_write_widget); }
		}

		/**
		 * Returns true if contents are specified, false otherwise
		 * 
		 * @since 0.1
		 */
		public bool is_valid {
			get { return (_object.is_valid_ref()); }
		}

		private EditMode _edit_mode = EditMode.VIEW;
		/**
		 * Specifies mode in which auto widget is in
		 * 
		 * @since 0.1
		 */
		public EditMode edit_mode {
			get { return ((mode_stack.visible_child == read_alignment) ? EditMode.VIEW : EditMode.EDIT); } 
			set {
				EditMode new_mode = value;
				if ((new_mode == EditMode.VIEW) && (_view_available == false))
					new_mode = EditMode.EDIT;
				if ((new_mode == EditMode.EDIT) && (_edit_available == false))
					new_mode = EditMode.VIEW;
				_edit_mode = value;
				if ((_mode_reset == false) && (_edit_mode == new_mode))
					return;
				if ((can_edit == true) && (can_view == true))
					mode_stack.visible_child = (new_mode == EditMode.VIEW) ? read_alignment : write_alignment;
				else if (can_edit == true)
					mode_stack.visible_child = write_alignment;
				else
					mode_stack.visible_child = read_alignment;
			}
		}

		/**
		 * Packs label widget into container. If widget is specified as null
		 * then previous widget is removed if needed. set_auto_label_widget()
		 * can be used to set up everything automatically
		 * 
		 * @since 0.1
		 * 
		 * @param widget Label widget
		 */
		public void set_label_widget (Gtk.Widget? widget)
		{
			if (_label_widget == widget)
				return;
			if (_label_widget != null) {
				label_container.remove (_label_widget);
				_label_widget.destroy();
			}
			_label_widget = widget;
			if (_label_widget != null) {
				_label_widget.visible = true;
				label_container.pack_start (_label_widget, false, false);
			}
			label_container.visible = (_label_widget != null);
		}

		/**
		 * Returns widget that should be used for label sizing
		 * 
		 * @since 0.1
		 * 
		 * @return Sizing widget
		 */
		public Gtk.Widget get_label_size_widget()
		{
			return (label_container);
		}

		/**
		 * Sets default label setup
		 * 
		 * @since 0.1
		 */
		public void set_auto_label_widget()
		{
			Gtk.Label label = new Gtk.Label("AUTO");
			label.visible = true;
			_auto_binder().bind (this, "label", label, "label", BindFlags.SYNC_CREATE);
			set_label_widget (label);
		}

		public void unbind()
		{
			if (_contract.is_valid_ref() == true) {
				if (_read_binding != null) {
					_contract.target.unbind(_read_binding);
					_read_binding = null;
				}
				if (_write_binding != null) {
					_contract.target.unbind(_write_binding);
					_write_binding = null;
				}
			}
			else {
				//TODO, standalone binder support
			}
		}

		private void _bind()
		{
			if (_contract.is_valid_ref() == true) {
				if (_read_widget != null)
					_read_binding = _contract.target.bind (_property_name, _read_widget, _read_property, BindFlags.SYNC_CREATE);
				if (_write_widget != null)
					_write_binding = _contract.target.bind (_property_name, _write_widget, _write_property, BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
			}
			else {
				//TODO standalone binder
			}
		}

		/**
		 * Sets auto widget on new target which if necessary removes old widgets
		 * and creates new ones
		 * 
		 * @since 0.1
		 * 
		 * @param object Object being target of editing
		 * @param property_name Property that is containing edited data
		 */
		public void set_new_target (Object? _object, string property_name)
		{
			weak Object? object = (_contract != null) ? as_contract_source(_contract.target) : _object;
			if ((_initialized == true) && (safe_get_type(object) == _object_type) && (_property_name == property_name)) {
				set_new_owner (object);
				return;
			}
			_initialized = true;
			unbind();
			Type new_object_type = (object == null) ? Type.INVALID : object.get_type();
			if ((_object_type == new_object_type) && (property_name == _property_name))
				return;
			_property_name = property_name;
			if (_read_widget != null) {
				read_alignment.remove (_read_widget);
				_read_widget.destroy();
			}
			if (_write_widget != null) {
				write_alignment.remove (_write_widget);
				_write_widget.destroy();
			}
			BindingDataTransfer? _source_transfer = BindingDefaults.get_instance().get_transfer_object_for (object, property_name, false);
			_label = (_source_transfer == null) ? "" : _source_transfer.get_nick();
			notify_property ("label");
			_blurb = (_source_transfer == null) ? "" : _source_transfer.get_blurb();
			if (_source_transfer == null)
				new_object_type = GLib.Type.INVALID;
			if (new_object_type == GLib.Type.INVALID) {
				_read_widget = new Gtk.Label ("No content");
				_read_widget.visible = true;
				read_alignment.add (_read_widget);
			}
			else {
				_read_property = "";
				if (has_set_flag(_creation_edit_mode, CreationEditMode.VIEW) == true) {
					_read_widget = _default_widgets.create_binding_transfer_widget (EditMode.VIEW, _source_transfer, out _read_property);
					if (_read_widget == null) {
						GLib.warning ("Could not resolve default widget for (%s).%s type=%s", _source_transfer.get_object_type(), 
						              _source_transfer.get_name(), _source_transfer.get_value_type().name());
						_read_widget = _default_widgets.default_fallback (EditMode.VIEW, _source_transfer.get_value_type(), out _read_property);
					}
					read_alignment.add (_read_widget);
				}
				if ((has_set_flag(_creation_edit_mode, CreationEditMode.EDIT) == true) && (has_set_flag(_source_transfer.get_property_flags(), ParamFlags.WRITABLE) == true)) {
					_write_property = "";
					_write_widget = _default_widgets.create_binding_transfer_widget (EditMode.EDIT, _source_transfer, out _write_property);
					if (_write_widget != null)
						write_alignment.add (_write_widget);
				}
			}
			_bind();
			if (_read_widget != null) {
				((Gtk.Buildable) _read_widget).set_name("read_widget");
				_read_widget.set_tooltip_text ((_show_hints = true) ? _blurb : "");
			}
			if (_write_widget != null) {
				((Gtk.Buildable) _write_widget).set_name("write_widget");
				_write_widget.set_tooltip_text ((_show_hints = true) ? _blurb : "");
			}
			edit_mode = _edit_mode;
			(this as Gtk.Buildable).set_name ((new_object_type == GLib.Type.INVALID) ? "" : property_name);
		}

		/**
		 * Leaves the property information and only changes the owner which
		 * is much faster method. Note that if type is not the same, error is
		 * reported
		 * 
		 * @since 0.1
		 * 
		 * @param object New owner object
		 */
		public void set_new_owner (Object? _object)
		{
			// rebind widgets to new owner
			if (_contract != null) {
				GLib.warning ("AutoWidget set up with contract should not modify object directly as it is taken care with contract automatically");
				return;
			}
			weak Object? object = (_contract != null) ? as_contract_source(_contract.target) : _object;
			if (safe_get_type(_object).is_a(_object_type) == true) {
				unbind();
				_bind();
			}
			else
				set_new_target (object, _property_name);
		}

		private void handle_invalid()
		{
			notify_property ("is-valid");
		}

		private AutoWidget.create_full (DefaultWidgets? default_widgets, string name, bool read_mode, bool write_mode, 
		                                Object? object, string property_name, CreationEditMode creation_edit_mode, BindingContract? contract)
		{
			_contract = new StrictWeakReference<BindingContract?> (contract);
			this._default_widgets = (default_widgets != null) ? default_widgets : DefaultWidgets.get_default();
			_creation_edit_mode = creation_edit_mode;
			_object = new StrictWeakRef (object, handle_invalid);
			_object_type = (object == null) ? Type.INVALID : object.get_type();
			_property_name = property_name;
			_view_available = read_mode;
			_edit_available = write_mode;
			set_new_target (object, property_name);
		}

		public AutoWidget.create (DefaultWidgets? default_widgets, string name, Object? object, string property_name, 
		                          CreationEditMode creation_edit_mode)
		{
			this.create_full (default_widgets, name, has_set_flag(creation_edit_mode, CreationEditMode.VIEW), has_set_flag(creation_edit_mode, CreationEditMode.EDIT),
			                  object, property_name, creation_edit_mode, null);
		}

		public AutoWidget.create_with_contract (DefaultWidgets? default_widgets, string name, string property_name, 
		                                        CreationEditMode creation_edit_mode, BindingContract contract)
		{
			this.create_full (default_widgets, name, has_set_flag(creation_edit_mode, CreationEditMode.VIEW), has_set_flag(creation_edit_mode, CreationEditMode.EDIT),
			                  as_contract_source(contract), property_name, creation_edit_mode, contract);
		}

		public AutoWidget()
		{
			this.create_full (DefaultWidgets.get_default(), "", true, false, null, "", CreationEditMode.VIEW, null);
		}
	}
}
