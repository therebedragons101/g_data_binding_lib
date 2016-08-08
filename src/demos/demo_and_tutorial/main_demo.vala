using GData;
using GData.Generics;

namespace Demo
{
	public void main_demo (DemoAndTutorial demo, Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "main_demo";
		BindingContract selection_contract = ContractStorage.get_storage(_STORAGE_)
			.add ("main-contract", new BindingContract(null))
				.bind ("name", ui_builder.get_object ("name"), "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, null, null,
					((v) => {
						return ((string) v != "");
					}))
				.bind ("surname", ui_builder.get_object ("surname"), "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, null, null,
					((v) => {
						return ((string) v != "");
					}))
				.bind ("required", ui_builder.get_object ("required"), "text", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.contract;
		
		// chaining contract as source
		BindingContract chain_contract = ContractStorage.get_storage(_STORAGE_)
			.add ("chain-contract", new BindingContract(selection_contract))
				.bind ("name", ui_builder.get_object ("name_chain"), "label", BindFlags.SYNC_CREATE)
				.bind ("surname", ui_builder.get_object ("surname_chain"), "label", BindFlags.SYNC_CREATE)
				.contract;

		bind_person_model ((Gtk.ListBox)ui_builder.get_object ("items"), persons, selection_contract);

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
		PropertyBinding.bind (selection_contract.get_state_object("validity"), "state", 
		                      ui_builder.get_object ("required_not_empty"), "sensitive", BindFlags.SYNC_CREATE);

		// bind to binding value. note that value is updated whenever contract source changes or specified properties in respective class get changed
		// which makes it perfectly ok to use simple binding as this connection will be stable for whole contract life
		PropertyBinding.bind (selection_contract.get_source_value ("length"), "data", 
		                      ui_builder.get_object ("custom_data"), "label", BindFlags.SYNC_CREATE, 
			(binding, srcval, ref targetval) => {
				targetval.set_string (((CustomBindingSourceData<string>) binding.source).data);
				return true;
			});

		PropertyBinding.bind (selection_contract, "is-valid", 
		                      ui_builder.get_object ("is_valid_source"), "sensitive", BindFlags.SYNC_CREATE);

		BindingPointer infoptr = selection_contract.hold (new BindingPointerFromPropertyValue (selection_contract, "info"));
		BindingPointer parentptr = selection_contract.hold (new BindingPointerFromPropertyValue (selection_contract, "parent"));

		BindingContract info_contract = ContractStorage.get_storage(_STORAGE_)
			.add ("info-contract", new BindingContract(infoptr))
				.bind ("some_num", ui_builder.get_object ("e1_s1_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.contract;

		BindingContract parent_contract = ContractStorage.get_storage(_STORAGE_)
			.add ("parent-contract", new BindingContract(parentptr))
				.bind ("name", ui_builder.get_object ("e1_s2_1"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.bind ("surname", ui_builder.get_object ("e1_s2_2"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.bind ("required", ui_builder.get_object ("e1_s2_3"), "&", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL)
				.contract;

		PropertyBinding.bind(parent_contract, "is-valid", 
		                     ui_builder.get_object ("e1_s2_g"), "visible", BindFlags.SYNC_CREATE);
	}
}
