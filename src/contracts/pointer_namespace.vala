namespace GData
{

	/**
	 * Class serves to store weak references for all pointers and it creates
	 * filesystem like structure
	 * 
	 * @since 0.1
	 */
	public class PointerNamespace : Object, GLib.ListModel
	{
		private bool dirty = false;
		private bool cleaning = false;

		private GLib.Array<WeakRefWrapper> _pointers = new GLib.Array<WeakRefWrapper>();

		private static PointerNamespace? _instance = null;

		/**
		 * Returns singleton instance of binding namespace
		 * 
		 * @since 0.1
		 * 
		 * @return Instance of binding namespace
		 */
		public static PointerNamespace get_instance()
		{
			if (_instance == null)
				_instance = new PointerNamespace();
			return (_instance);
		}

		// Safer to just clean everything as it is small amount of data
		private void clean_null()
		{
			if (cleaning == true) {
				dirty = true;
				return;
			}
			cleaning = true;
			for (int i=(int)_pointers.length-1; i>=0; i--) {
				if (((WeakRefWrapper) _pointers.data[(uint)i]).target == null) {
					_pointers.remove_index ((uint)i);
					items_changed ((uint)i, 1, 0);
				}
			}
			cleaning = false;
			if (dirty == true) {
				dirty = false;
				clean_null();
			}
		}

		internal void add (BindingPointer? pointer)
		{
			_pointers.append_val (new WeakRefWrapper(pointer, clean_null));
			items_changed (_pointers.length, 0, 1);
		}

		/**
		 * Resolves pointer by specified id
		 * 
		 * @since 0.1
		 * 
		 * @param id Pointer id
		 * @return Pointer reference if found, null if not
		 */
		public BindingPointer? get_by_id (int id)
		{
			for (uint i=0; i<_pointers.length; i++) {
				if (as_pointer(get_item(i)) != null)
					if (as_pointer(get_item(i)).id == id)
						return (as_pointer(get_item(i)));
			}
			GLib.warning ("id(%i) not found\n", id);
			return (null);
		}

		/**
		 * Returns pointer at position
		 * 
		 * @since 0.1
		 * 
		 * @param position Item position
		 * @return Binding at specified position
		 */
		public Object? get_item (uint position)
		{
			return (((WeakRefWrapper) _pointers.data[position]).target);
		}

		/**
		 * Returns item type
		 * 
		 * @since 0.1
		 * 
		 * @return Stored item type
		 */
		public Type get_item_type ()
		{
			return (typeof(BindingPointer));
		}

		/**
		 * Returns number of stored pointers
		 * 
		 * @since 0.1
		 * 
		 * @return Number of stored bindings
		 */
		public uint get_n_items ()
		{
			return (_pointers.length);
		}

		private PointerNamespace()
		{
		}
	}
}

