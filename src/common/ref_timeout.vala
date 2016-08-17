namespace GData
{
	/**
	 * RefTimeout is almost the same as GLib.Timeout with one exception of
	 * adding safety layer to its lifetime
	 * 
	 * This makes it guarateed to stop if specified reference is not alive
	 * anymore
	 * 
	 * @since 0.1
	 */
	public class RefTimeout : Object
	{
		private bool _destroyed = false;
		private uint _result = 0;
		/**
		 * Result returned when GLib.Timeout was initiated
		 * 
		 * @since 0.1
		 */
		public uint result {
			get { return (_result); }
		}

		private WeakRefWrapper? _ref_object = null;
		/**
		 * Access to reference track object. RefTimeout can change that safely
		 * during its lifetime
		 * 
		 * @since 0.1
		 */
		public WeakRefWrapper ref_object {
			get { return (_ref_object); }
		}

		private SourceFunc? _method = null;

		private bool timer_method()
		{
			if (ref_object.is_valid_ref() == false) {
				_method = null;
				if (_destroyed == false)
					unref();
				return (GLib.Source.REMOVE);
			}
			bool res = (_method != null) ? _method() : GLib.Source.REMOVE;
			if (res == false) {
				_method = null;
				if (_destroyed == false)
					unref();
			}
			return (res);
		}

		~RefTimeout()
		{
			ref_object.set_new_target (null);
		}

		private void self_ref(WeakRefWrapper ref_object)
		{
			_ref_object = ref_object;
			ref();
		}

		/**
		 * Instigates timeout by adding safety reference lock to 
		 * GLib.Timeout.add()
		 * 
		 * @since 0.1
		 * 
		 * @param ref_object Object wrapped in WeakRefWrapper
		 * @param interval The time between calls to the function, in 
		 *                 milliseconds (1/1000ths of a second)
		 * @param funtion Timeout handling method
		 * @param priority The priority of the timeout source. Typically this 
		 *                 will be in the range between G_PRIORITY_DEFAULT and 
		 *                 G_PRIORITY_HIGH.
		 * @return The ID (greater than 0) of the event source.
		 */
		public static uint add (WeakRefWrapper ref_object, uint interval, SourceFunc function, int priority = GLib.Priority.DEFAULT)
		{
			return (new RefTimeout._add (ref_object, interval, function, priority).result);
		}

		/**
		 * Instigates timeout by adding safety reference lock to 
		 * GLib.Timeout.add_full()
		 * 
		 * @since 0.1
		 * 
		 * @param ref_object Object wrapped in WeakRefWrapper
		 * @param priority The priority of the timeout source. Typically this 
		 *                 will be in the range between G_PRIORITY_DEFAULT and 
		 *                 G_PRIORITY_HIGH.
		 * @param interval The time between calls to the function, in 
		 *                 milliseconds (1/1000ths of a second)
		 * @param funtion Timeout handling method
		 * @return The ID (greater than 0) of the event source.
		 */
		public static uint add_full (WeakRefWrapper ref_object, int priority, uint interval, SourceFunc function)
		{
			return (new RefTimeout._add_full (ref_object, priority, interval, function).result);
		}

		/**
		 * Instigates timeout by adding safety reference lock to 
		 * GLib.Timeout.add_seconds()
		 * 
		 * @since 0.1
		 * 
		 * @param ref_object Object wrapped in WeakRefWrapper
		 * @param interval The time between calls to the function, in 
		 *                 milliseconds (1/1000ths of a second)
		 * @param funtion Timeout handling method
		 * @param priority The priority of the timeout source. Typically this 
		 *                 will be in the range between G_PRIORITY_DEFAULT and 
		 *                 G_PRIORITY_HIGH.
		 * @return The ID (greater than 0) of the event source.
		 */
		public static uint add_seconds (WeakRefWrapper ref_object, uint interval, SourceFunc function, int priority = GLib.Priority.DEFAULT)
		{
			return (new RefTimeout._add_seconds (ref_object, interval, function, priority).result);
		}

		/**
		 * Instigates timeout by adding safety reference lock to 
		 * GLib.Timeout.add_seconds_full()
		 * 
		 * @since 0.1
		 * 
		 * @param ref_object Object wrapped in WeakRefWrapper
		 * @param priority The priority of the timeout source. Typically this 
		 *                 will be in the range between G_PRIORITY_DEFAULT and 
		 *                 G_PRIORITY_HIGH.
		 * @param interval The time between calls to the function, in 
		 *                 milliseconds (1/1000ths of a second)
		 * @param funtion Timeout handling method
		 * @return The ID (greater than 0) of the event source.
		 */
		public static uint add_seconds_full (WeakRefWrapper ref_object, int priority, uint interval, SourceFunc function)
		{
			return (new RefTimeout._add_seconds_full (ref_object, priority, interval, function).result);
		}

		private RefTimeout._add (WeakRefWrapper ref_object, uint interval, SourceFunc function, int priority = GLib.Priority.DEFAULT)
		{
			self_ref(ref_object);
			_method = function;
			_result = GLib.Timeout.add (interval, timer_method, priority);
		}

		private RefTimeout._add_full (WeakRefWrapper ref_object, int priority, uint interval, SourceFunc function)
		{
			self_ref(ref_object);
			_method = function;
			_result = GLib.Timeout.add_full (priority, interval, timer_method);
		}

		private RefTimeout._add_seconds (WeakRefWrapper ref_object, uint interval, SourceFunc function, int priority = GLib.Priority.DEFAULT)
		{
			self_ref(ref_object);
			_method = function;
			_result = GLib.Timeout.add_seconds (interval, timer_method, priority);
		}

		private RefTimeout._add_seconds_full (WeakRefWrapper ref_object, int priority, uint interval, SourceFunc function)
		{
			self_ref(ref_object);
			_method = function;
			_result = GLib.Timeout.add_seconds_full (priority, interval, timer_method);
		}
	}
}

