using GData;
using GData.Generics;
using GDataGtk;

namespace Demo
{
	internal void example_contract_chaining (DemoAndTutorial demo, Gtk.Builder ui_builder, EventArray events)
	{
		string _STORAGE_ = "example_contract_chaining";
		string _MAIN_CONTRACT_ = "main-contract";
		string _SUB_CONTRACT_ = "sub-contract";
		/* 
		 * note the use of contract storage here
		 * 
		 * this allows avoiding local variable as pointer is accessible by name
		 * and in this case this is solely for demo purpose
		 */
		// create and register main contract then bind.
		BindingContract main_contract = ContractStorage.get_storage(_STORAGE_)
			.add(_MAIN_CONTRACT_, new BindingContract(john_doe))
				.bind ("name", ui_builder.get_object ("e6_name"), "label", BindFlags.SYNC_CREATE)
				.bind ("surname", ui_builder.get_object ("e6_surname"), "label", BindFlags.SYNC_CREATE)
				.contract;
		// create and register sub contract then bind.
		BindingContract sub_contract = ContractStorage.get_storage(_STORAGE_)
			.add(_SUB_CONTRACT_, new BindingContract(main_contract))
				.bind ("required", ui_builder.get_object ("e6_required"), "label", BindFlags.SYNC_CREATE)
				.contract;

		// assign "data" to main contract whenever radio button is pressed
		((Gtk.ToggleButton) ui_builder.get_object ("e6_set_1")).toggled.connect (() => {
			if (((Gtk.ToggleButton) ui_builder.get_object ("e6_set_1")).active == true)
				main_contract.data = john_doe;
		});
		((Gtk.ToggleButton) ui_builder.get_object ("e6_set_2")).toggled.connect (() => {
			if (((Gtk.ToggleButton) ui_builder.get_object ("e6_set_2")).active == true)
				main_contract.data = unnamed_person;
		});
		((Gtk.ToggleButton) ui_builder.get_object ("e6_set_3")).toggled.connect (() => {
			if (((Gtk.ToggleButton) ui_builder.get_object ("e6_set_3")).active == true)
				main_contract.data = null;
		});

		bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("e6_events"), events);

		events.resource = sub_contract;
	}
}
