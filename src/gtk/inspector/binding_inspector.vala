using GData;
using GData.Generics;

namespace GDataGtk
{
	/**
	 * Data binding inspector window provides runtime information like 
	 * gtk-inspector does
	 * 
	 * @since 0.1
	 */
	public class BindingInspector : Object
	{
		private static StrictWeakRef? self_ref = null;
		private StrictWeakRef wdata_ref = new StrictWeakRef(null);
		private int ptr_ref = -1;
		private int data_ref = -1;
		private int src_ref = -1;

		internal int pointer_ref { get; set; default=-1; }
		internal int pointer_data_ref { get; set; default=-1; }
		internal int pointer_source_ref { get; set; default=-1; }

		private EventArray _events = new EventArray(null);

		private Gtk.Button source_info_btn;
		private Gtk.Button clear_btn;
//		private Gtk.ToggleButton compact_events_btn;
		private Gtk.MenuButton find_btn;
		private Gtk.Label main_title;
		private Gtk.Label sub_title;
		private Gtk.MenuButton filter_events_btn;
		private Gtk.EventBox add_pointer_reference;
		private Gtk.EventBox add_pointer_to_inspector;
		private Gtk.EventBox add_data_reference;
		private Gtk.EventBox add_data_to_inspector;
		private Gtk.EventBox add_source_reference;
		private Gtk.EventBox add_source_to_inspector;

		private Gtk.Label ref_count_;
		private Gtk.Label uid;
		private Gtk.Label stored_as;
		private Gtk.Label type;
		private Gtk.Label data_ref_count;
		private Gtk.Label data;
		private Gtk.Label data_type;
		private Gtk.Label source_ref_count;
		private Gtk.Label source_data;
		private Gtk.Label source_type;
		private Gtk.Label ref_handling;
		private Gtk.Label update_type;
		private Gtk.Label binding_nr;
		private Gtk.Label suspended;
		private Gtk.Label is_valid;
		private Gtk.SearchEntry binding_namespace_search;

		private Gtk.Popover binding_namespace_view_popover;
		private Gtk.Popover event_filter_popover;

		private ObjectInspector binding_inspector;
		private ObjectInspector value_objects_inspector;
		private ObjectInspector state_objects_inspector;
		private ObjectInspector binding_namespace_inspector;

		private static bool inspector_is_visible { get; private set; default = false; }
		protected string binding_search_text { get; set; default=""; }

		protected BindingNamespaceViewMode binding_namespace_view { get; set; default=BindingNamespaceViewMode.ALL; }
		private BooleanGroup binding_namespace_view_flags;

		protected EventFilterMode event_filter { get; set; default=EventFilterMode.ALL; }
		private BooleanGroup event_filter_flags;

//		public bool compact_events { get; set; default = false; }

		private static BindingInspector? _instance = null;
		public static BindingInspector instance {
			get {
				if (_instance == null)
					_instance = new BindingInspector();
				return (_instance);
			}
		}

		private Gtk.Window? _window = null;
		private Gtk.Window window {
			get { return (_window); }
		}

		private BindingContract _main_contract = new BindingContract (null);
		public BindingContract main_contract {
			get { return (_main_contract); }
		}

		public BindingPointer? current_data {
			get { return ((BindingPointer?) _main_contract.data); }
			set {
				if (main_contract.data == value)
					return;
				_main_contract.data = value;
				_events.resource = value;
				wdata_ref.set_new_target (value);
			}
		}

		private AliasArray aliases;
		private PointerArray pointers;
		private ContractArray storages;

		public static void show (BindingPointer? inspect = null)
		{
			instance.window.present();
			if (instance.current_data != inspect)
				instance.current_data = inspect;
		}

		public static void set_target (BindingPointer? inspect = null)
		{
			if (inspector_is_visible == false)
				show (inspect);
			else
				instance.current_data = inspect;
		}

		private void _bind_event_listbox (Gtk.ListBox listbox, ObjectArray<EventDescription> events)
		{
			listbox.bind_model (events, ((o) => {
				ContractEventDescription obj = (ContractEventDescription) o;
				SmoothListBoxRow row = new SmoothListBoxRow(o);
				TitleDescriptionRow rrow = new TitleDescriptionRow.with_text(obj.title, obj.description);
				_binder().bind (event_filter_flags.get_state(EventFilterMode.SHOW_FULL_DESCRIPTION), "state", rrow, "show-description", BindFlags.SYNC_CREATE);
				row.get_container().add (rrow);
				_binder().bind (this, "event-filter", obj, "current-filter", BindFlags.SYNC_CREATE);
				_binder().bind (obj, "is-visible", row, "revealed", BindFlags.SYNC_CREATE);
				return (row);
			}));
		}

	internal void _bind_bindings_namespace_listbox (Gtk.ListBox listbox)
	{
		BindingNamespace.get_instance().clean_null();
		listbox.bind_model (BindingNamespace.get_instance(), ((o) => {
			SmoothListBoxRow row = new SmoothListBoxRow(o);
			WeakRefWrapper? wr = ((WeakRefWrapper?) o);
			row.visible = ((wr != null) && (wr.target != null));
			if (wr.target != null) {
				BindingInterface? obj = ((BindingInterface?) wr.target);
				row.set_data<WeakReference<BindingInterface?>> ("binding", new WeakReference<BindingInterface?>(obj));
				TitleDescriptionRow rrow = new TitleDescriptionRow.with_text(obj.as_str(true), obj.sources_as_str(true, _get_full_object_str_desc));
				_binder().bind (binding_namespace_view_flags.get_state(BindingNamespaceViewMode.SOURCES), "state", rrow, "show-description", BindFlags.SYNC_CREATE);
				_binder().bind (this, "binding-search-text", row, "revealed", BindFlags.SYNC_CREATE, 
					(b, s, ref t) => {
						string str = s.get_string();
						t.set_boolean ((binding_search_text == "") || (rrow.get_text().contains(binding_search_text) == true));
						return (true);
					});
				row.get_container().add (rrow);
			}
			return (row);
		}));
		BindingNamespace.get_instance().clean_null();
	}

		private void bind_aliases (Gtk.Builder ui_builder)
		{
			aliases = track_property_aliases();
			bind_kv_listbox<string, Type, string>((Gtk.ListBox) ui_builder.get_object ("aliases"), aliases, ((kv) => {
				return (((KeyValuePair<string, KeyValueArray<Type, string>>) kv).key.replace("&", "&amp;"));
			}), true);
			on_master_selected<string, Type, string> (
				(Gtk.ListBox) ui_builder.get_object ("aliases"), 
				(Gtk.ListBox) ui_builder.get_object ("alias_types"), 
				((kv) => {
					KeyValuePair<Type, string> sel = (KeyValuePair<Type, string>) kv;
					return ("Type: %s → \"%s\"".printf(TYPE_COLOR(sel.key.name()), bold(sel.val)).replace("&", "&amp;"));
				})
			);
		}

		private void bind_pointers (Gtk.Builder ui_builder)
		{
			pointers = track_pointer_storage();
			bind_kv_listbox<string, string, WeakReference<BindingPointer>>((Gtk.ListBox) ui_builder.get_object ("pointer_storages"), pointers, ((kv) => {
				return (((KeyValuePair<string, KeyValueArray<string, WeakReference<BindingPointer>>>) kv).key.replace("&", "&amp;"));
			}), true);
			on_master_selected<string, string, WeakReference<BindingPointer>> (
				(Gtk.ListBox) ui_builder.get_object ("pointer_storages"), 
				(Gtk.ListBox) ui_builder.get_object ("pointers"), 
				((kv) => {
					KeyValuePair<string, WeakReference<BindingPointer>> sel = (KeyValuePair<string, WeakReference<BindingPointer>>) kv;
					return ("Pointer: [%s]".printf(bold(sel.key)).replace("&", "&amp;"));
				})
			);
			((Gtk.ListBox) ui_builder.get_object ("pointers")).row_activated.connect ((r) => {
				if (r == null)
					return;
				int? i = r.get_data<int>("pointer");
				if (i != null)
					current_data = PointerNamespace.get_instance().get_by_id(i);
				find_btn.popover.hide();
			});
		}

		private void bind_storages (Gtk.Builder ui_builder)
		{
			storages = track_contract_storage();
			bind_kv_listbox<string, string, WeakReference<BindingContract>>((Gtk.ListBox) ui_builder.get_object ("contract_storages"), storages, 
				((kv) => {
					return (((KeyValuePair<string, KeyValueArray<string, WeakReference<BindingContract>>>) kv)
						.key.replace("&", "&amp;"));
				}), true);
			on_master_selected<string, string, WeakReference<BindingContract>> (
				(Gtk.ListBox) ui_builder.get_object ("contract_storages"), 
				(Gtk.ListBox) ui_builder.get_object ("contracts"), 
				((kv) => {
					KeyValuePair<string, WeakReference<BindingContract>> sel = (KeyValuePair<string, WeakReference<BindingContract>>) kv;
					return ("Contract: [%s]".printf(bold(sel.key)).replace("&", "&amp;"));
				})
			);
			((Gtk.ListBox) ui_builder.get_object ("contracts")).row_activated.connect ((r) => {
				if (r == null)
					return;
				int? i = r.get_data<int>("pointer");
				if (i != null)
					current_data = PointerNamespace.get_instance().get_by_id(i);
				find_btn.popover.hide();
			});
		}

		private void disconnect_everything()
		{
			if (self_ref.is_valid_ref() == false)
				return;
			main_contract.unbind_all();
			main_contract.data = null;
			_events.clear();
			_main_contract = null;
			_window.destroy();
			_window = null;
			inspector_is_visible = false;
			_instance = null;
			self_ref.set_new_target (null);
		}

		private string _box_css = """
			* {
				border: solid 2px gray;
				padding: 4px 4px 4px 4px;
				border-radius: 15px;
				color: rgba (255,255,255,0.8);
				background-color: rgba(25,25,25,1);
			}
		""";

		private string _title_css = """
			* {
				border: solid 2px gray;
				padding: 4px 4px 4px 4px;
				border-radius: 5px;
				color: rgba (255,255,255,0.7);
				background-color: rgba(0,0,0,0.2);
			}
		""";

		private string _chain_css = """
			* {
				padding: 4px 4px 4px 4px;
				border-radius: 5px;
				color: rgba (255,255,255,0.7);
				background-color: rgba(0,0,0,0.0);
			}
		""";

		private string _info_css = """
			* {
				color: rgba (255,255,255,0.5);
			}
		""";

		private bool ref_timer()
		{
			if (inspector_is_visible == true) {
/*				weak Object? __current_data = current_data;
				weak Object? __current_data_data = (__current_data != null) ? current_data.data : null;
				weak Object? __current_data_source = (__current_data != null) ? current_data.get_source() : null;
				ptr_ref = (__current_data == null) ? -1 : (int) __current_data.ref_count;
				data_ref = (__current_data_data == null) ? -1 : (int) __current_data_data.ref_count;
				src_ref = (__current_data_source == null) ? -1 : (int) __current_data_source.ref_count;
				ref_count_.set_markup ((ptr_ref == -1) ? bold(red("null")) : bold("%i").printf(ptr_ref));
				data_ref_count.set_markup ((data_ref == -1) ? bold(red("null")) : bold("%i").printf(data_ref));
				source_ref_count.set_markup ((src_ref == -1) ? bold(red("null")) : bold("%i").printf(src_ref));*/
				string p, d, s;
				_get_reference_markup (wdata_ref, out p, out d, out s);
				ref_count_.set_markup (p);
				data_ref_count.set_markup (d);
				source_ref_count.set_markup (s);
			}
			return (inspector_is_visible);
		}

		private bool update_source_data()
		{
			main_title.set_markup (bold("Resource type=%s".printf (get_object_type(main_contract.data))));
			sub_title.set_markup (small("Chain source=%s".printf (get_object_type(main_contract.get_source()))));
			uid.set_markup ((current_data == null) ? __null(true) : bold("@%i").printf(current_data.id));
			stored_as.set_markup (_get_stored_as (current_data));
			type.set_markup (get_object_type(current_data, true));
			data_type.set_markup (bold((current_data == null) ? __null(true) : get_object_type(current_data.data)));
			data.set_markup (bold((current_data == null) ? __null(true) : _get_object_str(current_data.data)));
			source_data.set_markup (bold((current_data == null) ? __null(true) : _get_object_str(current_data.get_source())));
			source_type.set_markup (bold((current_data == null) ? __null(true) : get_object_type(current_data.get_source())));
			ref_handling.set_markup (bold((current_data == null) ? __null(true) : current_data.reference_type.get_str()));
			update_type.set_markup (bold((current_data == null) ? __null(true) : current_data.update_type.get_str()));
			if (is_binding_contract(current_data) == true) {
				binding_nr.set_markup (bold("%i".printf((int) as_contract(current_data).length)));
				// bind actively
				suspended.set_markup (bool_activity(!as_contract(current_data).suspended));
				is_valid.set_markup (bool_strc(as_contract(current_data).is_valid));
			}
			else {
				binding_nr.set_markup (bold("*** NOT AVAILABLE ***"));
				// bind actively
				suspended.set_markup (bold("*** NOT AVAILABLE ***"));
				is_valid.set_markup (bold("*** NOT AVAILABLE ***"));
			}
			return (false);
		}

		private void assign_preflight_events (Gtk.EventBox box, Object? data, ObjectValueDelegate method)
		{
			bool _pressed = false;
			box.button_press_event.connect((e) => { _pressed = true; return (false); });
			box.button_release_event.connect((e) => { 
				if (_pressed == true)
					method (data);
				_pressed = false; 
				return (false); 
			});
			box.enter_notify_event.connect((e) => { box.opacity = 1.0f; return (false); });
			box.leave_notify_event.connect((e) => { box.opacity = 0.5f; return (false); });
			box.opacity = 0.5f;
		}

		private BindingInterface? i1 = null;
		private BindingInterface? i2 = null;
		private BindingInterface? i3 = null;

		~BindingInspector()
		{
			main_contract.data = null;
		}

		private BindingInspector()
		{
			event_filter_flags = new BooleanGroup (this, "event-filter", false);
			binding_namespace_view_flags = new BooleanGroup (this, "binding-namespace-view", false);

			if (self_ref == null)
				self_ref = new StrictWeakRef(null);

			inspector_is_visible = true;

			var ui_builder = new Gtk.Builder ();
			try {
				ui_builder.add_from_resource ("/org/gtk/g_data_binding_gtk/data/inspector.ui");
			}
			catch (Error e) { warning ("Could not load demo UI: %s", e.message); }
			_window = (Gtk.Window) ui_builder.get_object ("binding_inspector_window");
			self_ref.set_new_target (_window);

			Gtk.HeaderBar hbar = (Gtk.HeaderBar) ui_builder.get_object ("inspector_headerbar");
			_window.set_titlebar (hbar);
			_window.show();

			source_info_btn = (Gtk.Button) ui_builder.get_object ("source_info_btn");
			clear_btn = (Gtk.Button) ui_builder.get_object ("clear_btn");
//			compact_events_btn = (Gtk.ToggleButton) ui_builder.get_object ("compact_events_btn");
			find_btn = (Gtk.MenuButton) ui_builder.get_object ("find_btn");
			main_title = (Gtk.Label) ui_builder.get_object ("main_title");
			sub_title = (Gtk.Label) ui_builder.get_object ("sub_title");
			Gtk.Box events_box = (Gtk.Box) ui_builder.get_object ("events_box");
			Gtk.Stack resource_stack = (Gtk.Stack) ui_builder.get_object ("resource_stack");
			Gtk.ListBox bindings_listbox = (Gtk.ListBox) ui_builder.get_object ("bindings_listbox");
			filter_events_btn = (Gtk.MenuButton) ui_builder.get_object ("filter_events_btn");

			binding_namespace_view_popover = new EnumFlagsPopover(filter_events_btn, typeof(BindingNamespaceViewMode), (int) (BindingNamespaceViewMode.ALL));
			event_filter_popover = new EnumFlagsPopover(filter_events_btn, typeof(EventFilterMode), (int) (EventFilterMode.ALL));
			filter_events_btn.popover = binding_namespace_view_popover;

			_binder().bind(this, "event-filter", event_filter_popover, "uint-value", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
			_binder().bind(this, "binding-namespace-view", binding_namespace_view_popover, "uint-value", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);

			ref_count_ = (Gtk.Label) ui_builder.get_object ("ref_count");
			uid = (Gtk.Label) ui_builder.get_object ("uid");
			stored_as = (Gtk.Label) ui_builder.get_object ("stored_as");
			type = (Gtk.Label) ui_builder.get_object ("type");
			data_ref_count = (Gtk.Label) ui_builder.get_object ("data_ref_count");
			data = (Gtk.Label) ui_builder.get_object ("data");
			data_type = (Gtk.Label) ui_builder.get_object ("data_type");
			source_ref_count = (Gtk.Label) ui_builder.get_object ("source_ref_count");
			source_data = (Gtk.Label) ui_builder.get_object ("source_data");
			source_type = (Gtk.Label) ui_builder.get_object ("source_type");
			ref_handling = (Gtk.Label) ui_builder.get_object ("ref_handling");
			update_type = (Gtk.Label) ui_builder.get_object ("update_type");
			binding_nr = (Gtk.Label) ui_builder.get_object ("binding_nr");
			suspended = (Gtk.Label) ui_builder.get_object ("suspended");
			is_valid = (Gtk.Label) ui_builder.get_object ("is_valid");

//			main_contract.binder = binder;

			main_contract.before_source_change.connect ((pointer, is_same, next) => {
			});
			main_contract.source_changed.connect ((pointer) => {
				_events.resource = (BindingPointer?) main_contract.data;
				wdata_ref.set_new_target (main_contract.data);
				bind_linear_source_chain ((Gtk.ListBox) ui_builder.get_object ("chain_listbox"), this);
			});

			_binder().bind (main_contract, "data", main_title, "label", BindFlags.SYNC_CREATE, update_source_data);

			main_contract.connect_notifications.connect (() => {
				if (current_data == null)
					return;
				bind_bindings_listbox (bindings_listbox, (BindingPointer?) main_contract.data, this);
				bind_binding_object_listbox ((Gtk.ListBox) ui_builder.get_object ("value_listbox"), (BindingPointer?) main_contract.data, true, this);
				bind_binding_object_listbox ((Gtk.ListBox) ui_builder.get_object ("state_listbox"), (BindingPointer?) main_contract.data, false, this);
				i1 = _binder().bind (current_data, "data", main_title, "label", BindFlags.SYNC_CREATE, update_source_data);
				if (is_binding_contract(current_data) == true) {
					i2 = _binder().bind (current_data, "is_valid", main_title, "label", BindFlags.SYNC_CREATE, update_source_data);
					i3 = _binder().bind (current_data, "suspended", main_title, "label", BindFlags.SYNC_CREATE, update_source_data);
				}
			});

			main_contract.disconnect_notifications.connect (() => {
				bind_bindings_listbox (bindings_listbox, (BindingPointer?) null, this);
				bind_binding_object_listbox ((Gtk.ListBox) ui_builder.get_object ("value_listbox"), (BindingPointer?) null, true, this);
				bind_binding_object_listbox ((Gtk.ListBox) ui_builder.get_object ("state_listbox"), (BindingPointer?) null, false, this);
				if (i1 != null) i1.unbind(); i1 = null;
				if (i2 != null) i2.unbind(); i2 = null;
				if (i3 != null) i3.unbind(); i3 = null;
			});

			notify["current-data"].connect (() => {
				bind_linear_source_chain ((Gtk.ListBox) ui_builder.get_object ("chain_listbox"), this);
			});

			Gtk.Box bindingnamespace_box = (Gtk.Box)  ui_builder.get_object ("bindingnamespace_box");
			_binder().bind (resource_stack, "visible-child", clear_btn, "visible", BindFlags.SYNC_CREATE,
				() => {
					clear_btn.visible = (resource_stack.visible_child == events_box);
					filter_events_btn.visible = ((resource_stack.visible_child == events_box) || (resource_stack.visible_child == bindingnamespace_box));
					filter_events_btn.popover = (resource_stack.visible_child == events_box) ? event_filter_popover : binding_namespace_view_popover;
					return (false);
				});

			_binder().bind (this, "pointer-ref", ui_builder.get_object ("ref_count"), "label", BindFlags.SYNC_CREATE,
				(binding, src, ref tgt) => {
					clear_btn.visible = (resource_stack.visible_child == events_box);
					filter_events_btn.visible = ((resource_stack.visible_child == events_box) || (resource_stack.visible_child == bindingnamespace_box));
					filter_events_btn.popover = (resource_stack.visible_child == events_box) ? event_filter_popover : binding_namespace_view_popover;
					return (false);
				});

			clear_btn.clicked.connect (() => {
				_events.clear();
			});

			_bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("events"), _events);

			Gtk.ListBox searched_contracts = ((Gtk.ListBox) ui_builder.get_object ("searched_contracts"));
			Gtk.SearchEntry search_entry = ((Gtk.SearchEntry) ui_builder.get_object ("search_entry"));
			search_entry.search_changed.connect (() => {
				searched_contracts.invalidate_filter();
			});
			bind_namespace_listbox (searched_contracts);
			searched_contracts.set_filter_func ((r) => {
				if (search_entry.text == "")
					return (true);
				string? s = r.get_data<string> ("name");
				if (s == null)
					return (false);
				return (s.contains (search_entry.text));
			});
			searched_contracts.row_activated.connect ((r) => {
				if (r == null)
					current_data = null;
				else
					current_data = PointerNamespace.get_instance().get_by_id(r.get_data<int> ("pointer"));
				find_btn.popover.hide();
			});

			((Gtk.ListBox) ui_builder.get_object ("events")).set_placeholder (
				new Placeholder.from_icon ("Waiting for events", Gtk.IconSize.DIALOG, PROCESSING_ICON));
			((Gtk.ListBox) ui_builder.get_object ("searched_contracts")).set_placeholder (
				new Placeholder.from_icon ("No items found", Gtk.IconSize.LARGE_TOOLBAR, STOP_ICON));
			((Gtk.ListBox) ui_builder.get_object ("bindings_listbox")).set_placeholder (
				new Placeholder.from_icon ("No bindings available", Gtk.IconSize.DND, STOP_ICON));
			((Gtk.ListBox) ui_builder.get_object ("value_listbox")).set_placeholder (
				new Placeholder.from_icon ("No value objects available", Gtk.IconSize.DND, STOP_ICON));
			((Gtk.ListBox) ui_builder.get_object ("state_listbox")).set_placeholder (
				new Placeholder.from_icon ("No state objects available", Gtk.IconSize.DND, STOP_ICON));
			((Gtk.ListBox) ui_builder.get_object ("aliases")).set_placeholder (
				new Placeholder.from_icon ("No aliases found", Gtk.IconSize.LARGE_TOOLBAR, STOP_ICON));
			((Gtk.ListBox) ui_builder.get_object ("alias_types")).set_placeholder (
				new Placeholder.from_icon ("No aliases registered", Gtk.IconSize.LARGE_TOOLBAR, STOP_ICON));
			((Gtk.ListBox) ui_builder.get_object ("contract_storages")).set_placeholder (
				new Placeholder.from_icon ("No contract storages found", Gtk.IconSize.LARGE_TOOLBAR, STOP_ICON));
			((Gtk.ListBox) ui_builder.get_object ("contracts")).set_placeholder (
				new Placeholder.from_icon ("No contracts stored in storage", Gtk.IconSize.LARGE_TOOLBAR, STOP_ICON));
			((Gtk.ListBox) ui_builder.get_object ("pointer_storages")).set_placeholder (
				new Placeholder.from_icon ("No pointer storages found", Gtk.IconSize.LARGE_TOOLBAR, STOP_ICON));
			((Gtk.ListBox) ui_builder.get_object ("pointers")).set_placeholder (
				new Placeholder.from_icon ("No pointers stored in storage", Gtk.IconSize.LARGE_TOOLBAR, STOP_ICON));

			add_pointer_reference = (Gtk.EventBox) ui_builder.get_object ("add_pointer_reference");
			add_pointer_to_inspector = (Gtk.EventBox) ui_builder.get_object ("add_pointer_to_inspector");
			add_data_reference = (Gtk.EventBox) ui_builder.get_object ("add_data_reference");
			add_data_to_inspector = (Gtk.EventBox) ui_builder.get_object ("add_data_to_inspector");
			add_source_reference = (Gtk.EventBox) ui_builder.get_object ("add_source_reference");
			add_source_to_inspector = (Gtk.EventBox) ui_builder.get_object ("add_source_to_inspector");
			assign_preflight_events (add_pointer_reference, null, (o) => {
				if (current_data != null)
					SimpleEntryBox.show_popover (add_pointer_reference, "Add notification", "Use %s to specify where you want object name, %t for type",
						(text) => {
							ReferenceMonitorGroup.get_default().monitor_object (text.replace("%s",get_description_str(current_data, false)).replace("%t", current_data.get_type().name()), current_data);
						});
			});
			assign_preflight_events (add_pointer_to_inspector, null, (o) => {
				if (current_data != null)
					ObjectInspector.add_object (current_data);
			});
			assign_preflight_events (add_data_reference, null, (o) => {
				if ((current_data != null) && (current_data.data != null))
					SimpleEntryBox.show_popover (add_data_reference, "Add notification", "Use %s to specify where you want object name, %t for type",
						(text) => {
							ReferenceMonitorGroup.get_default().monitor_object (text.replace("%s",get_description_str(current_data.data, false)).replace("%t", current_data.data.get_type().name()), current_data.data);
						});
			});
			assign_preflight_events (add_data_to_inspector, null, (o) => {
				if ((current_data != null) && (current_data.data != null))
					ObjectInspector.add_object (current_data.data);
			});
			assign_preflight_events (add_source_reference, null, (o) => {
				if ((current_data != null) && (current_data.get_source() != null))
					SimpleEntryBox.show_popover (add_source_reference, "Add notification", "Use %s to specify where you want object name, %t for type",
						(text) => {
							ReferenceMonitorGroup.get_default().monitor_object (text.replace("%s",get_description_str(current_data.get_source(), false)).replace("%t", current_data.get_source().get_type().name()), current_data.get_source());
						});
			});
			assign_preflight_events (add_source_to_inspector, null, (o) => {
				if ((current_data != null) && (current_data.get_source() != null))
					ObjectInspector.add_object (current_data.get_source());
			});

			binding_inspector = new ObjectInspector();
			((Gtk.Box) ui_builder.get_object ("binding_object_box")).pack_start (binding_inspector, true, true);
			((Gtk.ListBox) ui_builder.get_object ("bindings_listbox")).row_selected.connect ((r) => {
				if (r == null)
					binding_inspector.inspected_object = null;
				else {
					WeakReference<BindingInformationInterface?> binding;
					binding = r.get_data<WeakReference<BindingInformationInterface?>> ("binding");
					binding_inspector.inspected_object = (binding == null) ? null : binding.target;
				}
			});

			value_objects_inspector = new ObjectInspector();
			((Gtk.Box) ui_builder.get_object ("value_object_box")).pack_start (value_objects_inspector, true, true);
			((Gtk.ListBox) ui_builder.get_object ("value_listbox")).row_selected.connect ((r) => {
				if (r == null)
					value_objects_inspector.inspected_object = null;
				else {
					WeakReference<Object?> binding;
					binding = r.get_data<WeakReference<Object?>> ("binding-object");
					value_objects_inspector.inspected_object = (binding == null) ? null : binding.target;
				}
			});

			state_objects_inspector = new ObjectInspector();
			((Gtk.Box) ui_builder.get_object ("state_object_box")).pack_start (state_objects_inspector, true, true);
			((Gtk.ListBox) ui_builder.get_object ("state_listbox")).row_selected.connect ((r) => {
				if (r == null)
					state_objects_inspector.inspected_object = null;
				else {
					WeakReference<Object?> binding;
					binding = r.get_data<WeakReference<Object?>> ("binding-object");
					state_objects_inspector.inspected_object = (binding == null) ? null : binding.target;
				}
			});

			bind_aliases (ui_builder);
			bind_pointers (ui_builder);
			bind_storages (ui_builder);

			binding_namespace_search = (Gtk.SearchEntry) ui_builder.get_object ("binding_namespace_search");
			binding_namespace_search.search_changed.connect (() => { binding_search_text = binding_namespace_search.text; });
			_bind_bindings_namespace_listbox (((Gtk.ListBox) ui_builder.get_object ("binding_namespace_listbox")));
			binding_namespace_inspector = new ObjectInspector();
			((Gtk.Box) ui_builder.get_object ("binding_namespace_box")).pack_start (binding_namespace_inspector, true, true);
			((Gtk.ListBox) ui_builder.get_object ("binding_namespace_listbox")).row_selected.connect ((r) => {
				if (r == null)
					binding_namespace_inspector.inspected_object = null;
				else {
					WeakReference<BindingInterface?> binding;
					binding = r.get_data<WeakReference<BindingInterface?>> ("binding");
					binding_namespace_inspector.inspected_object = (binding == null) ? null : binding.target;
				}
			});

			assign_builder_css (ui_builder, "frame", _box_css);
			assign_builder_css (ui_builder, "title_label", _title_css);
			assign_builder_css (ui_builder, "info_label", _info_css);
			assign_builder_css (ui_builder, "chain_listbox", _chain_css);

			find_btn.popover = new Gtk.Popover(find_btn);
			find_btn.popover.modal = true;
			Gtk.Box box = (Gtk.Box) ui_builder.get_object ("search_box");
			if (box.get_parent() != null)
				box.get_parent().remove (box);
			find_btn.popover.add (box);

			_window.hide.connect (() => {
				disconnect_everything();
			});

			GLib.Timeout.add (1000, ref_timer, GLib.Priority.DEFAULT);
		}
	}
}

