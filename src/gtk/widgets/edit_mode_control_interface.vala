namespace GDataGtk
{
	/**
	 * Simple edit mode control object for auto widgets in cases when there is 
	 * no actual data binding or when it needs to be manipulated externally
	 * 
	 * @since 0.1
	 */
	public interface EditModeControlInterface : Object
	{
		/**
		 * Specifies edit mode
		 * 
		 * @since 0.1
		 */
		public abstract EditMode mode { get; set; }

		/**
		 * Convenience boolean access to mode property
		 * 
		 * @since 0.1
		 */
		public bool editing {
			get { return (mode == EditMode.EDIT); }
			set { mode = (value == true) ? EditMode.EDIT : EditMode.VIEW; return; }
		}

		/**
		 * Inverts current state between edit and view
		 * 
		 * @since 0.1
		 */
		public void invert()
		{
			mode = (mode == EditMode.VIEW) ? EditMode.EDIT : EditMode.VIEW;
		}
	}
}

