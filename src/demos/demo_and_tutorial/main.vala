using GData;
using GData.Generics;
using GDataGtk;
using Demo;

public class DemoAndTutorial : Gtk.Application
{
	public const string resource_path = "/org/gtk/demo_and_tutorial/";

	public const string[] code_pages = {
		"main_demo",
		"simple_binding/example_alias_and_freeze",
		"simple_binding/example_contract_chaining",
		"simple_binding/example_contract_set_data",
		"simple_binding/example_custom_property_binding",
		"simple_binding/example_inspector",
		"simple_binding/example_pointer_relay",
		"simple_binding/example_pointer_set_data",
		"simple_binding/example_simple_property_binding",
		"simple_binding/example_state_objects",
		"simple_binding/example_validation",
		"simple_binding/example_validation"
	};

	public class StorageInspectRow : Gtk.ListBoxRow
	{
		private Gtk.Label title;

		public int id { get; set; }
		public string pname { get; set; }

		public StorageInspectRow (int id, string pname)
		{
			this.id = id;
			this.pname = pname;
			visible = true;
			title = new Gtk.Label("");
			title.visible = true;
			title.hexpand = true;
			title.xalign = 0;
			title.use_markup = true;
			title.set_markup(get_pointer_namespace_markup(PointerNamespace.get_instance().get_by_id(id)));
			add (title);
		}
	}

	private ObjectArray<StorageInspectRow> inspect_list = new ObjectArray<StorageInspectRow>();

	public Gtk.Window window;
	public Gtk.HeaderBar demo_headerbar;

	private Gtk.Stack code_demo_stack;
	private Gtk.Stack demo_stack;
	private Gtk.Stack basic_tutorial_stack;
	private Gtk.Box binding_tutorial_box;
	private Gtk.TextBuffer code_buffer;

	private EventArray _e4_events = new EventArray();
	private EventArray _e5_events = new EventArray();
	private EventArray _e6_events = new EventArray();
	private EventArray _e7_events = new EventArray();

	public int _counter = 0;
	public string counter {
		owned get { return ("counter=%i".printf(_counter)); }
	}

	private string _active_page = "";
	public string active_page { 
		get { return (_active_page); }
		set { 
			_active_page = value;
			string text = "";
			inspect_list.clear();
			if (value != "") {
				string res = "resource://%s%s.vala".printf (resource_path, value);
				File file = File.new_for_uri (res);
				if (!file.query_exists ())
					stderr.printf ("File '%s' => '%s' doesn't exist.\n", file.get_path (), res);
				else try {
					DataInputStream dis = new DataInputStream (file.read ());
					string line = "";
					while ((line = dis.read_line (null)) != null)
						text = "%s%s%s".printf (text, (text != "") ? "\n" : "", line);
				} catch (Error e) { error ("%s", e.message); }

				string nm = value;
				if (nm.last_index_of("/") > -1)
					nm = nm.splice (0, nm.last_index_of("/")+1);
				PointerStorage? ptrs = PointerStorage.find_storage(nm);
				if (ptrs != null) {
					ptrs.foreach ((k,v) => {
						inspect_list.add (new StorageInspectRow (v.id, v.stored_as));
					});
				}
				ContractStorage? ctrs = ContractStorage.find_storage(nm);
				if (ctrs != null) {
					ctrs.foreach ((k,v) => {
						inspect_list.add (new StorageInspectRow (v.id, v.stored_as));
					});
				}
			}
			code_buffer.set_text(text);
		}
	}

	public DemoAndTutorial ()
	{
		Object (flags: ApplicationFlags.FLAGS_NONE);
	}

	private Gtk.Builder set_ui()
	{
		Gtk.Settings.get_default().gtk_application_prefer_dark_theme = true;

		Environment.set_application_name ("test_data_bindings");

		var ui_builder = new Gtk.Builder ();
		try {
			ui_builder.add_from_resource ("/org/gtk/demo_and_tutorial/interface.ui");
		}
		catch (Error e) { warning ("Could not load demo UI: %s", e.message); }
		window = (Gtk.Window) ui_builder.get_object ("firstWindow");
		add_window (window);

		binding_tutorial_box = (Gtk.Box) ui_builder.get_object ("binding_tutorial_box");

		demo_stack = (Gtk.Stack) ui_builder.get_object ("demo_stack");
		((Gtk.Button) ui_builder.get_object ("demo_btn")).clicked.connect(() => {
			demo_stack.visible_child = (Gtk.Box) ui_builder.get_object ("demo_box");
		});
		((Gtk.Button) ui_builder.get_object ("map_btn")).clicked.connect(() => {
			demo_stack.visible_child = (Gtk.Box) ui_builder.get_object ("map_box");
		});
		((Gtk.Button) ui_builder.get_object ("binding_tutorial_btn")).clicked.connect(() => {
			demo_stack.visible_child = binding_tutorial_box;
		});
		((Gtk.Button) ui_builder.get_object ("mapping_tutorial_btn")).clicked.connect(() => {
			demo_stack.visible_child = (Gtk.Box) ui_builder.get_object ("mapping_tutorial_box");
		});

		demo_headerbar = (Gtk.HeaderBar) ui_builder.get_object ("demo_headerbar");
		window.set_titlebar (demo_headerbar);

		code_demo_stack = (Gtk.Stack) ui_builder.get_object ("code_demo_stack");
		demo_stack = (Gtk.Stack) ui_builder.get_object ("demo_stack");
		basic_tutorial_stack = (Gtk.Stack) ui_builder.get_object ("basic_tutorial_stack");
		code_buffer = (Gtk.TextBuffer) ui_builder.get_object ("code_buffer");

		demo_stack.notify["visible-child"].connect (() => {
			set_active_demo_page(demo_stack);
		});

		basic_tutorial_stack.notify["visible-child"].connect (() => {
			set_active_basic_tutorial_page(basic_tutorial_stack);
		});

		for (int i=0; i<code_pages.length; i++) {
			string nm = code_pages[i];
			if (nm.last_index_of("/") > -1)
				nm = nm.splice (0, nm.last_index_of("/")+1);
			Object b = ui_builder.get_object (nm);
			b.set_data<string> ("code", code_pages[i]);
		}

		Gtk.ToggleButton show_code = (Gtk.ToggleButton) ui_builder.get_object ("show_code");
		show_code.toggled.connect (() => {
			code_demo_stack.visible_child = (show_code.active == true) ? 
				((Gtk.Box) ui_builder.get_object ("code_box")) :
				((Gtk.Box) ui_builder.get_object ("demo"));
		});

		Binder.get_default().bind (code_demo_stack, "visible-child", ui_builder.get_object ("main_stack_switcher"), "visible",
		                      BindFlags.SYNC_CREATE, 
			((b, src, ref tgt) => {
				tgt.set_boolean (code_demo_stack.visible_child == ui_builder.get_object ("demo"));
				return (true);
			}));

		Binder.get_default().bind (this, "active-page", ui_builder.get_object ("code_and_storage"), "reveal-child",
		                      BindFlags.SYNC_CREATE, 
			((b, src, ref tgt) => {
				tgt.set_boolean ((src.get_string() != "") && (src.get_string() != null));
				return (true);
			}));

		Binder.get_default().bind (inspect_list, "length", ui_builder.get_object ("show_storages"), "sensitive",
		                      BindFlags.SYNC_CREATE, 
			((b, src, ref tgt) => {
				tgt.set_boolean (inspect_list.length > 0);
				return (true);
			}));

		Gtk.MenuButton show_storages = ((Gtk.MenuButton) ui_builder.get_object ("show_storages"));
		show_storages.popover = new Gtk.Popover(show_storages);
		show_storages.popover.add ((Gtk.Box) ui_builder.get_object ("inspect_list"));

		Gtk.ListBox used_resources = (Gtk.ListBox) ui_builder.get_object ("used_resources");
		used_resources.bind_model (inspect_list, (o) => {
			return ((StorageInspectRow) o);
		});
		used_resources.row_activated.connect ((r) => {
			if (r == null)
				BindingInspector.show (null);
			else
				BindingInspector.show (PointerNamespace.get_instance().get_by_id(((StorageInspectRow) r).id));
		});

		assign_builder_css (ui_builder, "label_description", _dark_label_css);
		assign_builder_css (ui_builder, "label_warning", _warning_label_css);
		assign_builder_css (ui_builder, "custom_data", _title_css);
		assign_builder_css (ui_builder, "evvo_4", _title_css);
		return (ui_builder);
	}

	private void set_page_name (Object? obj)
	{
		if (obj == null)
			return;
		string? str = obj.get_data<string>("code");
		if (str == null)
			active_page = "";
		else
			active_page = str;
	}

	private void set_active_basic_tutorial_page (Gtk.Stack stack)
	{
		set_page_name (stack.visible_child);
	}

	private void set_active_demo_page (Gtk.Stack stack)
	{
		if (stack.visible_child == binding_tutorial_box)
			set_active_basic_tutorial_page (basic_tutorial_stack);
		else
			set_page_name (stack.visible_child);
	}

	protected override void startup ()
	{
		base.startup ();

		// allocate "default" property as "&"
		PropertyAlias.get_instance ("&")
			.register (typeof(Gtk.Entry), "text")
			.register (typeof(Gtk.Label), "label")
			.register (typeof(Gtk.ToggleButton), "active")
			.register (typeof(Gtk.SpinButton), "value")
			.register (typeof(Gtk.Switch), "active");
		var ui_builder = set_ui();

		init_demo_persons();

		main_demo (this, ui_builder);
		example_simple_property_binding(this, ui_builder);
		example_custom_property_binding(this, ui_builder);
		example_alias_and_freeze(this, ui_builder);
		alias_storage(this, ui_builder);
		pointer_storage_example(this, ui_builder);
		contract_storage_example(this, ui_builder);
		example_pointer_set_data(this, ui_builder, _e4_events);
		example_contract_set_data(this, ui_builder, _e5_events);
		example_contract_chaining(this, ui_builder, _e6_events);
		example_validation(this, ui_builder);
		example_state_objects(this, ui_builder);
		example_value_objects(this, ui_builder);
		example_pointer_relay(this, ui_builder, _e7_events);
		example_inspector(ui_builder);
	}

	protected override void shutdown ()
	{
		base.shutdown ();
	}

	protected override void activate ()
	{
		window.present ();
	}

	public static int main (string[] args)
	{
		var app = new DemoAndTutorial ();
		return (app.run (args));
	}

	private void alias_storage (DemoAndTutorial demo, Gtk.Builder ui_builder)
	{
		AliasArray aliases = track_property_aliases();
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

	private void pointer_storage_example (DemoAndTutorial demo, Gtk.Builder ui_builder)
	{
		PointerStorage.get_storage("test_group1").add ("pointer 1", new BindingContract());
		PointerStorage.get_storage("test_group1").add ("pointer 2", new BindingContract());
		PointerStorage.get_storage("test_group1").add ("pointer 3", new BindingContract());
		PointerStorage.get_storage("test_group2").add ("pointer 4", new BindingContract());
		PointerStorage.get_storage("test_group2").add ("pointer 5", new BindingContract());
		PointerStorage.get_storage("test_group3").add ("pointer 6", new BindingContract());
		PointerStorage.get_storage("test_group3").add ("pointer 7", new BindingContract());
		PointerStorage.get_storage("test_group3").add ("pointer 8", new BindingContract());
		PointerArray aliases = track_pointer_storage();
		bind_kv_listbox<string, string, WeakReference<BindingPointer>>((Gtk.ListBox) ui_builder.get_object ("pointer_storages"), aliases, ((kv) => {
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

	private void contract_storage_example (DemoAndTutorial demo, Gtk.Builder ui_builder)
	{
		ContractStorage.get_storage("test_group1").add ("contract 1", new BindingContract());
		ContractStorage.get_storage("test_group1").add ("contract 2", new BindingContract());
		ContractStorage.get_storage("test_group1").add ("contract 3", new BindingContract());
		ContractStorage.get_storage("test_group2").add ("contract 4", new BindingContract());
		ContractStorage.get_storage("test_group2").add ("contract 5", new BindingContract());
		ContractStorage.get_storage("test_group3").add ("contract 6", new BindingContract());
		ContractStorage.get_storage("test_group3").add ("contract 7", new BindingContract());
		ContractStorage.get_storage("test_group3").add ("contract 8", new BindingContract());
		ContractArray aliases = track_contract_storage();
		bind_kv_listbox<string, string, WeakReference<BindingContract>>((Gtk.ListBox) ui_builder.get_object ("contract_storages"), aliases, ((kv) => {
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






}
