namespace G.Data
{
	private static void add_ptr_storage (string s, PointerArray list)
	{
		KeyValueArray<string, WeakReference<BindingPointer>> sub_list = new KeyValueArray<string, WeakReference<BindingPointer>>();
		PointerStorage storage = PointerStorage.get_storage (s);
		storage.foreach_registration ((t, p) => {
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
		PointerStorage.StorageSignal.get_instance().added_storage.connect ((s) => {
			add_ptr_storage (s, list);
		});
		return (list);
	}

	/**
	 * Storage for pointers in order to have guaranteed reference when there is 
	 * no need for local variable or to have them globally accessible by name
	 * 
	 * @since 0.1
	 */
	public class PointerStorage : Object
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
				store = new PointerStorage();
				_storages.insert (name, store);
				StorageSignal.get_instance().added_storage (name);
			}
			return (store);
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
		public PointerStorage()
		{
			_objects = new HashTable<string, BindingPointer> (str_hash, str_equal);
		}
	}
}
