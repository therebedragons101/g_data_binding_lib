namespace GData
{
	/**
	 * Specifies group monitoring of flags values and provides easy way to
	 * add specific monitoring states
	 * 
	 * @since 0.1
	 */
	public class FlagStateGroup : ProxyProperty
	{
		private uint __invalid_value = 0;
		private GLib.Array<FlagState> _flag_connections = new GLib.Array<FlagState>();

		/**
		 * Returns state machine for that binding. If state machine was already
		 * requested then returned is that same instance, if not then new 
		 * BooleanFlag state machine is created
		 * 
		 * @since 0.1
		 * 
		 * @param flag Which set of flags state machine should represent. This
		 *             can as well be MyFlags.FLAG1|MyFlags.FLAG2 and in this
		 *             case state machine only answers to that specific 
		 *             combination
		 */
		public FlagState get_state (uint flag)
		{
			for (int i=0; i<_flag_connections.length; i++)
				if (_flag_connections.data[i].watched_flag == flag)
					return (_flag_connections.data[i]);
			FlagState nf = new FlagState.as_group_element (this, flag);
			_flag_connections.append_val (nf);
			return (nf);
		}

		private uint _flags = 0;
		/**
		 * Flag value in monitored property
		 * 
		 * @since 0.1
		 */
		public uint flags {
			get {
				if (is_valid() == false)
					return (_flags);
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
		 * Creates new FlagStateGroup with no state machines. To add state 
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
		public FlagStateGroup (Object obj, string property_name, bool bidirectional = true, uint invalid_value=0)
		{
			GLib.Value invalid = GLib.Value(typeof(uint));
			invalid.set_uint (invalid_value);
			base (obj, property_name, invalid, bidirectional, typeof(uint));
			__invalid_value = invalid_value;
			value_changed.connect (() => {
				GLib.Value val = GLib.Value (typeof(uint));
				get_property_value (ref val);
				_flags = val.get_uint();
				notify_property("flags");
			});
			GLib.Value val = GLib.Value (typeof(uint));
			if (get_property_value (ref val) == true) {
				_flags = val.get_uint();
				notify_property("flags");
			}
		}
	}
}

