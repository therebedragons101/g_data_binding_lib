using GDataGtk;

namespace Demo
{
	private EditModeControl state1;
	private EditModeControl state2;

	private void pack (Gtk.Builder ui_builder, string container, Gtk.Widget widget)
	{
		((Gtk.Box) ui_builder.get_object (container)).pack_start (widget, true, false);
	}

	public void example_auto_widgets (Gtk.Builder ui_builder)
	{
		state1 = new EditModeControl(EditMode.VIEW);
		state2 = new EditModeControl(EditMode.EDIT);
		pack (ui_builder, "auto_simple_1", new AutoValueWidget.with_type(typeof(int)).set_mode_control(state1));
		pack (ui_builder, "auto_simple_2", new AutoValueWidget.with_type(typeof(string)).set_mode_control(state1));
		pack (ui_builder, "auto_simple_3", new AutoValueWidget.with_type(typeof(bool)).set_mode_control(state1));
		pack (ui_builder, "auto_simple_4", new AutoValueWidget.with_property(typeof(Person), "name").set_mode_control(state1));
		pack (ui_builder, "auto_simple_5", new AutoValueWidget.with_property(typeof(Person), "surname").set_mode_control(state1));
		pack (ui_builder, "auto_simple_6", new AutoValueWidget.with_property(typeof(PersonInfo), "some-num").set_mode_control(state1));
		pack (ui_builder, "auto_simple_7", new AutoValueWidget.with_type(typeof(int), EditMode.EDIT).set_mode_control(state2));
		pack (ui_builder, "auto_simple_8", new AutoValueWidget.with_type(typeof(string), EditMode.EDIT).set_mode_control(state2));
		pack (ui_builder, "auto_simple_9", new AutoValueWidget.with_type(typeof(bool), EditMode.EDIT).set_mode_control(state2));
		pack (ui_builder, "auto_simple_10", new AutoValueWidget.with_property(typeof(Person), "name", EditMode.EDIT).set_mode_control(state2));
		pack (ui_builder, "auto_simple_11", new AutoValueWidget.with_property(typeof(Person), "surname", EditMode.EDIT).set_mode_control(state2));
		pack (ui_builder, "auto_simple_12", new AutoValueWidget.with_property(typeof(PersonInfo), "some-num", EditMode.EDIT).set_mode_control(state2));
		pack (ui_builder, "auto_simple_13", new AutoValueWidget.with_type(typeof(EditMode)).set_mode_control(state1));
		pack (ui_builder, "auto_simple_15", new AutoValueWidget.with_type(typeof(CreationEditMode)).set_mode_control(state1));
		pack (ui_builder, "auto_simple_14", new AutoValueWidget.with_type(typeof(EditMode), EditMode.EDIT).set_mode_control(state2));
		pack (ui_builder, "auto_simple_16", new AutoValueWidget.with_type(typeof(CreationEditMode), EditMode.EDIT).set_mode_control(state2));

		((Gtk.ToggleButton) ui_builder.get_object ("invert_auto_widget_mode")).toggled.connect (() => {
			state1.invert();
			state2.invert();
		});
	}
}

