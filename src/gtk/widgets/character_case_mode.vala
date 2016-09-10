namespace GDataGtk
{
	/**
	 * Specifies string display character case conversion
	 * 
	 * @since 0.1
	 */
	public enum CharacterCaseMode
	{
		/**
		 * Leave unchanged
		 * 
		 * @since 0.1
		 */
		UNCHANGED,
		/**
		 * Convert to upcase string
		 * 
		 * @since 0.1
		 */
		UPCASE,
		/**
		 * Upcases first character and replaces _ and - with space
		 * 
		 * @since 0.1
		 */
		PRESENTABLE,
		/**
		 * Convert to locase string
		 * 
		 * @since 0.1
		 */
		LOCASE
	}
}
