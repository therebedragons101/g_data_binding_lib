using GData;

namespace GDataGtk
{
	public class ContractEventDescription : EventDescription
	{
		private EventFilterMode _event_mode;
		public EventFilterMode event_mode {
			get { return (_event_mode); }
		}

		public EventFilterMode current_filter { get; set; }

		public bool is_visible { get; set; }

		public ContractEventDescription.custom (EventFilterMode event_mode, string event_type, string name, string title, string description)
		{
			this (event_mode, "%s %s %s".printf(RESERVED_WORD(event_type), bold(name), title), small(italic(description)));
		}

		public ContractEventDescription.as_signal (EventFilterMode event_mode, string name, string title, string description)
		{
			this.custom (event_mode, "signal", name, title, description);
		}

		public ContractEventDescription.as_property (EventFilterMode event_mode, string name, string title)
		{
			this.custom (event_mode, "property", name, title, INFORMATION_COLOR("\tproperty %s value has changed".printf (bold(ACTIVE_COLOR(name)))));
		}

		public ContractEventDescription (EventFilterMode event_mode, string title, string description)
		{
			base (title, description);
			this._event_mode = event_mode;
			this.notify["current-filter"].connect (() => {
				is_visible = ((current_filter & _event_mode) == _event_mode);
			});
		}
	}
}
