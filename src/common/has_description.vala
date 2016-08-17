namespace GData
{
	/**
	 * Provides unified point for objects that have description property
	 * 
	 * @since 0.1
	 */
	public interface HasDescription : Object
	{
		/**
		 * Description text
		 * 
		 * @since 0.1
		 */
		public abstract string description { owned get; }
	}
}
