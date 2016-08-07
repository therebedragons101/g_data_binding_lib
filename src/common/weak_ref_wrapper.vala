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
}
