namespace GData
{
	/**
	 * EventConnector provides ability to connect to various sources in order
	 * to be notified when they do
	 * 
	 * @since 0.1
	 */
	public class EventConnector : Object
	{
		private string _name = "";
		/**
		 * Event connector name
		 * 
		 * @since 0.1
		 */
		public string name {
			get { return (_name); }
		}

		private bool _suspended = false;
		/**
		 * Specifies if event connector is suspended or not
		 * 
		 * @since 0.1
		 */
		public bool suspended {
			get { return (_suspended); }
			set { _suspended = value; }
		}

		/**
		 * Adds property to event connector. Note that property is resolved
		 * trough complete discovery which means that things like PropertyAlias
		 * are supported, same as object can be specified as pointer or contract
		 * and be reconnected to new sources when they change
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object containing property
		 * @param property_name Property name
		 */
		public void add_property (Object? obj, string property_name)
		{
			add_signal (obj, "notify::" + property_name);
		}

		/**
		 * Adds signal connection to event connector where if object is either
		 * contract or pointer this signal connection will follow the source and
		 * be updated with it
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object containing signal
		 * @param detailed_signal_name Detailed signal name which supports 
		 *                             signal::quark
		 */
		public void add_signal (Object? obj, string detailed_signal_name)
		{
			
		}

		/**
		 * Adds property to event connector. Note that property is resolved
		 * trough complete discovery which means that things like PropertyAlias
		 * are supported, same as object can be specified as pointer or contract
		 * and be reconnected to new sources when they change
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object containing property
		 * @param property_name Property name
		 */
		public void remove_property (Object? obj, string property_name)
		{
			remove_signal (obj, "notify::" + property_name);
		}

		/**
		 * Adds signal connection to event connector where if object is either
		 * contract or pointer this signal connection will follow the source and
		 * be updated with it
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object containing signal
		 * @param detailed_signal_name Detailed signal name which supports 
		 *                             signal::quark
		 */
		public void remove_signal (Object? obj, string detailed_signal_name)
		{
			
		}

		/**
		 * Signal dispatched when any of connected events happens. Note that
		 * signal can be tracked by quark which is based on group signal was
		 * added to
		 * 
		 * @since 0.1
		 */
		public signal void event_occured();
	}
}
