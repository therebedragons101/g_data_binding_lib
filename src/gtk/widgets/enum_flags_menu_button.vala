namespace GDataGtk
{
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/enum_flags_menu_button.ui")]
	public class EnumFlagsMenuButton : Gtk.MenuButton, EnumFlagsValueInterface
	{
		[GtkChild] private Gtk.Label value_label;

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

		private void set_caption()
		{
			GLib.Value val = GLib.Value (model_type);
			if (model_type.is_flags() == true)
				val.set_flags(uint_value);
			else
				val.set_enum(int_value);
			GLib.Value str = GLib.Value (typeof(string));
			val.transform (ref str);
			value_label.label = str.get_string().replace(convert_to_type_name(get_value_interface().model_type.name()), "");
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
			notify["int-value"].connect (() => {
				set_caption();
			});
			set_caption();
		}
	}
}

