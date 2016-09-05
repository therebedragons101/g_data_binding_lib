using GData;

namespace GDataGtk
{
	/**
	 * Provides collection of named sizegroups. This collection self manages its
	 * lifetime based on lifetime of ref_owner specified on creation. Since it
	 * has its own memory management only weak references should be ever held
	 * 
	 * @since 0.1
	 */
	public class SizeGroupCollection : Object
	{
		private StrictWeakRef? _wref = null;
		private GLib.HashTable<string, Gtk.SizeGroup> _hash = new GLib.HashTable<string, Gtk.SizeGroup> (str_hash, str_equal);

		/**
		 * Specifies common mode for all sizegroups
		 * 
		 * @since 0.1
		 */
		public Gtk.SizeGroupMode mode { get; private set; }

		private void handle_invalid()
		{
			_hash.remove_all();
			unref();
		}

		/**
		 * Returns size group by name or creates new one. For peek functionality
		 * find_group() should be used instead
		 * 
		 * @since 0.1
		 * 
		 * @param name Size group name
		 * @return SizeGroup object or null
		 */
		public Gtk.SizeGroup? get_group (string name)
		{
			Gtk.SizeGroup? grp = find_group (name);
			if (grp == null) {
				grp = new Gtk.SizeGroup (mode);
				_hash.insert (name, grp);
			}
			return (grp);
		}

		/**
		 * Returns size group by name or creates new one. For safe functionality
		 * get_group() should be used instead which creates new one if group
		 * does not exists
		 * 
		 * @since 0.1
		 * 
		 * @param name Size group name
		 * @return SizeGroup object or null
		 */
		public Gtk.SizeGroup? find_group (string name)
		{
			return (_hash.get(name));
		}

		/**
		 * Creates new SizeGroupCollection
		 * 
		 * @since 0.1
		 * 
		 * @param ref_owner Reference owner to which this collection is locked
		 * @param mode Specifies mode with which sizegroups are created
		 */
		public SizeGroupCollection (Object? ref_owner, Gtk.SizeGroupMode mode)
		{
			this.mode = mode;
			if (ref_owner != null) {
				ref();
				_wref = new StrictWeakRef (ref_owner, handle_invalid);
			}
			else
				_wref = new StrictWeakRef (null, handle_invalid);
		}
	}
}
