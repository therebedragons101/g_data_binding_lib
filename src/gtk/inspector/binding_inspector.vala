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
		public Binder binder = new Binder();

		private EventArray _events = new EventArray(null);

		private Gtk.Button source_info_btn;
		private Gtk.Button clear_btn;
		private Gtk.ToggleButton compact_events_btn;
		private Gtk.MenuButton find_btn;
		private Gtk.Label main_title;
		private Gtk.Label sub_title;

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
		}

		private void bind_storages (Gtk.Builder ui_builder)
		{
			storages = track_contract_storage();
			bind_kv_listbox<string, string, WeakReference<BindingContract>>((Gtk.ListBox) ui_builder.get_object ("contract_storages"), storages, ((kv) => {
				return (((KeyValuePair<string, KeyValueArray<string, WeakReference<BindingContract>>>) kv).key.replace("&", "&amp;"));
			}), true);
			on_master_selected<string, string, WeakReference<BindingContract>> (
				(Gtk.ListBox) ui_builder.get_object ("contract_storages"), 
				(Gtk.ListBox) ui_builder.get_object ("contracts"), 
				((kv) => {
					KeyValuePair<string, WeakReference<BindingContract>> sel = (KeyValuePair<string, WeakReference<BindingContract>>) kv;
					return ("Contract: [%s]".printf(bold(sel.key)).replace("&", "&amp;"));
				})
			);
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

		private string _get_type_str (Object? obj)
		{
			return ((obj == null) ? bold(red("null")) : "typeof(%s)".printf(obj.get_type().name()));
		}

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

			main_contract.binder = binder;

			main_contract.before_source_change.connect ((pointer, is_same, next) => {
				bind_bindings_listbox (bindings_listbox, (BindingPointer?) null);
			});
			main_contract.source_changed.connect ((pointer) => {
				_events.resource = (BindingPointer?) main_contract.data;
				bind_bindings_listbox (bindings_listbox, (BindingPointer?) main_contract.data);
			});

			binder.bind (main_contract, "data", main_title, "label", BindFlags.SYNC_CREATE,
				() => {
					main_title.set_markup (bold("Resource type=%s".printf (_get_type_str(main_contract.data))));
					sub_title.set_markup (small("Chain source=%s".printf (_get_type_str(main_contract.get_source()))));
					return (false);
				});

			binder.bind (resource_stack, "visible-child", clear_btn, "visible", BindFlags.SYNC_CREATE,
				() => {
					clear_btn.visible = (resource_stack.visible_child == events_box);
					compact_events_btn.visible = (resource_stack.visible_child == events_box);
					return (false);
				});

			clear_btn.clicked.connect (() => {
				_events.clear();
			});

			binder.bind (this, "compact-events", compact_events_btn, "active", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);

			bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("events"), _events, this, "compact-events");

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
		}
	}
}

