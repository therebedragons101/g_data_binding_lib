namespace GData
{
	public class BooleanGroup : Object
	{
		private string _property_name;
		private StrictWeakRef _wref;
		private uint _invalid_value = 0;
		private GLib.Array<BooleanFlag> _flags = new GLib.Array<BooleanFlag>();

		private bool _bidirectional = true;
		/**
		 * Specifies if flags assignment is bidirectional or not
		 * 
		 * @since 0.1
		 */
		public bool bidirectional {
			get { return (_bidirectional); }
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
		public BooleanFlag get_state (uint flag)
		{
			for (int i=0; i<_flags.length; i++)
				if (_flags.data[i].watched_flag == flag)
					return (_flags.data[i]);
			BooleanFlag nf = new BooleanFlag (_wref.target, _property_name, flag, _bidirectional);
			_flags.append_val (nf);
			return (nf);
		}

		/**
		 * Creates new BooleanGroup with no state machines. To add state machine
		 * call get_state() which either resolves already existing state machine
		 * or creates new one
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
		public BooleanGroup (Object obj, string property_name, bool bidirectional = true, uint invalid_value=0)
		{
			_invalid_value = invalid_value;
			_property_name = property_name;
			_wref = new StrictWeakRef (obj);
			_bidirectional = bidirectional;
		}
	}
}

