using GData;
using GData.Generics;

namespace Demo
{
	public void example_binder (DemoAndTutorial demo, Gtk.Builder ui_builder)
	{
		// ordinary binding from source to target with automatic data transfer
		Binder.get_default().bind (ui_builder.get_object ("basic_entry_left1"), "text", 
		                      ui_builder.get_object ("basic_entry_right1"), "text", BindFlags.SYNC_CREATE);

		// ordinary BIDIRECTIONAL binding with automatic data transfer
		Binder.get_default().bind (ui_builder.get_object ("basic_entry_left3"), "text", 
		                      ui_builder.get_object ("basic_entry_right4"), "text", 
		                      BindFlags.BIDIRECTIONAL | BindFlags.SYNC_CREATE);
	}
}

