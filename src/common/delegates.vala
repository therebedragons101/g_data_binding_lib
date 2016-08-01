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
}
