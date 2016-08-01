namespace G.Data
{
	/**
	 * Storage for contracts in order to have guaranteed reference when there is 
	 * no need for local variable or to have them globally accessible by name
	 * 
	 * @since 0.1
	 */
	public class ContractStorage : Object
	{
		public class Signals
		{
			private static Signals? _instance = null;
			public static Signals get_instance()
			{
				if (_instance == null)
					_instance = new Signals();
				return (_instance);
			}

			public signal void added_storage (string storage_name);
		}

		/**
		 * Access to global storage signals
		 * 
		 * @since 0.1
		 */
		public static Signals signals {
			owned get { return (Signals.get_instance()); }
		}

		public static void foreach_storage (StorageDelegateFunc method)
		{
			if (_storages != null)
				_storages.for_each ((s,p) => {
					method(s);
				});
		}

		public void foreach (ContractStorageDelegateFunc method)
		{
			if (_objects != null)
				_objects.for_each ((k,v) => {
					method(k,v);
				});
		}

		private static HashTable<string, ContractStorage>? _storages = null;
		private HashTable<string, BindingContract>? _objects = null;

		private static void _check()
		{
			if (_storages == null)
				_storages = new HashTable<string, ContractStorage> (str_hash, str_equal);
		}

		/**
		 * Resolves default contract storage
		 * 
		 * @since 0.1
		 * @return Default contract storage
		 */
		public static ContractStorage get_default()
		{
			return (get_storage (__DEFAULT__));
		}

		/**
		 * Resolves contract storage by specified name. Unlike find() this
		 * method guarantees resulting storage. If storage is not found new one
		 * with that name is created
		 * 
		 * @since 0.1
		 * @return Contract storage reference
		 */
		public static ContractStorage? get_storage (string name)
		{
			_check();
			ContractStorage? store = _storages.get (name);
			if (store == null) {
				store = new ContractStorage();
				_storages.insert (name, store);
				signals.added_storage (name);
			}
			return (store);
		}

		/**
		 * Resolves contract storage by specified name
		 * 
		 * @since 0.1
		 * @return Contract storage reference if found and null if not
		 */
		public BindingContract? find (string name)
		{
			if (_objects == null)
				return (null);
			return (_objects.get (name));
		}

		/**
		 * Adds contract into storage
		 * 
		 * Note! Contracts with same name are not supported
		 * 
		 * @since 0.1
		 * @param name Name under which contract should be stored
		 * @param obj Contract that needs to be stored
		 * @return Contract reference in order to allow API chaining in 
		 *         objective languages
		 */
		public BindingContract? add (string name, BindingContract? obj)
		{
			if (obj == null) {
				GLib.warning ("Trying to add [null] as stored contract \"%s\"!".printf(name));
				return (null);
			}
			if (find(name) != null) {
				GLib.critical ("Duplicate stored contract \"%s\"!".printf(name));
				return (obj);
			}
			if (_objects == null)
				_objects = new HashTable<string, BindingContract> (str_hash, str_equal);
			_objects.insert (name, obj);
			added (name, obj);
			return (obj);
		}

		/**
		 * Removes contract from storage if found
		 * 
		 * @since 0.1
		 * @param name Contract name that needs to be removed
		 */
		public void remove (string name)
		{
			BindingContract obj = find (name);
			if (obj == null)
				return;
			_objects.remove (name);
			removed (name, obj);
		}

		/**
		 * Signal emited when new contract is added to storage
		 * 
		 * @since 0.1
		 * @param name Name under which contract was stored
		 * @param obj Contract that was stored
		 */
		public signal void added (string name, BindingContract obj);

		/**
		 * Signal emited when contract is removed from storage
		 * 
		 * @since 0.1
		 * @param name Name under which contract was removed
		 * @param obj Contract that was removed
		 */
		public signal void removed (string name, BindingContract obj);

		/**
		 * Creates new ContractStorage
		 * 
		 * @since 0.1
		 */
		public ContractStorage()
		{
			_objects = new HashTable<string, BindingContract> (str_hash, str_equal);
		}
	}
}
