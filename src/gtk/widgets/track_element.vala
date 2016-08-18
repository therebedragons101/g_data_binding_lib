using GData;
using GData.Generics;

namespace GDataGtk
{
	public delegate void AddLogEventDelegate (string event_type, string event_name);

	/**
	 * Specifies tracking element that supports connection and logging where
	 * events are automatically dispatched to log specified at creation
	 * 
	 * Whenever event occurs while tracking is enabled new TrackLogElement is
	 * created and dispatched to log array.
	 * 
	 * @since 0.1
	 */
	public class TrackElement : TrackLogElement
	{
		private StrictWeakRef? _wref = null;
		private ulong signal_handler_id = 0;

		//private bool _connected = false;
		/**
		 * Specifies if track element is connected or not
		 * 
		 * @since 0.1
		 */
		public bool connected {
			get { return (signal_handler_id != 0); }
			set {
				if (connected == value)
					return;
				if (value == true)
					connect_event();
				else
					disconnect_event();
			}
		}

		private int _counter = 0;
		/**
		 * Event counter. This is reset on reconnection
		 * 
		 * @since 0.1
		 */
		public int counter {
			get { return (_counter); }
		}

		private void log ()
		{
			log_event (element_type, name);
		}

		/**
		 * Tracking event is connected if element is currently not connected and
		 * ignored otherwise
		 * 
		 * @since 0.1
		 */
		protected virtual void connect_event()
		{
			if ((_wref.is_valid_ref() == false) || (connected == true))
				return;
			_counter = 0;
			notify_property ("counter");
			if (element_type == __PROPERTY__)
				signal_handler_id = Signal.connect_swapped (_wref.target, "notify::" + name, (Callback) log, this);
			else
				signal_handler_id = Signal.connect_swapped (_wref.target, name, (Callback) log, this);
			notify_property ("connected");
		}

		/**
		 * Tracking event is disconnected if element is currently connected and
		 * ignored otherwise
		 * 
		 * @since 0.1
		 */
		protected virtual void disconnect_event()
		{
			if ((_wref.is_valid_ref() == false) || (connected == false))
				return;
			if (signal_handler_id != 0) {
				SignalHandler.disconnect (_wref.target, signal_handler_id);
				signal_handler_id = 0;
			}
			notify_property ("connected");
		}

		public void handle_invalid()
		{
			signal_handler_id = 0;
			notify_property ("connected");
		}

		~TrackElement()
		{
			disconnect_event();
		}

		public signal void log_event (string event_type, string event_name);

		/**
		 * Creates new TrackElement
		 * 
		 * @since 0.1
		 * 
		 * @param log Specifies log array where events are dispatched
		 * @param obj Specifies object which is being tracked
		 * @param element_type String representation of element type as it 
		 *                     should appear in log
		 * @param name Element name as it should appear in log
		 */
		public TrackElement (AddLogEventDelegate? method, Object? obj, string element_type, string name)
		{
			base (element_type, name);
			_wref = new StrictWeakRef (obj, handle_invalid);
			this.log_event.connect ((t,n) => {
				_counter++;
				notify_property ("counter");
				if (method != null)
					method (t,n);
			});
		}
	}
}
