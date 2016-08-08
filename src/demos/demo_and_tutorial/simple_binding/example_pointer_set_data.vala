using GData;
using GData.Generics;
using GDataGtk;

namespace Demo
{
	internal void example_pointer_set_data (DemoAndTutorial demo, Gtk.Builder ui_builder, EventArray events)
	{
		string _STORAGE_ = "example_pointer_set_data";
		/* 
		 * note the use of pointer storage here
		 * 
		 * this allows avoiding local variable as pointer is accessible by name
		 * and in this case this is solely for demo purpose
		 */
		// create and store pointer
		PointerStorage.get_storage(_STORAGE_).add("example-pointer-set-data", new BindingPointer(john_doe));

		// assign "data" to pointer whenever radio button is pressed
		((Gtk.ToggleButton) ui_builder.get_object ("e4_set_1")).toggled.connect (() => {
			if (((Gtk.ToggleButton) ui_builder.get_object ("e4_set_1")).active == true)
				PointerStorage.get_storage(_STORAGE_).find("example-pointer-set-data").data = john_doe;
		});
		((Gtk.ToggleButton) ui_builder.get_object ("e4_set_2")).toggled.connect (() => {
			if (((Gtk.ToggleButton) ui_builder.get_object ("e4_set_2")).active == true)
				PointerStorage.get_storage(_STORAGE_).find("example-pointer-set-data").data = unnamed_person;
		});
		((Gtk.ToggleButton) ui_builder.get_object ("e4_set_3")).toggled.connect (() => {
			if (((Gtk.ToggleButton) ui_builder.get_object ("e4_set_3")).active == true)
				PointerStorage.get_storage(_STORAGE_).find("example-pointer-set-data").data = null;
		});

		bind_event_listbox ((Gtk.ListBox) ui_builder.get_object ("e4_events"), events);

		events.resource = PointerStorage.get_storage(_STORAGE_).find("example-pointer-set-data");
	}
}

