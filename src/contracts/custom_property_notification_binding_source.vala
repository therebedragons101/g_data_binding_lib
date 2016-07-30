namespace G
{
	public class CustomPropertyNotificationBindingSource : Object
	{
		private bool _disconnected = false;
		public bool disconnected {
			get { return (_disconnected); }
		}

		public string name { get; set; }
		
		public virtual void disconnect_object()
		{
		}

		private string[]? connected_properties;
		private bool notify_connected = false;

		private WeakReference<BindingPointer?> _source;
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
				if (connected_properties.length == 0)
					source.get_source().notify.disconnect (property_notification);
				else
					for (int i=0; i<connected_properties.length; i++)
						source.get_source().notify[connected_properties[i]].disconnect (property_notification);
			}
		}

		public signal void properties_changed();

		~CustomPropertyNotificationBindingSource()
		{
			if (disconnected == true)
				return;
			_disconnected = true;
			disconnect_object();
		}

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
