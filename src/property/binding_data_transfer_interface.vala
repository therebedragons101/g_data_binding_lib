namespace GData
{
	public interface BindingDataTransferInterface : Object
	{
		/**
		 * Object being handled
		 * 
		 * @since 0.1
		 */
		public abstract unowned Object? get_object();

		/**
		 * Specifies if transfer data is valid or not. It can be invalid for
		 * multiple reasons.
		 * - It was only invoked for introspection
		 * - Data is not correct
		 * 
		 * @since 0.1
		 */
		public abstract bool is_valid { get; }

		/**
		 * Provides name as bindable point when redirection is done to this
		 * object it self
		 * 
		 * @since 0.1
		 */
		public string property_name {
			owned get { return (get_name()); }
		}

		/**
		 * Provides nick as bindable point when redirection is done to this
		 * object it self
		 * 
		 * @since 0.1
		 */
		public string property_nick {
			owned get { return (get_nick()); }
		}

		/**
		 * Provides blurb as bindable point when redirection is done to this
		 * object it self
		 * 
		 * @since 0.1
		 */
		public string property_blurb {
			owned get { return (get_blurb()); }
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
		public abstract ParamFlags get_property_flags();

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
		public abstract string get_object_type();

		/**
		 * Returns property name
		 * 
		 * @since 0.1
		 * 
		 * @return Property name
		 */
		public abstract string get_name();

		/**
		 * Returns property nick
		 * 
		 * @since 0.1
		 * 
		 * @return Property nick
		 */
		public abstract string get_nick();

		/**
		 * Returns property blurb
		 * 
		 * @since 0.1
		 * 
		 * @return Property blurb
		 */
		public abstract string get_blurb();

		/**
		 * Returns property value type
		 * 
		 * @since 0.1
		 * 
		 * @return Property value type
		 */
		public abstract Type get_value_type();

		/**
		 * Resolves data value in property of object
		 * 
		 * @since 0.1
		 * 
		 * @param val Value in which data is transfered
		 */
		public abstract void get_value (ref GLib.Value val);

		/**
		 * Sets data value in property of object
		 * 
		 * @since 0.1
		 * 
		 * @param val Value od new data
		 */
		public abstract void set_value (GLib.Value val);

		/**
		 * Connects signal handling the data changes
		 * 
		 * @since 0.1
		 */
		public abstract void connect_signal();

		/**
		 * Disconnects signal handling the data changes
		 * 
		 * @since 0.1
		 */
		public abstract void disconnect_signal();

		/**
		 * Returns true if reference to object is valid, false if not
		 * 
		 * @since 0.1
		 * 
		 * @return True if valid, false if not
		 */
		public abstract bool is_valid_ref();

		/**
		 * Signal emited when data is changed. Implementations handling custom
		 * properties or non GObject types should invoke this signal to notify
		 * data changed in property
		 * 
		 * @since 0.1
		 */
		public signal void changed();

		/**
		 * Signal emited if object reference is dropped prematurely
		 * 
		 * @since 0.1
		 */
		public signal void reference_dropped();
		
	}
}
