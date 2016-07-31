namespace G.Data
{
	/**
	 * Simplest delegate possible with no parameters and no return value
	 * 
	 * @since 0.1
	 */
	public delegate void SimpleDelegate();

	/**
	 * Simplest delegate possible with no return value and specifying passed
	 * value
	 * 
	 * @since 0.1
	 * 
	 * @param data Specifies data being passed with delegate
	 */
	public delegate void SimplePassDataDelegate<T>(T data);

	/**
	 * Specifies simple delegate that passes search string
	 * 
	 * @since 0.1
	 * 
	 * @param search_for Specifies string being searhed
	 */
	public delegate void SearchDelegate (string search_for);

	/**
	 * Specifies simple delegate that passes searched object
	 * 
	 * @since 0.1
	 * 
	 * @param search_for Specifies object being searhed
	 */
	public delegate bool FindObjectDelegate<T> (T search_for);

	/**
	 * Delegate being specified to StrictWeakReference upon its creation. This
	 * is called when target it points to becomes invalid
	 * 
	 * @since 0.1
	 */
	public delegate void WeakReferenceInvalid();
}
