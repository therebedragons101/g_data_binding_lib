namespace GData
{
	/**
	 * Handles transfer between for GSettings objects. If for some reason 
	 * binding needs to be bound to original source when binding with objects
	 * of this type it is possible if binding specifies 
	 * BindFlags.USE_ORIGINAL_SOURCE_TYPE or BindFlags.USE_ORIGINAL_TARGET_TYPE
	 * respectively based on which side of binding it is. In that case data 
	 * transfer creation is redirected to GObject type of data transfer
	 * 
	 * While GSettings has its own limited binding capabilities, this brings
	 * unified way of binding them as well as all the other capabilities
	 * 
	 * TODO, String array is not handled. Need some example case
	 * 
	 * @since 0.1
	 */
	public class GSettingsBindingDataTransfer : BindingDataTransfer
	{
		private string __key = "";
		private string _name = "";
		private string _summary = "";
		private string _description = "";
		private ParamFlags _flags = GLib.ParamFlags.READABLE;
		private SettingsSchemaKey? _key = null;
		private Type data_type = Type.INVALID;
		private ulong signal_handler_id = 0;
		private ulong signal_handler_id2 = 0;

		/**
		 * Simple recast of get_object() to GLib.Setting
		 * 
		 * @since 0.1
		 */
		protected GLib.Settings get_settings()
		{
			return ((GLib.Settings) get_object());
		}

		/**
		 * Returns property name
		 * 
		 * @since 0.1
		 * 
		 * @return Property name
		 */
		public override string get_name()
		{
			return (_name);
		}

		/**
		 * Returns property nick
		 * 
		 * @since 0.1
		 * 
		 * @return Property nick
		 */
		public override string get_nick()
		{
			return (_summary);
		}

		/**
		 * Returns property blurb
		 * 
		 * @since 0.1
		 * 
		 * @return Property blurb
		 */
		public override string get_blurb()
		{
			return (_description);
		}

		/**
		 * Returns property value type
		 * 
		 * @since 0.1
		 * 
		 * @return Property value type
		 */
		public override Type get_value_type()
		{
			return (data_type);
		}

		/**
		 * Returns parameter flags for property
		 * 
		 * @since 0.1
		 * 
		 * @return Property flags as specified on creation
		 */
		public override ParamFlags get_property_flags()
		{
			return ((_key != null) ? _flags : (ParamFlags) 0);
		}

		/**
		 * Resolves data value in property of object
		 * 
		 * @since 0.1
		 * 
		 * @param val Value in which data is transfered
		 */
		public override void get_value (ref GLib.Value val)
		{
			if (get_object() == null)
				return;
			GLib.Value nval;
			// handle enum and flags specifically to maintain it correctly if
			// destination expects it to be so
			if (val.type().is_flags() == true) {
				nval = GLib.Value (typeof(uint));
				if (get_value_type() == typeof(uint)) {
					nval.set_uint(get_settings().get_flags(__key));
					nval.transform (ref val);
					return;
				}
			}
			if (val.type().is_enum() == true) {
				nval = GLib.Value (typeof(int));
				if (get_value_type() == typeof(int)) {
					nval.set_uint(get_settings().get_enum(__key));
					nval.transform (ref val);
					return;
				}
			}
			nval = GLib.Value (get_value_type());
			if (nval.type() == typeof(bool))
				nval.set_boolean(get_settings().get_boolean(__key));
			else if (nval.type() == typeof(int))
				nval.set_int(get_settings().get_int(__key));
			else if (nval.type() == typeof(uint))
				nval.set_uint(get_settings().get_uint(__key));
			else if (nval.type() == typeof(double))
				nval.set_double(get_settings().get_double(__key));
			else if (nval.type() == typeof(string))
				nval.set_string(get_settings().get_string(__key));
			else if (nval.type() == typeof(string[])) {
				GLib.warning ("String array is on TODO for GSettingsBindingDataTransfer");
				return;
			}
			if (can_translate_value_type(nval.type(), val.type()) == true)
				copy_or_transform_value (nval, ref val);
			else
				GLib.message ("get_value failed from (%s) %s.%s=>(%s)", 
				              nval.type().name(), get_object().get_type().name(), 
				              get_name(), val.type().name());
		}

		/**
		 * Sets data value in property of object
		 * 
		 * @since 0.1
		 * 
		 * @param val Value od new data
		 */
		public override void set_value (GLib.Value val)
		{
			if (get_object() == null)
				return;
			GLib.Value nval;
			if (val.type().is_flags() == true) {
				if (get_value_type() == typeof(uint)) {
					nval = GLib.Value (typeof(uint));
					copy_or_transform_value (val, ref nval);
					get_settings().set_flags(__key, nval.get_uint());
					return;
				}
			}
			if (val.type().is_enum() == true) {
				if (get_value_type() == typeof(int)) {
					nval = GLib.Value (typeof(int));
					copy_or_transform_value (val, ref nval);
					get_settings().set_enum(__key, nval.get_int());
					return;
				}
			}
			else if (get_value_type() == typeof(string[])) {
				GLib.warning ("String array is on TODO for GSettingsBindingDataTransfer");
				return;
			}
			nval = GLib.Value (get_value_type());
			if (can_translate_value_type(val.type(), nval.type()) == true)
				copy_or_transform_value (val, ref nval);

			if (get_value_type() == typeof(bool))
				get_settings().set_boolean(__key, nval.get_boolean());
			else if (get_value_type() == typeof(int))
				get_settings().set_int(__key, nval.get_int());
			else if (get_value_type() == typeof(uint))
				get_settings().set_uint(__key, nval.get_uint());
			else if (get_value_type() == typeof(double))
				get_settings().set_double(__key, nval.get_double());
			else if (get_value_type() == typeof(string))
				get_settings().set_string(__key, nval.get_string());
			else
				GLib.message ("set_value failed from (%s)=>(%s) %s.%s", 
				              val.type().name(), get_value_type().name(), 
				              get_object().get_type().name(), get_name());
		}

		private void handle_writable_changed()
		{
			if (is_valid_ref() == false)
				return;
			_flags = GLib.ParamFlags.READABLE;
			if (((GLib.Settings) get_object).is_writable(__key) == true)
				_flags = _flags | GLib.ParamFlags.WRITABLE;
		}

		private void handle_data_change()
		{
			changed();
		}

		/**
		 * Connects signal handling the data changes
		 * 
		 * @since 0.1
		 */
		public override void connect_signal()
		{
			if (get_object() == null)
				return;
			if ((signal_handler_id != 0) || (signal_handler_id2 != 0))
				disconnect_signal();
			signal_handler_id = Signal.connect_swapped (get_object(), "changed::" + get_name(), (Callback) handle_data_change, this);
			signal_handler_id2 = Signal.connect_swapped (get_object(), "writable-changed::" + get_name(), (Callback) handle_writable_changed, this);
		}

		/**
		 * Disconnects signal handling the data changes
		 * 
		 * @since 0.1
		 */
		public override void disconnect_signal()
		{
			if (signal_handler_id == 0)
				return;
			if (SignalHandler.is_connected(get_object(), signal_handler_id) == true) {
				SignalHandler.disconnect (get_object(), signal_handler_id);
				signal_handler_id = 0;
			}
			else {
				GLib.warning ("LEAK**: Signal is connected, but there is no information how to disconnect");
				signal_handler_id = 0;
			}
			if (SignalHandler.is_connected(get_object(), signal_handler_id2) == true) {
				SignalHandler.disconnect (get_object(), signal_handler_id2);
				signal_handler_id2 = 0;
			}
			else {
				GLib.warning ("LEAK**: Signal is connected, but there is no information how to disconnect");
				signal_handler_id2 = 0;
			}
		}

		/**
		 * Most important method in derived classes. This is invoked as part of
		 * construction and at this point object should get to know what it 
		 * needs to handle data and signaling
		 * 
		 * Object reference is already accessible trough get_object() at this 
		 * point
		 * 
		 * Signal should not be connected at this point as binding invokes
		 * connect_signal() and disconnect_signal() when needed
		 * 
		 * @since 0.1
		 * 
		 * @param property_name Property name
		 */
		protected override void resolve (string property_name)
		{
			if ((get_object() == null) || (get_object().get_type().is_a(typeof(GLib.Settings)) == false)) {
				GLib.warning ("Object %s is not GSettings or derived from it", (get_object() == null) ? "null" : get_object().get_type().name());
				__key = "";
				data_type = Type.INVALID;
			}
			else {
				GLib.Settings settings = (GLib.Settings) get_object();
				if (settings.settings_schema.has_key(property_name) == false)
					return;
				__key = property_name;
				_key = settings.settings_schema.get_key(property_name);
				_name = _key.get_name();
				_description = _key.get_description();
				_summary = _key.get_summary();
				if (settings.is_writable(__key) == true)
					_flags = _flags | GLib.ParamFlags.WRITABLE;

				if (_key.get_value_type() == VariantType.BOOLEAN) data_type = typeof(bool);
				else if (_key.get_value_type() == VariantType.DOUBLE) data_type = typeof(double);
				else if (_key.get_value_type() == VariantType.INT32) data_type = typeof(int);
				else if (_key.get_value_type() == VariantType.UINT32) data_type = typeof(uint);
				else if (_key.get_value_type() == VariantType.STRING) data_type = typeof(string);
				else if (_key.get_value_type() == VariantType.STRING_ARRAY) data_type = typeof(string[]);
				else { 
					data_type = typeof(string);
					GLib.warning ("Settings type '%s' is not handled in GSettingsBindingDataTransfer", _key.get_value_type().dup_string());
				}
			}
		}

		/**
		 * Creates BindingSide and calls resolve() which needs to be overriden
		 * in subclasses
		 * 
		 * If reference to object drops reference_dropped() signal is invoked
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object containing property
		 * @param property_name Property name
		 */
		public GSettingsBindingDataTransfer (Object? obj, string property_name)
		{
			base (obj, property_name);
			ulong res = this.reference_dropped.connect (() => { signal_handler_id = 0; });
		}
	}
}

