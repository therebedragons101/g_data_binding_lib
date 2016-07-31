namespace G
{
	/**
	 * CustomPropertyNotificationBindingSource is base class for value and state
	 * objects.
	 * 
	 * Main purpose is providing ability to subclass it and only connect to
	 * signals properties_changed and manual_recalculation to calculate new data
	 * 
	 * Recalculation is also triggered whenever end of pointer chain changes
	 * 
	 * @since 0.1
	 */
	public class CustomPropertyNotificationBindingSource : Object
	{
		private bool _disconnected = false;
		/**
		 * Specifies if object is connected or not
		 *
		 * Avoid any activities when disconnected
		 * @since 0.1
		 */
		[Description (name="Disconnected", blurb="Disconnected state")]
		public bool disconnected {
			get { return (_disconnected); }
		}

		/**
		 * Name of object
		 * 
		 * @since 0.1
		 */
		[Description (name="Object name", blurb="Object name")]
		public string name { get; set; }
		
		/**
		 * Method called upon disconnection
		 * 
		 * @since 0.1
		 */
		public virtual void disconnect_object()
		{
		}

		private string[]? connected_properties;
		private bool notify_connected = false;

		private WeakReference<BindingPointer?> _source;
		/**
		 * Specifies pointer to which this object is connected to
		 * 
		 * @since 0.1
		 */
		[Description (name="Source", blurb="Source pointer object")]
		public BindingPointer source {
			get { return (_source.target); }
		}

		private void property_notification (GLib.ParamSpec paramspec)
		{
			properties_changed();
		}

		private void set_property_connection (bool active)
		{
			if ((notify_connected == active) || (connected_properties == null) || (source.get_source() == null))
				return;
			notify_connected = active;
			if (notify_connected == true) {
				if (connected_properties.length == 0)
					source.get_source().notify.connect (property_notification);
				else
					for (int i=0; i<connected_properties.length; i++)
						source.get_source().notify[connected_properties[i]].connect (property_notification);
			}
			else {
				if (source.get_source() != null)
					if (connected_properties.length == 0)
						source.get_source().notify.disconnect (property_notification);
					else
						for (int i=0; i<connected_properties.length; i++)
							source.get_source().notify[connected_properties[i]].disconnect (property_notification);
			}
		}

		/**
		 * Signal emited when properties that are connected change
		 * 
		 * @since 0.1
		 */ 
		public signal void properties_changed();

		/**
		 * Signal that can be emited when there is a need for custom 
		 * recalculation
		 * 
		 * @since 0.1
		 */ 
		public signal void manual_recalculation();

		~CustomPropertyNotificationBindingSource()
		{
			if (disconnected == true)
				return;
			_disconnected = true;
			disconnect_object();
		}

		/**
		 * Creates new CustomPropertyNotificationBindingSource
		 * 
		 * @since 0.1
		 * @param name Object name
		 * @param source Connected binding pointer
		 * @param connected_properties Names of properties object should connect
		 *                             to
		 */
		public CustomPropertyNotificationBindingSource (string name, BindingPointer source, string[]? connected_properties = null)
		{
			this.name = name;
			this.connected_properties = connected_properties;
			_source = new WeakReference<BindingPointer?>(source);
			source.before_source_change.connect ((src) => {
				set_property_connection (false);
			});
			source.source_changed.connect ((src) => {
				set_property_connection (true);
				properties_changed();
			});
			set_property_connection (true);
		}
	}
}
