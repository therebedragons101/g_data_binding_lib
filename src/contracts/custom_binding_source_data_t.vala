namespace G
{
	// in C rewrite this probably shouldn't be included. Only purpose of this being
	// here is to have more options for POC demo. This class might as well be reimplemented
	// in Vala at any time if needed 
	public class CustomBindingSourceData<T> : CustomPropertyNotificationBindingSource
	{
		// direct access of value instead of caching
		private bool _always_refresh = false;
		public bool always_refresh {
			get { return (_always_refresh); }
		}

		private T? _data = null;
		public T data {
			get {
				if (always_refresh == true)
					reset_data(); 
				if (_data == null)
					return (null_value);
				return (_data); 
			}
		}

		private T _null_value;
		public T null_value {
			get { return (_null_value); }
		}

		// IN CASE WHEN compare_method IS NULL 
		// property notify for data change is not called as this should be handled
		// from resolve_data delegate to avoid whole mess of innacuracy
		private CustomBindingSourceDataFunc<T>? _resolve_data = null;
		public CustomBindingSourceDataFunc<T>? resolve_data {
			get { return (_resolve_data); }
			owned set {
				if (_resolve_data == value)
					return;
				_resolve_data = (owned) value;
				reset_data(); 
			}
		}

		private CompareFunc<T>? _compare_func = null;
		public CompareFunc<T>? compare_func {
			get { return (_compare_func); }
		}

		private void reset_data()
		{
			T? dt = null;
			if (_resolve_data != null)
				dt = resolve_data<T> (source);
			if (_compare_func != null) {
				if ((_data == null) && (dt == null))
					return;
				if (((_data == null) || (dt == null)) || (compare_func<T>(dt, _data) != 0)) {
					_data = dt;
					notify_property ("data");
				}
			}
			else
				_data = dt;
		}

		public CustomBindingSourceData (string name, BindingPointer source, owned CustomBindingSourceDataFunc<T> get_data_method, owned CompareFunc<T>? compare_method, T null_value,
		                                bool always_refresh = false, string[]? connected_properties = null)
		{
			base (name, source, connected_properties);
			_null_value = null_value;
			_always_refresh = always_refresh;
			_resolve_data = (owned) get_data_method;
			_compare_func = (owned) compare_method;
			properties_changed.connect (reset_data);
			reset_data();
		}
	}
}
