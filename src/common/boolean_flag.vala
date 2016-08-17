namespace GData
{
	private static Binder? _boolean_binder = null;

	/**
	 * Allows active binding to specific boolean flag and also supports object
	 * change if specified object was binding pointer
	 * 
	 * @since 0.1
	 */
	public class BooleanFlag : Object
	{
		private BindingInterface? _prop_binding = null;

		private StrictWeakRef _ref = new StrictWeakRef(null);

		private FlagValue flags;

		private bool _bidirectional = true;
		/**
		 * Specifies if flags assignment is bidirectional or not
		 * 
		 * @since 0.1
		 */
		public bool bidirectional {
			get { return (_bidirectional); }
		}

		internal class FlagValue : Object
		{
			public uint full_flag_value { get; set; default=0; }
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

		private Type _flags_type = Type.INVALID;
		/**
		 * Specifies flags type
		 * 
		 * @since 0.1
		 */
		public Type flags_type {
			get { return (_flags_type); }
		}

		private bool _state = false;
		/**
		 * Specifies flag state
		 * 
		 * @since 0.1
		 */
		public bool state {
			get { return (has_set_flag(flags.full_flag_value, _watched_flag)); }
			set {
				if (_bidirectional == false)
					return;
				flags.full_flag_value = cond_set_flag (value, flags.full_flag_value, _watched_flag);
			}
		}

		private void check_state()
		{
			bool prev = _state;
			bool res = state;
			_state = res;
			if (prev != res)
				notify_property ("state");
		}

		/**
		 * Unbinds connection
		 * 
		 * @since 0.1
		 */
		public void unbind()
		{
			if (_prop_binding != null) {
				_prop_binding.unbind();
				_prop_binding = null;
			}
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
		public BooleanFlag (Object obj, string property_name, uint flag, bool bidirectional = true)
		{
			_watched_flag = flag;
			flags = new FlagValue();
			_bidirectional = bidirectional;
			flags.notify["full-flag-value"].connect (() => {
				check_state();
			});
			if (_boolean_binder == null)
				_boolean_binder = new Binder.silent();
			if (is_binding_pointer(obj) == true) {
				if (as_pointer(obj).get_source() != null)
					_prop_binding = _boolean_binder.bind (as_pointer(obj), property_name, flags, "full-flag-value",
						BindFlags.SYNC_CREATE|((bidirectional == true) ? BindFlags.BIDIRECTIONAL : 0));
				as_pointer(obj).before_source_change.connect ((b, i, n) => {
					unbind();
				});
				as_pointer(obj).source_changed.connect ((b) => {
					_prop_binding = _boolean_binder.bind (as_pointer(obj), property_name, flags, "full-flag-value",
						BindFlags.SYNC_CREATE|((bidirectional == true) ? BindFlags.BIDIRECTIONAL : 0));
				});
			}
			else
				_prop_binding = _boolean_binder.bind (obj, property_name, flags, "full-flag-value",
					BindFlags.SYNC_CREATE|((bidirectional == true) ? BindFlags.BIDIRECTIONAL : 0));
		}
	}
}
