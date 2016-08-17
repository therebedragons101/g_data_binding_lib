using GData;
using GData.Generics;

namespace Demo
{
	public void example_state_objects (DemoAndTutorial demo, Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example_state_objects";
		string _CONTRACT_ = "my-contract";
		// create, store and bind main contract
		BindingContract my_contract = ContractStorage.get_storage(_STORAGE_)
			.add (_CONTRACT_, new BindingContract())
				.bind ("name", ui_builder.get_object ("eso_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.bind ("surname", ui_builder.get_object ("eso_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.bind ("required", ui_builder.get_object ("eso_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.contract;

		// adding custom state value to contract
		my_contract.add_state (new CustomBindingSourceState ("validity", my_contract, "Field \"required\" validity", ((src) => {
			return ((src.data != null) && (((Person) src.data).required != ""));
		}), new string[1] { "required" }));

		// bind directly to state object "state" property with permanent static
		// connection. state will be reflected whenever its value changes or
		// contract starts pointing to some other object
		PropertyBinding.bind(my_contract.get_state_object("validity"), "state", 
		                     ui_builder.get_object ("eso_b1"), "sensitive", BindFlags.SYNC_CREATE);

		bind_person_model ((Gtk.ListBox) ui_builder.get_object ("eso_list"), persons, my_contract);
	}
}
