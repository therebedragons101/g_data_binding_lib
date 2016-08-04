using GData;

namespace GDataGtk
{
	// only for purpose of accessing contract trough gtk-inspector
	public class BindingListBoxRow : Gtk.ListBoxRow
	{
		public BindingContract contract {
			get { return (get_data<BindingContract>("binding-contract")); }
		}
	}
}

