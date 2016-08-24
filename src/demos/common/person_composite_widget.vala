namespace Demo
{
	[GtkTemplate(ui="/org/gtk/demo_and_tutorial/person_composite_widget.ui")]
	public class PersonCompositeWidget : Gtk.Grid
	{
		[GtkChild] private Gtk.Entry name;
		[GtkChild] private Gtk.Entry surname;
		[GtkChild] private Gtk.Entry required;
	}
}
