namespace G
{
	public class CustomBindingSourceValue : CustomPropertyNotificationBindingSource
	{
		// direct access of value instead of caching
		private bool _always_refresh = false;
		public bool always_refresh {
			get { return (_always_refresh); }
		}

		private GLib.Value? _data = null;
		public GLib.Value data {
			get {
				if (always_refresh == true)
					reset_data(); 
				if (_data == null)
					return (null_value);
				return (_data); 
			}
		}

		private GLib.Value _null_value;
		public GLib.Value null_value {
			get { return (_null_value); }
		}

		// IN CASE WHEN compare_method IS NULL 
		// property notify for data change is not called as this should be handled
		// from resolve_data delegate to avoid whole mess of innacuracy
		private CustomBindingSourceDataFunc<GLib.Value?>? _resolve_data = null;
		public CustomBindingSourceDataFunc<GLib.Value?>? resolve_data {
			get { return (_resolve_data); }
			owned set {
				if (_resolve_data == value)
					return;
				_resolve_data = (owned) value;
				reset_data(); 
			}
		}

		private CompareFunc<GLib.Value?>? _compare_func = null;
		public CompareFunc<GLib.Value?>? compare_func {
			get { return (_compare_func); }
		}

		private void reset_data()
		{
			GLib.Value? dt = null;
			if (_resolve_data != null)
				dt = resolve_data<GLib.Value> (source);
			if (_compare_func != null) {
				if ((_data == null) && (dt == null))
					return;
				if (((_data == null) || (dt == null)) || (compare_func<GLib.Value?>(dt, _data) != 0)) {
					_data = dt;
					notify_property ("data");
				}
			}
			else
				_data = dt;
		}

		public CustomBindingSourceValue (string name, BindingPointer source, owned CustomBindingSourceDataFunc<GLib.Value?> get_data_method, owned CompareFunc<GLib.Value?>? compare_method, GLib.Value null_value,
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
