using GData;
using GData.Generics;

namespace GDataGtk
{
	internal static DefaultWidgets? _widget_registry = null;

	internal static void create_inspector_widget_registry()
	{
		if (_widget_registry == null) {
			_widget_registry = DefaultWidgets.create_custom_instance();
			_widget_registry.fallback = DefaultWidgets.get_default();
		}
	}

	/**
	 * Property row for object inspector. This is not to be confused with
	 * Gtk.ListBoxRow, this widget only provides contents for that.
	 * 
	 * @since 0.1
	 */
	[GtkTemplate (ui="/org/gtk/g_data_binding_gtk/data/object_inspector.ui")]
	public class ObjectInspector : Gtk.Box
	{
		private StrictWeakReference<ObjectInspector?>? _synced_to = null;
		private ObjectArray<TrackElement> _tracked = new ObjectArray<TrackElement>();
		private ObjectArray<TrackLogElement> _log_array = new ObjectArray<TrackLogElement>();
		private ObjectArray<TrackLogElement> _current_log_array = null;
		private ReferenceMonitorGroup? _current_reference_group = null;
		private GLib.Array<Type> _cache = new GLib.Array<Type>();
		private bool icon_pressed = false;
		private ObjectArray<StrictWeakRef> _history = new ObjectArray<StrictWeakRef>();
		private ObjectArray<ObjectInspectorRow> _static_items = new ObjectArray<ObjectInspectorRow>();
		private ObjectArray<ObjectInspectorRow> _items = new ObjectArray<ObjectInspectorRow>();

		private Gtk.SizeGroup sizegroup;
		private Gtk.SizeGroup endsizegroup;

		private StrictWeakReference<Object?>? _inspected_object = null;
		/**
		 * Object being inspected
		 * 
		 * @since 0.1
		 */
		public Object? inspected_object {
			get { return (_inspected_object.target); }
			set {
				if (_inspected_object.target == value)
					return;
				for (int i=_tracked.length-1; i>=0; i--)
					_tracked.data[i].connected = false;
				_tracked.clear();
				_log_array.clear();
				_history.clear();
				_history.add (new StrictWeakRef(value));
				_pos = 0;
				revealer.reveal_child = false;
				_inspected_object.set_new_target (value);
				refresh_data();
				search_entry.text = "";
			}
		}

		private EditMode _edit_mode = EditMode.VIEW;
		public EditMode edit_mode {
			get { return (_edit_mode); }
			set {
				if (_edit_mode == value)
					return;
				_edit_mode = value;
				handle_search_changed();
				for (int i=0; i<_items.length; i++)
					_items.data[i].edit_mode = _edit_mode;
			}
		}

		/**
		 * Returns true when inspector is in slave mode
		 * 
		 * @since 0.1
		 */
		public bool in_slave_mode {
			get { return (_synced_to.is_valid_ref()); }
		}

		private int _pos = 0;
		/**
		 * Position in history
		 * 
		 * @since 0.1
		 */
		private int pos {
			get { return (_pos); }
			set {
				_pos = value;
				_inspected_object.set_new_target (_history.data[_pos].target);
				if (_pos > 0)
					previous_label.set_markup(_get_object_str(_history.data[_pos-1].target));
				else
					previous_label.set_markup("");
				refresh_data();
				notify_property ("inspected-object");
			}
		}

		/**
		 * True if history view is currently active view in stack
		 * 
		 * @since 0.1
		 */
		protected bool history_view {
			get { return (items_history_stack.visible_child == history_stack_box); }
			set {
				if (value == true)
					items_history_stack.visible_child = history_stack_box;
				else
					items_history_stack.visible_child = items_stack_box;
			}
		}

		/**
		 * Display option flags
		 * 
		 * @since 0.1
		 */
		public ObjectInspectorView display_options { get; set; default=ObjectInspectorView.ALL; }
		private BooleanFlag display_properties;
		private BooleanFlag display_signals;

		/**
		 * Reference monitor flags
		 * 
		 * @since 0.1
		 */
		public ReferenceMonitorShowView reference_monitor_options { get; set; default=ReferenceMonitorShowView.NAME | ReferenceMonitorShowView.REFERENCE; }
		private BooleanFlag reference_show_name;
		private BooleanFlag reference_show_description;
		private BooleanFlag reference_show_reference;

		[GtkChild] private Gtk.ListBox object_inspector_list_box;
		[GtkChild] private Gtk.ListBox static_info_object_inspector_list_box;
		[GtkChild] private Gtk.ScrolledWindow scrollbox;
		[GtkChild] private Gtk.Viewport viewport;
		[GtkChild] private Gtk.Revealer revealer;
		[GtkChild] private Gtk.EventBox back_event;
		[GtkChild] private Gtk.EventBox forward_event;
		[GtkChild] private Gtk.Label previous_label;
		[GtkChild] private Gtk.SearchEntry search_entry;
		[GtkChild] private Gtk.SearchBar search_bar;
		[GtkChild] private Gtk.Revealer search_revealer;
		[GtkChild] private Gtk.Stack items_history_stack;
		[GtkChild] private Gtk.Box items_stack_box;
		[GtkChild] private Gtk.Box history_stack_box;
		[GtkChild] private Gtk.ListBox reference_monitor_listbox;
		[GtkChild] private Gtk.ListBox object_inspector_event_history;
		[GtkChild] private Gtk.MenuButton reference_show_btn;

		private ObjectInspectorRow type_row;
		private ObjectInspectorRow description_row;
		private ObjectInspectorRow ref_row;
		private EnumFlagsPopover show_items;

		/**
		 * Current search filter
		 * 
		 * @since 0.1
		 */
		public string current_filter {
			get { return (search_entry.text); }
			set { search_entry.text = value; }
		}

		private void set_label_markup (Gtk.Label label, string text, bool add_arrow = true)
		{
			string arr = (add_arrow == true) ? " ▼" : "";
			label.set_markup (small(bold(italic(INFORMATION_COLOR(underline("%s%s".printf(text, arr)))))));
		}

		private PreflightEventBox create_event_label (string text, bool add_arrow = true, string pass_value = "", StringValueDelegate? method = null)
		{
			PreflightEventBox ev = new PreflightEventBox();
			Gtk.Label lbl = new Gtk.Label("");
			lbl.use_markup = true;
			set_label_markup (lbl, text, add_arrow);
			ev.add (lbl);
			ev.set_data<StrictWeakReference<Gtk.Label?>> ("label", new StrictWeakReference<Gtk.Label?>(lbl));
			ev.visible = true;
			lbl.visible = true;
			if (method != null) {
				ev.clicked.connect (() => {
					method (pass_value);
				});
			}
			return (ev);
		}

		private PreflightEventBox create_event_image (StateImage image, bool initial_value = true, bool change_states = true, BoolValueDelegate? method = null)
		{
			PreflightEventBox ev = new PreflightEventBox();
			image.visible = true;
			image.state = initial_value;
			ev.add (image);
			ev.set_data<StrictWeakReference<StateImage?>> ("image", new StrictWeakReference<StateImage?>(image));
			ev.visible = true;
			ev.clicked.connect (() => { 
				if (change_states == true)
					image.state = ! image.state;
				method (image.state);
			});
			return (ev);
		}

		private PreflightEventBox create_event_image_with_object (StateImage image, Object? pass_value, bool initial_value = true, 
		                                                          bool change_states = true, ObjectValueDelegate? method = null, Object? bind_to = null,
		                                                          string? bind_property = null, BindFlags extra_flags = 0)
		{
			PreflightEventBox ev = new PreflightEventBox();
			image.visible = true;
			image.state = initial_value;
			if ((bind_to != null) && (bind_property != null))
				_binder().bind (image, "state", bind_to, bind_property, BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL|extra_flags);
			ev.add (image);
			ev.set_data<StrictWeakReference<StateImage?>> ("image", new StrictWeakReference<StateImage?>(image));
			ev.visible = true;
			ev.clicked.connect (() => { 
				if (change_states == true)
					image.state = ! image.state;
				method (pass_value);
			});
			return (ev);
		}

		private void add_signals (Type type)
		{
			for (int i=0; i<_cache.length; i++)
				if (_cache.data[i] == type)
					return;
			bool added = false;
			_cache.append_val (type);
			uint[] ids = Signal.list_ids (type);
			foreach (uint id in ids) {
				if (added == false) {
					ObjectInspectorRow tr = new ObjectInspectorRow(this, type.name(), true, true);
					tr.manual_value = small(italic("  " + type.name()));
					tr.get_title_box().visible = false;
					_items.add (tr);
					added = true;
				}
				ObjectInspectorRow sr = new ObjectInspectorRow(this, Signal.name (id), true, true);
				TrackElement t = new TrackElement (_add_log_event, inspected_object, __SIGNAL__, Signal.name (id));

				sr.pack_action_widget (create_event_image_with_object (new StateImage.tracking(), t, true, true, (obj) => {
					// GLib.Message ("signal triggered");
				}, t, "connected", BindFlags.INVERT_BOOLEAN));

				sr.row_is_visible.connect ((ref vis) => {
					vis = display_signals.state;
				});
				_binder().bind (this, "in-slave-mode", sr.get_action_container(), "visible", BindFlags.SYNC_CREATE|BindFlags.INVERT_BOOLEAN);
				sr.manual_value = "";
				_items.add (sr);
				_tracked.add (t);
			}
			Type[] ints = type.interfaces();
			for (int i=0; i<ints.length; i++)
				if (ints[i] != Type.INVALID)
					add_signals (ints[i]);
			if (type.parent() != Type.INVALID)
				add_signals(type.parent());
		}

		private void refresh_data()
		{
			while (_cache.length > 0)
				_cache.remove_index(_cache.length-1);
			type_row = null;
			description_row = null;
			ref_row = null;
			for (int i=0; i<_items.length; i++)
				_items.data[i].disconnect_property();
			_static_items.clear();
			_items.clear();
			type_row = new ObjectInspectorRow(this, "Type", true);
//			type_row.get_action_container().visible = true;
			type_row.manual_value = get_object_type(inspected_object);
			PreflightEventBox ev = create_event_label ("show");
			type_row.pack_action_widget (ev);
			ev.clicked.connect (() => {
				show_items.relative_to = ev;
				show_items.show();
			});
			type_row.pack_action_widget (create_event_image (new StateImage.add_remove(), true, false, (val) => {
				ObjectInspector.add_object (inspected_object);
			}));
			type_row.pack_action_widget (create_event_image (new StateImage.search_and_replace(), false, false, (val) => {
				if (search_bar.search_mode_enabled == false) {
					search_revealer.reveal_child = false;
					search_bar.search_mode_enabled = true;
				}
				search_revealer.reveal_child = !search_revealer.reveal_child;
			}));
			type_row.pack_action_widget (create_event_image (new StateImage.items_events(), history_view, true, (val) => {
				history_view = !history_view;
			}));
			type_row.pack_action_widget (create_event_image (new StateImage.edit_mode(), (edit_mode == EditMode.EDIT), true, (val) => {
				edit_mode = (val == true) ? EditMode.EDIT : EditMode.VIEW;
			}));
			_static_items.add (type_row);

			description_row = new ObjectInspectorRow(this, "Description", true);
//			description_row.get_action_container().visible = true;
			_static_items.add (description_row);

			ref_row = new ObjectInspectorRow(this, "Ref count", true);
//			ref_row.get_action_container().visible = false;
			PreflightEventBox ev3 = create_event_label ("ref()", false);
			ref_row.pack_action_widget (ev3);
			ev3.clicked.connect (() => {
				if (inspected_object != null)
					inspected_object.ref();
			});
			PreflightEventBox ev4 = create_event_label ("unref()", false);
			ref_row.pack_action_widget (ev4);
			ev4.clicked.connect (() => {
				if (inspected_object != null)
					inspected_object.unref();
			});
			PreflightEventBox ev2 = create_event_label ("add notification");
			ref_row.pack_action_widget (ev2);
			ev2.clicked.connect (() => {
				SimpleEntryBox.show_popover (ev2, "Add notification", "Use %s to specify where you want object name, %t for type",
					(text) => {
						ReferenceMonitorGroup.get_default().monitor_object (text.replace("%s",get_description_str(inspected_object, false)).replace("%t", inspected_object.get_type().name()), inspected_object);
					});
			});
			_static_items.add (ref_row);
			ref_timer();

			if (_inspected_object.is_valid_ref() == false)
				return;

			// add properties title
			ObjectInspectorRow props_title = new ObjectInspectorRow(this, "", true);
			props_title.get_title_box().visible = false;
			props_title.get_value_label().visible = false;
			Gtk.Expander expander = new Gtk.Expander ("<b>Properties</b>");
			expander.margin_left = 6;
			expander.hexpand = true;
			expander.use_markup = true;
			expander.visible = true;
			_binder().bind (display_properties, "state", expander, "expanded", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
			props_title.pack_custom_widget (expander);
			props_title.pack_action_widget (create_event_label ("track all", false, "", ((s) => {
				for (int i=0; i<_tracked.length; i++)
					if (_tracked.data[i].element_type == __PROPERTY__)
						_tracked.data[i].connected = true;
			})));
			props_title.pack_action_widget (create_event_label ("stop tracking", false, "", ((s) => {
				for (int i=0; i<_tracked.length; i++)
					if (_tracked.data[i].element_type == __PROPERTY__)
						_tracked.data[i].connected = false;
			})));
			_binder().bind (this, "in-slave-mode", props_title.get_action_container(), "visible", BindFlags.SYNC_CREATE|BindFlags.INVERT_BOOLEAN);
			_items.add (props_title);

			Type type = inspected_object.get_type();
			ObjectClass ocl = (ObjectClass) type.class_ref ();
			foreach (ParamSpec spec in ocl.list_properties ()) {
				ObjectInspectorRow ir = new ObjectInspectorRow(this, spec.get_name());
				ir.row_is_visible.connect ((ref vis) => {
					vis = display_properties.state;
				});
				if (((spec.flags & GLib.ParamFlags.WRITABLE) == GLib.ParamFlags.WRITABLE) &&
				    ((spec.flags & GLib.ParamFlags.CONSTRUCT_ONLY) != GLib.ParamFlags.CONSTRUCT_ONLY)) {
					TrackElement t = new TrackElement (_add_log_event, inspected_object, __PROPERTY__, spec.name);

					ir.pack_action_widget (create_event_image_with_object (new StateImage.tracking(), t, true, true, (obj) => {
						// GLib.Message ("property changed");
					}, t, "connected", BindFlags.INVERT_BOOLEAN));

					_tracked.add (t);
				}
				_binder().bind (this, "in-slave-mode", ir.get_action_container(), "visible", BindFlags.SYNC_CREATE|BindFlags.INVERT_BOOLEAN);
				ir.edit_mode = edit_mode;
				endsizegroup.add_widget (ir.get_action_container());
				_items.add (ir);
			}

			// add properties title
			ObjectInspectorRow signal_title = new ObjectInspectorRow(this, "", true);
			signal_title.get_title_box().visible = false;
			signal_title.get_value_label().visible = false;
			expander = new Gtk.Expander ("<b>Signals</b>");
			expander.margin_left = 6;
			expander.hexpand = true;
			expander.use_markup = true;
			expander.visible = true;
			_binder().bind (display_signals, "state", expander, "expanded", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
			expander.use_markup = true;
			expander.visible = true;
			signal_title.pack_custom_widget (expander);
			signal_title.pack_action_widget (create_event_label ("track all", false, "", ((s) => {
				for (int i=0; i<_tracked.length; i++)
					if (_tracked.data[i].element_type == __SIGNAL__)
						_tracked.data[i].connected = true;
			})));
			signal_title.pack_action_widget (create_event_label ("stop tracking", false, "", ((s) => {
				for (int i=0; i<_tracked.length; i++)
					if (_tracked.data[i].element_type == __SIGNAL__)
						_tracked.data[i].connected = false;
			})));
			_binder().bind (this, "in-slave-mode", signal_title.get_action_container(), "visible", BindFlags.SYNC_CREATE|BindFlags.INVERT_BOOLEAN);
			_items.add (signal_title);
			add_signals (inspected_object.get_type());
		}

		private bool can_go_back()
		{
			return (pos>0);
		}

		private bool can_go_forward()
		{
			return (pos<(_history.length-1));
		}

		private void set_preflight()
		{
			back_event.button_press_event.connect((e) => { icon_pressed = true; return (false); });
			back_event.button_release_event.connect((e) => {
				if (can_go_back() == false)
					return (false); 
				if (icon_pressed == true)
					pos--;
				icon_pressed = false; 
				return (false); 
			});
			back_event.enter_notify_event.connect((e) => { if (can_go_back() == true) back_event.opacity = 1.0f; return (false); });
			back_event.leave_notify_event.connect((e) => { back_event.opacity = 0.4f; return (false); });
			back_event.opacity = 0.4f;
			forward_event.button_press_event.connect((e) => { icon_pressed = true; return (false); });
			forward_event.button_release_event.connect((e) => { 
				if (can_go_forward() == false)
					return (false); 
				if (icon_pressed == true)
					pos++;
				icon_pressed = false; 
				return (false); 
			});
			forward_event.enter_notify_event.connect((e) => { if (can_go_forward() == true) forward_event.opacity = 1.0f; return (false); });
			forward_event.leave_notify_event.connect((e) => { forward_event.opacity = 0.4f; return (false); });
			forward_event.opacity = 0.4f;
		}

		public void continue_with (Object? object)
		{
			while (pos<(_history.length-1))
				_history.remove_at_index (_history.length-1);
			revealer.reveal_child = true;
			_inspected_object.set_new_target(object);
			_history.add (new StrictWeakRef(object));
			pos++;
		}

		private void handle_invalid()
		{
			refresh_data();
		}

		public void handle_search_changed()
		{
			do_filter_items();
			notify_property("current-filter");
		}

		private void do_filter_items()
		{
			object_inspector_list_box.@foreach ((w) => {
				if (w == null)
					return;
				if (w.get_type().is_a(typeof(SmoothListBoxRow)) == true)
					((SmoothListBoxRow) w).revealed = filter_items ((SmoothListBoxRow) w);
			});
		}

		private bool filter_items (SmoothListBoxRow row)
		{
			bool vis = true;
			((ObjectInspectorListBoxRow) row).row.row_is_visible(ref vis);
			bool res = ((vis == true) &&
			            ((current_filter == "") ||
			             (((ObjectInspectorListBoxRow) row).manual == true) ||
			             (((ObjectInspectorListBoxRow) row).text.contains (current_filter) == true)));
			return (res);
		}

		public static void add_object (Object? obj)
		{
			__add_to_object_inspector (obj);
		}

		public static void add_objects (Object?[] obj)
		{
			for (int i=0; i<obj.length; i++)
				__add_to_object_inspector (obj[i]);
		}

		public static void remove_object (Object? obj)
		{
			__remove_from_object_inspector (obj);
		}

		public static void remove_objects (Object?[] obj)
		{
			for (int i=0; i<obj.length; i++)
				__remove_from_object_inspector (obj[i]);
		}

		public static void clean()
		{
			__clean_object_inspector();
		}

		public bool ref_timer()
		{
			if (description_row != null)
				description_row.manual_value = get_description_str(inspected_object);
			if (ref_row != null)
				ref_row.manual_value = bold("%i".printf((inspected_object != null) ? (int) inspected_object.ref_count : 0));
			if (_current_reference_group != null)
				_current_reference_group.update_all();
			return (GLib.Source.CONTINUE); // exit is handled by RefTimeout
		}

		private void _add_log_event (string event_type, string event_name)
		{
			if (_log_array.length > 0) {
				TrackLogElement t = _log_array.data[_log_array.length-1];
				if ((t.element_type == event_type) && (t.name == event_name)) {
					t.another();
					return;
				}
			}
			_log_array.add (new TrackLogElement(event_type, event_name));
			while (_log_array.length > 200) 
				_log_array.remove_at_index(0);
		}

		private void set_slave_target (ParamSpec pspec)
		{
			if (_synced_to.is_valid_ref() == true)
				inspected_object = _synced_to.target.inspected_object;
		}

		/**
		 * Syncs object inspector view with another
		 * 
		 * @since 0.1
		 * 
		 * @param inspector Objects inspector that should perform as master
		 */
		public void sync_to (ObjectInspector? inspector)
		{
			if ((inspector == null) || (_synced_to.is_valid_ref() == true))
				return;

			_synced_to.set_new_target (inspector);
			inspector.notify["inspected-object"].connect (set_slave_target);
			inspected_object = inspector.inspected_object;
			_current_log_array = inspector._log_array;
			bind_events();
			notify_property ("in-slave-mode");
		}

		/**
		 * Unsyncs current slave mode
		 * 
		 * @since 0.1
		 */
		public void unsync()
		{
			if (_synced_to.is_valid_ref() == false)
				return;
			_synced_to.target.notify["inspected-object"].disconnect (set_slave_target);
			_synced_to.set_new_target (null);
			notify_property ("in-slave-mode");
			handle_invalid_sync();
		}

		private void handle_invalid_sync()
		{
			_current_log_array = _log_array;
			bind_events();
		}

		private void bind_events()
		{
			object_inspector_event_history.bind_model (new InvertedListModel(_current_log_array), (o) => {
				TrackLogElement t = (TrackLogElement) o;
				SmoothListBoxRow row = new SmoothListBoxRow.with_delete (o, 4);
				row.get_container().pack_start (new ObjectEventsRow(t), true, true);
				return (row);
			});
		}

		~ObjectInspector()
		{
			inspected_object = null;
		}

		/**
		 * Creates new object inspector row
		 * 
		 * @since 0.1
		 */
		public ObjectInspector (Object? inspected_object = null)
		{
			_synced_to = new StrictWeakReference<ObjectInspector?>(null, handle_invalid_sync);
			_current_log_array = _log_array;
			ReferenceMonitor.__get_object_description = _get_full_object_str_desc;
			display_properties = new BooleanFlag (this, "display-options", ObjectInspectorView.PROPERTIES, true);
			display_signals = new BooleanFlag (this, "display-options", ObjectInspectorView.SIGNALS, true);
			reference_show_name = new BooleanFlag (this, "reference-monitor-options", ReferenceMonitorShowView.NAME, true);
			reference_show_description = new BooleanFlag (this, "reference-monitor-options", ReferenceMonitorShowView.NOTIFICATION, true);
			reference_show_reference = new BooleanFlag (this, "reference-monitor-options", ReferenceMonitorShowView.REFERENCE, true);
			notify["display-options"].connect (() => { handle_search_changed(); });

			create_inspector_widget_registry();
			search_revealer.reveal_child = false;
			_inspected_object = new StrictWeakReference<Object?>(inspected_object, handle_invalid);
			sizegroup = new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL);
			endsizegroup = new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL);
			show_items = new EnumFlagsPopover (null, typeof(ObjectInspectorView), ObjectInspectorView.ALL);
			_binder().bind (this, "display-options", show_items, "uint-value", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
			static_info_object_inspector_list_box.bind_model (_static_items, (o) => {
				ObjectInspectorListBoxRow r = new ObjectInspectorListBoxRow((ObjectInspectorRow) o);
				((ObjectInspectorRow) o).visible = true;
				sizegroup.add_widget (((ObjectInspectorRow) o).get_size_box_widget());
				return (r);
			});
			object_inspector_list_box.bind_model (_items, (o) => {
				ObjectInspectorListBoxRow r = new ObjectInspectorListBoxRow((ObjectInspectorRow) o);
				((ObjectInspectorRow) o).visible = true;
				sizegroup.add_widget (((ObjectInspectorRow) o).get_size_box_widget());
				return (r);
			});
			object_inspector_list_box.set_placeholder (
				new Placeholder.from_icon ("Nothing to inspect", Gtk.IconSize.DND, STOP_ICON));
			refresh_data();
			revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_UP);
			revealer.reveal_child = false;
			set_preflight();
			search_entry.search_changed.connect (handle_search_changed);

			_current_reference_group = ReferenceMonitorGroup.get_default();
			reference_monitor_listbox.bind_model (ReferenceMonitorGroup.get_default(), (o) => {
				SmoothListBoxRow row = new SmoothListBoxRow.with_delete (o, 4);
				ReferenceMonitorRow rrow = new ReferenceMonitorRow ((ReferenceMonitor) o);
				_binder().bind (reference_show_name, "state", rrow, "show-name", BindFlags.SYNC_CREATE);
				_binder().bind (reference_show_description, "state", rrow, "show-notification", BindFlags.SYNC_CREATE);
				_binder().bind (reference_show_reference, "state", rrow, "show-reference", BindFlags.SYNC_CREATE);
				row.get_container().pack_start (rrow, true, true);
				row.action_taken.connect ((action, obj) => {
					if (action == ACTION_DELETE)
						_current_reference_group.remove_monitor ((ReferenceMonitor) obj);
				});
				return (row);
			});
			reference_show_btn.popover = new EnumFlagsPopover (reference_show_btn, typeof(ReferenceMonitorShowView), reference_monitor_options);
			_binder().bind (this, "reference-monitor-options", reference_show_btn.popover, "uint-value", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);

			bind_events();

			RefTimeout.add (new WeakRefWrapper(this), 1000, ref_timer, GLib.Priority.DEFAULT);
		}
	}
}

