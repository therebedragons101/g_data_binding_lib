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

	/**
	 * Base class for row columns
	 * 
	 * @since 0.1
	 */
	public class RowColumn : Object
	{
		internal RowModel? model { get; internal set; default = null; }

		/**
		 * Specifies if column is visible or not
		 * 
		 * @since 0.1
		 */
		public bool visible { get; set; default = true; }

		/**
		 * Creates new RowColumn
		 * 
		 * @since 0.1
		 */
		public RowColumn()
		{
			
		}
	}

	/**
	 * Row model is base class to generate row representations in list widgets
	 * 
	 * @since 0.1
	 */
	public class RowModel : Object, GLib.ListModel
	{
		private GLib.Array<RowColumn> _columns = new GLib.Array<RowColumn>();

		/**
		 * Number of columns in row model
		 * 
		 * @since 0.1
		 */
		public uint length {
			get { return (_columns.length); }
		}

		/**
		 * Number of visible columns
		 * 
		 * @since 0.1
		 */
		public uint visible_length {
			get {
				uint cnt = 0;
				for (int i=0; i<_columns.length; i++)
					if (_columns.data[i].visible == true)
						cnt++; 
				return (cnt); 
			}
		}

		private int _find (RowColumn column)
		{
			for (int i=0; i<length; i++)
				if (column == _columns.data[i])
					return (i);
			return (-1);
		}

		/**
		 * Adds new binding to row model. Note that only source is passed here
		 * as creation and binding is controlled by registered handlers
		 * 
		 * @since 0.1
		 * 
		 */
		public RowModel add (RowColumn column)
		{
			if (_find(column) >= 0)
				return (this);
			_columns.append_val (column);
			items_changed (_columns.length-1, 0, 1);
			return (this);
		}

		/**
		 * Removes column from model
		 * 
		 * @since 0.1
		 * 
		 * @param column Column that needs to be removed
		 */
		public RowModel remove (RowColumn column)
		{
			remove_at (_find (column));
			return (this);
		}

		/**
		 * Removes columns at specified index from model
		 * 
		 * @since 0.1
		 * 
		 * @param index Index of column that needs to be removed
		 */
		public RowModel remove_at (int index)
		{
			if ((index < 0) || (index >= length))
				return (this);
			_columns.remove_index (index);
			items_changed (index, 1, 0);
			return (this);
		}

		/**
		 * Returns column at specified index or null if column does not exist
		 * 
		 * @since 0.1
		 */
		public RowColumn? get_at (int index)
		{
			if ((index < 0) || (index >= length))
				return (null);
			
			return (null);
		}

		/**
		 * -- Neeed for ListModel implementation --
		 * 
		 * Returns item at specified position
		 * 
		 * @since 0.1
		 * 
		 * @param position Item position
		 */
		public Object? get_item (uint position)
		{
			return (get_at ((int) position));
		}

		/**
		 * -- Neeed for ListModel implementation --
		 * 
		 * Returns item at specified position
		 * 
		 * @since 0.1
		 * 
		 * @param position Item position
		 */
		public virtual Type get_item_type ()
		{
			return (typeof(Object));
		}

		/**
		 * -- Neeed for ListModel implementation --
		 * 
		 * Returns item at specified position
		 * 
		 * @since 0.1
		 * 
		 * @param position Item position
		 */
		public uint get_n_items ()
		{
			return (length);
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

