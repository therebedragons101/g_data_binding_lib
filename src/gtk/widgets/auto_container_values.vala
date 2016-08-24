namespace GDataGtk
{
	/**
	 * Provides simplest modeled container that can be used to easily create
	 * and map ListBox rows
	 * 
	 * @since 0.1
	 */
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/auto_container_values.ui")]
	public class AutoContainerValues : Gtk.Alignment
	{
		[GtkChild] Gtk.Box main_box;

		/**
		 * Specifies orientation of values
		 * 
		 * @since 0.1
		 */
		public Gtk.Orientation orientation {
			get { return (main_box.orientation); }
			set { main_box.orientation = value; }
		}

		/**
		 * Specifies spacing between values
		 * 
		 * @since 0.1
		 */
		public uint spacing {
			get { return (main_box.spacing); }
			set { main_box.spacing = value; }
		}

		/**
		 * Returns content container
		 * 
		 * @since 0.1
		 * 
		 * @return Content container
		 */
		public Gtk.Box get_content_container()
		{
			return (main_box);
		}

		/**
		 * Specifies internal content margins
		 * 
		 * @since 0.1
		 * 
		 * @param left Left margin
		 * @param top Top margin
		 * @param right Right margin
		 * @param bottom Bottom margin
		 */
		public void set_content_margins (int left, int top, int right, int bottom)
		{
			main_box.margin_left = left;
			main_box.margin_right = right;
			main_box.margin_top = top;
			main_box.margin_bottom = bottom;
		}

		public AutoContainerValues()
		{
		}
	}
}
