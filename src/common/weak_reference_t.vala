namespace G
{
	/**
	 * .Net C# WeakReference like implementation
	 *
	 * Main purpose is always having safe minimal object that can be used in hash
	 * tables or arrays and that object always being valid no matter its contents
	 *
	 * Difference from .Net implementation is that this one supports setting new
	 * target in order to minimize object creation needs.
	 *
	 * Note that this class is not derived from GLib.Object and as such it is not
	 * possible to connect to property notification or track validity of pointed
	 * object. For that purpose StrictWeakReference should be used
	 *
	 * @since 0.1
	 */
	public class WeakReference<T> 
	{
		protected weak T? _target;
		/**
		 * Specifies currently pointed target and does not guarantee its validity
		 * If validity is required, then StrictWeakReference should be used
		 *
		 * @since 0.1
		 */
		public T? target { 
			get { return (_target); }
		}

		/**
		 * Sets new target as currently pointed object
		 *
		 * @since 0.1
		 *
		 * @param new_target Specifies new target as pointed object
		 * @return true if new target was set, false if not
		 */
		public virtual bool set_new_target (T? new_target)
		{
			if (_target == new_target)
				return (false);
			_target = new_target;
			return (true);
		}

		/**
		 * Sets null target as currently pointed object
		 *
		 * @since 0.1
		 */
		public void reset()
		{
			set_new_target (null);
		}

		/**
		 * Creates new WeakReference and points it to specified object
		 *
		 * @since 0.1
		 *
		 * @param set_to_target Specifies object being pointed with target
		 */
		public WeakReference (T? set_to_target)
		{
			_target = set_to_target;
		}
	}
}
