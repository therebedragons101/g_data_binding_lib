namespace GDataGtk
{
	/**
	 * List box row for ObjectInspectorRow
	 * 
	 * @since 0.1
	 */
	public class ObjectInspectorListBoxRow : SmoothListBoxRow
	{
		private ObjectInspectorRow? _row = null;
		/**
		 * Returns reference to row contents
		 * 
		 * @since 0.1
		 */
		public ObjectInspectorRow row {
			get { return (_row); }
		}

		/**
		 * Returns whole text represented in ObjectInspectorRow for search
		 * purposes
		 * 
		 * @since 0.1
		 */
		public string text
		{
			owned get {
				if (row == null)
					return ("");
				return (row.text);
			}
		}

		/**
		 * Returns true if row is filled manually
		 * 
		 * @since 0.1
		 */
		public bool manual {
			get { return (row.manual); }
		}

		/**
		 * Creates new ObjectInspectorListBoxRow
		 * 
		 * @since 0.1
		 * 
		 * @param row Description row
		 */
		public ObjectInspectorListBoxRow (ObjectInspectorRow? row)
		{
			base (row);
			this._row = row;
			if (row != null) {
				get_container().pack_start (row, true, true);
				row.visible = true;
			}
			else
				visible = false;
			assign_css (this, """
					row {
					padding: 0px 0px 0px 0px;
				}
			""");
		}
	}
}
