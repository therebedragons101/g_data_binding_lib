namespace GData
{
	/**
	 * Non-generic class StrictWeakRef is different from WeakRef in two things. 
	 * 
	 * - Target is always correct as it is connected to pointed object with
	 *   weak_ref
	 * 
	 * - It can specify delegate which is notified when target is invalid. Note 
	 *   that at time of delegate invocation target points to null
	 *
	 * @since 0.1
	 */
	public class StrictWeakRef : WeakRef
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
		public override bool set_new_target (Object? new_target)
		{
			if (_target == new_target)
				return (false);
			if (_target != null)
				_target.weak_unref (handle_weak_ref); 
			base.set_new_target (new_target);
			if (_target != null)
				_target.weak_ref (handle_weak_ref); 
			return (true);
		}

		~StrictWeakRef()
		{
			if (_target != null) {
				_target.weak_unref (handle_weak_ref); 
				_target = null;
			}
		}

		/**
		 * Creates new StrictWeakRef and points it to specified object
		 *
		 * @since 0.1
		 *
		 * @param set_to_target Specifies object being pointed with target
		 */
		public StrictWeakRef (Object? set_to_target, owned WeakReferenceInvalid? notify_method = null)
		{
			base (set_to_target);
			_notify_method = (owned) notify_method;
			if (_target != null)
				((Object) _target).weak_ref (handle_weak_ref); 
		}
	}
}
