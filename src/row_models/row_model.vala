namespace GData
{
	/**
	 * Specifies orientation how row should treat building when it needs to fill
	 * row
	 * 
	 * @since 0.1
	 */
	public enum RowOrientation
	{
		/**
		 * Horizontally aligned row
		 * 
		 * @since 0.1
		 */
		HORIZONTAL,
		/**
		 * Vertically aligned row
		 * 
		 * @since 0.1
		 */
		VERTICAL
	}

	public class RowColumn : Object
	{
		internal RowModel? model { get; internal set; default = null; }

		public RowColumn()
		{
			
		}
	}

	public class RowModel : Object
	{
		private GLib.Array<RowColumn> _columns = new GLib.Array<RowColumn>();

		/**
		 * Adds new binding to row model. Note that only source is passed here
		 * as creation and binding is controlled by registered handlers
		 * 
		 * @since 0.1
		 * 
		 */
		public RowModel add (RowColumn column)
		{
			return (this);
		}

		/**
		 * Creates new RowModel
		 * 
		 * @since 0.1
		 * 
		 * @param orientation Specifies row orientation
		 */
		public RowModel(RowOrientation orientation)
		{
		}
	}
}

