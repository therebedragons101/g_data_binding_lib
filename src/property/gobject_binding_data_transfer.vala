namespace GData
{
	/**
	 * Specifies get/set override for property value in binding. Do not store
	 * any hard references as it get passed in request and
	 * 
	 * If object being handled is not derived from GObject then some sort of
	 * wrapper should be provided
	 * 
	 * @since 0.1
	 */
	public class GObjectBindingDataTransfer : BindingDataTransfer
	{
		private ParamSpec? parm = null;
		private ulong signal_handler_id = 0;

		/**
		 * Returns property name
		 * 
		 * @since 0.1
		 * 
		 * @return Property name
		 */
		public override string get_name()
		{
			return ((parm != null) ? parm.name : "");
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
			return ((parm != null) ? parm.get_nick() : "");
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
			return ((parm != null) ? parm.get_blurb() : "");
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
			return ((parm != null) ? parm.value_type : Type.INVALID);
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
			return ((parm != null) ? parm.flags : (ParamFlags) 0);
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
			GLib.Value nval = GLib.Value (get_value_type());
			if (GLib.Value.type_compatible(val.type(), get_value_type()) == true)
				get_object().get_property (get_name(), ref val);
			else if (can_translate_value_type(get_value_type(), val.type()) == true) {
				get_object().get_property (get_name(), ref nval);
				copy_or_transform_value (nval, ref val);
			} else
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
			GLib.Value nval = GLib.Value (get_value_type());
			if (GLib.Value.type_compatible(val.type(), get_value_type()) == true)
				get_object().set_property (get_name(), val);
			else if (can_translate_value_type(get_value_type(), val.type()) == true) {
				copy_or_transform_value (val, ref nval);
				get_object().set_property (get_name(), nval);
			} else
				GLib.message ("set_value failed from (%s)=>(%s) %s.%s", 
				              val.type().name(), nval.type().name(), 
				              get_object().get_type().name(), get_name());
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
			if (signal_handler_id != 0)
				disconnect_signal();
			signal_handler_id = Signal.connect_swapped (get_object(), "notify::" + get_name(), (Callback) handle_data_change, this);
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
			parm = TypeInformation.get_instance().find_property_from_ref (get_object(), property_name);
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
		public GObjectBindingDataTransfer (Object? obj, string property_name)
		{
			base (obj, property_name);
			ulong res = this.reference_dropped.connect (() => { signal_handler_id = 0; });
		}
	}
}

