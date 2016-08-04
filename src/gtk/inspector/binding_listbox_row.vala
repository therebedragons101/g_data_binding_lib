using GData;

namespace GDataGtk
{
	/**
	 * Use this only temporary for purpose of accessing contract trough 
	 * gtk-inspector if needed
	 * 
	 * This is only convenience to
	 * 
	 * @since 0.1
	 */
	public class BindingListBoxRow : Gtk.ListBoxRow
	{
		/**
		 * Access contract
		 * 
		 * @since 0.1
		 */
		public BindingContract contract {
			get { return (get_data<BindingContract>("binding-contract")); }
		}
	}
}

