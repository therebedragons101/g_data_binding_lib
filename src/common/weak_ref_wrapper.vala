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

		/**
		 * Sets new target object to be wrapped
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object that will become new target
		 */
		public void set_new_target (Object? obj)
		{
			wref.set_new_target (obj);
		}

		public bool is_valid_ref()
		{
			return (wref.is_valid_ref());
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
		public WeakRefWrapper (Object? obj, WeakReferenceInvalid? notify_method = null)
		{
			wref = new StrictWeakReference<Object?> (obj, notify_method);
		}
	}
}
