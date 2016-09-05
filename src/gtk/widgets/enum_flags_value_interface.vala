namespace GDataGtk
{
	/**
	 * Convenience enum flags value interface
	 * 
	 * @since 0.1
	 */
	public interface EnumFlagsValueInterface : Object
	{
		/**
		 * Enum or Flags type being handled
		 * 
		 * @since 0.1
		 */
		public abstract Type? model_type { get; set; }
		/**
		 * int value of Flags or Enum
		 * 
		 * @since 0.1
		 */
		public abstract int int_value { get; set; }
		/**
		 * uint value of Flags or Enum
		 * 
		 * @since 0.1
		 */
		public abstract uint uint_value { get; set; }
	}
}
