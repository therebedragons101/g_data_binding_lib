namespace GData
{
	/**
	 * BindingPointer subclass that defines data change dispatch is being
	 * maintained manually and dispatch is being handled by timer
	 * 
	 * When TimerControlledBindingPointer is created it only needs to connect
	 * to its own timer_action() signal in order to emit events.
	 * 
	 * Example:
	 * 
	 * void handle_signal()
	 * {
	 *     myptr.data_changed (myptr, "something-chaged");
	 * }
	 * 
	 * myptr = new TimerControlledBindingPointer(500);
	 * myptr.timer_action.connect (handle_signal);
	 *
	 * There is no need to check validity when signal is emited because signal
	 * only gets emited when source is valid and (timer_active == true) 
	 * 
	 * @since 0.1
	 */
	public class TimerControlledBindingPointer : BindingPointer
	{
		private int timer_id = 0;
		
		/**
		 * Specifies timeout interval on which BindingPointer should emit
		 * timer_action signal
		 * 
		 * Note that changing this value will only take effect on next timeout.
		 * This is why in most cases timer_interval should be specified on 
		 * creation
		 * 
		 * @since 0.1
		 */
		public uint timer_interval { get; private set; default = 1000; }
		
		private bool _timer_active = true;
		/**
		 * Specifies whether timer is active or not
		 * 
		 * Note that timer will ignore this if pointer is not connected to valid
		 * source
		 * 
		 * @since 0.1
		 */ 
		public bool timer_active {
			get { return (_timer_active); }
			set { _timer_active = value; }
		}

		private void activate_timer (int intid)
		{
			GLib.Timeout.add ((timer_interval), (() => {
				if ((intid == timer_id) && (_timer_active == true))
					timer_action();
				return (intid == timer_id);
			}), GLib.Priority.DEFAULT);
		}

		/**
		 * Signal that is emited when action needs to be taken. For this to 
		 * be emiting two conditions must be met.
		 * - timer_active must be true
		 * - get_source() must point to valid object
		 * 
		 * @since 0.1
		 */
		public signal void timer_action();
		
		/**
		 * Creates new TimerControlledBindingPointer
		 * 
		 * @since 0.1
		 * @param timer_interval Interval in ms with which events are emited
		 * @param data Data used as initial source. If data is pointer or 
		 *             contract this leads to chaining them. More on chaining
		 *             in tutorial application
		 * @param reference_type Specifies how source reference should be 
		 *                       treated. Value can be WEAK, STRONG or DEFAULT
		 */
		public TimerControlledBindingPointer (uint timer_interval = 1000, Object? data = null, BindingReferenceType reference_type = BindingReferenceType.WEAK)
		{
			base (data, reference_type, BindingPointerUpdateType.MANUAL);
			this.timer_interval = timer_interval;
			before_source_change.connect ((ptr, is_same, next) => {
				if (get_source() == null)
					return;
				timer_id++;
			});
			source_changed.connect ((ptr) => {
				if (get_source() == null)
					return;
				activate_timer (timer_id++);
			});
			if (get_source() != null)
				activate_timer (timer_id++);
		}
	}
}

