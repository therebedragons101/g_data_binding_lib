using GData;

namespace DemoAndTutorial
{
	private BindingContract my_contract;
	private BindingContract contract1_in_group;
	private BindingContract contract2_in_group;
	private BindingSuspensionGroup suspension_group;

	public void example_contract_suspension()
	{
		// create binding contract
		my_contract = new BindingContract();
		// control suspended state
		my_contract.suspended = true;

		// same control can be achieved by grouping more contracts
		contract1_in_group = new BindingContract();
		contract2_in_group = new BindingContract();
		// create suspension group
		suspension_group = new BindingSuspensionGroup();
		// add both contracts to group
		suspension_group.add (contract1_in_group);
		suspension_group.add (contract2_in_group);
		// now suspension can be controlled from group object
		suspension_group.suspended = true;
	}
}
