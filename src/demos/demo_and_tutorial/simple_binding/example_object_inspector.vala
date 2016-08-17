using GData;

namespace Demo
{
	public static void example_object_inspector (Gtk.Builder ui_builder, DemoAndTutorial app)
	{
		// calls of inspector with specified target, you can stack them and 
		// make available for comparison
		((Gtk.Button) ui_builder.get_object ("add_object_to_inspector")).clicked.connect (() =>{
			GDataGtk.ObjectInspector.add_object(persons.data[0]);
		});
		((Gtk.Button) ui_builder.get_object ("add_object_to_inspector4")).clicked.connect (() =>{
			GDataGtk.ObjectInspector.add_object(persons.data[1]);
		});
		((Gtk.Button) ui_builder.get_object ("add_object_to_inspector2")).clicked.connect (() =>{
			GDataGtk.ObjectInspector.add_object(PointerNamespace.get_instance().get_by_id(1));
		});
		((Gtk.Button) ui_builder.get_object ("add_object_to_inspector3")).clicked.connect (() =>{
			GDataGtk.ObjectInspector.add_object(app);
		});
		((Gtk.Button) ui_builder.get_object ("clean_objects_in_inspector")).clicked.connect (() =>{
			GDataGtk.ObjectInspector.clean();
		});
	}
}
