using GData;
using GDataGtk;

namespace Demo
{
	// exact same thing can be used for rows in listbox
	public void example_composite_widgets (Gtk.Builder ui_builder)
	{
		// pack composite widgets into interface
		PersonCompositeWidget wdg1 = new PersonCompositeWidget();
		PersonCompositeWidget wdg2 = new PersonCompositeWidget();
		((Gtk.Box) ui_builder.get_object ("widget1")).pack_start (wdg1, true, false);
		((Gtk.Box) ui_builder.get_object ("widget2")).pack_start (wdg2, true, false);

		// this only has to be called once per application in case of mapping
		// as it registers property aliases for widgets, in this case binding
		// is done to ALIAS_DEFAULT property alias which needs to be registered
		// for widgets
		DefaultWidgets.init();

		// allocate binder and widget mapper
		Binder b = new GData.Binder.silent();
		GtkBuildableMapper mapper = new GDataGtk.GtkBuildableMapper();
		// map first widget
		b.set_mapper (mapper)
			.map (persons.data[0], wdg1, BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL, "property_");
		// map second widget
		b.set_mapper (mapper)
			.map (persons.data[1], wdg2, BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL, "property_");
		// maping sensitivity to checkbox, but this time only name and surname
		b.set_mapper (mapper)
			.map_single (ui_builder.get_object ("set_2_insensitive"), "active", wdg2,
				new string[2] { "name", "surname"}, ALIAS_SENSITIVITY, BindFlags.SYNC_CREATE, "property_");
		// maping visibility to checkbox, but this time only name and surname
		b.set_mapper (mapper)
			.map_single (ui_builder.get_object ("set_2_visible"), "active", wdg2,
				new string[2] { "name", "required"}, ALIAS_VISIBILITY, BindFlags.SYNC_CREATE, "property_");
	}
}

