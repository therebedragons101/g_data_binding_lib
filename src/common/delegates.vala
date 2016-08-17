namespace GData
{
	/**
	 * Simplest delegate possible with no parameters and no return value
	 * 
	 * @since 0.1
	 */
	public delegate void SimpleDelegate();

	/**
	 * Specifies delegate passing boolean value
	 * 
	 * @since 0.1
	 * 
	 * @param val Value
	 */
	public delegate void BoolValueDelegate (bool val);

	/**
	 * Specifies delegate passing int value
	 * 
	 * @since 0.1
	 * 
	 * @param val Value
	 */
	public delegate void IntValueDelegate (int val);

	/**
	 * Specifies delegate passing string value
	 * 
	 * @since 0.1
	 * 
	 * @param val Value
	 */
	public delegate void StringValueDelegate (string val);

	/**
	 * Specifies delegate passing GLib.Value type of value
	 * 
	 * @since 0.1
	 * 
	 * @param val Value
	 */
	public delegate void ValueDelegate (GLib.Value val);

	/**
	 * Specifies delegate passing object value
	 * 
	 * @since 0.1
	 * 
	 * @param val Value
	 */
	public delegate void ObjectValueDelegate (Object? val);

	/**
	 * Specifies method to get object description
	 * 
	 * @since 0.1
	 * 
	 * @param obj Object needing description
	 * @param use_markup If string needs to be represented as markup or not
	 * @return Object description
	 */
	public delegate string GetObjectDescriptionStringDelegate (Object? obj, bool use_markup);

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

	public delegate void ObjectIterationFunc (Object obj);

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
