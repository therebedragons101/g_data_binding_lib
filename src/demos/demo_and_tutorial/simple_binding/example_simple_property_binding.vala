using GData;
using GData.Generics;

namespace Demo
{
// counter is implemented in main app and accessed trough demo.counter
/*
 * 	public int _counter = 0;
 *  public string counter {
 *		owned get { return ("counter=%i".printf(_counter)); }
 * 	}
 */

	private static DemoAndTutorial __demo;
	private static Gtk.ToggleButton basic_flood_data_btn;
	private static Gtk.Builder __ui_builder;

	// timer method that runs until toggle button is depressed
	public bool flood_timer()
	{
		__demo._counter++;
		__demo.notify_property("counter");
		return (basic_flood_data_btn.active);
	}

	// method called when flood is detected
	public void flooded (BindingInterface binding)
	{
		((Gtk.Button) __ui_builder.get_object ("basic_label_right4")).sensitive = false;
		((Gtk.Label) __ui_builder.get_object ("basic_label_right4")).label = 
			"*** FLOODING *** last before freeze=>%i".printf(__demo._counter);
	}

	// method called when flood is over. note that data is already transfered
	// so this method only makes it sensitive again to counter what was done
	// when flood started
	public void flood_over (BindingInterface binding)
	{
		((Gtk.Label) __ui_builder.get_object ("basic_label_right4")).sensitive = true;
	}

	public void example_simple_property_binding (DemoAndTutorial demo, Gtk.Builder ui_builder)
	{
		// note that although here PropertyBinding.bind is used, Binder.bind() 
		// is much better choice as it allows more flexibility. 
		__demo = demo;
		__ui_builder = ui_builder;
		basic_flood_data_btn = (Gtk.ToggleButton) ui_builder.get_object ("basic_flood_data_btn");

		// ordinary binding from source to target with automatic data transfer
		PropertyBinding.bind (ui_builder.get_object ("basic_entry_left"), "text", 
		                      ui_builder.get_object ("basic_entry_right"), "text", BindFlags.SYNC_CREATE);

		// ordinary BIDIRECTIONAL binding with automatic data transfer
		PropertyBinding.bind (ui_builder.get_object ("basic_entry_left2"), "text", 
		                      ui_builder.get_object ("basic_entry_right2"), "text", 
		                      BindFlags.BIDIRECTIONAL | BindFlags.SYNC_CREATE);

		// reverse binding. both SYNC_CREATE and data transfer are now from
		// target to source. this is ignored if BIDIRECTIONAL is specified
		PropertyBinding.bind (ui_builder.get_object ("basic_label_left3"), "label", 
		                      ui_builder.get_object ("basic_entry_right3"), "text", 
		                      BindFlags.REVERSE_DIRECTION | BindFlags.SYNC_CREATE);

		// flood detection enabled binding
		PropertyBinding basic4 = PropertyBinding.bind (demo, "counter", 
		                                               ui_builder.get_object ("basic_label_right4"), "label", 
		                                               BindFlags.FLOOD_DETECTION | BindFlags.SYNC_CREATE);
		// set methods for event when flood is detected and when it stops
		basic4.flood_detected.connect (flooded);
		basic4.flood_stopped.connect (flood_over);
		// set intentional flooding on toggle button when active as it will
		// assign value way below "flood_interval"
		basic_flood_data_btn.toggled.connect (() => {
			if (basic_flood_data_btn.active == true)
				GLib.Timeout.add (20, flood_timer, GLib.Priority.DEFAULT);
		});

		// this binding disables automatic data transfer, instead it relied on
		// update_from_source() or update_from_target() to be called manually
		PropertyBinding basic5 = PropertyBinding.bind (ui_builder.get_object ("basic_entry_left5"), "text", 
		                                               ui_builder.get_object ("basic_label_right5"), "label", 
		                                               BindFlags.MANUAL_UPDATE | BindFlags.SYNC_CREATE);
		// trigger update from source when button is pressed
		((Gtk.Button) __ui_builder.get_object ("basic_transfer_data_btn")).clicked.connect (() => {
			basic5.update_from_source();
		});

		PropertyBinding.bind (ui_builder.get_object ("basic_entry_left6"), "text", 
		                      ui_builder.get_object ("basic_entry_right6"), "text", 
		                      BindFlags.BIDIRECTIONAL | BindFlags.SYNC_CREATE | BindFlags.DELAYED);
	}
}

