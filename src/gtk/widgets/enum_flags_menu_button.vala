using GData;

namespace GDataGtk
{
	/**
	 * EnumFlagsMenuButton provides button with popover that can be used to edit
	 * flags and enums
	 * 
	 * @since 0.1
	 */
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/enum_flags_menu_button.ui")]
	public class EnumFlagsMenuButton : Gtk.MenuButton, EnumFlagsValueInterface
	{
		[GtkChild] private Gtk.Label value_label;

		private EnumFlagsString _value_string;
		/**
		 * Allows access to display options and control
		 * 
		 * @since 0.1
		 */
		public EnumFlagsString value_string {
			get { return (_value_string); }
		}

		/**
		 * Enum or Flags type being handled
		 * 
		 * @since 0.1
		 */
		public Type? model_type {
			get { return (get_value_interface().model_type); }
			set {
				get_value_interface().model_type = value;
				return;
			}
		}

		/**
		 * int representation of flags or enum value
		 * 
		 * @since 0.1
		 */
		public int int_value {
			get { return (get_value_interface().int_value); }
			set {
				get_value_interface().int_value = value;
				return;
			}
		}

		/**
		 * uint representation of flags or enum value
		 * 
		 * @since 0.1
		 */
		public uint uint_value {
			get { return (get_value_interface().uint_value); }
			set {
				get_value_interface().uint_value = value;
				return;
			}
		}

		/**
		 * Returns enum/flags value interface
		 * 
		 * @since 0.1
		 * @return enum/flags value interface
		 */
		protected EnumFlagsValueInterface get_value_interface()
		{
			return ((EnumFlagsValueInterface) popover);
		}

		/**
		 * Create new EnumFlagsMenuButton
		 * 
		 * @since 0.1
		 * 
		 * @param type Enum or Flags value being displayed
		 * @param val Value being assigned initially
		 */
		public EnumFlagsMenuButton(Type type = typeof(UnspecifiedEnumType), int val = 0)
		{
			popover = new EnumFlagsPopover(this, type, val);
			// set complete 1:1 reliance on property notifications
			get_value_interface().notify["int-value"].connect (() => { notify_property("int-value"); });
			get_value_interface().notify["uint-value"].connect (() => { notify_property("uint-value"); });
			get_value_interface().notify["model-type"].connect (() => { notify_property("model-type"); });
			_value_string = new EnumFlagsString (this);
			_auto_binder().bind(value_string, "text", value_label, "label", BindFlags.SYNC_CREATE);
		}
	}
}

