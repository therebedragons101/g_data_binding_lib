using GData;
using GData.Generics;

namespace Demo
{
	public void example_value_objects (DemoAndTutorial demo, Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example_value_objects";
		string _CONTRACT_ = "my-contract";
		// create, store and bind main contract
		BindingContract my_contract = ContractStorage.get_storage(_STORAGE_)
			.add (_CONTRACT_, new BindingContract())
				.bind ("name", ui_builder.get_object ("evvo_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.bind ("surname", ui_builder.get_object ("evvo_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.bind ("required", ui_builder.get_object ("evvo_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.contract;

		// adding custom value to contract
		my_contract.add_source_value (new CustomBindingSourceData<string> ("length", my_contract, "Cumulative string length",
			((src) => {
				return ("(cumulative of string lengths)=>%i".printf((src.data != null) ? ((Person) src.data).name.length + ((Person) src.data).surname.length + ((Person) src.data).required.length : 0));
			}), 
			((a,b) => { return ((a == b) ? 0 : 1); }), 
			"", false, ALL_PROPERTIES));

		// bind to binding value. note that value is updated whenever contract 
		// source changes or specified properties in respective class get changed
		// which makes it perfectly ok to use simple binding as this connection 
		// will be stable for whole contract life
		PropertyBinding.bind (my_contract.get_source_value ("length"), "data", 
		                      ui_builder.get_object ("evvo_4"), "&", BindFlags.SYNC_CREATE, 
			(binding, srcval, ref targetval) => {
				targetval.set_string (((CustomBindingSourceData<string>) binding.source).data);
				return true;
			});

		bind_person_model ((Gtk.ListBox) ui_builder.get_object ("evvo_list"), persons, my_contract);
	}
}

