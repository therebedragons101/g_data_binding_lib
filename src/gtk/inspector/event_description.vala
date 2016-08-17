using GData;

namespace GDataGtk
{
	public class EventDescription : Object
	{
		public string title { get; private set; }
		public string description { get; private set; }

		public EventDescription.custom (string event_type, string name, string title, string description)
		{
			this ("%s %s %s".printf(RESERVED_WORD(event_type), bold(name), title), small(italic(description)));
		}

		public EventDescription.as_signal (string name, string title, string description)
		{
			this.custom ("signal", name, title, description);
		}

		public EventDescription.as_property (string name, string title)
		{
			this.custom ("property", name, title, INFORMATION_COLOR("\tproperty %s value has changed".printf (bold(ACTIVE_COLOR(name)))));
		}

		public EventDescription (string title, string description)
		{
			this.title = title;
			this.description = description;
		}
	}
}

