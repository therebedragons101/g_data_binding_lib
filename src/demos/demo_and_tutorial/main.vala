using GData;
using GData.Generics;
using GDataGtk;
using Demo;

public class test_data_bindings : Gtk.Application
{
	private Gtk.Window window;
	private Gtk.Stack demo_stack;
	private Gtk.ListBox items;
	private Gtk.Entry name;
	private Gtk.Entry surname;
	private Gtk.Entry required;
	private Gtk.Button required_not_empty;
	private Gtk.Button is_valid_source;
	private Gtk.Label name_chain;
	private Gtk.Label surname_chain;
	private Gtk.Label custom_data;
	private Gtk.HeaderBar demo_headerbar;

	private Gtk.Entry basic_entry_left;
	private Gtk.Entry basic_entry_right;
	private Gtk.Entry basic_entry_left2;
	private Gtk.Entry basic_entry_right2;
	private Gtk.Label basic_label_left3;
	private Gtk.Entry basic_entry_right3;
	private Gtk.Label basic_label_right4;
	private Gtk.ToggleButton basic_flood_data_btn;
	private Gtk.Entry basic_entry_left5;
	private Gtk.Label basic_label_right5;
	private Gtk.Button basic_transfer_data_btn;
	private Gtk.Entry basic_entry_left6;
	private Gtk.Entry basic_entry_right6;

	private Gtk.Entry custom_binding_l1;
	private Gtk.Label custom_binding_r1;
	private Gtk.Entry custom_binding_l2;
	private Gtk.Entry custom_binding_r2;
	private Gtk.Entry custom_binding_l3;
	private Gtk.ToggleButton custom_binding_r3;
	private Gtk.Entry custom_binding_l4;
	private Gtk.ToggleButton custom_binding_r4;

	private Gtk.Entry advanced_binding_l1;
	private Gtk.Label advanced_binding_r1;
	private Gtk.Entry advanced_binding_l2;
	private Gtk.Label advanced_binding_r2;
	private Gtk.Entry advanced_binding_l3;
	private Gtk.Label advanced_binding_r3;
	private Gtk.Entry advanced_binding_l4;
	private Gtk.Label advanced_binding_r4;
	private Gtk.ToggleButton advanced_freeze1;
	private Gtk.ToggleButton advanced_freeze2;
	private Gtk.ToggleButton advanced_freeze3;
	private PropertyBinding advanced4;

	private Gtk.CheckButton e4_set_1;
	private Gtk.CheckButton e4_set_2;
	private Gtk.CheckButton e4_set_3;
	private ObjectArray<EventDescription> _e4_events = new ObjectArray<EventDescription>();

	private Gtk.CheckButton e5_set_1;
	private Gtk.CheckButton e5_set_2;
	private Gtk.CheckButton e5_set_3;
	private ObjectArray<EventDescription> _e5_events = new ObjectArray<EventDescription>();

	private Gtk.CheckButton e6_set_1;
	private Gtk.CheckButton e6_set_2;
	private Gtk.CheckButton e6_set_3;
	private ObjectArray<EventDescription> _e6_events = new ObjectArray<EventDescription>();
	private ObjectArray<EventDescription> _e7_events = new ObjectArray<EventDescription>();

	private int _counter = 0;
	public string counter {
		owned get { return ("counter=%i".printf(_counter)); }
	}

	public test_data_bindings ()
	{
		Object (flags: ApplicationFlags.FLAGS_NONE);
	}

	private Gtk.Builder set_ui()
	{
		Gtk.Settings.get_default().gtk_application_prefer_dark_theme = true;

		Environment.set_application_name ("test_data_bindings");

		// yes, nightmare implementation
		// this is just temporary hack until i add resource building
		// into demo executable.
		// it is just that that is on lowest priority right now
		var ui_builder = new Gtk.Builder ();
		try {
//			ui_builder.add_from_file ("./interface.ui");
			ui_builder.add_from_resource ("/org/gtk/demo_and_tutorial/interface.ui");
		}
		catch (Error e) { warning ("Could not load demo UI: %s", e.message); }
		window = (Gtk.Window) ui_builder.get_object ("firstWindow");
		add_window (window);

		demo_stack = (Gtk.Stack) ui_builder.get_object ("demo_stack");
		((Gtk.Button) ui_builder.get_object ("demo_btn")).clicked.connect(() => {
			demo_stack.visible_child = (Gtk.Box) ui_builder.get_object ("demo_box");
		});
		((Gtk.Button) ui_builder.get_object ("map_btn")).clicked.connect(() => {
			demo_stack.visible_child = (Gtk.Box) ui_builder.get_object ("map_box");
		});
		((Gtk.Button) ui_builder.get_object ("binding_tutorial_btn")).clicked.connect(() => {
			demo_stack.visible_child = (Gtk.Box) ui_builder.get_object ("binding_tutorial_box");
		});
		((Gtk.Button) ui_builder.get_object ("mapping_tutorial_btn")).clicked.connect(() => {
			demo_stack.visible_child = (Gtk.Box) ui_builder.get_object ("mapping_tutorial_box");
		});

		demo_headerbar = (Gtk.HeaderBar) ui_builder.get_object ("demo_headerbar");
		window.set_titlebar (demo_headerbar);

		items = (Gtk.ListBox) ui_builder.get_object ("items");
		name = (Gtk.Entry) ui_builder.get_object ("name");
		surname = (Gtk.Entry) ui_builder.get_object ("surname");
		required = (Gtk.Entry) ui_builder.get_object ("required");
		name_chain = (Gtk.Label) ui_builder.get_object ("name_chain");
		surname_chain = (Gtk.Label) ui_builder.get_object ("surname_chain");
		custom_data = (Gtk.Label) ui_builder.get_object ("custom_data");

		basic_entry_left = (Gtk.Entry) ui_builder.get_object ("basic_entry_left");
		basic_entry_right = (Gtk.Entry) ui_builder.get_object ("basic_entry_right");
		basic_entry_left2 = (Gtk.Entry) ui_builder.get_object ("basic_entry_left2");
		basic_entry_right2 = (Gtk.Entry) ui_builder.get_object ("basic_entry_right2");
		basic_label_left3 = (Gtk.Label) ui_builder.get_object ("basic_label_left3");
		basic_entry_right3 = (Gtk.Entry) ui_builder.get_object ("basic_entry_right3");
		basic_label_right4 = (Gtk.Label) ui_builder.get_object ("basic_label_right4");
		basic_flood_data_btn = (Gtk.ToggleButton) ui_builder.get_object ("basic_flood_data_btn");
		basic_entry_left5 = (Gtk.Entry) ui_builder.get_object ("basic_entry_left5");
		basic_label_right5 = (Gtk.Label) ui_builder.get_object ("basic_label_right5");
		basic_entry_left6 = (Gtk.Entry) ui_builder.get_object ("basic_entry_left6");
		basic_entry_right6 = (Gtk.Entry) ui_builder.get_object ("basic_entry_right6");

		required_not_empty = (Gtk.Button) ui_builder.get_object ("required_not_empty");
		is_valid_source = (Gtk.Button) ui_builder.get_object ("is_valid_source");

		e4_set_1 = (Gtk.CheckButton) ui_builder.get_object ("e4_set_1");
		e4_set_2 = (Gtk.CheckButton) ui_builder.get_object ("e4_set_2");
		e4_set_3 = (Gtk.CheckButton) ui_builder.get_object ("e4_set_3");

		custom_binding_l1 = (Gtk.Entry) ui_builder.get_object ("custom_binding_l1");
		custom_binding_r1 = (Gtk.Label) ui_builder.get_object ("custom_binding_r1");
		custom_binding_l2 = (Gtk.Entry) ui_builder.get_object ("custom_binding_l2");
		custom_binding_r2 = (Gtk.Entry) ui_builder.get_object ("custom_binding_r2");
		custom_binding_l3 = (Gtk.Entry) ui_builder.get_object ("custom_binding_l3");
		custom_binding_r3 = (Gtk.ToggleButton) ui_builder.get_object ("custom_binding_r3");
		custom_binding_l4 = (Gtk.Entry) ui_builder.get_object ("custom_binding_l4");
		custom_binding_r4 = (Gtk.ToggleButton) ui_builder.get_object ("custom_binding_r4");

		advanced_binding_l1 = (Gtk.Entry) ui_builder.get_object ("advanced_binding_l1");
		advanced_binding_r1 = (Gtk.Label) ui_builder.get_object ("advanced_binding_r1");
		advanced_binding_l2 = (Gtk.Entry) ui_builder.get_object ("advanced_binding_l2");
		advanced_binding_r2 = (Gtk.Label) ui_builder.get_object ("advanced_binding_r2");
		advanced_binding_l3 = (Gtk.Entry) ui_builder.get_object ("advanced_binding_l3");
		advanced_binding_r3 = (Gtk.Label) ui_builder.get_object ("advanced_binding_r3");
		advanced_binding_l4 = (Gtk.Entry) ui_builder.get_object ("advanced_binding_l4");
		advanced_binding_r4 = (Gtk.Label) ui_builder.get_object ("advanced_binding_r4");
		advanced_freeze1 = (Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze1");
		advanced_freeze2 = (Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze2");
		advanced_freeze3 = (Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze3");

		e5_set_1 = (Gtk.CheckButton) ui_builder.get_object ("e5_set_1");
		e5_set_2 = (Gtk.CheckButton) ui_builder.get_object ("e5_set_2");
		e5_set_3 = (Gtk.CheckButton) ui_builder.get_object ("e5_set_3");

		e6_set_1 = (Gtk.CheckButton) ui_builder.get_object ("e6_set_1");
		e6_set_2 = (Gtk.CheckButton) ui_builder.get_object ("e6_set_2");
		e6_set_3 = (Gtk.CheckButton) ui_builder.get_object ("e6_set_3");

		assign_builder_css (ui_builder, "label_description", _dark_label_css);
		assign_builder_css (ui_builder, "label_warning", _warning_label_css);
		assign_builder_css (ui_builder, "custom_data", _title_css);
		assign_builder_css (ui_builder, "evvo_4", _title_css);
		return (ui_builder);
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

		main_demo (ui_builder);
		example1(ui_builder);
		example2(ui_builder);
		example3(ui_builder);
		alias_example(ui_builder);
		pointer_storage_example(ui_builder);
		contract_storage_example(ui_builder);
		example4(ui_builder);
		example5(ui_builder);
		example6(ui_builder);
		example_v(ui_builder);
		example_so(ui_builder);
		example_vo(ui_builder);
		example_relay(ui_builder);
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
		var app = new test_data_bindings ();
		return (app.run (args));
	}

	public void main_demo (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "main-example";
		BindingContract selection_contract = ContractStorage.get_storage(_STORAGE_).add ("main-contract", new BindingContract(null))
			.bind ("name", name, "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, null, null,
				((v) => {
					return ((string) v != "");
				}))
			.bind ("surname", surname, "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, null, null,
				((v) => {
					return ((string) v != "");
				}))
			.bind ("required", required, "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.contract;
		
		// chaining contract as source
		BindingContract chain_contract = ContractStorage.get_storage(_STORAGE_).add ("chain-contract", new BindingContract(selection_contract))
			.bind ("name", name_chain, "label", BindFlags.SYNC_CREATE)
			.bind ("surname", surname_chain, "label", BindFlags.SYNC_CREATE)
			.contract;

		bind_person_model (items, persons, selection_contract);

		// adding custom state value to contract
		selection_contract.add_state (new CustomBindingSourceState ("validity", selection_contract, ((src) => {
			return ((src.data != null) && (((Person) src.data).required != ""));
		}), new string[1] { "required" }));

		// adding custom value to contract
		selection_contract.add_source_value (new CustomBindingSourceData<string> ("length", selection_contract, 
			((src) => {
				return ("(cumulative of string lengths)=>%i".printf((src.data != null) ? ((Person) src.data).name.length + ((Person) src.data).surname.length + ((Person) src.data).required.length : 0));
			}), 
			((a,b) => { return ((a == b) ? 0 : 1); }), 
			"", false, ALL_PROPERTIES));

		// bind to state. note that state is updated whenever contract source changes or specified properties in respective class get changed
		// which makes it perfectly ok to use simple binding as this connection will be stable for whole contract life
		PropertyBinding.bind (selection_contract.get_state_object("validity"), "state", required_not_empty, "sensitive", BindFlags.SYNC_CREATE);

		// bind to binding value. note that value is updated whenever contract source changes or specified properties in respective class get changed
		// which makes it perfectly ok to use simple binding as this connection will be stable for whole contract life
		PropertyBinding.bind (selection_contract.get_source_value ("length"), "data", custom_data, "label", BindFlags.SYNC_CREATE, 
			(binding, srcval, ref targetval) => {
				targetval.set_string (((CustomBindingSourceData<string>) binding.source).data);
				return true;
			});

		PropertyBinding.bind (selection_contract, "is-valid", is_valid_source, "sensitive", BindFlags.SYNC_CREATE);

		BindingPointer infoptr = selection_contract.hold (new BindingPointerFromPropertyValue (selection_contract, "info"));
		BindingPointer parentptr = selection_contract.hold (new BindingPointerFromPropertyValue (selection_contract, "parent"));

		BindingContract info_contract = ContractStorage.get_storage(_STORAGE_).add ("info-contract", new BindingContract(infoptr))
			.bind ("some_num", ui_builder.get_object ("e1_s1_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.contract;

		BindingContract parent_contract = ContractStorage.get_storage(_STORAGE_).add ("parent-contract", new BindingContract(parentptr))
			.bind ("name", ui_builder.get_object ("e1_s2_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.bind ("surname", ui_builder.get_object ("e1_s2_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.bind ("required", ui_builder.get_object ("e1_s2_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.contract;

		PropertyBinding.bind(parent_contract, "is-valid", ui_builder.get_object ("e1_s2_g"), "visible", BindFlags.SYNC_CREATE);
	}

	public bool flood_timer()
	{
		_counter++;
		this.notify_property("counter");
		return (basic_flood_data_btn.active);
	}

	public void flooded (BindingInterface binding)
	{
		basic_label_right4.sensitive = false;
		basic_label_right4.label = "*** FLOODING *** last before freeze=>%i".printf(_counter);
	}

	public void flood_over (BindingInterface binding)
	{
		basic_label_right4.sensitive = true;
	}

	public void example1 (Gtk.Builder ui_builder)
	{
		PropertyBinding.bind (basic_entry_left, "text", basic_entry_right, "text", BindFlags.SYNC_CREATE);

		PropertyBinding.bind (basic_entry_left2, "text", basic_entry_right2, "text", BindFlags.BIDIRECTIONAL | BindFlags.SYNC_CREATE);

		PropertyBinding.bind (basic_label_left3, "label", basic_entry_right3, "text", BindFlags.REVERSE_DIRECTION | BindFlags.SYNC_CREATE);

		PropertyBinding basic4 = PropertyBinding.bind (this, "counter", basic_label_right4, "label", BindFlags.FLOOD_DETECTION | BindFlags.SYNC_CREATE);
		basic4.flood_detected.connect (flooded);
		basic4.flood_stopped.connect (flood_over);
		basic_flood_data_btn.toggled.connect (() => {
			if (basic_flood_data_btn.active == true)
				GLib.Timeout.add (20, flood_timer, GLib.Priority.DEFAULT);
		});

		PropertyBinding basic5 = PropertyBinding.bind (basic_entry_left5, "text", basic_label_right5, "label", BindFlags.MANUAL_UPDATE | BindFlags.SYNC_CREATE);
		basic_transfer_data_btn = (Gtk.Button) ui_builder.get_object ("basic_transfer_data_btn");
		basic_transfer_data_btn.clicked.connect (() => {
			basic5.update_from_source();
		});

		PropertyBinding.bind (basic_entry_left6, "text", basic_entry_right6, "text", BindFlags.BIDIRECTIONAL | BindFlags.SYNC_CREATE | BindFlags.DELAYED);
	}

	public void example2 (Gtk.Builder ui_builder)
	{
		PropertyBinding.bind (custom_binding_l1, "text", custom_binding_r1, "label", BindFlags.SYNC_CREATE, ((b, src, ref tgt) => {
				tgt.set_string("value=" + src.get_string());
				return (true);
		}));

		PropertyBinding.bind (custom_binding_l2, "text", custom_binding_r2, "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, 
			((binding, src, ref tgt) => {
				((Gtk.Entry) binding.target).text = ((Gtk.Entry) binding.source).text;
				return (false);
			}),
			((binding, src, ref tgt) => {
				((Gtk.Entry) binding.source).text = ((Gtk.Entry) binding.target).text;
				return (false);
			}));

		GLib.Value.register_transform_func (typeof(string), typeof(bool), ((src, ref tgt) => {
			tgt.set_boolean ((src.get_string() != "") && (src.get_string() != null));
		}));

		PropertyBinding.bind (custom_binding_l3, "text", custom_binding_r3, "active", BindFlags.SYNC_CREATE);

		PropertyBinding.bind (custom_binding_l4, "text", custom_binding_r4, "active", BindFlags.SYNC_CREATE | BindFlags.INVERT_BOOLEAN);
	}

	private void toggle_freeze4 (Gtk.ToggleButton btn)
	{
		if (btn.active == true)
			advanced4.freeze();
		else
			advanced4.unfreeze();
	}

	public void example3 (Gtk.Builder ui_builder)
	{
		PropertyBinding.bind (advanced_binding_l1, "&", advanced_binding_r1, "&", BindFlags.SYNC_CREATE);

		PropertyAlias.get_instance("alias:text")
			.register (typeof(Gtk.Entry), "text")
			.register (typeof(Gtk.Label), "label");
		PropertyBinding.bind (advanced_binding_l2, "alias:text", advanced_binding_r2, "alias:text", BindFlags.SYNC_CREATE);


		advanced4 = PropertyBinding.bind (advanced_binding_l4, "&", advanced_binding_r4, "&", BindFlags.SYNC_CREATE);
		advanced_freeze1.toggled.connect (() => { toggle_freeze4 (advanced_freeze1); });
		advanced_freeze2.toggled.connect (() => { toggle_freeze4 (advanced_freeze2); });
		advanced_freeze3.toggled.connect (() => { toggle_freeze4 (advanced_freeze3); });
	}

	private void alias_example (Gtk.Builder ui_builder)
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

	private void pointer_storage_example (Gtk.Builder ui_builder)
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

	private void contract_storage_example (Gtk.Builder ui_builder)
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

	public void example4 (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example--pointer-set-data";
		// note the use of pointer storage here
		//
		// this allows avoiding local variable as pointer is accessible by name
		// and in this case this is solely for demo purpose
		PointerStorage.get_storage(_STORAGE_).add("example-pointer-set-data", new BindingPointer(john_doe));

		e4_set_1.toggled.connect (() => {
			if (e4_set_1.active == true)
				PointerStorage.get_storage(_STORAGE_).find("example-pointer-set-data").data = john_doe;
		});
		e4_set_2.toggled.connect (() => {
			if (e4_set_2.active == true)
				PointerStorage.get_storage(_STORAGE_).find("example-pointer-set-data").data = unnamed_person;
		});
		e4_set_3.toggled.connect (() => {
			if (e4_set_3.active == true)
				PointerStorage.get_storage(_STORAGE_).find("example-pointer-set-data").data = null;
		});

		bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("e4_events"), _e4_events);

		connect_binding_pointer_events (PointerStorage.get_storage(_STORAGE_).find("example-pointer-set-data"), _e4_events);
	}

	public void example5 (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example--contract-set-data";
		// note the use of contract storage here
		//
		// this allows avoiding local variable as pointer is accessible by name
		// and in this case this is solely for demo purpose
		ContractStorage.get_storage(_STORAGE_)
			.add("example-contract-storage-set-data", new BindingContract(john_doe))
				.bind ("name", ui_builder.get_object ("e5_name"), "label", BindFlags.SYNC_CREATE)
				.bind ("surname", ui_builder.get_object ("e5_surname"), "label", BindFlags.SYNC_CREATE);

		e5_set_1.toggled.connect (() => {
			if (e5_set_1.active == true)
				ContractStorage.get_storage(_STORAGE_).find("example-contract-storage-set-data").data = john_doe;
		});
		e5_set_2.toggled.connect (() => {
			if (e5_set_2.active == true)
				ContractStorage.get_storage(_STORAGE_).find("example-contract-storage-set-data").data = unnamed_person;
		});
		e5_set_3.toggled.connect (() => {
			if (e5_set_3.active == true)
				ContractStorage.get_storage(_STORAGE_).find("example-contract-storage-set-data").data = null;
		});

		bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("e5_events"), _e5_events);

		connect_binding_contract_events (ContractStorage.get_storage(_STORAGE_).find("example-contract-storage-set-data"), _e5_events);
	}

	public void example6 (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example-contract-chaining";
		// note the use of contract storage here
		//
		// this allows avoiding local variable as pointer is accessible by name
		// and in this case this is solely for demo purpose
		ContractStorage.get_storage(_STORAGE_)
			.add("main-contract", new BindingContract(john_doe))
				.bind ("name", ui_builder.get_object ("e6_name"), "label", BindFlags.SYNC_CREATE)
				.bind ("surname", ui_builder.get_object ("e6_surname"), "label", BindFlags.SYNC_CREATE);
		ContractStorage.get_storage(_STORAGE_)
			.add("sub-contract", new BindingContract(ContractStorage.get_storage(_STORAGE_).find("main-contract")))
				.bind ("required", ui_builder.get_object ("e6_required"), "label", BindFlags.SYNC_CREATE);

		e6_set_1.toggled.connect (() => {
			if (e6_set_1.active == true)
				ContractStorage.get_storage(_STORAGE_).find("main-contract").data = john_doe;
		});
		e6_set_2.toggled.connect (() => {
			if (e6_set_2.active == true)
				ContractStorage.get_storage(_STORAGE_).find("main-contract").data = unnamed_person;
		});
		e6_set_3.toggled.connect (() => {
			if (e6_set_3.active == true)
				ContractStorage.get_storage(_STORAGE_).find("main-contract").data = null;
		});

		bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("e6_events"), _e6_events);

		connect_binding_contract_events (ContractStorage.get_storage(_STORAGE_).find("sub-contract"), _e6_events);
	}

	public void example_v (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example-validation";
		BindingContract my_contract = ContractStorage.get_storage(_STORAGE_).add ("my-contract", new BindingContract());
		my_contract.bind ("name", ui_builder.get_object ("evo_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, null, null,
			((v) => {
				return ((string) v != "");
			}));
		my_contract.bind ("surname", ui_builder.get_object ("evo_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, null, null,
			((v) => {
				return ((string) v != "");
			}));
		my_contract.bind ("required", ui_builder.get_object ("evo_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);

		bind_person_model ((Gtk.ListBox) ui_builder.get_object ("evo_list"), persons, my_contract);

		PropertyBinding.bind(my_contract, "is_valid", ui_builder.get_object ("evo_b1"), "sensitive", BindFlags.SYNC_CREATE);
	}

	public void example_so (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example-state-objects";
		BindingContract my_contract = ContractStorage.get_storage(_STORAGE_).add ("my-contract", new BindingContract())
			.bind ("name", ui_builder.get_object ("eso_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.bind ("surname", ui_builder.get_object ("eso_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.bind ("required", ui_builder.get_object ("eso_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.contract;

		bind_person_model ((Gtk.ListBox) ui_builder.get_object ("eso_list"), persons, my_contract);

		// adding custom state value to contract
		my_contract.add_state (new CustomBindingSourceState ("validity", my_contract, ((src) => {
			return ((src.data != null) && (((Person) src.data).required != ""));
		}), new string[1] { "required" }));

		PropertyBinding.bind(my_contract.get_state_object("validity"), "state", ui_builder.get_object ("eso_b1"), "sensitive", BindFlags.SYNC_CREATE);
	}

	public void example_vo (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example-value-objects";
		BindingContract my_contract = ContractStorage.get_storage(_STORAGE_).add ("my-contract", new BindingContract())
			.bind ("name", ui_builder.get_object ("evvo_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.bind ("surname", ui_builder.get_object ("evvo_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.bind ("required", ui_builder.get_object ("evvo_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.contract;

		bind_person_model ((Gtk.ListBox) ui_builder.get_object ("evvo_list"), persons, my_contract);

		// adding custom value to contract
		my_contract.add_source_value (new CustomBindingSourceData<string> ("length", my_contract, 
			((src) => {
				return ("(cumulative of string lengths)=>%i".printf((src.data != null) ? ((Person) src.data).name.length + ((Person) src.data).surname.length + ((Person) src.data).required.length : 0));
			}), 
			((a,b) => { return ((a == b) ? 0 : 1); }), 
			"", false, ALL_PROPERTIES));

		// bind to binding value. note that value is updated whenever contract source changes or specified properties in respective class get changed
		// which makes it perfectly ok to use simple binding as this connection will be stable for whole contract life
		PropertyBinding.bind (my_contract.get_source_value ("length"), "data", ui_builder.get_object ("evvo_4"), "&", BindFlags.SYNC_CREATE, 
			(binding, srcval, ref targetval) => {
				targetval.set_string (((CustomBindingSourceData<string>) binding.source).data);
				return true;
			});
	}

	public void example_relay (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example-relay";
		BindingContract my_contract = ContractStorage.get_storage(_STORAGE_).add ("main-contract", new BindingContract());
		bind_person_model ((Gtk.ListBox) ui_builder.get_object ("e7_list"), persons, my_contract);

		BindingPointer infoptr = my_contract.hold (new BindingPointerFromPropertyValue (my_contract, "info"));
		BindingPointer parentptr = my_contract.hold (new BindingPointerFromPropertyValue (my_contract, "parent"));

		BindingContract info_contract = ContractStorage.get_storage(_STORAGE_).add ("info-contract", new BindingContract(infoptr));
		BindingContract parent_contract = ContractStorage.get_storage(_STORAGE_).add ("parent-contract", new BindingContract(parentptr));

		my_contract.bind ("name", ui_builder.get_object ("e7_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.bind ("surname", ui_builder.get_object ("e7_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.bind ("required", ui_builder.get_object ("e7_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);

		info_contract.bind ("some_num", ui_builder.get_object ("e7_s1_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);

		parent_contract.bind ("name", ui_builder.get_object ("e7_s2_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.bind ("surname", ui_builder.get_object ("e7_s2_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
			.bind ("required", ui_builder.get_object ("e7_s2_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);

		PropertyBinding.bind(parent_contract, "is-valid", ui_builder.get_object ("e7_s2_g"), "visible", BindFlags.SYNC_CREATE);

		bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("e7_events"), _e7_events);
		connect_binding_contract_events (parent_contract, _e7_events);
	}

	public void example_inspector (Gtk.Builder ui_builder)
	{
		//test references
/*		BindingContract my_contract = new BindingContract();
		stdout.printf ("\t\tDirect ref_count:%i\n", (int)my_contract.ref_count);
		debug_references ("after create", my_contract);*/
		((Gtk.Button) ui_builder.get_object ("show_inspector")).clicked.connect (() =>{
			GDataGtk.BindingInspector.show(null);
		});
		((Gtk.Button) ui_builder.get_object ("show_inspector_with_target")).clicked.connect (() =>{
		StrictWeakRef my_contract = new StrictWeakRef (ContractStorage.get_storage("main-example").find ("main-contract"));
		_debug_references ("main contract", my_contract);
		debug_references ("_main contract", as_contract(my_contract.target));
		stdout.printf ("%i\n", (int)my_contract.target.ref_count);
		stdout.printf ("%i\n", (int)persons.data[0].ref_count);
		stdout.printf ("%i\n", (int)persons.data[1].ref_count);
		stdout.printf ("%i\n", (int)persons.data[2].ref_count);
			GDataGtk.BindingInspector.show(ContractStorage.get_storage("main-example").find ("main-contract"));
		});
	}
}
