namespace G
{
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

		~StrictWeakReference()
		{
			if (_target != null) {
				((Object) _target).weak_unref (handle_weak_ref); 
				_target = null;
			}
		}

		public StrictWeakReference (T? set_to_target, owned WeakReferenceInvalid? notify_method = null)
		{
			base (set_to_target);
			_notify_method = (owned) notify_method;
			if (_target is GLib.Object)
				((Object) _target).weak_ref (handle_weak_ref); 
			else
				if (_target != null)
					GLib.warning ("Cannot set weak_ref on non GLib.Object");
		}

	}
}
