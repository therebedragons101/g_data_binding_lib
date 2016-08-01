namespace GData.Generics
{
	private static void add_ptr_storage (string s, PointerArray list)
	{
		KeyValueArray<string, WeakReference<BindingPointer>> sub_list = new KeyValueArray<string, WeakReference<BindingPointer>>();
		PointerStorage storage = PointerStorage.get_storage (s);
		storage.foreach ((t, p) => {
			sub_list.add (new KeyValuePair<string, WeakReference<BindingPointer>> (t, new WeakReference<BindingPointer>(p)));
		});
		storage.added.connect ((t, p) => {
			sub_list.add (new KeyValuePair<string, WeakReference<BindingPointer>> (t, new WeakReference<BindingPointer>(p)));
		});
		storage.removed.connect ((t, p) => {
			for (int i=0; i<sub_list.length; i++) {
				if (p == sub_list.data[i].val.target) {
					sub_list.remove_at_index(i);
					return;
				}
			}
		});
		KeyValuePair<string, KeyValueArray<string, WeakReference<BindingPointer>>> pair = 
			new KeyValuePair<string, KeyValueArray<string, WeakReference<BindingPointer>>>(s, sub_list);
		list.add (pair);
	}

	/**
	 * Returns PointerArray for complete structure of defined pointers and
	 * their groups. At the same time taps into modifications as ObjectArray is 
	 * also GLib.ListModel
	 * 
	 * @since 0.1
	 */ 
	public static PointerArray track_pointer_storage()
	{
		PointerArray list = new PointerArray();
		PointerStorage.foreach_storage ((s) => {
			add_ptr_storage (s, list);
		});
		PointerStorage.signals.added_storage.connect ((s) => {
			add_ptr_storage (s, list);
		});
		return (list);
	}
}

