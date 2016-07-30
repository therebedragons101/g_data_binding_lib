namespace G
{
	public class WeakReference<T> 
	{
		protected weak T? _target;
		public T? target { 
			get { return (_target); }
		}

		public WeakReference (T? set_to_target)
		{
			_target = set_to_target;
		}
	}
}
