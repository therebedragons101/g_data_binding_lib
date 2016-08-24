namespace GDataGtk
{
	/**
	 * Specifies editing mode
	 * 
	 * @since 0.1
	 */
	[Flags]
	public enum CreationEditMode
	{
		/**
		 * View mode only
		 * 
		 * @since 0.1
		 */
		VIEW,
		/**
		 * Edit mode enabled
		 * 
		 * @since 0.1
		 */
		EDIT,
		/**
		 * Read/write mode enabled
		 * 
		 * @since 0.1
		 */
		FULL = VIEW | EDIT
	}
}
