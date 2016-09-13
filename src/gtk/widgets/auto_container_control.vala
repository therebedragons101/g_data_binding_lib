namespace GDataGtk
{
	/**
	 * Controls defaults over how widgets are displayed in auto container
	 * 
	 * @since 0.1
	 */
	public class AutoContainerControl : EditModeControl
	{
		/**
		 * Specifies if auto widget labels are visible or not
		 * 
		 * @since 0.1
		 */
		public bool show_labels { get; set; default = true; }
		/**
		 * Specifies if auto widget tools are visible or not
		 * 
		 * @since 0.1
		 */
		public bool show_tools { get; set; default = true; }
		/**
		 * Specifies label horizontal alignment
		 * 
		 * @since 0.1
		 */
		public Gtk.Align label_halignment { get; set; default = Gtk.Align.END; }
		/**
		 * Specifies label vertical alignment
		 * 
		 * @since 0.1
		 */
		public Gtk.Align label_valignment { get; set; default = Gtk.Align.CENTER; }
		/**
		 * Specifies opacity of label widgets
		 * 
		 * @since 0.1
		 */
		public double label_opacity { get; set; default = 0.7f; }
		/**
		 * Specifies if labels use markup or not
		 * 
		 * @since 0.1
		 */
		public bool labels_use_markup { get; set; default = true; }
		/**
		 * Encasing format for label markup. Use %s to specify label text
		 * position. This is meant to provide uniform look over all labels
		 * 
		 * Example:
		 * "<small>%s</small>"
		 * 
		 * @since 0.1
		 */
		public string label_markup_format { get; set; default = ""; }
		/**
		 * Specifies is tooltips should be assigned if available
		 * 
		 * @since 0.1
		 */
		public bool show_tooltips { get; set; default = true; }
		/**
		 * Specifies if tooltips use markup or not
		 * 
		 * @since 0.1
		 */
		public bool tooltip_use_markup { get; set; default = true; }
		/**
		 * Specifies orientation between label and value editor
		 * 
		 * @since 0.1
		 */
		public Gtk.Orientation orientation { get; set; default = Gtk.Orientation.HORIZONTAL; }
	}
}

