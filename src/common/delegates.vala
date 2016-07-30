namespace G
{
	public delegate void SimpleDelegate();

	public delegate void SimplePassDataDelegate<T>(T data);

	public delegate void SearchDelegate (string search_for);

	public delegate bool FindObjectDelegate<T> (T data);

	public delegate void WeakReferenceInvalid();
}
