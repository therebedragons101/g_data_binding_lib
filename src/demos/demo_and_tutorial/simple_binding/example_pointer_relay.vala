using GData;
using GData.Generics;
using GDataGtk;

namespace Demo
{
	internal void example_pointer_relay (DemoAndTutorial demo, Gtk.Builder ui_builder, EventArray events)
	{
		string _STORAGE_ = "example_pointer_relay";
		string _MAIN_CONTRACT_ = "main-contract";
		string _INFO_CONTRACT_ = "info-contract";
		string _PARENT_CONTRACT_ = "parent-contract";
		// create, store and bind main contract
		BindingContract my_contract = ContractStorage.get_storage(_STORAGE_)
			.add (_MAIN_CONTRACT_, new BindingContract())
				.bind ("name", ui_builder.get_object ("e7_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.bind ("surname", ui_builder.get_object ("e7_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.bind ("required", ui_builder.get_object ("e7_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.contract;

		// bind pointer to main contracts "info" property value
		BindingPointer infoptr = my_contract.hold (new BindingPointerFromPropertyValue (my_contract, "info"));
		// bind pointer to main contracts "parent" property value
		BindingPointer parentptr = my_contract.hold (new BindingPointerFromPropertyValue (my_contract, "parent"));

		// create new contract that points to previously create "info" pointer
		BindingContract info_contract = ContractStorage.get_storage(_STORAGE_)
			.add (_INFO_CONTRACT_, new BindingContract(infoptr))
				.bind ("some_num", ui_builder.get_object ("e7_s1_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.contract;
		// create new contract that points to previously create "parent" pointer
		BindingContract parent_contract = ContractStorage.get_storage(_STORAGE_)
			.add (_PARENT_CONTRACT_, new BindingContract(parentptr))
				.bind ("name", ui_builder.get_object ("e7_s2_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.bind ("surname", ui_builder.get_object ("e7_s2_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.bind ("required", ui_builder.get_object ("e7_s2_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.contract;

		// bind parent editing box visibility to state of "is_valid" on parent contract
		PropertyBinding.bind(parent_contract, "is-valid", ui_builder.get_object ("e7_s2_g"), "visible", BindFlags.SYNC_CREATE);

		bind_person_model ((Gtk.ListBox) ui_builder.get_object ("e7_list"), persons, my_contract);

		bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("e7_events"), events);
		events.resource = parent_contract;
	}

}
