namespace G
{
	private static void add_storage (string s, ContractArray list)
	{
		KeyValueArray<string, WeakReference<BindingContract>> sub_list = new KeyValueArray<string, WeakReference<BindingContract>>();
		ContractStorage storage = ContractStorage.get_storage (s);
		storage.foreach_registration ((t, p) => {
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

	public static ContractArray track_contract_storage()
	{
		ContractArray list = new ContractArray();
		ContractStorage.foreach_storage ((s) => {
			add_storage (s, list);
		});
		ContractStorage.StorageSignal.get_instance().added_storage.connect ((s) => {
			add_storage (s, list);
		});
		return (list);
	}

	// storage for contracts in order to have guaranteed reference when
	// there is no need for local variable or to have them globally 
	// accessible by name
	public class ContractStorage : Object
	{
		internal class StorageSignal
		{
			private static StorageSignal? _instance = null;
			public static StorageSignal get_instance()
			{
				if (_instance == null)
					_instance = new StorageSignal();
				return (_instance);
			}

			public signal void added_storage (string storage_name);
		}

		internal static void foreach_storage (Func<string> method)
		{
			if (_storages != null)
				_storages.for_each ((s,p) => {
					method(s);
				});
		}

		internal void foreach_registration (HFunc<string, BindingContract> method)
		{
			if (_objects != null)
				_objects.for_each (method);
		}

		private static HashTable<string, ContractStorage>? _storages = null;
		private HashTable<string, BindingContract>? _objects = null;

		private static void _check()
		{
			if (_storages == null)
				_storages = new HashTable<string, ContractStorage> (str_hash, str_equal);
		}

		public static ContractStorage get_default()
		{
			return (get_storage (__DEFAULT__));
		}

		public static ContractStorage? get_storage (string name)
		{
			_check();
			ContractStorage? store = _storages.get (name);
			if (store == null) {
				store = new ContractStorage();
				_storages.insert (name, store);
				StorageSignal.get_instance().added_storage (name);
			}
			return (store);
		}

		public BindingContract? find (string name)
		{
			if (_objects == null)
				return (null);
			return (_objects.get (name));
		}

		public BindingContract? add (string name, BindingContract? obj)
		{
			if (obj == null) {
				GLib.warning ("Trying to add [null] as stored contract \"%s\"!".printf(name));
				return (null);
			}
			if (find(name) != null) {
				GLib.critical ("Duplicate stored contract \"%s\"!".printf(name));
				return (null);
			}
			if (_objects == null)
				_objects = new HashTable<string, BindingContract> (str_hash, str_equal);
			_objects.insert (name, obj);
			added (name, obj);
			return (obj);
		}

		public void remove (string name)
		{
			BindingContract obj = find (name);
			if (obj == null)
				return;
			_objects.remove (name);
			removed (name, obj);
		}

		public signal void added (string name, BindingContract obj);

		public signal void removed (string name, BindingContract obj);

		public ContractStorage()
		{
			_objects = new HashTable<string, BindingContract> (str_hash, str_equal);
		}
	}
}
