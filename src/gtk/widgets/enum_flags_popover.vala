using GData;

namespace GDataGtk
{
	/**
	 * Provides popover with alread filled up editor for specific enum or 
	 * flags value type
	 * 
	 * It is mainly meant for internal use as it treats enums and flags as basic
	 * int or uint
	 * 
	 * @since 0.1
	 */
	public class EnumFlagsPopover : Gtk.Popover, EnumFlagsValueInterface, EnumFlagsStringInterface
	{
		private weak EnumFlagsStringInterface? _control = null;
		private BindingInterface?[] _bindings = new BindingInterface[3];

		private EnumFlagsValues _values;

		/**
		 * Enum or Flags type being handled
		 * 
		 * @since 0.1
		 */
		public Type? model_type {
			get { return (_values.model_type); }
			set {
				_values.model_type = value;
				return;
			}
		}

		/**
		 * int representation of flags or enum value
		 * 
		 * @since 0.1
		 */
		public int int_value {
			get { return (_values.int_value); }
			set {
				_values.int_value = value;
				return;
			}
		}

		/**
		 * uint representation of flags or enum value
		 * 
		 * @since 0.1
		 */
		public uint uint_value {
			get { return (_values.uint_value); }
			set {
				_values.uint_value = value;
				return;
			}
		}

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
				_values.or_definition = value;
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
				_values.character_case = value;
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
				_values.mode = value;
			}
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
		public EnumFlagsPopover set_mode_control (EnumFlagsStringInterface? control)
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
		 * Create new EnumFlagsPopover
		 * 
		 * @since 0.1
		 * 
		 * @param type Enum or Flags value being displayed
		 * @param val Value being assigned initially
		 */
		public EnumFlagsPopover(Gtk.Widget? relative_to = null, Type type = typeof(UnspecifiedEnumType), int val = 0)
		{
			if (relative_to != null)
				this.relative_to = relative_to;
			_values = new EnumFlagsValues(type, val);
			_values.margin = 8;
			_values.visible = true;
			add (_values);
			// set complete 1:1 reliance on property notifications
			_values.notify["int-value"].connect (() => { notify_property("int-value"); });
			_values.notify["uint-value"].connect (() => { notify_property("uint-value"); });
			_values.notify["model-type"].connect (() => { notify_property("model-type"); });
		}
	}
}
