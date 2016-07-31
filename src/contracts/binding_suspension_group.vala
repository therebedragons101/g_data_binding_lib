namespace G.Data
{
	public class BindingSuspensionGroup : Object
	{
		private static int counter = 1;

		private int id;

		private bool _suspended = false;
		public bool suspended {
			get { return (_suspended); }
			set { 
				if (_suspended == value)
					return;
				_suspended = value; 
			}
		}

		public void add (BindingContract? contract)
		{
			if (contract == null)
				return;
			StrictWeakReference<PropertyBinding?> prop = contract.get_data<StrictWeakReference<PropertyBinding?>>("suspend-group-%i".printf(id));
			if ((prop != null) && (prop.target != null))
				return;
			PropertyBinding nprop = PropertyBinding.bind (this, "suspended", contract, "suspended", BindFlags.SYNC_CREATE);
			contract.set_data<StrictWeakReference<PropertyBinding?>> ("suspend-group-%i".printf(id), new StrictWeakReference<PropertyBinding?>(nprop));
		}

		public void remove (BindingContract? contract)
		{
			StrictWeakReference<PropertyBinding?> prop = contract.get_data<StrictWeakReference<PropertyBinding?>> ("suspend-group-%i".printf(id));
			if ((prop != null) && (prop.target != null)) {
				contract.set_data<StrictWeakReference<PropertyBinding?>> ("suspend-group-%i".printf(id), new StrictWeakReference<PropertyBinding?> (null));
				prop.target.unbind();
			}
		}

		public BindingSuspensionGroup()
		{
			id = counter;
			counter++;
		}
	}
}
