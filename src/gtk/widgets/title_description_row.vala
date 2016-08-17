namespace GDataGtk
{
	/**
	 * Provides simple ListBox row where title and description are aligned
	 * vertically
	 * 
	 * @since 0.1
	 */
	[GtkTemplate (ui="/org/gtk/g_data_binding_gtk/data/title_description_row.ui")]
	public class TitleDescriptionRow : Gtk.Box
	{
		[GtkChild] private Gtk.Label title_label;
		[GtkChild] private Gtk.Label description_label;
		[GtkChild] private Gtk.Revealer description_revealer;

		/**
		 * Row title
		 * 
		 * @since 0.1
		 */
		public string title { 
			get { return (title_label.label); }
			set { title_label.set_markup(value); } 
		}

		/**
		 * Row description
		 * 
		 * @since 0.1
		 */
		public string description { 
			get { return (description_label.label); }
			set { description_label.set_markup(value); } 
		}

		/**
		 * Specifies if row description is visible or not
		 * 
		 * @since 0.1
		 */
		public bool show_description { 
			get { return (description_revealer.reveal_child); }
			set { description_revealer.reveal_child = value; } 
		}

		/**
		 * Returns text contents of both labels
		 * 
		 * @since 0.1
		 */
		public string get_text()
		{
			string s = remove_markup(title + ((description_revealer.reveal_child == true) ? (" " + description) : ""));
			return (s);
		}

		private string remove_markup (string str)
		{
			string s = str;
			while ((s.index_of("<") >= 0) && (s.index_of(">") >= 2))
				s = s.splice (s.index_of("<"), s.index_of(">"));
			return (s);
		}

		/**
		 * Creates TitleDescriptionRow with ability to preset values
		 * 
		 * @since 0.1
		 * 
		 * @param title Row title
		 * @param description Row description
		 * @param show_description Specifies if description is revealed or not
		 */
		public TitleDescriptionRow.with_text (string title, string description = "", bool show_description = true)
		{
			this();
			this.title = title;
			this.description = description;
			this.show_description = show_description;
		}

		/**
		 * Creates TitleDescriptionRow
		 * 
		 * @since 0.1
		 */
		public TitleDescriptionRow()
		{
		}
	}
}

