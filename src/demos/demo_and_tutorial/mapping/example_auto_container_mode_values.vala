using GData;
using GDataGtk;

namespace Demo
{
	public void example_auto_container_mode_values (Gtk.Builder ui_builder)
	{
		AutoContainerModeValues auto_container = new AutoContainerModeValues(EditMode.EDIT);
		auto_container.visible = true;
		((Gtk.Box) ui_builder.get_object("auto_mode_container_box")).pack_start (auto_container);
		// create exact same layout as in Gtk Composite Widgets example
		auto_container.create_type_layout (typeof(Person), ALL_PROPERTIES, "property_");

		// allocate binder and widget mapper
		Binder b = new GData.Binder.silent();
		GtkBuildableMapper mapper = new GDataGtk.GtkBuildableMapper();
		// map first widget
		b.set_mapper (mapper)
			.map (persons.data[0], auto_container, BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL, "property_");

		// End of Person handling code
		// Code from here is for handling buttons to modify edit states for demonstration purposes

		// Button created and inserted manually since glade support is on TODO
		EnumFlagsMenuButton button = new EnumFlagsMenuButton(typeof(EditMode));
		button.visible = true;
		((Gtk.Box) ui_builder.get_object("ac_edit_mode")).pack_start(button);
		b.bind (auto_container.mode, "mode", button, "uint-value", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
		b.bind (auto_container.control, "show-labels", ui_builder.get_object("show_labels"), "active", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
		b.bind (auto_container.control, "show-tooltips", ui_builder.get_object("show_tooltips"), "active", BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL);
	}
}
