namespace GData
{
	/**
	 * Specifies group monitoring of flags values and provides easy way to
	 * add specific monitoring states
	 * 
	 * @since 0.1
	 */
	public class EnumStateGroup : ProxyProperty
	{
		private int __invalid_value = 0;
		private GLib.Array<EnumState> _enum_connections = new GLib.Array<EnumState>();

		/**
		 * Returns state machine for that binding. If state machine was already
		 * requested then returned is that same instance, if not then new 
		 * EnumState state machine is created
		 * 
		 * @since 0.1
		 * 
		 * @param flag Which set of flags state machine should represent. This
		 *             can as well be MyFlags.FLAG1|MyFlags.FLAG2 and in this
		 *             case state machine only answers to that specific 
		 *             combination
		 */
		public EnumState get_state (int val)
		{
			for (int i=0; i<_enum_connections.length; i++)
				if (_enum_connections.data[i].watched_value == val)
					return (_enum_connections.data[i]);
			EnumState nf = new EnumState.as_group_element (this, val);
			_enum_connections.append_val (nf);
			return (nf);
		}

		private uint _enum_value = 0;
		/**
		 * Enum value in monitored property
		 * 
		 * @since 0.1
		 */
		public uint enum_value {
			get {
				if (is_valid() == false)
					return (_enum_value);
				return (__invalid_value);
			}
			set {
				if ((is_valid() == true) && (bidirectional == true)) {
					GLib.Value val = GLib.Value(typeof(uint));
					val.set_uint (value);
					set_property_value (val);
				}
			}
		}

		/**
		 * Creates new EnumStateGroup with no state machines. To add state 
		 * machine call get_state() which either resolves already existing state 
		 * machine or creates new one
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object or pointer/contract that owns property
		 * @param property_name Property name
		 * @param bidirectional Specifies if state machines are bidirectional or
		 *                      not
		 * @param invalid_value Specifies value which should be returned on
		 *                      momentary invalid state machine (aka. source
		 *                      being pointer/contract but pointing to null)
		 */
		public EnumStateGroup (Object obj, string property_name, bool bidirectional = true, int invalid_value=0)
		{
			GLib.Value invalid = GLib.Value(typeof(int));
			invalid.set_int (invalid_value);
			base (obj, property_name, invalid, bidirectional, typeof(int));
			__invalid_value = invalid_value;
			value_changed.connect (() => {
				GLib.Value val = GLib.Value (typeof(int));
				get_property_value (ref val);
				_enum_value = val.get_uint();
				notify_property("enum-value");
			});
			GLib.Value val = GLib.Value (typeof(int));
			if (get_property_value (ref val) == true) {
				_enum_value = val.get_uint();
				notify_property("enum-value");
			}
		}
	}
}
