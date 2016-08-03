using GData;
using GData.Generics;

namespace GData
{
	public static string get_info_str (ObjectInformation? obj)
	{
		return ((obj == null) ? _null() : "[%s]->\"%s\"".printf(green(obj.get_type().name()), obj.get_info()));
	}

	public static string get_pointer_info_str (BindingPointer? obj)
	{
		return ((obj == null) ? _null() : "[%s]->\"%s\"".printf(green(obj.get_type().name()), (obj.data != null) ? obj.data.get_type().name() : _null()));
	}

	public static string _null()
	{
		return ("[%s]".printf(bold(red("null"))));
	}

	public static string color (string color, string str)
	{
		return ("<span color='%s'>%s</span>".printf(color, str));
	}

	public static string green (string str)
	{
		return (color ("green", str));
	}

	public static string red (string str)
	{
		return (color ("red", str));
	}

	public static string yellow (string str)
	{
		return (color ("yellow", str));
	}

	public static string blue (string str)
	{
		return (color ("blue", str));
	}

	public static string italic (string str)
	{
		return ("<i>%s</i>".printf(str));
	}

	public static string bold (string str)
	{
		return ("<b>%s</b>".printf(str));
	}
}

// note that this interface is in no way required for databinding
// its whole purpose is having uniform way of displaying events
// for this demo in order to be able to propagate more descriptive
// events
public interface ObjectInformation : Object
{
	public abstract string get_info();
}

public class PersonInfo : Object, ObjectInformation
{
	public int some_num { get; set; }

	public string get_info()
	{
		return ("some_num=%i".printf(some_num));
	}

	public PersonInfo (int num)
	{
		some_num = num;
	}
}

public class Person : Object, ObjectInformation
{
	public string name { get; set; }
	public string surname { get; set; }
	public string required { get; set; }

	public PersonInfo info { get; set; }
	private Person? _parent = null;
	public Person? parent { 
		get { return (_parent); }
		set { _parent = value; }
	}

	public string get_info()
	{
		return (fullname());
	}

	public string fullname()
	{
		return ("%s %s".printf(name, surname));
	}

	public Person (string name, string surname, string required = "")
	{
		this.name = name;
		this.surname = surname;
		this.required = required;
		info = new PersonInfo((int) GLib.Random.int_range(1,10));
	}
}

public class EventDescription : Object
{
	public string title { get; private set; }
	public string description { get; private set; }

	public EventDescription.custom (string event_type, string name, string title, string description)
	{
		this ("<span color='red'>%s</span> <b>%s</b> %s".printf(event_type, name, title), "<small><i>%s</i></small>".printf(description));
	}

	public EventDescription.as_signal (string name, string title, string description)
	{
		this.custom ("signal", name, title, description);
	}

	public EventDescription.as_property (string name, string title)
	{
		this.custom ("property", name, title, yellow("\tproperty %s value has changed".printf (bold(green(name)))));
	}

	public EventDescription (string title, string description)
	{
		this.title = title;
		this.description = description;
	}
}

// only for purpose of accessing contract trough gtk-inspector
public class BindingListBoxRow : Gtk.ListBoxRow
{
	public BindingContract contract {
		get { return (get_data<BindingContract>("binding-contract")); }
	}
}

public class test_data_bindings : Gtk.Application
{
	private string _title_css = """
		* {
			border: solid 2px gray;
			padding: 4px 4px 4px 4px;
			border-radius: 5px;
			color: rgba (255,255,255,0.7);
			background-color: rgba(0,0,0,0.09);
		}
	""";

	private string _dark_label_css = """
		* {
			border-radius: 5px;
			padding: 4px 4px 4px 4px;
			color: rgba (255,255,255,0.7);
			background-color: rgba(0,0,0,0.2);
		}
	""";

	private string _warning_label_css = """
		* {
			border: solid 1px rgba (0,0,0,1);
			padding: 4px 4px 4px 4px;
			border-radius: 5px;
			color: rgba (255,255,255,0.7);
			background-color: rgba(255,0,0,0.05);
		}
	""";

	private ObjectArray<Person> _persons = new ObjectArray<Person>();
	public ObjectArray<Person> persons {
		get { return (_persons); }
	}

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

	private Person john_doe = new Person("John", "Doe", "ABC");
	private Person unnamed_person = new Person("Unnamed", "Person", "DEF");

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

	public Gtk.CssProvider? assign_css (Gtk.Widget? widget, string css_content)
		requires (widget != null)
	{
		Gtk.CssProvider provider = new Gtk.CssProvider();
		try {
			provider.load_from_data(css_content, css_content.length);
			Gtk.StyleContext style = widget.get_style_context();
			style.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
		}
		catch (Error e) { print ("Could not load CSS. %s\n", e.message); }
		return (provider);
	}

	public void assign_builder_css (Gtk.Builder ui_builder, string widget_name, string css)
	{
		string wname = widget_name;
		Gtk.Widget w = (Gtk.Widget) ui_builder.get_object (wname);
		while (w != null) {
			assign_css (w, css);
			wname += "_";
			w = (Gtk.Widget) ui_builder.get_object (wname);
		}
	}

	public test_data_bindings ()
	{
		Object (flags: ApplicationFlags.FLAGS_NONE);
	}

	private void bind_person_model (Gtk.ListBox listbox, GLib.ListModel model, BindingPointer pointer)
	{
		listbox.bind_model (model, ((o) => {
			Gtk.ListBoxRow r = new BindingListBoxRow();
			r.set_data<WeakReference<Person?>>("person", new WeakReference<Person?>((Person) o));
			r.visible = true;
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
			box.visible = true;
			r.add (box);
			Gtk.Label name = new Gtk.Label("");
			name.visible = true;
			Gtk.Label surname = new Gtk.Label("");
			surname.visible = true;
			box.pack_start (name);
			box.pack_start (surname);

			// This would be much more suitable in this use case
			PropertyBinding.bind (o, "name", name, "label", BindFlags.SYNC_CREATE);
			PropertyBinding.bind (o, "surname", surname, "label", BindFlags.SYNC_CREATE);
			return (r);
		}));
		listbox.row_selected.connect ((r) => {
			pointer.data = (r != null) ? (r.get_data<WeakReference<Person?>>("person")).target : null;
		});
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
			ui_builder.add_from_file ("./interface.ui");
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

		persons.add (new Person("John", "Doe"));
		persons.add (new Person("Somebody", "Nobody"));
		persons.add (new Person("Intentionally_Invalid_State", "", "Nobody"));
		persons.data[0].parent = persons.data[1];
		persons.data[2].parent = persons.data[0];

		main_demo (ui_builder);
stdout.printf ("example\n");
		example1(ui_builder);
stdout.printf ("example\n");
		example2(ui_builder);
stdout.printf ("example\n");
		example3(ui_builder);
stdout.printf ("example\n");
		alias_example(ui_builder);
stdout.printf ("example\n");
		pointer_storage_example(ui_builder);
stdout.printf ("example\n");
		contract_storage_example(ui_builder);
stdout.printf ("example\n");
		example4(ui_builder);
stdout.printf ("example\n");
		example5(ui_builder);
stdout.printf ("example\n");
		example6(ui_builder);
stdout.printf ("example\n");
		example_v(ui_builder);
stdout.printf ("example\n");
		example_so(ui_builder);
stdout.printf ("example\n");
		example_vo(ui_builder);
stdout.printf ("example\n");
		example_relay(ui_builder);
stdout.printf ("example\n");
	}

	public void main_demo (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "main-example";
		BindingContract selection_contract = ContractStorage.get_storage(_STORAGE_).add ("main-contract", new BindingContract(null));
		selection_contract.bind ("name", name, "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, null, null,
			((v) => {
				return ((string) v != "");
			}));
		selection_contract.bind ("surname", surname, "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, null, null,
			((v) => {
				return ((string) v != "");
			}));
		selection_contract.bind ("required", required, "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
		
		// chaining contract as source
		BindingContract chain_contract = ContractStorage.get_storage(_STORAGE_).add ("chain-contract", new BindingContract(selection_contract));
		chain_contract.bind ("name", name_chain, "label", BindFlags.SYNC_CREATE);
		chain_contract.bind ("surname", surname_chain, "label", BindFlags.SYNC_CREATE);

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

		required_not_empty = (Gtk.Button) ui_builder.get_object ("required_not_empty");
		is_valid_source = (Gtk.Button) ui_builder.get_object ("is_valid_source");

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

		BindingContract info_contract = ContractStorage.get_storage(_STORAGE_).add ("info-contract", new BindingContract(infoptr));
		BindingContract parent_contract = ContractStorage.get_storage(_STORAGE_).add ("parent-contract", new BindingContract(parentptr));

		info_contract.bind ("some_num", ui_builder.get_object ("e1_s1_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);

		parent_contract.bind ("name", ui_builder.get_object ("e1_s2_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
		parent_contract.bind ("surname", ui_builder.get_object ("e1_s2_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
		parent_contract.bind ("required", ui_builder.get_object ("e1_s2_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);

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
		basic_entry_left = (Gtk.Entry) ui_builder.get_object ("basic_entry_left");
		basic_entry_right = (Gtk.Entry) ui_builder.get_object ("basic_entry_right");
		PropertyBinding.bind (basic_entry_left, "text", basic_entry_right, "text", BindFlags.SYNC_CREATE);

		basic_entry_left2 = (Gtk.Entry) ui_builder.get_object ("basic_entry_left2");
		basic_entry_right2 = (Gtk.Entry) ui_builder.get_object ("basic_entry_right2");
		PropertyBinding.bind (basic_entry_left2, "text", basic_entry_right2, "text", BindFlags.BIDIRECTIONAL | BindFlags.SYNC_CREATE);

		basic_label_left3 = (Gtk.Label) ui_builder.get_object ("basic_label_left3");
		basic_entry_right3 = (Gtk.Entry) ui_builder.get_object ("basic_entry_right3");
		PropertyBinding.bind (basic_label_left3, "label", basic_entry_right3, "text", BindFlags.REVERSE_DIRECTION | BindFlags.SYNC_CREATE);

		basic_label_right4 = (Gtk.Label) ui_builder.get_object ("basic_label_right4");
		PropertyBinding basic4 = PropertyBinding.bind (this, "counter", basic_label_right4, "label", BindFlags.FLOOD_DETECTION | BindFlags.SYNC_CREATE);
		basic4.flood_detected.connect (flooded);
		basic4.flood_stopped.connect (flood_over);
		basic_flood_data_btn = (Gtk.ToggleButton) ui_builder.get_object ("basic_flood_data_btn");
		basic_flood_data_btn.toggled.connect (() => {
			if (basic_flood_data_btn.active == true)
				GLib.Timeout.add (20, flood_timer, GLib.Priority.DEFAULT);
		});

		basic_entry_left5 = (Gtk.Entry) ui_builder.get_object ("basic_entry_left5");
		basic_label_right5 = (Gtk.Label) ui_builder.get_object ("basic_label_right5");
		PropertyBinding basic5 = PropertyBinding.bind (basic_entry_left5, "text", basic_label_right5, "label", BindFlags.MANUAL_UPDATE | BindFlags.SYNC_CREATE);
		basic_transfer_data_btn = (Gtk.Button) ui_builder.get_object ("basic_transfer_data_btn");
		basic_transfer_data_btn.clicked.connect (() => {
			basic5.update_from_source();
		});

		basic_entry_left6 = (Gtk.Entry) ui_builder.get_object ("basic_entry_left6");
		basic_entry_right6 = (Gtk.Entry) ui_builder.get_object ("basic_entry_right6");
		PropertyBinding.bind (basic_entry_left6, "text", basic_entry_right6, "text", BindFlags.BIDIRECTIONAL | BindFlags.SYNC_CREATE | BindFlags.DELAYED);
	}

	public void example2 (Gtk.Builder ui_builder)
	{
		custom_binding_l1 = (Gtk.Entry) ui_builder.get_object ("custom_binding_l1");
		custom_binding_r1 = (Gtk.Label) ui_builder.get_object ("custom_binding_r1");
		PropertyBinding.bind (custom_binding_l1, "text", custom_binding_r1, "label", BindFlags.SYNC_CREATE, ((b, src, ref tgt) => {
				tgt.set_string("value=" + src.get_string());
				return (true);
		}));

		custom_binding_l2 = (Gtk.Entry) ui_builder.get_object ("custom_binding_l2");
		custom_binding_r2 = (Gtk.Entry) ui_builder.get_object ("custom_binding_r2");
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

		custom_binding_l3 = (Gtk.Entry) ui_builder.get_object ("custom_binding_l3");
		custom_binding_r3 = (Gtk.ToggleButton) ui_builder.get_object ("custom_binding_r3");
		PropertyBinding.bind (custom_binding_l3, "text", custom_binding_r3, "active", BindFlags.SYNC_CREATE);

		custom_binding_l4 = (Gtk.Entry) ui_builder.get_object ("custom_binding_l4");
		custom_binding_r4 = (Gtk.ToggleButton) ui_builder.get_object ("custom_binding_r4");
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
		advanced_binding_l1 = (Gtk.Entry) ui_builder.get_object ("advanced_binding_l1");
		advanced_binding_r1 = (Gtk.Label) ui_builder.get_object ("advanced_binding_r1");
		PropertyBinding.bind (advanced_binding_l1, "&", advanced_binding_r1, "&", BindFlags.SYNC_CREATE);

		advanced_binding_l2 = (Gtk.Entry) ui_builder.get_object ("advanced_binding_l2");
		advanced_binding_r2 = (Gtk.Label) ui_builder.get_object ("advanced_binding_r2");
		PropertyAlias.get_instance("alias:text")
			.register (typeof(Gtk.Entry), "text")
			.register (typeof(Gtk.Label), "label");
		PropertyBinding.bind (advanced_binding_l2, "alias:text", advanced_binding_r2, "alias:text", BindFlags.SYNC_CREATE);

		advanced_binding_l3 = (Gtk.Entry) ui_builder.get_object ("advanced_binding_l3");
		advanced_binding_r3 = (Gtk.Label) ui_builder.get_object ("advanced_binding_r3");

		advanced_binding_l4 = (Gtk.Entry) ui_builder.get_object ("advanced_binding_l4");
		advanced_binding_r4 = (Gtk.Label) ui_builder.get_object ("advanced_binding_r4");
		advanced4 = PropertyBinding.bind (advanced_binding_l4, "&", advanced_binding_r4, "&", BindFlags.SYNC_CREATE);
		advanced_freeze1 = (Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze1");
		advanced_freeze1.toggled.connect (() => { toggle_freeze4 (advanced_freeze1); });
		advanced_freeze2 = (Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze2");
		advanced_freeze2.toggled.connect (() => { toggle_freeze4 (advanced_freeze2); });
		advanced_freeze3 = (Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze3");
		advanced_freeze3.toggled.connect (() => { toggle_freeze4 (advanced_freeze3); });
	}

	private delegate string GetKeyValueString (Object obj);

	private void bind_kv_listbox<MK, K, V> (Gtk.ListBox listbox, GLib.ListModel events, GetKeyValueString method, bool sublist)
	{
		listbox.bind_model ((GLib.ListModel) events, ((o) => {
			Gtk.ListBoxRow r = new BindingListBoxRow();
			if (sublist == true)
				r.set_data<GLib.ListModel> ("sublist", ((KeyValuePair<MK, KeyValueArray<K, V>>) o).val);
			r.visible = true;
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
			box.expand = true;
			box.visible = true;
			r.add (box);
			Gtk.Label title = new Gtk.Label("");
			title.visible = true;
			title.hexpand = true;
			title.xalign = 0;
			title.use_markup = true;
			title.set_markup(method(o));
			box.pack_start (title, false, false, 0);
			return (r);
		}));
	}

	private void on_master_selected<MK,K,V> (Gtk.ListBox list_box, Gtk.ListBox slave_list_box, GetKeyValueString method)
	{
		list_box.row_selected.connect ((row) => {
			bind_kv_listbox<MK, K, V>(
				slave_list_box,
				(row == null) ? new ObjectArray<Object>() : row.get_data<GLib.ListModel>("sublist"),
				method,
				false);
		});
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

	private void bind_event_listbox (Gtk.ListBox listbox, ObjectArray<EventDescription> events)
	{
		listbox.bind_model (events, ((o) => {
			Gtk.ListBoxRow r = new BindingListBoxRow();
			r.visible = true;
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
			box.expand = true;
			box.visible = true;
			r.add (box);
			Gtk.Label title = new Gtk.Label("");
			title.visible = true;
			title.hexpand = true;
			title.xalign = 0;
			title.use_markup = true;
			title.set_markup(((EventDescription) o).title);
			Gtk.Label description = new Gtk.Label("");
			description.visible = true;
			description.use_markup = true;
			description.hexpand = true;
			description.xalign = 0;
			description.set_markup(((EventDescription) o).description);
			box.pack_start (title, false, false, 0);
			box.pack_start (description, false, false, 0);
			return (r);
		}));
	}

	private string get_current_source (Object? obj)
	{
		return ("\n\t\t%s".printf(_get_current_source(obj)));
	}

	private string _get_current_source (Object? obj)
	{
		return ("currently pointing => %s".printf (__get_current_source (obj)));
	}

	private string __get_current_source (Object? obj)
	{
		if (is_binding_pointer(obj) == true)
			return ("%s".printf (get_pointer_info_str((BindingPointer?) obj)));
		else
			// demo only uses ObjectInformation so this is safe
			return ("%s".printf (get_info_str((ObjectInformation?) obj)));
	}

	private void connect_binding_pointer_events (BindingPointer pointer, ObjectArray<EventDescription> events)
	{
		pointer.data_changed.connect ((binding, cookie) => {
			events.add (
				new EventDescription.as_signal (
					"data_changed", 
					"(binding=%s, data_change_cookie=%s)".printf ((binding == pointer) ? "THIS" : "OTHER", cookie),
					yellow("\tSource object change notification. Note that this is event triggered from outside when BindingPointer is MANUAL\n") +
					"\t\tbinding (BindingPointer emiting the notification)\n" +
					"\t\tdata_change_cookie (description of data change as passed on by triggering event)" +
					get_current_source (binding.get_source())
				)
			);
		});
		pointer.before_source_change.connect ((binding, is_same, next) => {
			events.add (
				new EventDescription.as_signal (
					"before_source_change", 
					"(binding=%s, is_same=%i, next=%s)".printf ((binding == pointer) ? "THIS" : "OTHER", (int) is_same, (next != null) ? ((Person) next).fullname() : _null()),
					yellow("\tObject being pointed is about to change. In case if reference was not dropped it can still be accessed trough binding\n") +
					"\t\tbinding (BindingPointer emiting the notification)\n" +
					"\t\tis_same (specifies if type of next source being pointed to is the same)\n" +
					"\t\tnext (reference to next object being pointed to)" +
					get_current_source (binding.get_source())
				)
			);
		});
		pointer.source_changed.connect ((binding) => {
			events.add (
				new EventDescription.as_signal (
					"source_changed", 
					"(binding=%s)".printf((binding == pointer) ? "THIS" : "OTHER"),
					yellow("\tObject being pointed has changed.\n") +
					"\t\tbinding (BindingPointer emiting the notification)" +
					get_current_source (binding.get_source())
				)
			);
		});
		pointer.connect_notifications.connect ((obj) => {
			events.add (
				new EventDescription.as_signal (
					"connect_notifications", 
					"(obj = %s)".printf (__get_current_source (obj)),
					yellow("\tSignal to connect anything application needs connected beside basic requirements when data source changes.")
				)
			);
		});
		pointer.disconnect_notifications.connect ((obj) => {
			events.add (
				new EventDescription.as_signal (
					"disconnect_notifications", 
					"(obj = %s)".printf (__get_current_source (obj)),
					yellow("\tSignal to disconnect anything application needs connected beside basic requirements when data source changes.")
				)
			);
		});
		pointer.notify["data"].connect ((binding) => {
			events.add (
				new EventDescription.as_property (
					"data", 
					" = %s => %s".printf (__get_current_source (pointer.data), _get_current_source (pointer.get_source()))
				)
			);
		});
	}

	private void connect_binding_contract_events (BindingContract contract, ObjectArray<EventDescription> events)
	{
		connect_binding_pointer_events (contract, events);

		contract.contract_changed.connect ((ccontract) => {
			events.add (
				new EventDescription.as_signal (
					"contract_changed", 
					"(contract=%s)".printf((ccontract == contract) ? "THIS" : "OTHER"),
					yellow("\tEmited when contract is disolved or renewed after source change.\n") +
					"\t\tcontract (BindingContract emiting the notification)" +
					get_current_source (contract.get_source())
				)
			);
		});
		contract.bindings_changed.connect ((ccontract, change_type, binding) => {
			events.add (
				new EventDescription.as_signal (
					"bindings_changed", 
					"(contract=%s, change_type=%s, binding)".printf((ccontract == contract) ? "THIS" : "OTHER", (change_type == ContractChangeType.ADDED) ? "ADDED" : "REMOVED"),
					yellow("\tEmited when bindings are changed by adding or removing.\n") +
					"\t\tcontract (BindingContract emiting the notification)\n" +
					"\t\tchange_type (binding ADDED or REMOVED)\n" +
					"\t\tbinding (BindingContract emiting the notification)" +
					get_current_source (contract.get_source())
				)
			);
		});
		contract.notify["is-valid"].connect ((c) => {
			events.add (
				new EventDescription.as_property (
					"is_valid", 
					" = %s".printf ((contract.is_valid == true) ? "TRUE" : "FALSE")
				)
			);
		});
		contract.notify["length"].connect ((c) => {
			events.add (
				new EventDescription.as_property (
					"is_valid", 
					" = %i".printf ((int) contract.length)
				)
			);
		});
		contract.notify["suspended"].connect ((c) => {
			events.add (
				new EventDescription.as_property (
					"is_valid", 
					" = %s".printf ((contract.suspended == true) ? "TRUE" : "FALSE")
				)
			);
		});
	}

	public void example4 (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example--pointer-set-data";
		// note the use of pointer storage here
		//
		// this allows avoiding local variable as pointer is accessible by name
		// and in this case this is solely for demo purpose
		PointerStorage.get_storage(_STORAGE_).add("example-pointer-set-data", new BindingPointer(john_doe));

		e4_set_1 = (Gtk.CheckButton) ui_builder.get_object ("e4_set_1");
		e4_set_1.toggled.connect (() => {
			if (e4_set_1.active == true)
				PointerStorage.get_storage(_STORAGE_).find("example-pointer-set-data").data = john_doe;
		});
		e4_set_2 = (Gtk.CheckButton) ui_builder.get_object ("e4_set_2");
		e4_set_2.toggled.connect (() => {
			if (e4_set_2.active == true)
				PointerStorage.get_storage(_STORAGE_).find("example-pointer-set-data").data = unnamed_person;
		});
		e4_set_3 = (Gtk.CheckButton) ui_builder.get_object ("e4_set_3");
		e4_set_3.toggled.connect (() => {
			if (e4_set_3.active == true)
				PointerStorage.get_storage(_STORAGE_).find("example-pointer-set-data").data = null;
		});

		bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("e4_events"), _e4_events);

		connect_binding_pointer_events (PointerStorage.get_default().find("example-pointer-set-data"), _e4_events);
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

		e5_set_1 = (Gtk.CheckButton) ui_builder.get_object ("e5_set_1");
		e5_set_1.toggled.connect (() => {
			if (e5_set_1.active == true)
				ContractStorage.get_storage(_STORAGE_).find("example-contract-storage-set-data").data = john_doe;
		});
		e5_set_2 = (Gtk.CheckButton) ui_builder.get_object ("e5_set_2");
		e5_set_2.toggled.connect (() => {
			if (e5_set_2.active == true)
				ContractStorage.get_storage(_STORAGE_).find("example-contract-storage-set-data").data = unnamed_person;
		});
		e5_set_3 = (Gtk.CheckButton) ui_builder.get_object ("e5_set_3");
		e5_set_3.toggled.connect (() => {
			if (e5_set_3.active == true)
				ContractStorage.get_storage(_STORAGE_).find("example-contract-storage-set-data").data = null;
		});

		bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("e5_events"), _e5_events);

		connect_binding_contract_events (ContractStorage.get_default().find("example-contract-storage-set-data"), _e5_events);
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

		e6_set_1 = (Gtk.CheckButton) ui_builder.get_object ("e6_set_1");
		e6_set_1.toggled.connect (() => {
			if (e6_set_1.active == true)
				ContractStorage.get_storage(_STORAGE_).find("main-contract").data = john_doe;
		});
		e6_set_2 = (Gtk.CheckButton) ui_builder.get_object ("e6_set_2");
		e6_set_2.toggled.connect (() => {
			if (e6_set_2.active == true)
				ContractStorage.get_storage(_STORAGE_).find("main-contract").data = unnamed_person;
		});
		e6_set_3 = (Gtk.CheckButton) ui_builder.get_object ("e6_set_3");
		e6_set_3.toggled.connect (() => {
			if (e6_set_3.active == true)
				ContractStorage.get_storage(_STORAGE_).find("main-contract").data = null;
		});

		bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("e6_events"), _e6_events);

		connect_binding_contract_events (ContractStorage.get_storage("example-contract-chaining").find("sub-contract"), _e6_events);
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
		BindingContract my_contract = ContractStorage.get_storage(_STORAGE_).add ("my-contract", new BindingContract());
		bind_person_model ((Gtk.ListBox) ui_builder.get_object ("eso_list"), persons, my_contract);

		my_contract.bind ("name", ui_builder.get_object ("eso_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
		my_contract.bind ("surname", ui_builder.get_object ("eso_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
		my_contract.bind ("required", ui_builder.get_object ("eso_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);

		// adding custom state value to contract
		my_contract.add_state (new CustomBindingSourceState ("validity", my_contract, ((src) => {
			return ((src.data != null) && (((Person) src.data).required != ""));
		}), new string[1] { "required" }));

		PropertyBinding.bind(my_contract.get_state_object("validity"), "state", ui_builder.get_object ("eso_b1"), "sensitive", BindFlags.SYNC_CREATE);
	}

	public void example_vo (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example-value-objects";
		BindingContract my_contract = ContractStorage.get_storage(_STORAGE_).add ("my-contract", new BindingContract());
		bind_person_model ((Gtk.ListBox) ui_builder.get_object ("evvo_list"), persons, my_contract);

		my_contract.bind ("name", ui_builder.get_object ("evvo_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
		my_contract.bind ("surname", ui_builder.get_object ("evvo_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
		my_contract.bind ("required", ui_builder.get_object ("evvo_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);

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
}
