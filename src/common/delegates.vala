namespace GData
{
	/**
	 * Simplest delegate possible with no parameters and no return value
	 * 
	 * @since 0.1
	 */
	public delegate void SimpleDelegate();

	/**
	 * Specifies simple delegate that passes search string
	 * 
	 * @since 0.1
	 * 
	 * @param search_for Specifies string being searhed
	 */
	public delegate void SearchDelegate (string search_for);

	/**
	 * Delegate being specified to StrictWeakReference upon its creation. This
	 * is called when target it points to becomes invalid
	 * 
	 * @since 0.1
	 */
	public delegate void WeakReferenceInvalid();

	/**
	 * Specifies simple delegate that passes searched object
	 * 
	 * @since 0.1
	 * 
	 * @param search_for Specifies object being searhed
	 */
//	public delegate bool ObjectFindDelegate (Object? search_for);

	/**
	 * Delegate to iterate lists
	 * 
	 * @since 0.1
	 * 
	 * @param object Object reference
	 */
//	public delegate void ForeachFunc (Object object);
	
	/**
	 * Delegate aimed at comparing two objects
	 * 
	 * @since 0.1
	 * 
	 * @param obj1 First object
	 * @param obj2 Second object
	 * @return -1 if smaller, 0 if equal, 1 if greater
	 */
//	public delegate int CompareObjectsFunc (Object? obj1, Object? obj2);
}
