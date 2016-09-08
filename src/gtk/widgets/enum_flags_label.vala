using GData;

namespace GDataGtk
{
	/**
	 * GtkLabel extension that simply takes advantage of binding to
	 * EnumFlagsString and displaying live human readable representation of
	 * enum/flags value
	 * 
	 * @since 0.1
	 */
	public class EnumFlagsLabel : Gtk.Label
	{
		private BindingInterface? _binding = null;

		private EnumFlagsString? _string_handler = null;
		/**
		 * Enum/Flags conversion to string as well as tracking changes
		 * automatically
		 * 
		 * @since 0.1
		 */
		public EnumFlagsString? string_handler {
			get { return (_string_handler); }
			set {
				if (_string_handler == value)
					return;
				if (_binding != null) {
					_binding.unbind();
					_binding = null;
				}
				_string_handler = value;
				if (_string_handler != null)
					_binding = Binder.get_default_silent().bind (_string_handler, "text", this, "label", BindFlags.SYNC_CREATE);
				else
					label = "";
			}
		}

		/**
		 * Creates new EnumFlagsLabel
		 * 
		 * @since 0.1
		 * 
		 * @param string_handler Specifies enum/flag string converter for label
		 */
		public EnumFlagsLabel (EnumFlagsString? string_handler = null)
		{
			this.string_handler = string_handler;
		}
	}
}
