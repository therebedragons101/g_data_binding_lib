namespace GData
{
	/**
	 * This is more of a middle link binding pointer that in most cases it can't
	 * be usable by it self. 
	 * 
	 * Its main purpose is to connect to another pointers data_changed() signal
	 * (which only happens when pointer has update_type set as MANUAL) and then
	 * throttle its emission by only dispatching notifications after delay and
	 * throttled so all signal emissions are not dispatched until there is at
	 * least one full interval when nothing happened
	 * 
	 * Note that design of this pointer assumes data it will point to is next
	 * binding pointer with MANUAL update. If this is not so, then link is not
	 * established
	 * 
	 * @since 0.1
	 */
	public class ThrottlingBindingPointer : BindingPointer
	{
		private WeakReference<Object?> _last = new WeakReference<Object?> (null);
		
		/**
		 * Specifies throttle interval in ms
		 * 
		 * @since 0.1
		 */
		public uint throttle_interval { get; private set; default = 400; }
		
		private bool _throttle_active = true;
		/**
		 * Specifies whether throttle is active or not
		 * 
		 * Note that if this is false, data_changed will be emited instantly
		 * 
		 * @since 0.1
		 */ 
		public bool throttle_active {
			get { return (_throttle_active); }
			set { _throttle_active = value; }
		}

		private void drop_collection()
		{
		}
		
		private void handle_data_changed (BindingPointer source, string data_change_cookie)
		{
			//TODO throttle and cookie collection on timer
			if (_throttle_active == false)
				data_changed (source, data_change_cookie);
			else {
				// emit
				// drop_collection();
			}
		}	
			
		/**
		 * Creates new ThrottlingBindingPointer
		 * 
		 * @since 0.1
		 * @param throttle_interval Interval in ms with which events are emited
		 * @param data Data used as initial source. If data is pointer or 
		 *             contract this leads to chaining them. More on chaining
		 *             in tutorial application
		 * @param reference_type Specifies how source reference should be 
		 *                       treated. Value can be WEAK, STRONG or DEFAULT
		 */
		public ThrottlingBindingPointer (uint throttle_interval = 1000, Object? data = null, BindingReferenceType reference_type = BindingReferenceType.WEAK)
		{
			base (data, reference_type, BindingPointerUpdateType.MANUAL);
			this.throttle_interval = throttle_interval;
			before_source_change.connect ((ptr, is_same, next) => {
				if ((data == null) || (is_binding_pointer(data) == false))
					return;
				((BindingPointer) data).data_changed.disconnect (handle_data_changed);
				drop_collection();
			});
			source_changed.connect ((ptr) => {
				if ((data == null) || (is_binding_pointer(data) == false))
					return;
				((BindingPointer) data).data_changed.connect (handle_data_changed);
			});
			if ((data == null) || (is_binding_pointer(data) == false))
				return;
			((BindingPointer) data).data_changed.connect (handle_data_changed);
		}
	}
}

