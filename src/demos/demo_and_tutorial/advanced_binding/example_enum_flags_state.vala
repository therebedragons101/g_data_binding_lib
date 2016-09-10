using GData;
using GDataGtk;

namespace Demo
{
	EnumFlagsString str;

	[Flags]
	public enum WidgetFlags
	{
		SENSITIVE,
		VISIBLE,
		EDITABLE,
		READONLY_MODE = SENSITIVE | VISIBLE,
		FULL_MODE = SENSITIVE | VISIBLE | EDITABLE;
	}

	public class RandomClassContainingFlagProperty : Object
	{
		public string name { get; set; }
		public WidgetFlags flags { get; set; default=WidgetFlags.READONLY_MODE; }

		public RandomClassContainingFlagProperty (string name, WidgetFlags flags)
		{
			this.name = name;
			this.flags = flags;
		}
	}

	public void bind_entry_states (Gtk.Builder ui_builder, FlagStateGroup group, string widget_name, bool inverted)
	{
		Binder.get_default().bind (group.get_state(WidgetFlags.VISIBLE), (inverted == true) ? "inverted-state" : "state",
			ui_builder.get_object (widget_name), "visible", BindFlags.SYNC_CREATE);
		Binder.get_default().bind (group.get_state(WidgetFlags.SENSITIVE), (inverted == true) ? "inverted-state" : "state",
			ui_builder.get_object (widget_name), "sensitive", BindFlags.SYNC_CREATE);
		Binder.get_default().bind (group.get_state(WidgetFlags.EDITABLE), (inverted == true) ? "inverted-state" : "state",
			ui_builder.get_object (widget_name), "editable", BindFlags.SYNC_CREATE);
	}

	public void example_enum_flags_state (Gtk.Builder ui_builder)
	{
		string _STORAGE_ = "example_enum_flags";
		// Creation of two random objects
		RandomClassContainingFlagProperty cls1 = new RandomClassContainingFlagProperty("Set 1", WidgetFlags.READONLY_MODE);
		RandomClassContainingFlagProperty cls2 = new RandomClassContainingFlagProperty("Set 2", WidgetFlags.FULL_MODE);
		// Set contract for label binding
		BindingContract my_contract = ContractStorage.get_storage(_STORAGE_).add("example-enum-flags", new BindingContract(cls1));
		// Button created and inserted manually since glade support is on TODO
		EnumFlagsMenuButton button = new EnumFlagsMenuButton(typeof(WidgetFlags));
		button.visible = true;
		((Gtk.Box) ui_builder.get_object ("flag_button_box")).pack_start (button, true, true);
		// bind flag popover button
		my_contract.bind ("flags", button, "uint-value", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
		// set flag set switching button for fun
		my_contract.bind ("name", ui_builder.get_object ("flag_set_switch"), "label", BindFlags.SYNC_CREATE);
		// Set toggle button so it switches object containing flag set
		((Gtk.ToggleButton) ui_builder.get_object ("flag_set_switch")).toggled.connect (
			() => my_contract.data = (my_contract.data == cls1) ? cls2 : cls1);
		// Flag definition
		FlagStateGroup my_flag_group = new FlagStateGroup (my_contract, "flags"); // bidirectional is by default
		// bind switches
		Binder.get_default().bind (my_flag_group.get_state(WidgetFlags.VISIBLE), "state", 
			ui_builder.get_object ("visible_flag_state"), "active", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
		Binder.get_default().bind (my_flag_group.get_state(WidgetFlags.SENSITIVE), "state",
			ui_builder.get_object ("sensitive_flag_state"), "active", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
		Binder.get_default().bind (my_flag_group.get_state(WidgetFlags.EDITABLE), "state", 
			ui_builder.get_object ("editable_flag_state"), "active", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
		// this could as well be achieved by INVERT_BOOLEAN, except "inverted-state" is more universaly usable
		Binder.get_default().bind (my_flag_group.get_state(WidgetFlags.VISIBLE), "inverted-state", 
			ui_builder.get_object ("visible_flag_statei"), "active", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
		Binder.get_default().bind (my_flag_group.get_state(WidgetFlags.SENSITIVE), "inverted-state",
			ui_builder.get_object ("sensitive_flag_statei"), "active", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
		Binder.get_default().bind (my_flag_group.get_state(WidgetFlags.EDITABLE), "inverted-state", 
			ui_builder.get_object ("editable_flag_statei"), "active", BindFlags.SYNC_CREATE|BindFlags.BIDIRECTIONAL);
		bind_entry_states (ui_builder, my_flag_group, "flag_entry_1", false);
		bind_entry_states (ui_builder, my_flag_group, "flag_entry_2", true);
		str = new EnumFlagsString (button);
		Binder.get_default().bind (str, "text", ui_builder.get_object ("enum_flags_test"), "label", BindFlags.SYNC_CREATE);
	}
}
