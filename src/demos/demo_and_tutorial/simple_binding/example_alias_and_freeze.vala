using GData;
using GData.Generics;

namespace Demo
{
	static PropertyBinding advanced4;

	private void toggle_freeze4 (Gtk.ToggleButton btn)
	{
		// toggle freeze/unfreeze based on button state
		if (btn.active == true)
			advanced4.freeze();
		else
			advanced4.unfreeze();
	}

	public void example_alias_and_freeze (DemoAndTutorial demo, Gtk.Builder ui_builder)
	{
		// Bind to "&" which is registered by demo
		PropertyBinding.bind (ui_builder.get_object ("advanced_binding_l1"), "&", 
		                      ui_builder.get_object ("advanced_binding_r1"), "&", BindFlags.SYNC_CREATE);

		// register "alias:text" name for "text" and "label" for Gtk.Entry and Gtk.Label
		PropertyAlias.get_instance("alias:text")
			.register (typeof(Gtk.Entry), "text")
			.register (typeof(Gtk.Label), "label");
		// now it is possible to bind to "alias:text"
		PropertyBinding.bind (ui_builder.get_object ("advanced_binding_l2"), "alias:text", 
		                      ui_builder.get_object ("advanced_binding_r2"), "alias:text", BindFlags.SYNC_CREATE);

		// bind
		advanced4 = PropertyBinding.bind (ui_builder.get_object ("advanced_binding_l4"), "&", 
		                                  ui_builder.get_object ("advanced_binding_r4"), "&", BindFlags.SYNC_CREATE);
		// connect freeze toggling to all 3 toggle buttons
		((Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze1")).toggled.connect (
			() => { toggle_freeze4 (((Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze1"))); });
		((Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze2")).toggled.connect (
			() => { toggle_freeze4 (((Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze2"))); });
		((Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze3")).toggled.connect (
			() => { toggle_freeze4 (((Gtk.ToggleButton) ui_builder.get_object ("advanced_freeze3"))); });
	}
}

