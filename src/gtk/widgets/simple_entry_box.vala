namespace GDataGtk
{
	/**
	 * Simple popover containing entry with Apply button
	 * 
	 * @since 0.1
	 */
	[GtkTemplate (ui="/org/gtk/g_data_binding_gtk/data/simple_entry_box.ui")]
	public class SimpleEntryBox : Gtk.Box
	{
		[GtkChild] private Gtk.Label label;
		[GtkChild] private Gtk.Entry entry;
		[GtkChild] private Gtk.Button apply;

		/**
		 * Title
		 * 
		 * @since 0.1
		 */
		public string title {
			get { return (label.label); }
			set { label.label = value; }
		}

		/**
		 * Tooltip on entry widget
		 * 
		 * @since 0.1
		 */
		public string tooltip {
			set { entry.tooltip_text = value; }
		}

		/**
		 * Contents of entry widget
		 * 
		 * @since 0.1
		 */
		public string text {
			get { return (entry.text); }
			set { entry.text = value; }
		}

		/**
		 * Entry widget placeholder text
		 * 
		 * @since 0.1
		 */
		public string placeholder_text {
			get { return (entry.text); }
			set { entry.placeholder_text = value; }
		}

		public string confirmation_text {
			get { return (apply.label); }
			set { apply.label = value; }
		}

		/**
		 * Signal is emited whenever entry widget contents change
		 * 
		 * @since 0.1
		 */
		public signal void changed();

		/**
		 * Signal is emited when Apply button is pressed
		 * 
		 * @since 0.1
		 * 
		 * @param res Resulting text in entry widget
		 */
		public signal void confirmed (string res);

		/**
		 * Shows popover over specified widget that has contents set as defined
		 * 
		 * @since 0.1
		 * 
		 * @param relative_to Widget which popover should be relative to
		 * @param title Title
		 * @param tooltip Entry tooltip
		 * @param on_confirm Method being called when Apply button is pressed
		 * @param confirmation_text Option to specify custom button label
		 */
		public static void show_popover (Gtk.Widget relative_to, string title, string tooltip, GData.StringValueDelegate on_confirm, string confirmation_text = "Apply")
		{
			Gtk.Popover popover = new Gtk.Popover (relative_to);
			popover.position = Gtk.PositionType.BOTTOM;
			SimpleEntryBox box = new SimpleEntryBox();
			popover.add (box);
			box.confirmed.connect (() => {
				on_confirm(box.text);
				popover.hide();
			});
			box.margin_bottom = 8;
			box.margin_top = 8;
			box.margin_left = 8;
			box.margin_right = 8;
			box.title = title;
			box.tooltip = tooltip;
			box.confirmation_text = confirmation_text;
			box.visible = true;
			popover.modal = true;
			popover.show();
		}

		/**
		 * Creates SimpleEntryBox
		 * 
		 * @since 0.1
		 */
		public SimpleEntryBox()
		{
			apply.sensitive = false;
			label.notify["label"].connect (() => { notify_property("title"); });
			apply.notify["label"].connect (() => { notify_property("confirmation-text"); });
			entry.notify["text"].connect (() => { 
				notify_property("text"); 
				apply.sensitive = (entry.text != "");
			});
			entry.notify["placeholder-text"].connect (() => { notify_property("placeholder-text"); });
			entry.changed.connect (() => {
				changed();
			});
			apply.clicked.connect (() => {
				confirmed (text);
			});
		}
	}
}
