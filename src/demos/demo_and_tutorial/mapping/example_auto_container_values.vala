using GData;
using GDataGtk;

namespace Demo
{
	private SizeGroupCollection sz;

	public void example_auto_container_values (Gtk.Builder ui_builder)
	{
		// allocate binder and widget mapper
		Binder b = new GData.Binder.silent();
		GtkBuildableMapper mapper = new GDataGtk.GtkBuildableMapper();

		AutoContainerValues auto_container = new AutoContainerValues(EditMode.EDIT);
		auto_container.visible = true;
		((Gtk.Box) ui_builder.get_object("auto_container_box")).pack_start (auto_container);
		// create exact same layout as in Gtk Composite Widgets example
		auto_container.create_type_layout (typeof(Person), ALL_PROPERTIES, "property_");

		// map first widget
		b.set_mapper (mapper)
			.map (persons.data[0], auto_container, BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL, "property_");

		// Create size group collection
		sz = new SizeGroupCollection(null, Gtk.SizeGroupMode.HORIZONTAL);

		// Example of auto header creation
		AutoContainerValues auto_header = new AutoContainerValues(EditMode.VIEW);
		auto_header.visible = true;
		((Gtk.Box) ui_builder.get_object("auto_container_header")).pack_start (auto_header);
		// create exact same layout as in Gtk Composite Widgets example and in case
		// of header binding is not necessary
		auto_header.create_type_header_layout (typeof(Person), ALL_PROPERTIES, "property_", "", sz);

		AutoContainerValues auto_container2 = new AutoContainerValues(EditMode.VIEW);
		auto_container2.visible = true;
		((Gtk.Box) ui_builder.get_object("auto_container_view_box")).pack_start (auto_container2);
		// create exact same layout as in Gtk Composite Widgets example
		auto_container2.create_type_layout (typeof(Person), ALL_PROPERTIES, "property_", "", sz);

		// map first widget
		b.set_mapper (mapper)
			.map (persons.data[0], auto_container2, BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL, "property_");
	}
}
