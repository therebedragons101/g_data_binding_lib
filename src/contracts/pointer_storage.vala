namespace GData
{
	/**
	 * Storage for pointers in order to have guaranteed reference when there is 
	 * no need for local variable or to have them globally accessible by name
	 * 
	 * @since 0.1
	 */
	public class PointerStorage : Object
	{
		public class Signals : Object
		{
			private static Signals? _instance = null;
			internal static Signals get_instance()
			{
				if (_instance == null)
					_instance = new Signals();
				return (_instance);
			}

			public signal void added_storage (string storage_name);

			internal signal void get_by_id (int id, ref BindingPointer? pointer);

			private Signals()
			{
			}
		}

		private string _name;
		/**
		 * Storage name
		 * 
		 * @since 0.1
		 */
		public string name {
			get { return (_name); }
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

		public void foreach (PointerStorageDelegateFunc method)
		{
			if (_objects != null)
				_objects.for_each ((k,v) => {
					method(k,v);
				});
		}

		private static HashTable<string, PointerStorage>? _storages = null;
		private HashTable<string, BindingPointer>? _objects = null;

		private static void _check()
		{
			if (_storages == null)
				_storages = new HashTable<string, PointerStorage> (str_hash, str_equal);
		}

		/**
		 * Resolves default pointer storage
		 * 
		 * @since 0.1
		 * @return Default contract storage
		 */
		public static PointerStorage get_default()
		{
			return (get_storage (__DEFAULT__));
		}

		/**
		 * Resolves pointer storage by specified name. Unlike find() this
		 * method guarantees resulting storage. If storage is not found new one
		 * with that name is created
		 * 
		 * @since 0.1
		 * @return Pointer storage reference
		 */
		public static PointerStorage? get_storage (string name)
		{
			_check();
			PointerStorage? store = _storages.get (name);
			if (store == null) {
				store = new PointerStorage(name);
				_storages.insert (name, store);
				signals.added_storage (name);
			}
			return (store);
		}

		/**
		 * Searches for pointer by specified unique id which is autoassigned on
		 * pointer creation (accessible trough its id property)
		 * 
		 * This search is not limited to pointers stored in storage. Any pointer
		 * can be accessed
		 * 
		 * Note that since BindingContract is subclass of BindingPointer 
		 * contracts can be accessed as well, but it is probably better for type 
		 * safety reasons to use BindingContract.get_by_id()
		 * 
		 * @since 0.1
		 * 
		 * @param id Id of requested pointer
		 */
		public static BindingPointer? get_by_id (int id)
		{
			BindingPointer ptr = null;
			signals.get_by_id (id, ref ptr);
			return (ptr);
		}

		/**
		 * Resolves pointer storage by specified name
		 * 
		 * @since 0.1
		 * @return Pointer storage reference if found and null if not
		 */
		public BindingPointer? find (string name)
		{
			if (_objects == null)
				return (null);
			return (_objects.get (name));
		}

		/**
		 * Adds pointer into storage
		 * 
		 * Note! Pointers with same name are not supported
		 * 
		 * @since 0.1
		 * @param name Name under which contract should be stored
		 * @param obj Contract that needs to be stored
		 * @return Pointer reference in order to allow API chaining in 
		 *         objective languages
		 */
		public BindingPointer? add (string name, BindingPointer? obj)
		{
			if (obj == null) {
				GLib.warning ("Trying to add [null] as stored pointer \"%s\"!".printf(name));
				return (null);
			}
			if (find(name) != null) {
				GLib.critical ("Duplicate stored pointer \"%s\"!".printf(name));
				return (null);
			}
			if (_objects == null)
				_objects = new HashTable<string, BindingPointer> (str_hash, str_equal);
			string? s = obj.get_data<string?>("stored-as");
			if ((s != null) && (s != "")) {
				GLib.critical ("Pointer \"%s\"is already stored as \"%s\"!".printf(name, s));
				return (obj);
			}
			obj.set_data<string?>("stored-as", "%s/%s".printf(this.name, name));
			_objects.insert (name, obj);
			added (name, obj);
			return (obj);
		}

		/**
		 * Removes pointer from storage if found
		 * 
		 * @since 0.1
		 * @param name Pointer name that needs to be removed
		 */
		public void remove (string name)
		{
			BindingPointer obj = find (name);
			if (obj == null)
				return;
			obj.set_data<string?>("stored-as", "");
			_objects.remove (name);
			removed (name, obj);
		}

		/**
		 * Signal emited when new pointer is added to storage
		 * 
		 * @since 0.1
		 * @param name Name under which pointer was stored
		 * @param obj Pointer that was stored
		 */
		public signal void added (string name, BindingPointer obj);

		/**
		 * Signal emited when pointer is removed from storage
		 * 
		 * @since 0.1
		 * @param name Name under which pointer was removed
		 * @param obj Pointer that was removed
		 */
		public signal void removed (string name, BindingPointer obj);

		/**
		 * Creates new PointerStorage
		 * 
		 * @since 0.1
		 */
		private PointerStorage (string name)
		{
			_name = name;
			_objects = new HashTable<string, BindingPointer> (str_hash, str_equal);
		}
	}
}
