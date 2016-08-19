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
		private GLib.Value _invalid_value = 0;
		private ParamSpec? parm = null;

		/**
		 * Provides direct access to connected object by always providing
		 * end point of chain in case if connected object is source pointed by
		 * contract or pointer
		 * 
		 * @since 0.1
		 * 
		 * @return Connected object
		 */
		public weak Object? get_connected_object() 
		{
			if (is_binding_pointer(_wref.target) == true)
				return (as_pointer_source(_wref.target));
			return (_wref.target);
		}

		/**
		 * Connected property
		 * 
		 * @since 0.1
		 */
		public string connected_property {
			get { return ((parm != null) ? parm.name : ""); }
		}

		private BindingInterface? _prop_binding = null;

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

		private GLib.Value _property_value;
		/**
		 * Value of property in connected object.
		 * 
		 * @since 0.1
		 */
		protected GLib.Value property_value {
			get {
				_copy = GLib.Value(_property_value.value_type);
				if ((_prop_binding != null) && (_wref.is_valid_ref() == true)) {
					if (get_property_value (connected_object, parm, ref _copy) == true)
						return (_copy);
				}
				_invalid_value.copy (ref _copy);
				return (_copy);
			}
			set {
				if (_bidirectional == true) {
					set_property_value (connected_object, parm, value);
					// this should already emit signal as feedback
				}
				// omit signal
				return;
			}
		}

		/**
		 * Returns connected property value. For access to object reference
		 * 
		 * @since 0.1
		 * 
		 * @param pspec ParamSpec of connected property
		 * @param val Property value
		 * @return True if value copy was made, false if not
		 */
		protected virtual bool get_property_value (ParamSpec? pspec, ref GLib.Value val)
		{
			if (connected_object == null)
				return (false);
			connected_object.get_property (pspec.name, ref val);
		}

		/**
		 * Sets property value in connected object
		 * 
		 * @since 0.1
		 * @param pspec ParamSpec of connected property
		 * @param val Property value
		 */
		protected virtual void set_property_value (weak Object? obj, ParamSpec? pspec, GLib.Value val)
		{
			obj.set_property (pspec.name, val);
		}

		/**
		 * Unbinds connection
		 * 
		 * @since 0.1
		 */
		public void unbind()
		{
			if (signal_handler_id != null)
				if (SignalHandler.is_connected(connected_object, signal_handler_id) == true)
					SignalHandler.disconnect (connected_object, signal_handler_id);
			signal_handler_id = 0;
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

		~BoundPropertyValue()
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
		 */
		public ProxyProperty (Object obj, string property_name, GLib.Value invalid_value, bool bidirectional = true)
		{
			_invalid_value = GLib.Value (typeof(invalid_value.value_type));
			invalid_value.copy (ref _invalid_value);
			_property_name = property_name;
			_wref = new StrictWeakRef (obj);
			_bidirectional = bidirectional;
			string _original_property_name = property_name;
			if (is_binding_pointer(_wref.target) == true) {
				parm = TypeInformation.get_instance().find_property_from_ref (as_pointer_source(_wref.target), _original_property_name);
				if ((parm != null) && (as_pointer_source(_wref.target) != null))
					Signal.connect_swapped(as_pointer_source(_wref.target), "notify::" + parm.name, property_changed, this);
				as_pointer(obj).before_source_change.connect ((b, i, n) => {
					unbind();
				});
				as_pointer(obj).source_changed.connect ((b) => {
					parm = TypeInformation.get_instance().find_property_from_ref (as_pointer_source(_wref.target), _original_property_name);
					if (parm != null) {
						Signal.connect_swapped(as_pointer_source(_wref.target), "notify::" + parm.name, property_changed, this);
						_property_value = GLib.Value (parm.value_type);
					}
					value_changed();
				});
			}
			else {
				parm = TypeInformation.get_instance().find_property_from_ref (_wref.target, _original_property_name);
				if (parm != null) {
					Signal.connect_swapped(_wref.target, "notify::" + parm.name, property_changed, this);
			}
			if (parm != null)
				_property_value = GLib.Value (parm.value_type);
			value_changed();
		}
	}
}

