namespace GData
{
	/**
	 * Allows active binding to specific boolean flag and also supports object
	 * change if specified object was binding pointer
	 * 
	 * @since 0.1
	 */
	public class EnumState : Object
	{
		private ProxyProperty? _proxy = null;
		private StrictWeakReference<EnumStateGroup>? _group = null;

		/**
		 * Specifies if value assignment is bidirectional or not
		 * 
		 * @since 0.1
		 */
		public bool bidirectional {
			get {
				if (_group != null)
					return (_group.target.bidirectional);
				return (_proxy.bidirectional);
			}
		}

		private int _watched_value = 0;
		/**
		 * Specifies value that is being watched in connected property
		 * 
		 * @since 0.1
		 */
		public uint watched_value {
			get { return (_watched_value); }
		}

		/**
		 * Specifies enum type
		 * 
		 * @since 0.1
		 */
		public Type enum_type {
			get {
				if (_group != null)
					return (_group.target.value_type);
				if (_proxy.is_valid() == true)
					return (_proxy.connected_property_pspec.value_type);
				return (Type.INVALID);
			}
		}

		private bool _state = false;
		/**
		 * Specifies watched enum state
		 * 
		 * @since 0.1
		 */
		public bool state {
			get { return (_state); }
			set {
				if ((bidirectional == false) && (_state != value))
					return;
				int nvalue = _watched_value;
				if (_group != null)
					_group.target.enum_value = nvalue;
				else {
					GLib.Value val = GLib.Value(typeof(int));
					val.set_int(nvalue);
					_proxy.set_property_value (val);
				}
			}
		}

		/**
		 * Convenience access to inverted state value
		 * 
		 * @since 0.1
		 */
		public bool inverted_state {
			get { return (!state); }
			set { state = !value; }
		}

		private uint _enum_value = 0;
		/**
		 * Returns complete value of enum in bound property
		 * 
		 * @since 0.1
		 */
		public uint enum_value {
			get { return (_enum_value); }
		}

		private void check_state()
		{
			if (_group != null)
				_enum_value = _group.target.enum_value;
			else if (_proxy.is_valid() == true) {
				GLib.Value __val = GLib.Value (typeof(int));
				if (_proxy.get_property_value (ref __val) == false)
					_enum_value = _proxy.get_invalid_value().get_int();
				else
					_enum_value = __val.get_int();
			}
			bool prev = _state;
			_state = (_enum_value == _watched_value);
			if (prev != _state) {
				notify_property ("state");
				notify_property("inverted-state");
			}
		}

		internal EnumState.as_group_element (EnumStateGroup group, int val)
		{
			_group = new StrictWeakReference<EnumStateGroup> (group);
			_watched_value = val;
			if (_group.is_valid_ref() == true)
				_group.target.notify["enum-value"].connect (() => {
					notify_property ("enum-value");
					check_state();
				});
			check_state();
			notify_property ("enum-value");
		}

		/**
		 * Creates boolean flag connection between object and state property
		 * based on specific flag
		 * 
		 * If specified object is binding pointer then this connection is 
		 * actively reestablished whenever source changes
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object or pointer that contains flags
		 * @param property_name Name of property containing flags
		 * @param bidirectional Specifies if assignment goes both ways or not
		 */
		public EnumState (Object obj, string property_name, int val, bool bidirectional = true, int invalid_value = 0)
		{
			GLib.Value invalid = GLib.Value(typeof(int));
			invalid.set_int (invalid_value);
			_proxy = new ProxyProperty (obj, property_name, invalid, bidirectional, typeof(int));
			_watched_value = val;
			_proxy.value_changed.connect (() => {
				notify_property ("enum-value");
				check_state();
			});
			check_state();
			notify_property ("enum-value");
		}
	}
}
