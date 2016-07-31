namespace G.Data
{
	// class used to store bindings in contracts. adds locking so
	// same binding can be added more than once and then removed 
	// only when lock drops to zero
	internal class BindingInformationReference
	{
		private int _lock_count = 1;
		public int lock_count {
			get { return (_lock_count); }
		}

		private BindingInformationInterface? _binding = null;
		public BindingInformationInterface? binding {
			get { return (_binding); }
		}

		public void lock()
		{
			_lock_count++;
		}

		public void unlock()
		{
			_lock_count--;
		}

		public void full_unlock()
		{
			_lock_count = 0;
		}

/*		public void reset()
		{
			_binding = null;
		}*/

		~BindingInformationReference()
		{
			_binding = null;
		}

		public BindingInformationReference (BindingInformationInterface binding)
		{
			_binding = binding;
		}
	}
}
