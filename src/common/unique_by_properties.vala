namespace G.Data
{
	/**
	 * UniqueByProperies is helper interface for ObjectArray and its only
	 * purpose is to enable definition of objects which can be compared
	 * by properties in uniform fashion
	 * 
	 * @since 0.1
	 */
	public interface UniqueByProperies : Object
	{
		/**
		 * Compares its value with another object that has UniqueByProperies
		 * interface implementation
		 * 
		 * @since 0.1
		 * @param object Object being compared to
		 * @return -1 if smaller, 0 if equal, 1 if greater
		 */
		public abstract int compare_to (UniqueByProperies object);
	}
}
