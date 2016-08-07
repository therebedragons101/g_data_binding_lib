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
		private StrictWeakRef wdata_ref = new StrictWeakRef(null);
		private int ptr_ref = -1;
		private int data_ref = -1;
		private int src_ref = -1;

		internal int pointer_ref { get; set; default=-1; }
		internal int pointer_data_ref { get; set; default=-1; }
		internal int pointer_source_ref { get; set; default=-1; }

		public Binder binder = new Binder();

		private EventArray _events = new EventArray(null);

		private Gtk.Button source_info_btn;
		private Gtk.Button clear_btn;
		private Gtk.ToggleButton compact_events_btn;
		private Gtk.MenuButton find_btn;
		private Gtk.Label main_title;
		private Gtk.Label sub_title;

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

		private static bool inspector_is_visible { get; private set; default = false; }

		public bool compact_events { get; set; default = false; }

		private static BindingInspector? _instance = null;
		public static BindingInspector instance {
			get {
				if (_instance == null)
					_instance = new BindingInspector();
				return (_instance);
			}
		}

		private Gtk.Window? _window = null;
		public Gtk.Window window {
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
					return ("Type: [%s] => \"%s\"".printf(green(sel.key.name()), bold(sel.val)).replace("&", "&amp;"));
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
			main_contract.unbind_all();
			main_contract.data = null;
			_events.clear();
			_main_contract = null;
			_window.destroy();
			_window = null;
			inspector_is_visible = false;
			_instance = null;
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

		public bool ref_timer()
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
			main_title.set_markup (bold("Resource type=%s".printf (_get_type_str(main_contract.data))));
			sub_title.set_markup (small("Chain source=%s".printf (_get_type_str(main_contract.get_source()))));
			uid.set_markup ((current_data == null) ? red(bold("null")) : bold("@%i").printf(current_data.id));
			stored_as.set_markup (_get_stored_as (current_data));
			type.set_markup (bold("%s".printf (_get_type_str(current_data))));
			data_type.set_markup (bold((current_data == null) ? _get_type_str(null) : _get_type_str(current_data.data)));
			data.set_markup (bold((current_data == null) ? red("null") : _get_object_str(current_data.data)));
			source_data.set_markup (bold((current_data == null) ? red("null") : _get_object_str(current_data.get_source())));
			source_type.set_markup (bold((current_data == null) ? _get_type_str(null) : _get_type_str(current_data.get_source())));
			ref_handling.set_markup (bold((current_data == null) ? red("null") : current_data.reference_type.get_str()));
			update_type.set_markup (bold((current_data == null) ? red("null") : current_data.update_type.get_str()));
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
			source_type.set_markup (bold((current_data == null) ? _get_type_str(null) : _get_type_str(current_data.get_source())));
			return (false);
		}

		private BindingInterface? i1 = null;
		private BindingInterface? i2 = null;
		private BindingInterface? i3 = null;

		private BindingInspector()
		{
			inspector_is_visible = true;

			var ui_builder = new Gtk.Builder ();
			try {
				ui_builder.add_from_resource ("/org/gtk/g_data_binding_gtk/data/inspector.ui");
			}
			catch (Error e) { warning ("Could not load demo UI: %s", e.message); }
			_window = (Gtk.Window) ui_builder.get_object ("binding_inspector_window");

			Gtk.HeaderBar hbar = (Gtk.HeaderBar) ui_builder.get_object ("inspector_headerbar");
			_window.set_titlebar (hbar);
			_window.show();

			source_info_btn = (Gtk.Button) ui_builder.get_object ("source_info_btn");
			clear_btn = (Gtk.Button) ui_builder.get_object ("clear_btn");
			compact_events_btn = (Gtk.ToggleButton) ui_builder.get_object ("compact_events_btn");
			find_btn = (Gtk.MenuButton) ui_builder.get_object ("find_btn");
			main_title = (Gtk.Label) ui_builder.get_object ("main_title");
			sub_title = (Gtk.Label) ui_builder.get_object ("sub_title");
			Gtk.Box events_box = (Gtk.Box) ui_builder.get_object ("events_box");
			Gtk.Stack resource_stack = (Gtk.Stack) ui_builder.get_object ("resource_stack");
			Gtk.ListBox bindings_listbox = (Gtk.ListBox) ui_builder.get_object ("bindings_listbox");

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

			main_contract.binder = binder;

			main_contract.before_source_change.connect ((pointer, is_same, next) => {
			});
			main_contract.source_changed.connect ((pointer) => {
				_events.resource = (BindingPointer?) main_contract.data;
				wdata_ref.set_new_target (main_contract.data);
				bind_linear_source_chain ((Gtk.ListBox) ui_builder.get_object ("chain_listbox"), this);
			});

			binder.bind (main_contract, "data", main_title, "label", BindFlags.SYNC_CREATE, update_source_data);

			main_contract.connect_notifications.connect (() => {
				if (current_data == null)
					return;
				bind_bindings_listbox (bindings_listbox, (BindingPointer?) main_contract.data, this);
				i1 =binder.bind (current_data, "data", main_title, "label", BindFlags.SYNC_CREATE, update_source_data);
				if (is_binding_contract(current_data) == true) {
					i2 = binder.bind (current_data, "is_valid", main_title, "label", BindFlags.SYNC_CREATE, update_source_data);
					i3 = binder.bind (current_data, "suspended", main_title, "label", BindFlags.SYNC_CREATE, update_source_data);
				}
			});

			main_contract.disconnect_notifications.connect (() => {
				bind_bindings_listbox (bindings_listbox, (BindingPointer?) null, this);
				if (i1 != null) i1.unbind(); i1 = null;
				if (i2 != null) i2.unbind(); i2 = null;
				if (i3 != null) i3.unbind(); i3 = null;
			});

			notify["current-data"].connect (() => {
				bind_linear_source_chain ((Gtk.ListBox) ui_builder.get_object ("chain_listbox"), this);
			});

			binder.bind (resource_stack, "visible-child", clear_btn, "visible", BindFlags.SYNC_CREATE,
				() => {
					clear_btn.visible = (resource_stack.visible_child == events_box);
					compact_events_btn.visible = (resource_stack.visible_child == events_box);
					return (false);
				});

			binder.bind (this, "pointer-ref", ui_builder.get_object ("ref_count"), "label", BindFlags.SYNC_CREATE,
				(binding, src, ref tgt) => {
					clear_btn.visible = (resource_stack.visible_child == events_box);
					compact_events_btn.visible = (resource_stack.visible_child == events_box);
					return (false);
				});

			clear_btn.clicked.connect (() => {
				_events.clear();
			});

			binder.bind (this, "compact-events", compact_events_btn, "active", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);

			bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("events"), _events, this, "compact-events");

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
			((Gtk.ListBox) ui_builder.get_object ("binding_information")).set_placeholder (
				new Placeholder.from_icon ("No bindings available", Gtk.IconSize.DND, STOP_ICON));
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

			bind_aliases (ui_builder);
			bind_pointers (ui_builder);
			bind_storages (ui_builder);

			_window.hide.connect (() => {
				disconnect_everything();
			});

			GLib.Timeout.add (1000, ref_timer, GLib.Priority.DEFAULT);
		}
	}
}

