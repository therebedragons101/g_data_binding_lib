namespace GData
{
	/**
	 * Provides access to all bindings done with any Binder. Manually connected
	 * property bindings are not stored
	 * 
	 * @since 0.1
	 */
	public class BindingNamespace : Object, GLib.ListModel
	{
		private bool dirty = false;
		private bool cleaning = false;

		private GObjectArray _bindings = new GObjectArray();

		private static BindingNamespace? _instance = null;

		/**
		 * Returns singleton instance of binding namespace
		 * 
		 * @since 0.1
		 * 
		 * @return Instance of binding namespace
		 */
		public static BindingNamespace get_instance()
		{
			if (_instance == null)
				_instance = new BindingNamespace();
			return (_instance);
		}

		// Safer to just clean everything as it is small amount of data
		public void clean_null()
		{
			if (cleaning == true) {
				dirty = true;
				return;
			}
			cleaning = true;
			for (int i=_bindings.length-1; i>=0; i--)
				if (((WeakRefWrapper) _bindings.data[i]).target == null)
					_bindings.remove_at_index (i);
			cleaning = false;
			if (dirty == true) {
				dirty = false;
				clean_null();
			}
		}

		internal void add (BindingInterface? binding)
		{
			if (binding == null)
				return;
			_bindings.add (new WeakRefWrapper(binding, clean_null));
		}

/*		public BindingInterface? get_by_object (Object? obj)
		{
			for (uint i=0; i<_bindings.length; i++) {
				if ((BindingInterface) (get_item(i)) != null)
					if ((BindingInterface) (get_item(i)) == id)
						return (as_pointer(get_item(i)));
			}
			return (null);
		}*/

		internal void register_binder (Binder binder)
		{
			binder.binding_created.connect (add);
		}

		/**
		 * Returns binding at position
		 * 
		 * @since 0.1
		 * 
		 * @param position Item position
		 * @return Binding at specified position
		 */
		public Object? get_item (uint position)
		{
			if (_bindings.data[position] == null)
				return (new WeakRefWrapper(null, null));
			return (_bindings.data[position]);
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
			return (typeof(WeakRefWrapper));
		}

		/**
		 * Returns number of stored bindings
		 * 
		 * @since 0.1
		 * 
		 * @return Number of stored bindings
		 */
		public uint get_n_items ()
		{
			return (_bindings.length);
		}

		private BindingNamespace()
		{
			_bindings.items_changed.connect ((i, d, a) => {
				items_changed (i, d, a);
			});
		}
	}
}

