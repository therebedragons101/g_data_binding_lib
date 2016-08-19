namespace GData
{
	/**
	 * Defines proxy access to one specific property and relays notifications
	 * that are connected to it
	 * 
	 * Note that proxy respects not only direct object connection, but pointer
	 * and contract as well. If connected object is pointer or contract then
	 * property proxy follows all changes to data source and updates connected
	 * party
	 * 
	 * @since 0.1
	 */
	public class ProxyProperty : Object
	{
		private ulong signal_handler_id = 0;
		private StrictWeakRef _wref;
		private ParamSpec? parm = null;

		private GLib.Value? _invalid_value = null;
		private GLib.Value? __invalid_value = null;

		/**
		 * Returns value specified as invalid
		 * 
		 * @since 0.1
		 */
		public GLib.Value get_invalid_value()
		{
			if (__invalid_value == null) {
				if (is_valid() == true) {
					__invalid_value = GLib.Value (parm.value_type);
					if (GLib.Value.type_compatible(_invalid_value.type(), __invalid_value.type()) == true)
						_invalid_value.copy (ref __invalid_value);
					if (GLib.Value.type_transformable(_invalid_value.type(), __invalid_value.type()) == true)
						_invalid_value.transform (ref __invalid_value);
				}
			}
			return (__invalid_value);
		}

		/**
		 * Provides direct access to connected object by always providing
		 * end point of chain in case if connected object is source pointed by
		 * contract or pointer
		 * 
		 * @since 0.1
		 * 
		 * @return Connected object
		 */
		public Object? get_connected_object()
		{
			if (is_binding_pointer(_wref.target) == true)
				return (as_pointer_source(_wref.target));
			return (_wref.target);
		}

		/**
		 * Returns ParamSpec of connected property or null if not connected
		 * 
		 * @since 0.1
		 */
		public ParamSpec? connected_property_pspec {
			get {
				if (signal_handler_id == 0)
					return (null);
				return (parm);
			}
		}

		/**
		 * Connected property
		 * 
		 * @since 0.1
		 */
		public string connected_property {
			get { return ((parm != null) ? parm.name : ""); }
		}

		private bool _bidirectional = true;
		/**
		 * Specifies if assignment is bidirectional or not
		 * 
		 * @since 0.1
		 */
		public bool bidirectional {
			get { return (_bidirectional); }
		}

		/**
		 * Specifies value type
		 * 
		 * @since 0.1
		 */
		public Type value_type {
			get {
				if (parm == null)
					return (Type.INVALID);
				return (parm.value_type); 
			}
		}

		public bool is_valid()
		{
			return ((_wref.is_valid_ref() == true) && 
			        (parm != null) &&
			        (get_connected_object() != null));
		}

		/**
		 * Gets property value in connected object. For access to object 
		 * reference get_connected_object() should be used
		 * 
		 * @since 0.1
		 * @param val Property value
		 */
		public virtual bool get_property_value (ref GLib.Value val)
		{
			if (is_valid() == false) {
				if (_invalid_value.type() != Type.INVALID)
					_invalid_value.transform (ref val);
				return (false);
			}
			GLib.Value nval = GLib.Value(parm.value_type);
			get_connected_object().get_property (parm.name, ref nval);
			if (copy_or_transform_value (nval, ref val) == true)
				return (true);
			GLib.warning ("ProxyProperty.get_property_value().Incompatible types");
			return (false);
		}

		/**
		 * Sets property value in connected object. For access to object 
		 * reference get_connected_object() should be used
		 * 
		 * @since 0.1
		 * @param val Property value
		 */
		public virtual void set_property_value (GLib.Value val)
		{
			if (is_valid() == false)
				return;
			GLib.Value nval = GLib.Value(parm.value_type);
			if (copy_or_transform_value(val, ref nval) == true)
				get_connected_object().set_property (parm.name, nval);
			else
				GLib.warning ("ProxyProperty.get_property_value().Incompatible types");
		}

		/**
		 * Unbinds connection
		 * 
		 * @since 0.1
		 */
		public void unbind()
		{
			if (signal_handler_id != 0)
				if (SignalHandler.is_connected(get_connected_object(), signal_handler_id) == true)
					SignalHandler.disconnect (get_connected_object(), signal_handler_id);
			signal_handler_id = 0;
			__invalid_value = GLib.Value(Type.INVALID);
			value_changed();
		}

		private void property_changed()
		{
			value_changed();
		}

		/**
		 * Signal is emited when connected property changes
		 * 
		 * @since 0.1
		 */
		public signal void value_changed();

		~ProxyProperty()
		{
			unbind();
		}

		/**
		 * Creates object for sole purpose of tracking one single property and
		 * allowing that tracking to respect pointer/contract source changes
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object or pointer/contract that owns property
		 * @param property_name Property name
		 * @param invalid_value Specifies value which should be returned on
		 *                      momentary invalid state machine (aka. source
		 *                      being pointer/contract but pointing to null)
		 * @param bidirectional Specifies if state machines are bidirectional or
		 *                      not
		 * @param restrict_to Type safety. If property type is not transformable
		 *                    to that type it will act like connection never
		 *                    happened
		 */
		public ProxyProperty (Object obj, string property_name, GLib.Value invalid_value, bool bidirectional = true, Type restrict_to = GLib.Type.INVALID)
		{
			_invalid_value = GLib.Value (invalid_value.type());
			bool fail = copy_or_transform_value (invalid_value, ref _invalid_value);

			if ((restrict_to != Type.INVALID) && (can_translate_value_type(_invalid_value.type(), restrict_to) == false)) {
				GLib.warning ("Specified invalid value of type (%s) for proxy property is not transformable to (%s)", invalid_value.type().name(), restrict_to.name());
				_invalid_value = GLib.Value (restrict_to);
			}
			_wref = new StrictWeakRef (obj);
			_bidirectional = bidirectional;
			string _original_property_name = property_name;
			if (is_binding_pointer(_wref.target) == true) {
				parm = TypeInformation.get_instance().find_typesafe_property_from_ref (as_pointer_source(_wref.target), _original_property_name, restrict_to);
				if ((parm != null) && (as_pointer_source(_wref.target) != null))
					Signal.connect_swapped(as_pointer_source(_wref.target), "notify::" + parm.name, (Callback) property_changed, this);
				as_pointer(obj).before_source_change.connect ((b, i, n) => {
					unbind();
				});
				as_pointer(obj).source_changed.connect ((b) => {
					parm = TypeInformation.get_instance().find_typesafe_property_from_ref (as_pointer_source(_wref.target), _original_property_name, restrict_to);
					if (parm != null)
						Signal.connect_swapped(as_pointer_source(_wref.target), "notify::" + parm.name, (Callback) property_changed, this);
					value_changed();
				});
			}
			else {
				parm = TypeInformation.get_instance().find_typesafe_property_from_ref (_wref.target, _original_property_name, restrict_to);
				if (parm != null)
					Signal.connect_swapped(_wref.target, "notify::" + parm.name, (Callback) property_changed, this);
			}
			value_changed();
		}
	}
}

