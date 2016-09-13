using GData;

namespace GDataGtk
{
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/auto_container_mode_values.ui")]
	public class AutoContainerModeValues : Gtk.Alignment
	{
		[GtkChild] Gtk.Box main_box;

		private GLib.Array<AutoContainerRow> _widgets = new GLib.Array<AutoContainerRow>();

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

		private AutoContainerControl _control = new AutoContainerControl();
		/**
		 * Specifies common control over row display
		 * 
		 * @since 0.1
		 */
		public AutoContainerControl control {
			get { return (_control); }
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

		private CreationEditMode _creation_mode = CreationEditMode.FULL;
		/**
		 * Specifies how mode widgets should be created
		 * 
		 * @since 0.1
		 */
		public CreationEditMode creation_mode {
			get { return (_creation_mode); }
		}

		private EditModeControl _mode = new EditModeControl(EditMode.EDIT);
		/**
		 * Specifies mode which widget is handling. Note that this can be
		 * changed at any time and widget will be swapped with new one that
		 * handles that mode. At this point there are two options, if widget
		 * was bound then all is good, if value was handled directly assigning
		 * correct value is solely responsability of application.
		 * 
		 * @since 0.1
		 */
		public EditModeControl mode {
			get { return (_mode); }
			set {
				if (_mode == value)
					return;
				_mode = value;
			}
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
		public void create_layout (Object? source, string[] layout, string prefix = "", string suffix = "", bool build_full_rows = false)
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
		public void create_type_layout (Type source, string[] layout, string prefix = "", string suffix = "", bool build_full_rows = false)
		{
			clear_layout();
			string[] props = resolve_type_layout (source, layout);
			if (props.length == 0)
				return;
			Gtk.SizeGroup labels = new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL);
			Gtk.SizeGroup values = new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL);
			Gtk.SizeGroup tools = new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL);
			for (int i=0; i<props.length; i++) {
				ParamSpec? parm = TypeInformation.get_instance().find_property_from_type(source, props[i]);
				if (parm == null)
					continue;
				if (parm.value_type.is_a(typeof(Object)) == true)
					if ((default_widgets.property_widget_registered(EditMode.VIEW, parm, true) == false) &&
					    (default_widgets.property_widget_registered(EditMode.EDIT, parm, true) == false))
						continue;
				AutoContainerRow row = new AutoContainerRow(_control);
				AutoValueModeWidget wdg = new AutoValueModeWidget.with_property (source, parm.name, mode.mode, creation_mode, default_widgets);
				row.notify["data-tooltip"].connect (() => {
					wdg.data_tooltip = row.data_tooltip;
				});
				wdg.set_mode_control (mode);
				row.set_data_widget (prefix + parm.name + suffix, wdg);
				wdg.visible = true;
				_widgets.append_val (row);
				row.visible = true;
				Gtk.Label lbl = new Gtk.Label (parm.get_nick());
				row.data_tooltip = parm.get_blurb();
				labels.add_widget (row.get_label_sizing_alignment());
				values.add_widget (row.get_value_sizing_alignment());
				tools.add_widget (row.get_tools_sizing_alignment());
				row.set_label_widget (lbl);
				lbl.visible = true;
				main_box.pack_start (row, true, true);
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
		public AutoContainerModeValues set_mode_control (EditModeControlInterface? control)
		{
			_mode.set_mode_control (control);
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
		public AutoContainerModeValues (EditMode mode = EditMode.VIEW, CreationEditMode creation_mode = CreationEditMode.FULL, int spacing = 6)
		{
			_creation_mode = creation_mode;
			this.mode.mode = mode;
			this.spacing = spacing;
			main_box.orientation = Gtk.Orientation.VERTICAL;
		}
	}
}
