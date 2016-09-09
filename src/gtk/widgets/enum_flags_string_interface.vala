namespace GDataGtk
{
	/**
	 * Provides control interface for enum/flags string representations
	 * 
	 * @since 0.1
	 */
	public interface EnumFlagsStringInterface : Object
	{
		/**
		 * Specifies how OR should be represented in string
		 * 
		 * @since 0.1
		 */
		public abstract string or_definition { get; set; }
		/**
		 * Specifies character case conversion if any
		 * 
		 * @since 0.1
		 */
		public abstract CharacterCaseMode character_case { get; set; }
		/**
		 * Specifies mode of value representation that can be either VALUE,
		 * NAME, NICK or CUSTOM
		 * 
		 * @since 0.1
		 */
		public abstract EnumFlagsMode mode { get; set; }
	}
}
