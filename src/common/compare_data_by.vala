namespace G
{
	/**
	 * CompareDataBy specifies how objects stored in ObjectArray are compared
	 * in order to allow handling of unique elements
	 * 
	 * @since 0.1
	 */
	public enum CompareDataBy
	{
		/**
		 * Objects are compared by reference
		 * 
		 * @since 0.1
		 */
		REFERENCE,
		/**
		 * Object specify UniqueByProperties interfaces and are compared as such
		 * 
		 * @since 0.1
		 */
		UNIQUE_OBJECTS,
		/**
		 * Array was specified with custom comparison delegate
		 * 
		 * @since 0.1
		 */
		FUNCTION
	}
}
