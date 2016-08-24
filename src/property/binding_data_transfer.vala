namespace GData
{
	/**
	 * Delegate method specifying creation of BindingDataTransfer object for
	 * object and property.
	 * 
	 * TODO, source optimization level needs to be inserted under this structure
	 * That will bring memory consumption to near zero as well as it will bring
	 * better performance. Task: LOW LEVEL/LOW IMPORTANCE as neither is really
	 * problematic
	 * 
	 * @since 0.1
	 * 
	 * @param object Object that will be handled
	 * @param property_name Property name
	 * @return BindingDataTransfer object or null if creation is not possible
	 */
	public delegate BindingDataTransfer CreateDataTransferFunc (Object object, string property_name);

	/**
	 * Specifies get/set override for property value in binding. Do not store
	 * any hard references as it get passed in request and
	 * 
	 * If object being handled is not derived from GObject then some sort of
	 * wrapper should be provided
	 * 
	 * @since 0.1
	 */
	public class BindingDataTransfer : Object, BindingDataTransferInterface
	{
		private bool creation = true;
		private Type _introspection_type = Type.INVALID;

		private StrictWeakRef _wref = null;
		/**
		 * Object being handled
		 * 
		 * @since 0.1
		 */
		public unowned Object? get_object()
		{
			return (_wref.target);
		}

		/**
		 * Specifies if transfer data is valid or not. It can be invalid for
		 * multiple reasons.
		 * - It was only invoked for introspection
		 * - Data is not correct
		 * 
		 * @since 0.1
		 */
		public virtual bool is_valid { 
			get { return ((get_object() == null) || (get_name() == "")); }
		}

		/**
		 * This should only be called during call to resolve and not later. What
		 * it does is specify another target of binding which is useful when
		 * handling things like redirected properties
		 * 
		 * Example redirection is to BindingDataTransfer object it self and
		 * binding to nick or blurb properties
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object which data handling is redirected to
		 */
		public void set_object_redirection (Object obj)
		{
			_wref.set_new_target (obj);
		}

		/**
		 * Returns parameter flags for property
		 * 
		 * @since 0.1
		 * 
		 * @return Default return is ParamFlags.READABLE | ParamFlags.WRITABLE,
		 *         but any subclass implementation should most probably 
		 *         override this result by handling it natively for handled
		 *         object
		 */
		public virtual ParamFlags get_property_flags()
		{
			return (ParamFlags.READABLE | ParamFlags.WRITABLE);
		}

		/**
		 * Specifies type of handled object. Note that this is available even
		 * when real reference is presented and all resolving in STATIC types
		 * should be handled trough this and not object reference
		 * 
		 * Default handling returns GObject type
		 * 
		 * @since 0.1
		 * 
		 * @return Object type 
		 */
		public virtual Type get_introspection_type()
		{
			return (_introspection_type);
		}

		/**
		 * Returns string representation of handled object type which is useful
		 * to distinct when non GObject type is wrapped inside to get real type
		 * name
		 * 
		 * Default handling returns name of GObject type
		 * 
		 * @since 0.1
		 * 
		 * @return Object type name
		 */
		public virtual string get_object_type()
		{
			if (_wref.is_valid_ref() == false)
				return ("");
			return (get_object().get_type().name());
		}

		/**
		 * Returns property name
		 * 
		 * @since 0.1
		 * 
		 * @return Property name
		 */
		public virtual string get_name()
		{
			GLib.error ("Abstract method");
			return ("");
		}

		/**
		 * Returns property nick
		 * 
		 * @since 0.1
		 * 
		 * @return Property nick
		 */
		public virtual string get_nick()
		{
			return (get_name());
		}

		/**
		 * Returns property blurb
		 * 
		 * @since 0.1
		 * 
		 * @return Property blurb
		 */
		public virtual string get_blurb()
		{
			return (get_name());
		}

		/**
		 * Returns property value type
		 * 
		 * @since 0.1
		 * 
		 * @return Property value type
		 */
		public virtual Type get_value_type()
		{
			GLib.error ("Abstract method");
			return (Type.INVALID);
		}

		/**
		 * Resolves data value in property of object
		 * 
		 * @since 0.1
		 * 
		 * @param val Value in which data is transfered
		 */
		public virtual void get_value (ref GLib.Value val)
		{
			GLib.error ("Abstract method");
		}

		/**
		 * Sets data value in property of object
		 * 
		 * @since 0.1
		 * 
		 * @param val Value od new data
		 */
		public virtual void set_value (GLib.Value val)
		{
			GLib.error ("Abstract method");
		}

		/**
		 * Connects signal handling the data changes
		 * 
		 * @since 0.1
		 */
		public virtual void connect_signal()
		{
			GLib.error ("Abstract method");
		}

		/**
		 * Disconnects signal handling the data changes
		 * 
		 * @since 0.1
		 */
		public virtual void disconnect_signal()
		{
			GLib.error ("Abstract method");
		}

		/**
		 * Returns true if reference to object is valid, false if not
		 * 
		 * @since 0.1
		 * 
		 * @return True if valid, false if not
		 */
		public bool is_valid_ref()
		{
			return (_wref.is_valid_ref());
		}

		/**
		 * Most important method in derived classes. This is invoked as part of
		 * construction and at this point object should get to know what it 
		 * needs to handle data and signaling
		 * 
		 * Object reference is already accessible trough get_object() at this 
		 * point if this is not introspection only object. In case of STATIC
		 * get_introspection_type() should be used instead
		 * 
		 * Signal should not be connected at this point as binding invokes
		 * connect_signal() and disconnect_signal() when needed
		 * 
		 * @since 0.1
		 * 
		 * @param property_name Property name
		 */
		protected virtual void resolve (string property_name)
		{
			GLib.error ("Abstract method");
		}

		private void handle_invalid()
		{
			reference_dropped();
		}

		~BindingDataTransfer()
		{
			disconnect_signal();
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
		public BindingDataTransfer.introspection_only (Type class_type, string property_name)
		{
			_introspection_type = class_type;
			_wref = new StrictWeakRef (null, handle_invalid);
			resolve (property_name);
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
		public BindingDataTransfer (Object? obj, string property_name)
		{
			_introspection_type = (obj != null) ? obj.get_type() : GLib.Type.INVALID;
			_wref = new StrictWeakRef (obj, handle_invalid);
			resolve (property_name);
		}
	}
}

