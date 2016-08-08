namespace GData
{
	public static void example_inspector (Gtk.Builder ui_builder)
	{
		// call of inspector without specified target
		((Gtk.Button) ui_builder.get_object ("show_inspector")).clicked.connect (() =>{
			GDataGtk.BindingInspector.show(null);
		});
		// call of inspector with specified target, not that this works same if 
		// inspector is visible or not
		((Gtk.Button) ui_builder.get_object ("show_inspector_with_target")).clicked.connect (() =>{
			GDataGtk.BindingInspector.show(ContractStorage.get_storage("main_demo").find ("chain-contract"));
		});
	}
}
