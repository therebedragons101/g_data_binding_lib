using GData;
using GData.Generics;
using GDataGtk;

namespace Demo
{
	internal void example_contract_set_data (DemoAndTutorial demo, Gtk.Builder ui_builder, EventArray events)
	{
		string _STORAGE_ = "example_contract_set_data";
		string _CONTRACT_ = "example-contract-storage-set-data";
		/* 
		 * note the use of contract storage here
		 * 
		 * this allows avoiding local variable as pointer is accessible by name
		 * and in this case this is solely for demo purpose
		 */
		// create, store and bind contract
		BindingContract main_contract = ContractStorage.get_storage(_STORAGE_)
			.add(_CONTRACT_, new BindingContract(john_doe))
				.bind ("name", ui_builder.get_object ("e5_name"), "label", BindFlags.SYNC_CREATE)
				.bind ("surname", ui_builder.get_object ("e5_surname"), "label", BindFlags.SYNC_CREATE)
				.contract;

		// assign "data" to main contract whenever radio button is pressed
		((Gtk.ToggleButton) ui_builder.get_object ("e5_set_1")).toggled.connect (() => {
			if (((Gtk.ToggleButton) ui_builder.get_object ("e5_set_1")).active == true)
				main_contract.data = john_doe;
		});
		((Gtk.ToggleButton) ui_builder.get_object ("e5_set_2")).toggled.connect (() => {
			if (((Gtk.ToggleButton) ui_builder.get_object ("e5_set_2")).active == true)
				main_contract.data = unnamed_person;
		});
		((Gtk.ToggleButton) ui_builder.get_object ("e5_set_3")).toggled.connect (() => {
			if (((Gtk.ToggleButton) ui_builder.get_object ("e5_set_3")).active == true)
				main_contract.data = null;
		});

		bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("e5_events"), events);

		events.resource = main_contract;
	}
}
