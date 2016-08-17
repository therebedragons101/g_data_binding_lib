namespace GData
{
	/**
	 * Provides grouping of reference monitor object lifetimes in order to 
	 * centrally manipulate notifications
	 * 
	 * @since 0.1
	 */
	public class ReferenceMonitorGroup : Object, GLib.ListModel
	{
		private static GObjectArray? _groups = null;

		private GObjectArray? _array = null;

		private string _name = "";
		/**
		 * Group name
		 * 
		 * @since 0.1
		 */
		public string name {
			get { return (_name); }
		}
		
		/**
		 * Returns group list which can if needed be manually edited. Since 
		 * GObjectArray is also GLib.Model displaying it in list box is simple.
		 * 
		 * @since 0.1
		 * 
		 * @return Group list
		 */
		public static GObjectArray get_groups()
		{
			if (_groups == null)
				_groups = new GObjectArray();
			return (_groups);
		}

		/**
		 * Specifies if notifications should be outputed to console or not
		 * 
		 * @since 0.1
		 */
		public bool output_to_console { get; set; default=true; }

		/**
		 * Activates monitoring of objects lifetime. There is no limit on object
		 * being monitored more than once
		 * 
		 * @since 0.1
		 * 
		 * @param notification Notification text message when reference dies
		 * @param obj Object that needs to be monitored
		 * @return ReferenceMonitor object
		 */
		public ReferenceMonitor? monitor_object (string notification, Object? obj)
		{
			if (obj == null)
				return (null);
			ReferenceMonitor _tap = new ReferenceMonitor (notification, obj);
			return (monitor(_tap));
		}

		/**
		 * Activates monitoring of objects lifetime. There is no limit on object
		 * being monitored more than once
		 * 
		 * @since 0.1
		 * 
		 * @param notification Notification text message when reference dies
		 * @param obj Array of objects that needs to be monitored
		 */
		public void monitor_objects (string notification, Object?[] obj)
		{
			for (int i=0; i<obj.length; i++)
				monitor_object (notification, obj[i]);
		}

		/**
		 * Stops specified monitor
		 * 
		 * @since 0.1
		 * 
		 * @param monitor Monitor that needs to be removed
		 */
		public void remove_monitor (ReferenceMonitor? monitor)
		{
			if (monitor == null)
				return;
			for (int i=0; i<_array.length; i++) {
				if (_array.data[i] == monitor) {
					ReferenceMonitor mon = (ReferenceMonitor) _array.data[i];
					_array.remove_at_index(i);
					mon.remove();
				}
			}
		}

		/**
		 * Stops specified monitors
		 * 
		 * @since 0.1
		 * 
		 * @param monitors Monitors that needs to be removed
		 */
		public void remove_monitors (ReferenceMonitor?[] monitors)
		{
			for (int i=0; i<monitors.length; i++)
				remove_monitor (monitors[i]);
		}

		/**
		 * Activates monitoring of objects lifetime. There is no limit on object
		 * being monitored more than once
		 * 
		 * @since 0.1
		 * 
		 * @param monitor_ref Tap reference object
		 * @param obj Object that needs to be tapped
		 * @return ReferenceTap object
		 */
		public ReferenceMonitor? monitor (ReferenceMonitor? monitor_ref)
		{
			if (monitor_ref == null)
				return (null);
			monitor_ref.reference_deleted.connect ((msg) => {
				reference_deleted (msg);
				_array.remove (monitor_ref);
				if (output_to_console == true)
					GLib.message ("[%s] %s", monitor_ref.get_type().name(), monitor_ref.notification);
			});
			_array.add (monitor_ref);
			return (monitor_ref);
		}

		/**
		 * Adds specified monitors
		 * 
		 * @since 0.1
		 * 
		 * @param monitors Monitors that needs to be added
		 */
		public void add_monitors (ReferenceMonitor?[] monitors)
		{
			for (int i=0; i<monitors.length; i++)
				monitor (monitors[i]);
		}

		/**
		 * Get the item at position.
		 * 
		 * @since 0.1
		 * 
		 * @param position Item position
		 */
		public Object? get_item (uint position)
		{
			return (_array.get_item (position));
		}

		/**
		 * Gets the type of the items in this.
		 * 
		 * @since 0.1
		 * 
		 * @return Item type
		 */
		public Type get_item_type ()
		{
			return (typeof (ReferenceMonitor));
		}

		/**
		 * Returns number of tapped references
		 * 
		 * @since 0.1
		 * 
		 * @return Number of items being watched in this group
		 */
		public uint get_n_items ()
		{
			return (_array.length);
		}

		/**
		 * Creates new reference tap group. If group with specified name already
		 * exists then reference for that one is returned
		 * 
		 * @since 0.1
		 * 
		 * @param name Group name
		 * @return Either already existing group by specified name or newly 
		 *         created one
		 */
		public static ReferenceMonitorGroup get_group (string name)
		{
			if (_groups == null)
				_groups = new GObjectArray();
			for (int i=0; i<_groups.length; i++)
				if (((ReferenceMonitorGroup) _groups.data[i]).name == name)
					return ((ReferenceMonitorGroup) _groups.data[i]);
			ReferenceMonitorGroup grp = new ReferenceMonitorGroup (name);
			_groups.add (grp);
			return (grp);
		}

		/**
		 * Returns default monitor group
		 * 
		 * @since 0.1
		 */
		public static ReferenceMonitorGroup get_default()
		{
			return (get_group (__DEFAULT__));
		}

		public void update_all()
		{
			for (int i=_array.length-1; i>=0; i--)
				((ReferenceMonitor) _array.data[i]).update();
		}

		/**
		 * Signal being sent when reference is deleted
		 * 
		 * @since 0.1
		 * 
		 * @param notification Notification message
		 */
		public signal void reference_deleted (string notification);

		private ReferenceMonitorGroup (string name)
		{
			if (_groups == null)
				_groups = new GObjectArray();
			_array = new GObjectArray();
			_array.items_changed.connect ((i,d,a) => {
				items_changed(i,d,a);
			});
			_name = name;
		}
	}
}
