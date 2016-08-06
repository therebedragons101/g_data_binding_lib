namespace GData
{
	/**
	 * StrictWeakReference wrapped in GObject
	 * 
	 * @since 0.1
	 */
	public class WeakRefWrapper : Object
	{
		private StrictWeakReference<Object?>? wref = null;

		/**
		 * Target object
		 * 
		 * @since 0.1
		 */
		public Object target {
			owned get { return (wref.target); }
		}

		~WeakRefWrapper()
		{
			wref.set_new_target (null);
			wref = null;
		}

		/**
		 * Creates new WeakRefWrapper
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object being wrapped
		 * @param notify_method Notification method when reference becomes 
		 *                      invalid
		 */
		public WeakRefWrapper (Object obj, owned WeakReferenceInvalid? notify_method)
		{
			wref = new StrictWeakReference<Object?> (obj, (owned) notify_method);
		}
	}

	/**
	 * Class serves to store weak references for all pointers and it creates
	 * filesystem like structure
	 * 
	 * @since 0.1
	 */
	public class PointerNamespace : Object, GLib.ListModel
	{
		private GLib.Array<WeakRefWrapper> _pointers = new GLib.Array<WeakRefWrapper>();

		private static PointerNamespace? _instance = null;

		public static PointerNamespace get_instance()
		{
			if (_instance == null)
				_instance = new PointerNamespace();
			return (_instance);
		}

		// Safer to just clean everything as it is small amount of data
		private void clean_null()
		{
			for (uint i=_pointers.length-1; i<=0; i--) {
				if (((WeakRefWrapper) _pointers.data[i]).target == null) {
					_pointers.remove_index (i);
					items_changed (i, 1, 0);
				}
			}
		}

		internal void add (BindingPointer? pointer)
		{
			_pointers.append_val (new WeakRefWrapper(pointer, clean_null));
			items_changed (_pointers.length, 0, 1);
		}

		public BindingPointer? get_by_id (int id)
		{
			stdout.printf ("searching %i/%i\n", id, (int)_pointers.length);
			for (uint i=1; i<_pointers.length; i++) {
			stdout.printf("%i\n", as_pointer(get_item(i)).id);
				if (get_item(i) != null) {
					if (as_pointer(get_item(i)) != null)
						if (as_pointer(get_item(i)).id == id)
							return (as_pointer(get_item(i)));
				}
			}
			stdout.printf("not found\n");
			return (null);
		}

		public Object? get_item (uint position)
		{
			return (((WeakRefWrapper) _pointers.data[position]).target);
		}

		public Type get_item_type ()
		{
			return (typeof(BindingPointer));
		}
		
		public uint get_n_items ()
		{
			return (_pointers.length);
		}

		private PointerNamespace()
		{
		}
	}
}
