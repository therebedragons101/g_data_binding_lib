using GData;

namespace GDataGtk
{
	private static Binder? __container_binder = null;
	internal static Binder _container_binder()
	{
		if (__container_binder == null)
			__container_binder = new Binder.silent();
		return (__container_binder);
	}

	/**
	 * Provides simplest modeled container that can be used to easily create
	 * and map ListBox rows
	 * 
	 * The main feature of this container is the fact that it is also
	 * implementing BinderMapper interface where there is a difference in the
	 * fact that it autocreates appropriate widgets on the fly and then binds
	 * them afterwards
	 * 
	 * IMPORTANT! This widget is only taking care of layout, not binding. While
	 * binding could be done as well it would only become too complex. When one
	 * needs binding, it is best to simply use Mapper objects
	 * 
	 * TODO build recording in order to speed up rebuilding same container
	 * contents over and over. It is not really good to provide listbox contents
	 * and discover trough reflection each time.
	 * 
	 * TODO add record_object_layout(), record_type_layout() and 
	 * build_from_recording()
	 * 
	 * TODO recording will also depend on adding constructor to AutoValueWidget
	 * 
	 * @since 0.1
	 */
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/auto_container_values.ui")]
	public class AutoContainerValues : Gtk.Alignment
	{
		[GtkChild] Gtk.Box main_box;

		private GLib.Array<AutoValueWidget> _widgets = new GLib.Array<AutoValueWidget>();

		private BindingInterface? _mode_control_binding = null;

		private Binder? _binder_object = null;
		/**
		 * Binder object that instigated this interface
		 * 
		 * @since 0.1
		 */
		public Binder binder_object {
			owned get {
				if (_binder_object == null)
					return (_container_binder());
				return (_binder_object);
			}
			set { _binder_object = value; }
		}

		/**
		 * Specifies orientation of values
		 * 
		 * @since 0.1
		 */
		public Gtk.Orientation orientation {
			get { return (main_box.orientation); }
			set { main_box.orientation = value; }
		}

		/**
		 * Specifies spacing between values
		 * 
		 * @since 0.1
		 */
		public int spacing {
			get { return (main_box.spacing); }
			set { main_box.spacing = value; }
		}

		private DefaultWidgets? _default_widgets = null;
		/**
		 * Specifies default widget builder for container
		 * 
		 * @since 0.1
		 */
		public DefaultWidgets default_widgets {
			owned get {
				if (_default_widgets == null)
					return (DefaultWidgets.get_default());
				return (_default_widgets);
			}
			set {
				if (_default_widgets == value)
					return;
				_default_widgets = value;
				_set_default_widgets();
			}
		}

		private void _set_default_widgets()
		{
			for (int i=0; i<_widgets.length; i++)
				_widgets.data[i].default_widgets = default_widgets;
		}

		/**
		 * Returns content container
		 * 
		 * @since 0.1
		 * 
		 * @return Content container
		 */
		public Gtk.Box get_content_container()
		{
			return (main_box);
		}

		private EditMode _mode = EditMode.VIEW;
		/**
		 * Specifies mode which widget is handling. Note that this can be
		 * changed at any time and widget will be swapped with new one that
		 * handles that mode. At this point there are two options, if widget
		 * was bound then all is good, if value was handled directly assigning
		 * correct value is solely responsability of application.
		 * 
		 * @since 0.1
		 */
		public EditMode mode {
			get { return (_mode); }
			set {
				if (_mode == value)
					return;
				_mode = value;
				_set_mode();
			}
		}

		private void _set_mode()
		{
			for (int i=0; i<_widgets.length; i++)
				_widgets.data[i].mode = mode;
		}

		/**
		 * Creates widget setup for specific source without any binding
		 * 
		 * @since 0.1
		 * 
		 * @param source Source object
		 * @param layout Property layout which needs to be built for
		 * @param prefix Name prefix that will be supplied to widget buildable
		 *               name
		 * @param suffix Name suffix that will be supplied to widget buildable
		 *               name
		 * @param size_collection Sizing of widgets. If size group is specified
		 *                        widgets are simply added to specific size
		 *                        group in collection
		 */
		public void create_layout (Object? source, string[] layout, string prefix = "", string suffix = "", SizeGroupCollection? size_collection = null)
		{
			clear_layout();
			if (source != null)
				create_type_layout (source.get_type(), layout, prefix, suffix);
		}

		/**
		 * Creates widget setup for specific source type without any binding
		 * 
		 * @since 0.1
		 * 
		 * @param source Source object
		 * @param layout Property layout which needs to be built for
		 * @param prefix Name prefix that will be supplied to widget buildable
		 *               name
		 * @param suffix Name suffix that will be supplied to widget buildable
		 *               name
		 * @param size_collection Sizing of widgets. If size group is specified
		 *                        widgets are simply added to specific size
		 *                        group in collection
		 */
		public void create_type_layout (Type source, string[] layout, string prefix = "", string suffix = "", SizeGroupCollection? size_collection = null)
		{
			clear_layout();
			string[] props = resolve_type_layout (source, layout);
			if (props.length == 0)
				return;
			for (int i=0; i<props.length; i++) {
				ParamSpec? parm = TypeInformation.get_instance().find_property_from_type(source, props[i]);
				if (parm == null)
					continue;
				if (parm.value_type.is_a(typeof(Object)) == true)
					if ((default_widgets.property_widget_registered(EditMode.VIEW, parm, true) == false) &&
					    (default_widgets.property_widget_registered(EditMode.EDIT, parm, true) == false))
						continue;
				AutoValueWidget wdg = new AutoValueWidget.with_property(source, parm.name, mode, default_widgets);
				_widgets.append_val (wdg);
				wdg.visible = true;
				((Gtk.Buildable) wdg).set_name(prefix + parm.name + suffix);
				main_box.pack_start (wdg, (orientation == Gtk.Orientation.VERTICAL) ? true : false, (orientation == Gtk.Orientation.VERTICAL) ? true : false);
				if (size_collection != null)
					size_collection.get_group (prefix + parm.name + suffix).add_widget (wdg);
			}
		}

		/**
		 * Creates widget setup for specific source type without any binding.
		 * This method on the other hand does not create value widgets, but
		 * creates labels with names instead.
		 * 
		 * If there is a need to override label creation, this is perfectly
		 * simple once known how it works.
		 * - For every ParamSpec it finds in specified layout it resolves
		 *   unique bindable PropertyInfoAttribute and binds label ti its nick
		 *   property
		 * - By default no custom creation method is specified, so build falls
		 *   down to resolving typeof(string) widget
		 * 
		 * Solution is simple. Simply register custom method for
		 * PropertyInfoAttribute and "nick" property
		 * 
		 * @since 0.1
		 * 
		 * @param source Source object
		 * @param layout Property layout which needs to be built for
		 * @param prefix Name prefix that will be supplied to widget buildable
		 *               name
		 * @param suffix Name suffix that will be supplied to widget buildable
		 *               name
		 * @param size_collection Sizing of widgets. If size group is specified
		 *                        widgets are simply added to specific size
		 *                        group in collection
		 */
		public void create_type_header_layout (Type source, string[] layout, string prefix = "", string suffix = "", SizeGroupCollection? size_collection = null)
		{
			clear_layout();
			string[] props = resolve_type_layout (source, layout);
			if (props.length == 0)
				return;
			for (int i=0; i<props.length; i++) {
				ParamSpec? parm = TypeInformation.get_instance().find_property_from_type(source, props[i]);
				if (parm == null)
					continue;
				if (parm.value_type.is_a(typeof(Object)) == true)
					if ((default_widgets.property_widget_registered(EditMode.VIEW, parm, true) == false) &&
					    (default_widgets.property_widget_registered(EditMode.EDIT, parm, true) == false))
						continue;
				PropertyInfoAttribute attr = PropertyInfoAttribute.get_property_info(parm);
				AutoValueWidget wdg = new AutoValueWidget.with_property(typeof(PropertyInfoAttribute), "nick", EditMode.VIEW, default_widgets);
				_container_binder().bind (attr, "nick", wdg.get_bindable_widget(), wdg.get_value_binding_property(), BindFlags.SYNC_CREATE);
				_widgets.append_val (wdg);
				wdg.visible = true;
				((Gtk.Buildable) wdg).set_name(prefix + parm.name + suffix);
				main_box.pack_start (wdg, (orientation == Gtk.Orientation.VERTICAL) ? true : false, (orientation == Gtk.Orientation.VERTICAL) ? true : false);
				if (size_collection != null)
					size_collection.get_group (prefix + parm.name + suffix).add_widget (wdg);
			}
		}

		/**
		 * Removes all widgets from container
		 * 
		 * @since 0.1
		 */
		public void clear_layout()
		{
			while (_widgets.length > 0) {
				remove (_widgets.data[_widgets.length-1]);
				_widgets.remove_index (_widgets.length-1);
			}
		}

		/**
		 * Sets mode control object which is shared amongs all widgets of this
		 * type for certain group
		 * 
		 * @since 0.1
		 * 
		 * @param control Control object for EDIT/VIEW mode
		 */
		public AutoContainerValues set_mode_control (EditModeControlInterface? control)
		{
			if (_mode_control_binding != null) {
				_mode_control_binding.unbind();
				_mode_control_binding = null;
			}
			if (control != null)
				_mode_control_binding = _auto_binder().bind (control, "mode", this, "mode", BindFlags.SYNC_CREATE);
			return (this);
		}

		/**
		 * Specifies internal content margins
		 * 
		 * @since 0.1
		 * 
		 * @param left Left margin
		 * @param top Top margin
		 * @param right Right margin
		 * @param bottom Bottom margin
		 */
		public void set_content_margins (int left, int top, int right, int bottom)
		{
			main_box.margin_left = left;
			main_box.margin_right = right;
			main_box.margin_top = top;
			main_box.margin_bottom = bottom;
		}

		/**
		 * Creates new container for auto values. By default container is empty
		 * and needs to be filled trough create_layout() or create_type_layout()
		 * 
		 * @since 0.1
		 * 
		 * @param mode Edit mode for widgets
		 * @param orientation Container orientation
		 * @param spacing Widget spacing
		 */
		public AutoContainerValues (EditMode mode = EditMode.VIEW, Gtk.Orientation orientation = Gtk.Orientation.HORIZONTAL, int spacing = 8)
		{
			this.mode = mode;
			this.orientation = orientation;
			this.spacing = spacing;
		}
	}
}

