using GData;
using GData.Generics;
using GDataGtk;

namespace DemoAddressBook
{
	[GtkTemplate (ui="/org/gtk/demo_address_book/main_window.ui")]
	public class MainWindow : Gtk.Window
	{
		[GtkChild] private Gtk.ListBox address_list;
		[GtkChild] private Gtk.Stack address_stack;
		[GtkChild] private Gtk.Box no_address;
		[GtkChild] private Gtk.Box address_page_box;
		[GtkChild] private Gtk.Box address_editor;
		[GtkChild] private Gtk.Box editor_contents;
		[GtkChild] private Gtk.Box new_person_buttons_box;
		[GtkChild] private Gtk.Button cancel_new_contact;
		[GtkChild] private Gtk.Button add_contact_button;
		[GtkChild] private Gtk.Button add_button;
		[GtkChild] private Gtk.Button remove_button;
		[GtkChild] private Gtk.Button edit_button;
		[GtkChild] private Gtk.Button explore_contract;
		[GtkChild] private Gtk.Button explore_selected_object;
		[GtkChild] private Gtk.Entry search_entry;

		private Contact ct;
		private ObjectArray<Contact> _contacts = new ObjectArray<Contact>();
		private BindingContract _editing_contract = new BindingContract();
		private Binder _binder = new GData.Binder.silent();
		private GtkBuildableMapper _mapper = new GDataGtk.GtkBuildableMapper();
		private GtkBuildableContractMapper _cmapper = new GDataGtk.GtkBuildableContractMapper();
		private EditModeControl _edit_control = new EditModeControl (EditMode.VIEW);
		private ProxyPropertyGroup _edit_condition = new ProxyPropertyGroup();

		private string _current_search = "";
		public string current_search { 
			get { return (_current_search); }
			set {
				_current_search = value;
				_apply_search();
			}
		}

		private void _apply_search()
		{
			address_list.@foreach ((w) => {
				SmoothListBoxRow r = (SmoothListBoxRow) w;
				r.revealed = ((Contact) r.object).full_name.down().contains(current_search.down());
			});
		}

		public MainWindow()
		{
			no_address.add (new Placeholder.from_icon("No data selected")); // this could as well be designed in Glade, it is just Placeholder widget demonstration
			SizeGroupCollection sz = new SizeGroupCollection (address_list, Gtk.SizeGroupMode.HORIZONTAL);
			address_list.bind_model (_contacts, (o) => {
				SmoothListBoxRow row = new SmoothListBoxRow(o);
				AutoContainerValues auto_container = new AutoContainerValues(EditMode.VIEW);
				auto_container.visible = true;
				auto_container.create_type_layout (typeof(Contact), new string[2] { "full-name", "city" }, "property_", "", sz);
				_binder.set_mapper (_mapper)
					.map (o, auto_container, BindFlags.SYNC_CREATE, "property_");
				row.visible = true;
				row.get_container().add (auto_container);
				return (row);
			});
			address_list.row_selected.connect ((r) => {
				if ((r != null) && (_editing_contract.data == ((SmoothListBoxRow) r).object))
					return;
				_editing_contract.data = (r != null) ? ((SmoothListBoxRow) r).object : null;
				_edit_control.mode = EditMode.VIEW;
			});
			address_list.row_activated.connect ((r) => {
				_editing_contract.data = ((SmoothListBoxRow) r).object;
				_edit_control.mode = EditMode.EDIT;
			});

			AutoContainerModeValues auto_editor = new AutoContainerModeValues(EditMode.VIEW);
			auto_editor.set_mode_control (_edit_control);
			auto_editor.visible = true;
			editor_contents.pack_start (auto_editor);
			auto_editor.create_type_layout (typeof(Contact), ALL_PROPERTIES, "property_");
			_editing_contract.set_mapper (_cmapper)
				.map (typeof(Contact), auto_editor, BindFlags.SYNC_CREATE|BindFlags.CONDITIONAL_BIDIRECTIONAL, "property_");

			_binder.bind (this, "current-search", search_entry, "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL | BindFlags.DELAYED);
			_edit_condition.add_property ("data", _editing_contract, "data", GLib.Value(typeof(Object)));
			_edit_condition.add_property ("mode", _edit_control, "mode", GLib.Value(typeof(EditMode)));
			_edit_condition.value_changed.connect (() => {
				address_stack.visible_child = (_editing_contract.data != null) ? address_page_box : no_address;
				add_button.sensitive = (_edit_control.mode == EditMode.VIEW);
				remove_button.sensitive = ((_editing_contract.data != null) && (_edit_control.mode == EditMode.VIEW));
				edit_button.sensitive = ((_editing_contract.data != null) && (_edit_control.mode == EditMode.VIEW));
				explore_selected_object.sensitive = ((_editing_contract.data != null) && (_edit_control.mode == EditMode.VIEW));
				new_person_buttons_box.visible = ((_editing_contract.data != null) && (_editing_contract.data == ct));
			});
			_edit_condition.value_changed(); // trigger proxy property group event
			_editing_contract.add_state (new CustomBindingSourceState ("validity", _editing_contract, "Contact name validity", ((src) => {
				return ((src.data != null) && (((Contact) src.data).first_name != "") && (((Contact) src.data).last_name != ""));
			}), new string[2] { "first-name", "last-name" }));
			_binder.bind (_editing_contract.get_state_object("validity"), "state", add_contact_button, "sensitive", BindFlags.SYNC_CREATE);

			add_button.clicked.connect (() => {
				ct = new Contact();
				_editing_contract.data = ct;
				_edit_control.mode = EditMode.EDIT;
			});
			remove_button.clicked.connect (() => { _contacts.remove ((Contact) ((SmoothListBoxRow) address_list.get_selected_row()).object); });
			edit_button.clicked.connect (() => { _edit_control.mode = EditMode.EDIT; });
			add_contact_button.clicked.connect (() => { 
				_contacts.add ((Contact) _editing_contract.get_source()); 
				_editing_contract.data = (address_list.get_selected_row() != null) ? ((SmoothListBoxRow) address_list.get_selected_row()).object : null;;
				_edit_control.mode = EditMode.VIEW;
			});
			cancel_new_contact.clicked.connect (() => {
				_editing_contract.data = (address_list.get_selected_row() != null) ? ((SmoothListBoxRow) address_list.get_selected_row()).object : null;
				_edit_control.mode = EditMode.VIEW;
			});

			explore_contract.clicked.connect (() => { GDataGtk.BindingInspector.show(_editing_contract); });
			explore_selected_object.clicked.connect (() => { GDataGtk.ObjectInspector.add_object(((SmoothListBoxRow) address_list.get_selected_row()).object); });
		}
	}
}

