namespace G.Data.Generics
{
	private static void add_storage (string s, ContractArray list)
	{
		KeyValueArray<string, WeakReference<BindingContract>> sub_list = new KeyValueArray<string, WeakReference<BindingContract>>();
		ContractStorage storage = ContractStorage.get_storage (s);
		storage.foreach ((t, p) => {
			sub_list.add (new KeyValuePair<string, WeakReference<BindingContract>> (t, new WeakReference<BindingContract>(p)));
		});
		storage.added.connect ((t, p) => {
			sub_list.add (new KeyValuePair<string, WeakReference<BindingContract>> (t, new WeakReference<BindingContract>(p)));
		});
		storage.removed.connect ((t, p) => {
			for (int i=0; i<sub_list.length; i++) {
				if (p == sub_list.data[i].val.target) {
					sub_list.remove_at_index(i);
					return;
				}
			}
		});
		KeyValuePair<string, KeyValueArray<string, WeakReference<BindingContract>>> pair = 
			new KeyValuePair<string, KeyValueArray<string, WeakReference<BindingContract>>>(s, sub_list);
		list.add (pair);
	}

	/**
	 * Returns ContractArray for complete structure of defined contracts and
	 * their groups. At the same time taps into modifications as ObjectArray is 
	 * also GLib.ListModel
	 * 
	 * @since 0.1
	 */ 
	public static ContractArray track_contract_storage()
	{
		ContractArray list = new ContractArray();
		ContractStorage.foreach_storage ((s) => {
			add_storage (s, list);
		});
		ContractStorage.signals.added_storage.connect ((s) => {
			add_storage (s, list);
		});
		return (list);
	}
}

