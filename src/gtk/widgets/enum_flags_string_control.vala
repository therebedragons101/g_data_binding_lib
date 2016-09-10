namespace GDataGtk
{
	/**
	 * Provides common control mechanism for group control of enum/flags
	 * representation to string
	 * 
	 * @since 0.1
	 */
	public class EnumFlagsStringControl : Object, EnumFlagsStringInterface
	{
		/**
		 * Specifies how OR should be represented in string
		 * 
		 * @since 0.1
		 */
		public string or_definition { get; set; default = " | "; }
		/**
		 * Specifies character case conversion if any
		 * 
		 * @since 0.1
		 */
		public CharacterCaseMode character_case { get; set; default = CharacterCaseMode.PRESENTABLE; }
		/**
		 * Specifies mode of value representation that can be either VALUE,
		 * NAME, NICK or CUSTOM
		 * 
		 * @since 0.1
		 */
		public EnumFlagsMode mode { get; set; default = EnumFlagsMode.NICK; }
	}
}
