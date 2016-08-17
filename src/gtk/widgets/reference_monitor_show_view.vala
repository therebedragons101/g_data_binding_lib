namespace GDataGtk
{
	/**
	 * Specifies what information should be presented in reference monitor
	 * 
	 * @since 0.1
	 */
	[Flags]
	public enum ReferenceMonitorShowView
	{
		/**
		 * Specifies name should be displayed
		 * 
		 * @since 0.1
		 */
		NAME,
		/**
		 * Specifies description should be displayed
		 * 
		 * @since 0.1
		 */
		NOTIFICATION,
		/**
		 * Specifies reference should be displayed
		 * 
		 * @since 0.1
		 */
		REFERENCE,
		/**
		 * Specifies everything should be displayed
		 * 
		 * @since 0.1
		 */
		FULL = NAME | NOTIFICATION | REFERENCE
	}
}
