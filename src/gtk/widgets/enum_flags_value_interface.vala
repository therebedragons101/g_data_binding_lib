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
		public abstract int int_value { get; set; }
		public abstract uint uint_value { get; set; }
	}
}
