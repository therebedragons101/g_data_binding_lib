using GData;
using GData.Generics;

namespace Demo
{
	public void example_validation (DemoAndTutorial demo, Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example_validation";
		string _CONTRACT_ = "my-contract";
		// create, store and bind main contract
		BindingContract my_contract = ContractStorage.get_storage(_STORAGE_)
			.add (_CONTRACT_, new BindingContract())
				.bind ("name", ui_builder.get_object ("evo_1"), "&", 
				       BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, null, null,
				    // specify validity condition
					((v) => {
						return ((string) v != "");
					}))
				.bind ("surname", ui_builder.get_object ("evo_2"), "&", 
				       BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, null, null,
				    // specify validity condition
					((v) => {
						return ((string) v != "");
					}))
				.bind ("required", ui_builder.get_object ("evo_3"), "&", 
				       BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.contract;

		// bind "sensitive" to contracts "is_valid" property
		PropertyBinding.bind(my_contract, "is_valid", 
		                     ui_builder.get_object ("evo_b1"), "sensitive", BindFlags.SYNC_CREATE);

		bind_person_model ((Gtk.ListBox) ui_builder.get_object ("evo_list"), persons, my_contract);
	}
}

