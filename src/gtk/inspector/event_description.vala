using GData;

namespace GDataGtk
{
	public class EventDescription : Object
	{
		public string title { get; private set; }
		public string description { get; private set; }

		public EventDescription.custom (string event_type, string name, string title, string description)
		{
			this ("<span color='red'>%s</span> <b>%s</b> %s".printf(event_type, name, title), "<small><i>%s</i></small>".printf(description));
		}

		public EventDescription.as_signal (string name, string title, string description)
		{
			this.custom ("signal", name, title, description);
		}

		public EventDescription.as_property (string name, string title)
		{
			this.custom ("property", name, title, yellow("\tproperty %s value has changed".printf (bold(green(name)))));
		}

		public EventDescription (string title, string description)
		{
			this.title = title;
			this.description = description;
		}
	}
}

