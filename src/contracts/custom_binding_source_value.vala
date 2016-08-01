namespace GData
{
	/**
	 * CustomBindingSourceValue is one of value objects implementations. It
	 * serves as well as example on how to create custom value objects as having
	 * usable functionality. Unlike CustomBindingSourceData<T> this one uses
	 * GLib.Value for value type
	 * 
	 * Being derived from CustomPropertyNotificationBindingSource it also
	 * inherits all of its connection and awareness and adds only access to
	 * custom data and automates its recalculation
	 * 
	 * @since 0.1
	 */
	public class CustomBindingSourceValue : CustomPropertyNotificationBindingSource
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

		private GLib.Value? _data = null;
		/**
		 * Data for this value object. If value object is not valid (source set
		 * to null or any other reason on value calculation to fail) then 
		 * null_value is returned
		 * 
		 * @since 0.1
		 */
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
		public GLib.Value null_value {
			get { return (_null_value); }
		}

		private CustomBindingSourceValueFunc? _resolve_data = null;
		/**
		 * If resolve_data is set then this is primary method of value 
		 * recalculation
		 * 
		 * @since 0.1
		 */
		public CustomBindingSourceValueFunc? resolve_data {
			get { return (_resolve_data); }
			owned set {
				if (_resolve_data == value)
					return;
				_resolve_data = (owned) value;
				reset_data(); 
			}
		}

		private CompareValueFunc? _compare_func = null;
		/**
		 * Delegate used to compare value in order to enable cache possibility.
		 * If this is not specified this leads to more notifications as it is
		 * not possible to discern when value didn't change
		 * 
		 * Note that if this is not specified then default method is used where
		 * it tries to compare it with what is available on GLib.Value
		 * 
		 * @since 0.1
		 */
		public CompareValueFunc? compare_func {
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

		/**
		 * Creates new CustomBindingSourceValue
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
		public CustomBindingSourceValue (string name, BindingPointer source, owned CustomBindingSourceValueFunc? get_data_method, owned CompareValueFunc? compare_method, GLib.Value null_value,
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

