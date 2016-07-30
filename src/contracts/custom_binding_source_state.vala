namespace G
{
	public class CustomBindingSourceState : CustomPropertyNotificationBindingSource
	{
		private CustomBindingSourceStateFunc? _check_state = null;
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

		public CustomBindingSourceState (string name, BindingPointer source, owned CustomBindingSourceStateFunc state_check_method, string[]? connected_properties = null)
		{
			base (name, source, connected_properties);
			_check_state = (owned) state_check_method;
			properties_changed.connect (check_source_state);
			check_source_state();
		}
	}
}
