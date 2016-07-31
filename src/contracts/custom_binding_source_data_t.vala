namespace G.Data
{
	/**
	 * CustomBindingSourceData<T> is one of value objects implementations. It
	 * serves as well as example on how to create custom value objects as having
	 * usable functionality.
	 * 
	 * Being derived from CustomPropertyNotificationBindingSource it also
	 * inherits all of its connection and awareness and adds only access to
	 * custom data and automates its recalculation
	 * 
	 * @since 0.1
	 */
	public class CustomBindingSourceData<T> : CustomPropertyNotificationBindingSource
	{
		private bool _always_refresh = false;
		/**
		 * Specifies if value shoud be cached as much as possible or 
		 * recalculated each time. Even when cached, recalculation will still
		 * occur at crucial points
		 * 
		 * @since 0.1
		 */
		public bool always_refresh {
			get { return (_always_refresh); }
		}

		private T? _data = null;
		/**
		 * Data for this value object. If value object is not valid (source set
		 * to null or any other reason on value calculation to fail) then 
		 * null_value is returned
		 * 
		 * @since 0.1
		 */
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
		/**
		 * Custom null value, so object can represent it self even in invalid
		 * mode. This way application gets relieved of tedious checking.
		 * 
		 * Example:
		 * With <string> null value could be set to "Unavailable" and then any
		 * widget connected to value object will get automatical visual state
		 * representation
		 *
		 * @since 0.1
		 */
		public T null_value {
			get { return (_null_value); }
		}

		private CustomBindingSourceDataFunc<T>? _resolve_data = null;
		/**
		 * If resolve_data is set then this is primary method of data 
		 * recalculation
		 * 
		 * @since 0.1
		 */
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
		/**
		 * Delegate used to compare value in order to enable cache possibility.
		 * If this is not specified this leads to more notifications as it is
		 * not possible to discern when value didn't change
		 * 
		 * @since 0.1
		 */
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

		/**
		 * Creates new CustomBindingSourceData
		 * 
		 * @since 0.1
		 * @param name Value object name
		 * @param source Binding pointer this object is connected to
		 * @param get_data_method Method used to calculate data
		 * @param always_refresh Specifies if value should be cached or not
		 * @param connected_properties Property names to which signals value
		 *                             object should connect. Specify
		 *                             ALL_PROPERTIES or null for cases when
		 *                             all or none are to be used.
		 */ 
		public CustomBindingSourceData (string name, BindingPointer source, owned CustomBindingSourceDataFunc<T> get_data_method, owned CompareFunc<T>? compare_method, T null_value,
		                                bool always_refresh = false, string[]? connected_properties = null)
		{
			base (name, source, connected_properties);
			_null_value = null_value;
			_always_refresh = always_refresh;
			_resolve_data = (owned) get_data_method;
			_compare_func = (owned) compare_method;
			properties_changed.connect (reset_data);
			manual_recalculation.connect (reset_data);
			reset_data();
		}
	}
}
