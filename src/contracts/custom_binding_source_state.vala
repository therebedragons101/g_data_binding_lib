namespace GData
{
	/**
	 * CustomBindingSourceState is state object implementation. Unlike value
	 * objects that are stored as CustomPropertyNotificationBindingSource in
	 * order to create flexible implementations state objects can only be stored
	 * as CustomBindingSourceState or its subclass. If there is a need for 
	 * different state object, then classifying it as bool value object might
	 * be better
	 * 
	 * Being derived from CustomPropertyNotificationBindingSource it also
	 * inherits all of its connection and awareness and adds only access to
	 * custom data and automates its recalculation
	 * 
	 * @since 0.1
	 */
	public class CustomBindingSourceState : CustomPropertyNotificationBindingSource
	{
		private CustomBindingSourceStateFunc? _check_state = null;
		/**
		 * Delegate which is called to calculate state 
		 * 
		 * @since 0.1
		 */
		public CustomBindingSourceStateFunc? check_state {
			get { return (_check_state); }
			owned set {
				if (_check_state == value)
					return;
				_check_state = (owned) value;
				check_source_state(); 
			}
		}

		private bool _state = false;
		/**
		 * Value of state object
		 * 
		 * @since 0.1
		 */
		public bool state {
			get { return (_state); }
		}

		private void check_source_state()
		{
			bool new_state = false;
			if (_check_state != null)
				new_state = _check_state (source);
			if (new_state != state) {
				_state = new_state;
				notify_property("state");
			}
		}

		/**
		 * Creates new CustomBindingSourceState
		 * 
		 * @param name Value object name
		 * @param source Binding pointer this object is connected to
		 * @param state_check_method Method used to calculate state
		 * @param connected_properties Property names to which signals value
		 *                             object should connect. Specify
		 *                             ALL_PROPERTIES or null for cases when
		 *                             all or none are to be used.
		 */ 
		public CustomBindingSourceState (string name, BindingPointer source, owned CustomBindingSourceStateFunc state_check_method, string[]? connected_properties = null)
		{
			base (name, source, connected_properties);
			_check_state = (owned) state_check_method;
			properties_changed.connect (check_source_state);
			manual_recalculation.connect (check_source_state);
			check_source_state();
		}
	}
}
