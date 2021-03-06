namespace GData.Generics
{
	/**
	 * StrictWeakReference is different from WeakReference in two
	 * things. 
	 * 
	 * - Target is always correct as it is connected to pointed object with
	 * weak_ref
	 * 
	 * - It can specify delegate which is notified when target is invalid. Note 
	 * that at time of delegate invocation target points to null
	 *
	 * @since 0.1
	 */
	public class StrictWeakReference<T> : WeakReference<T>
	{
		private WeakReferenceInvalid? _notify_method = null;

		private void handle_weak_ref (Object o)
		{
			if (_target == null)
				return;
			_target = null;
			if (_notify_method != null)
				_notify_method();
		}

		/**
		 * Sets new target as currently pointed object
		 *
		 * @since 0.1
		 *
		 * @param new_target Specifies new target as pointed object
		 * @return true if new target was set, false if not
		 */
		public override bool set_new_target (T? new_target)
		{
			if (_target == new_target)
				return (false);
			if (_target != null)
				((Object) _target).weak_unref (handle_weak_ref); 
			base.set_new_target (new_target);
			if (_target != null)
				((Object) _target).weak_ref (handle_weak_ref); 
			return (true);
		}

		~StrictWeakReference()
		{
			if (_target != null) {
				((Object) _target).weak_unref (handle_weak_ref); 
				_target = null;
			}
		}

		/**
		 * Creates new StrictWeakReference and points it to specified object
		 *
		 * @since 0.1
		 *
		 * @param set_to_target Specifies object being pointed with target
		 */
		public StrictWeakReference (T? set_to_target = null, WeakReferenceInvalid? notify_method = null)
		{
			base (set_to_target);
			_notify_method = notify_method;
			if (_target is GLib.Object)
				((Object) _target).weak_ref (handle_weak_ref); 
			else
				if (_target != null)
					GLib.warning ("Cannot set weak_ref on non GLib.Object");
		}
	}
}
