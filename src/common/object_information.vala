namespace GData
{
	/**
	 * Provides additional way of generalizing information about objects
	 * that implement this interface
	 *
	 * Note that this interface is in no way required for databinding
	 * and if specified on some class it will be used in binding inspector
	 *
	 * @since 0.1
	 */
	public interface ObjectInformation : Object
	{
		/**
		 * Returns object information string much like ToString() does in
		 * .Net
		 *
		 * @since 0.1
		 *
		 * @return Object information string
		 */
		public abstract string get_info();
	}
}
