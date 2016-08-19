namespace GData
{
	/**
	 * Allows active binding to specific boolean flag and also supports object
	 * change if specified object was binding pointer
	 * 
	 * @since 0.1
	 */
	public class FlagState : Object
	{
		private ProxyProperty? _proxy = null;
		private StrictWeakReference<FlagStateGroup>? _group = null;

		/**
		 * Specifies if flags assignment is bidirectional or not
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

		private uint _watched_flag = 0;
		/**
		 * Specifies flag that is being watched in connected property
		 * 
		 * @since 0.1
		 */
		public uint watched_flag {
			get { return (_watched_flag); }
		}

		/**
		 * Specifies flags type
		 * 
		 * @since 0.1
		 */
		public Type flags_type {
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
		 * Specifies flag state
		 * 
		 * @since 0.1
		 */
		public bool state {
			get { return (_state); }
			set {
				if ((bidirectional == false) && (_state != value))
					return;
				uint nflags = cond_set_flag (value, _flags, _watched_flag);
				if (_group != null)
					_group.target.flags = nflags;
				else {
					GLib.Value val = GLib.Value(typeof(uint));
					val.set_uint(nflags);
					_proxy.set_property_value (val);
				}
			}
		}

		private uint _flags = 0;
		/**
		 * Returns complete value of flags in bound property
		 * 
		 * @since 0.1
		 */
		public uint flags {
			get { return (_flags); }
		}

		private void check_state()
		{
			if (_group != null)
				_flags = _group.target.flags;
			else if (_proxy.is_valid() == true) {
				GLib.Value __val = GLib.Value (typeof(uint));
				if (_proxy.get_property_value (ref __val) == false)
					_flags = _proxy.get_invalid_value().get_uint();
				else
					_flags = __val.get_uint();
			}
			bool prev = _state;
			_state = has_set_flag(_flags, _watched_flag);
			if (prev != _state)
				notify_property ("state");
		}

		internal FlagState.as_group_element (FlagStateGroup group, uint flag)
		{
			_group = new StrictWeakReference<FlagStateGroup> (group);
			_watched_flag = flag;
			_group.target.notify["flags"].connect (() => {
				notify_property ("flags");
				check_state();
			});
			check_state();
			notify_property ("flags");
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
		public FlagState (Object obj, string property_name, uint flag, bool bidirectional = true, uint invalid_value = 0)
		{
			GLib.Value invalid = GLib.Value(typeof(uint));
			invalid.set_uint (invalid_value);
			_proxy = new ProxyProperty (obj, property_name, invalid, bidirectional, typeof(uint));
			_watched_flag = flag;
			_proxy.value_changed.connect (() => {
				GLib.Value val = GLib.Value(typeof(uint));
				_proxy.get_property_value (ref val);
				_flags = val.get_uint();
				notify_property ("flags");
				check_state();
			});
			check_state();
			notify_property ("flags");
		}
	}
}

