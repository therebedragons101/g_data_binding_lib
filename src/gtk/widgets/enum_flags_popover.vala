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
	public class EnumFlagsPopover : Gtk.Popover, EnumFlagsValueInterface
	{
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
