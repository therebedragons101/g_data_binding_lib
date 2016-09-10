using GData;

namespace GDataGtk
{
	/**
	 * Simple object that can be used for enum/flags string formating
	 * 
	 * @since 0.1
	 */
	public class EnumFlagsString : Object, EnumFlagsValueInterface, EnumFlagsStringInterface
	{
		private weak EnumFlagsStringInterface? _control = null;
		private BindingInterface?[] _bindings = new BindingInterface[3];

		private string _or_definition = " | ";
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

		private CharacterCaseMode _character_case = CharacterCaseMode.PRESENTABLE;
		/**
		 * Specifies character case conversion if any
		 * 
		 * @since 0.1
		 */
		public CharacterCaseMode character_case {
			get { return (_character_case); }
			set {
				if (_character_case == value)
					return;
				_character_case = value;
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

		private string _resolve_enum_val_str (int val)
		{
			EnumClass cls = (EnumClass) model_type.class_ref();
			EnumValue? vval = cls.get_value(val);
			return (_get_enum_value_str (vval, mode, character_case));
		}

		private string _resolve_flags_val_str (uint val)
		{
			FlagsClass cls = (FlagsClass) model_type.class_ref();
			cls.mask = val;
			string t = "";
			for (int i=0; i<cls.values.length; i++) {
				if (has_set_flag (cls.mask, cls.values[i].value) == true) {
					t += ((t != "") ? _or_definition : "") + _get_flags_value_str(cls.values[i], mode, character_case);
					cls.mask = unset_flag(cls.mask, cls.values[i].value);
				}
			}
			return (t);
		}

		private void resolve_string()
		{
			if (model_type == Type.INVALID)
				_text = "";
			else {
				if (model_type.is_enum() == true)
					_text = _resolve_enum_val_str (int_value);
				else if (model_type.is_flags() == true)
					_text = _resolve_flags_val_str (uint_value);
				else
					_text = "invalid type";
			}
		}

		private void handle_notify_change()
		{
			resolve_string();
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
			set { _value_object.model_type = value; }
		}

		/**
		 * int value of Flags or Enum
		 * 
		 * @since 0.1
		 */
		public int int_value {
			get { return (_value_object.int_value); }
			set { _value_object.int_value = value; }
		}

		/**
		 * uint value of Flags or Enum
		 * 
		 * @since 0.1
		 */
		public uint uint_value {
			get { return (_value_object.uint_value); }
			set { _value_object.uint_value = value; } 
		}

		private void handle_control_reset()
		{
			_bindings[0] = null;
			_bindings[1] = null;
			_bindings[2] = null;
		}

		/**
		 * Sets mode control object which is shared amongs all widgets/strings
		 * handling this type for certain group
		 * 
		 * @since 0.1
		 * 
		 * @param control Control object for enum/flags display mode
		 */
		public EnumFlagsString set_mode_control (EnumFlagsStringInterface? control)
		{
			if (_control != null)
				_control.weak_unref (handle_control_reset);
			for (int i=0; i<3; i++)
				if (_bindings[i] != null)
					_bindings[i].unbind();
			handle_control_reset();
			_control = control;
			if (control != null) {
				for (int i=0; i<3; i++) {
					_bindings[0] = _auto_binder().bind (control, "mode", this, "mode", BindFlags.SYNC_CREATE);
					_bindings[1] = _auto_binder().bind (control, "or-definition", this, "or-definition", BindFlags.SYNC_CREATE);
					_bindings[2] = _auto_binder().bind (control, "character-case", this, "character-case", BindFlags.SYNC_CREATE);
					control.weak_ref (handle_control_reset);
				}
			}
			return (this);
		}

		/**
		 * Creates new EnumFlagsString
		 * 
		 * @since 0.1
		 * 
		 * @param value_object Object used for value/type information
		 */
		public EnumFlagsString (EnumFlagsValueInterface value_object, EnumFlagsMode mode = EnumFlagsMode.NICK, CharacterCaseMode character_case = CharacterCaseMode.PRESENTABLE)
		{
			handle_control_reset();
			this.value_object = value_object;
			this.mode = mode;
			this.character_case = character_case;
			this.value_object.notify["int-value"].connect (() => {
				handle_notify_change();
			});
		}
	}
}

