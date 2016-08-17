using GData;
using GData.Generics;

namespace GDataGtk
{
	/**
	 * Property row for object inspector.
	 * 
	 * @since 0.1
	 */
	[GtkTemplate (ui="/org/gtk/g_data_binding_gtk/data/object_inspector_row.ui")]
	public class ObjectInspectorRow : Gtk.Box
	{
		private bool _normal_css = false;
		private bool _manual = false;
		private bool icon_pressed = false;
		private bool _unchecked = true;
		private StrictWeakReference<Object?>? _connected_object = null;
		private StrictWeakReference<ObjectInspector?>? _inspector = null;
		protected ParamSpec? _property = null;

		/**
		 * Object being inspected
		 * 
		 * @since 0.1
		 */
		public ObjectInspector? inspector {
			get { return (_inspector.target); }
		}

		[GtkChild] private Gtk.Label property_label;
		[GtkChild] private Gtk.Label value_label;
		[GtkChild] private Gtk.EventBox inspect_events;
		[GtkChild] private Gtk.Image inspect_image;
		[GtkChild] private Gtk.Box name_box;
		[GtkChild] private Gtk.Box value_box;
		[GtkChild] private Gtk.Box custom_widget_box;
		[GtkChild] private Gtk.Stack mode_stack;
		[GtkChild] private Gtk.Box editor_box;
		[GtkChild] private Gtk.Box end_box;

		private string _property_name = "";
		/**
		 * Specifies inspected property name
		 * 
		 * @since 0.1
		 */
		public string property_name {
			get { return (_property_name); }
			protected set { 
				_property_name = value;
				refresh_data();
				if (_property_name == "")
					property_label.label = "";
				else {
					string q = (_manual == true) ? "\"" : "";
					property_label.set_markup (fix_markup2("%s%s%s".printf(q, bold(small(italic(_property_name)), ((_manual == true) && (_normal_css == false))), q)));
				}
				property_label.tooltip_text = "";
			}
		}

		/**
		 * Returns contents of both label and value as string
		 * 
		 * @since 0.1
		 */
		public string text {
			owned get {
				if (visible == false)
					return ("");
				return ("%s %s".printf (property_name, value_label.label)); 
			}
		}

		/**
		 * This property is only valid if creation specified manual update
		 * 
		 * @since 0.1
		 */
		public string manual_value {
			get { return (value_label.label); }
			set {
				if (_manual == true)
					value_label.set_markup(fix_markup2(bold(value))); 
			}
		}

		private EditMode _edit_mode = EditMode.VIEW;
		/**
		 * Switches between modes for row
		 * 
		 * @since 0.1
		 */
		public EditMode edit_mode {
			get { return (_edit_mode); }
			set {
				if (_manual == true)
					return;
				if (_property == null)
					return;
				if (((_property.flags & GLib.ParamFlags.WRITABLE) != GLib.ParamFlags.WRITABLE) ||
				    ((_property.flags & GLib.ParamFlags.CONSTRUCT_ONLY) == GLib.ParamFlags.CONSTRUCT_ONLY))
					return;
				if ((value == EditMode.EDIT) && (container_child_count(editor_box) == 0))
					return;
				_edit_mode = value;
				if (_edit_mode == EditMode.VIEW)
					mode_stack.visible_child = value_box;
				else
					mode_stack.visible_child = editor_box;
			}
		}

		/**
		 * Returns true if row is filled manually
		 * 
		 * @since 0.1
		 */
		public bool manual {
			get { return ((_manual == true) && (_normal_css == false)); }
		}

		/**
		 * Returns widget that can be used for sizing the left side
		 * 
		 * @since 0.1
		 * 
		 * @return Widget that specifies left side
		 */
		public Gtk.Widget get_size_box_widget()
		{
			return (property_label);
		}

		private bool is_important()
		{
			return (false);
		}

		private void refresh_data()
		{
			visible = ((_inspector.is_valid_ref() == true) && (inspector.inspected_object != null));
			if (visible == false)
				return;
			if (_manual == true) {
				property_label.set_markup (fix_markup2("%s".printf(small(italic(bold(_property_name))))));
				return;
			}
			if (_property == null) {
				if (_unchecked == false)
					return;
				Type type = inspector.inspected_object.get_type();
				ObjectClass ocl = (ObjectClass) type.class_ref ();
				_property = ocl.find_property (_property_name);
				if ((_property.get_nick() != "") && (_property.get_nick() != _property_name))
					property_label.tooltip_text = _property.get_nick();

				_unchecked = false;
				if (_property == null)
					return;
			}
			inspect_image.visible = ((_property != null) && (_property.value_type.is_a(typeof(Object)) == true));
			if ((_property.flags & GLib.ParamFlags.READABLE) != GLib.ParamFlags.READABLE) {
				value_label.set_markup (fix_markup2(gray("** NOT READABLE **")));
				return;
			}
			Value val = Value (_property.value_type);
			inspector.inspected_object.get_property (_property_name, ref val);
			if (_property.value_type.is_a(typeof(Object)) == true)
				value_label.set_markup (fix_markup2(bold((val.get_object() == null) ? red("null") : _get_full_object_str_desc(val.get_object()))));
			else {
				if (_property.value_type == typeof(string))
					value_label.set_markup (fix_markup2(bold(val.get_string())));
				if (_property.value_type == typeof(bool))
					value_label.set_markup (bold(bool_strc(val.get_boolean())));
				else if (Value.type_transformable(_property.value_type, typeof(string)) == true) {
					Value sval = Value (typeof(string));
					val.transform (ref sval);
					value_label.set_markup (fix_markup2(bold((sval.get_string() == null) ? "" : sval.get_string())));
				}
				else
					value_label.set_markup (fix_markup2(gray("** Cannot transform to string **")));
			}
		}

		private void handle_unavailable()
		{
			refresh_data();
		}

		private void handle_object_change (ParamSpec parm)
		{
			if (_manual == false)
				if (_connected_object.is_valid_ref() == true)
					_connected_object.target.notify[property_name].disconnect (handle_value_change);
			_connected_object.set_new_target (inspector.inspected_object);
			_property = null;
			_unchecked = true;
			refresh_data();
			if (_manual == false)
				if (_connected_object.is_valid_ref() == true)
					_connected_object.target.notify[property_name].connect (handle_value_change);
		}

		public void disconnect_property()
		{
			if (_manual == false)
				if (_connected_object.is_valid_ref() == true)
					_connected_object.target.notify[property_name].disconnect (handle_value_change);
		}

		private void handle_value_change (ParamSpec parm)
		{
			refresh_data();
		}

		private int container_child_count(Gtk.Container container)
		{
			int cnt = 0;
			container.@foreach((w) => { cnt++; });
			return (cnt);
		}

		/**
		 * Packs custom widget in viewing mode
		 * 
		 * @since 0.1
		 * 
		 * @param widget Widget that needs to be packed
		 */
		public void pack_custom_widget (Gtk.Widget widget)
		{
			custom_widget_box.add (widget);
		}

		/**
		 * Packs custom widget in viewing mode
		 * 
		 * @since 0.1
		 * 
		 * @param widget Widget that needs to be packed
		 */
		public void pack_action_widget (Gtk.Widget widget)
		{
			get_action_container().add (widget);
		}

		/**
		 * Returns container that contains custom viewing widgets
		 * 
		 * @since 0.1
		 */
		public Gtk.Box get_custom_widget_container()
		{
			return (custom_widget_box);
		}

		/**
		 * Returns container that contains custom viewing widgets
		 * 
		 * @since 0.1
		 */
		public Gtk.Box get_action_container()
		{
			return (end_box);
		}

		/**
		 * Returns box containing name label
		 * 
		 * @since 0.1
		 */
		public Gtk.Box get_title_box()
		{
			return (name_box);
		}

		/**
		 * Returns box containing value label
		 * 
		 * @since 0.1
		 */
		public Gtk.Box get_value_box()
		{
			return (value_box);
		}

		/**
		 * Returns box containing value label
		 * 
		 * @since 0.1
		 */
		public Gtk.Label get_value_label()
		{
			return (value_label);
		}

		/**
		 * Packs custom widget in edit mode
		 * 
		 * @since 0.1
		 * 
		 * @param widget Widget that needs to be packed
		 */
		public void pack_custom_edit_widget (Gtk.Widget widget)
		{
			widget.margin_right = 4;
			editor_box.add(widget);//pack_start (widget, false, true);
		}

		/**
		 * Returns container that contains custom editing widgets
		 * 
		 * @since 0.1
		 */
		public Gtk.Box get_custom_edit_widget_container()
		{
			return (editor_box);
		}

		protected virtual void create_editor()
		{
			if ((inspector.inspected_object == null) || (_property == null))
				return;
			if (((_property.flags & GLib.ParamFlags.WRITABLE) != GLib.ParamFlags.WRITABLE) ||
			    ((_property.flags & GLib.ParamFlags.CONSTRUCT_ONLY) == GLib.ParamFlags.CONSTRUCT_ONLY))
				return;
			if (_property.value_type == typeof(string)) {
				Gtk.Entry entry = new Gtk.Entry();
				entry.visible = true;
				editor_box.pack_start (entry, true, true);
				_binder().bind (inspector.inspected_object, _property.name, entry, "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
			}
			else if (_property.value_type == typeof(bool)) {
				Gtk.Switch tswitch = new Gtk.Switch();
				tswitch.visible = true;
				editor_box.pack_start (tswitch, false, false);
				_binder().bind (inspector.inspected_object, _property.name, tswitch, "active", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
			}
			else if ((_property.value_type.is_enum() == true) || (_property.value_type.is_flags() == true)) {
//				GLib.Value val = GLib.Value(_property.value_type);
				EnumFlagsMenuButton ebtn = new EnumFlagsMenuButton(_property.value_type);
				ebtn.visible = true;
				editor_box.pack_start (ebtn, true, true);
				if (_property.value_type.is_enum() == true)
					_binder().bind (inspector.inspected_object, _property.name, ebtn, "int-value", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
				else
					_binder().bind (inspector.inspected_object, _property.name, ebtn, "uint-value", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
			}
		}

		private void set_preflight()
		{
			inspect_events.button_press_event.connect((e) => { icon_pressed = true; return (false); });
			inspect_events.button_release_event.connect((e) => { 
				if (icon_pressed == true) {
					Value val = Value (_property.value_type);
					inspector.inspected_object.get_property (_property_name, ref val);
					if (_property.value_type.is_a(typeof(Object)) == true)
						inspector.continue_with (val.get_object());
				}
				icon_pressed = false; 
				return (false); 
			});
			inspect_events.enter_notify_event.connect((e) => { inspect_image.opacity = 1.0f; return (false); });
			inspect_events.leave_notify_event.connect((e) => { inspect_image.opacity = 0.4f; return (false); });
			inspect_image.opacity = 0.4f;
			inspect_events.visible = ! _manual;
		}

		~ObjectInspectorRow()
		{
			if (_manual == false)
				if (_connected_object.is_valid_ref() == true)
					_connected_object.target.notify[property_name].disconnect (handle_value_change);
			if (_inspector.is_valid_ref() == true)
				inspector.notify["inspected-object"].disconnect (handle_object_change);
		}

		public signal void row_is_visible (ref bool vis);

		/**
		 * Creates new object inspector row
		 * 
		 * @since 0.1
		 */
		public ObjectInspectorRow (ObjectInspector? inspector = null, string property_name, bool manual = false, bool normal_css = false)
		{
			create_inspector_widget_registry();
			property_label.opacity = 0.6f;
			_manual = manual;
			_normal_css = normal_css;
				_inspector = new StrictWeakReference<ObjectInspector?>(inspector, handle_unavailable);
			_connected_object = new StrictWeakReference<Object?>(inspector.inspected_object, handle_unavailable);
			this.property_name = property_name;
			inspector.notify["inspected-object"].connect (handle_object_change);
			if (_manual == false)
				if (_connected_object.is_valid_ref() == true)
					_connected_object.target.notify[property_name].connect (handle_value_change);
			refresh_data();
			create_editor();
			set_preflight();
			if ((_manual == false) || (normal_css == true))
				assign_css (name_box, "* { background-color: rgba(255,255,255,0.1); }");
			if ((manual == true) && (normal_css == false))
				assign_css (value_box, "* { background-color: rgba(0,0,0,0.2); }");
			assign_css (this, """ * {
					border: none 1px darkgray;
					border-bottom-style: dotted;
				}"""
			);

			custom_widget_box.add.connect ((w) => {
				custom_widget_box.visible = (container_child_count(custom_widget_box) > 0);
			});
			custom_widget_box.remove.connect ((w) => {
				custom_widget_box.visible = (container_child_count(custom_widget_box) > 0);
			});
		}
	}
}

