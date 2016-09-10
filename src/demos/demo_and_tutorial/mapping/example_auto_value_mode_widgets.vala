using GData;
using GDataGtk;

namespace Demo
{
	private EditModeControl state;

//	private void pack (Gtk.Builder ui_builder, string container, Gtk.Widget widget)
//	{
//		((Gtk.Box) ui_builder.get_object (container)).pack_start (widget, true, false);
//	}

	public void example_auto_value_mode_widgets (Gtk.Builder ui_builder)
	{
		state = new EditModeControl();
		AutoValueWidget btn = new AutoValueWidget.with_type(typeof(EditMode), EditMode.EDIT);
		Binder.get_default().bind (state, "mode", btn.get_bindable_widget(), btn.get_value_binding_property(), BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
		pack (ui_builder, "auto_value_mode_switch_box", btn);
		pack (ui_builder, "auto_value_1", new AutoValueModeWidget.with_type(typeof(int)).set_mode_control(state));
		pack (ui_builder, "auto_value_2", new AutoValueModeWidget.with_type(typeof(string)).set_mode_control(state));
		pack (ui_builder, "auto_value_3", new AutoValueModeWidget.with_type(typeof(bool)).set_mode_control(state));
		pack (ui_builder, "auto_value_4", new AutoValueModeWidget.with_property(typeof(Person), "name").set_mode_control(state));
		pack (ui_builder, "auto_value_5", new AutoValueModeWidget.with_property(typeof(Person), "surname").set_mode_control(state));
		pack (ui_builder, "auto_value_6", new AutoValueModeWidget.with_property(typeof(PersonInfo), "some-num").set_mode_control(state));
		pack (ui_builder, "auto_value_7", new AutoValueModeWidget.with_type(typeof(EditMode)).set_mode_control(state));
		pack (ui_builder, "auto_value_8", new AutoValueModeWidget.with_type(typeof(CreationEditMode)).set_mode_control(state));
	}
}
