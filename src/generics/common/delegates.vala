namespace GData.Generics
{
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
	 * Specifies simple delegate that passes searched object
	 * 
	 * @since 0.1
	 * 
	 * @param search_for Specifies object being searhed
	 */
	public delegate bool FindObjectDelegate<T> (T search_for);
}
