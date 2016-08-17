namespace GData
{
	/**
	 * List model that inverts order of displayed items whose lifetime depends
	 * solely on lifetime of handled model and as such it shouldn't ever be
	 * referenced manually.
	 * 
	 * Note that reference holding of actual model must be maintained by 
	 * application
	 * 
	 * Example:
	 * my_listbox.bind_model (new InvertedListModel(my_model), ...)
	 * 
	 * @since 0.1
	 */
	public class InvertedListModel : Object, GLib.ListModel
	{
		private StrictWeakRef? _wref = null;
		/**
		 * Returns wrapped model
		 * 
		 * @since 0.1
		 */
		public GLib.ListModel? model {
			get { return ((GLib.ListModel) _wref.target); }
		}

		private uint invert(uint index)
		{
			if (_wref.is_valid_ref() == false)
				return (0);
			uint cnt = model.get_n_items();
			if ((cnt - index - 1) < 0)
				return (0);
			return (cnt - index - 1);
		}
		
		/**
		 * This method is GLib.ListModel implementation requirement and resolves
		 * item at specified position
		 * 
		 * @since 0.1
		 * 
		 * @param position Element position that needs to be returned
		 * @return Object reference is element exists, null if not
		 */ 
		public Object? get_item (uint position)
		{
			if (_wref.is_valid_ref() == false)
				return (null);
			stdout.printf ("GET_ITEM(%lu)\n", position);
			return (model.get_item (invert(position)));
		}

		/**
		 * This method is GLib.ListModel implementation requirement and resolves
		 * type of stored items
		 * 
		 * @since 0.1
		 * 
		 * @return Object type that is stored in ObjectArray
		 */ 
		public Type get_item_type ()
		{
			if (_wref.is_valid_ref() == false)
				return (typeof(Object));
			return (model.get_item_type());
		}
		
		/**
		 * This method is GLib.ListModel implementation requirement and resolves
		 * number of items in ObjectArray
		 * 
		 * @since 0.1
		 * 
		 * @return Number of stored items in ObjectArray
		 */ 
		public uint get_n_items()
		{
			if (_wref.is_valid_ref() == false)
				return (0);
			return (model.get_n_items());
		}

		private void handle_invalid()
		{
			stdout.printf ("UNREF\n");
			unref();
		}

		/**
		 * Creates InvertedListModel
		 * 
		 * @since 0.1
		 * 
		 * @param model Model whose order should be displayed inverted
		 */
		public InvertedListModel (GLib.ListModel? invertmodel)
		{
			ref();
			if (invertmodel == null)
				return;
			stdout.printf ("WRAP\n");
			_wref = new StrictWeakRef (invertmodel, handle_invalid);
			this.model.items_changed.connect ((i,d,a) => {
				items_changed (invert(i), d, a);
			});
		}
	}
}
