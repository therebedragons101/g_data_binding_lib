using GData;
using GData.Generics;

namespace GDataGtk
{
	[GtkTemplate (ui="/org/gtk/g_data_binding_gtk/data/object_events_row.ui")]
	public class ObjectEventsRow : Gtk.Box
	{
		private StrictWeakReference<TrackLogElement?> _wref = new StrictWeakReference<TrackLogElement?>(null);
		[GtkChild] private Gtk.Label type_label;
		[GtkChild] private Gtk.Label name_label;
		[GtkChild] private Gtk.Label consecutive;

		public string row_text {
			owned get { return ("%s %s".printf (type_label.label, name_label.label)); }
		}

		public ObjectEventsRow set_captions (string event_type, string event_name)
		{
			type_label.set_markup ("<span color='red'>%s</span>".printf(event_type));
			name_label.set_markup ("<b>%s</b>".printf(event_name));
			_binder().bind(_wref.target, "consecutive", consecutive, "label", BindFlags.SYNC_CREATE,
				((b, s, ref t) => {
					t.set_string ((s.get_int() > 1) ? bold("(%i)").printf(s.get_int()) : "");
					return (true);
				}));
			return (this);
		}

		public ObjectEventsRow (TrackLogElement element)
		{
			_wref.set_new_target (element);
			set_captions (element.element_type, element.name);
		}
	}
}
