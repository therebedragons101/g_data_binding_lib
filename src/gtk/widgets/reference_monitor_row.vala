using GData;
using GData.Generics;

namespace GDataGtk
{
	/**
	 * Reference monitor row used in object inspector
	 * 
	 * @since 0.1
	 */
	[GtkTemplate (ui="/org/gtk/g_data_binding_gtk/data/reference_monitor_row.ui")]
	public class ReferenceMonitorRow : Gtk.Box
	{
		private StrictWeakReference<ReferenceMonitor?> _ref = new StrictWeakReference<ReferenceMonitor?> (null);

		[GtkChild] private Gtk.Label name_label;
		[GtkChild] private Gtk.Label notification_label;
		[GtkChild] private Gtk.Label ref_count_label;
		[GtkChild] private Gtk.Revealer name_revealer;
		[GtkChild] private Gtk.Revealer notification_revealer;
		[GtkChild] private Gtk.Revealer ref_count_revealer;

		/**
		 * Show/hide name
		 * 
		 * @since 0.1
		 */
		public bool show_name { get; set; }
		/**
		 * Show/hide notification
		 * 
		 * @since 0.1
		 */
		public bool show_notification { get; set; }
		/**
		 * Show/hide reference
		 * 
		 * @since 0.1
		 */
		public bool show_reference { get; set; }

		/**
		 * Creates new ReferenceMonitorRow with specified monitor
		 * 
		 * @since 0.1
		 * 
		 * @param monitor Monitor being displayed
		 */
		public ReferenceMonitorRow (ReferenceMonitor monitor)
		{
			_ref.set_new_target (monitor);
			_binder().bind (monitor, "object-name", name_label, "label", BindFlags.SYNC_CREATE);
			_binder().bind (monitor, "notification", notification_label, "label", BindFlags.SYNC_CREATE);
			_binder().bind (monitor, "reference-count", ref_count_label, "label", BindFlags.SYNC_CREATE,
				(b, s, ref t) => {
					t.set_string(bold("%i").printf (s.get_int()));
					return (true);
				});
			_binder().bind (this, "show-name", name_revealer, "reveal-child", BindFlags.SYNC_CREATE);
			_binder().bind (this, "show-notification", notification_revealer, "reveal-child", BindFlags.SYNC_CREATE);
			_binder().bind (this, "show-reference", ref_count_revealer, "reveal-child", BindFlags.SYNC_CREATE);
		}
	}
}
