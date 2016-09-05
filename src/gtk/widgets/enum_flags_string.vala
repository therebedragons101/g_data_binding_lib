namespace GDataGtk
{
	/**
	 * Simple object that can be used for enum/flags string formating
	 * 
	 * @since 0.1
	 */
	public class EnumFlagsString : Object, EnumFlagsValueInterface
	{
		private string _or_definition = "|";
		/**
		 * Specifies how OR should be represented in string
		 * 
		 * @since 0.1
		 */
		public string or_definition {
			get { return (_or_definition); }
			set {
				if (_or_definition == value)
					return;
				_or_definition = value;
				handle_notify_change();
			}
		}

		private EnumFlagsMode _mode = EnumFlagsMode.NICK;
		/**
		 * Specifies how enum/flags values should be represented in string
		 * 
		 * @since 0.1
		 */
		public EnumFlagsMode mode {
			get { return (_mode); }
			set {
				if (_mode == value)
					return;
				_mode = value;
				handle_notify_change();
			}
		}

		private string _text = "";
		/**
		 * Text value representation of current enum/flags value
		 * 
		 * @since 0.1
		 */
		public string text {
			get { return (_text); }
		}

		private EnumFlagsValueInterface? _value_object = null;
		/**
		 * Object used to represent value
		 * 
		 * @since 0.1
		 */
		public EnumFlagsValueInterface value_object {
			get { return (_value_object); }
			set {
				if (_value_object == value)
					return;
				if (_value_object != null) {
					_value_object.notify["int-value"].disconnect (handle_notify_change);
					_value_object.notify["uint-value"].disconnect (handle_notify_change);
				}
				_value_object = value;
				if (_value_object != null) {
					_value_object.notify["int-value"].connect (handle_notify_change);
					_value_object.notify["uint-value"].connect (handle_notify_change);
				}
				handle_notify_change();
			}
		}

		private void handle_notify_change()
		{
			notify_property ("text");
			notify_property ("int-value");
			notify_property ("uint-value");
		}

		/**
		 * Enum/Flags model type
		 * 
		 * @since 0.1
		 */
		public Type? model_type { 
			get { return (_value_object.model_type); }
			set { value_object.model_type = value; } 
		}

		/**
		 * int value of Flags or Enum
		 * 
		 * @since 0.1
		 */
		public int int_value {
			get { return (_value_object.int_value); }
			set { value_object.int_value = value; }
		}

		/**
		 * uint value of Flags or Enum
		 * 
		 * @since 0.1
		 */
		public uint uint_value {
			get { return (_value_object.uint_value); }
			set { value_object.uint_value = value; } 
		}

		/**
		 * Creates new EnumFlagsString
		 * 
		 * @since 0.1
		 * 
		 * @param value_object Object used for value/type information
		 */
		public EnumFlagsString (EnumFlagsValueInterface value_object, EnumFlagsMode mode = EnumFlagsMode.NICK)
		{
			this.value_object = value_object;
		}
	}
}

