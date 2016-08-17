using GData;
using GData.Generics;

namespace GDataGtk
{
	public const string __SIGNAL__ = "signal";
	public const string __PROPERTY__ = "property";

	/**
	 * Specifies simple log event description to track object events
	 * 
	 * @since 0.1
	 */
	public class TrackLogElement : Object
	{
		/**
		 * Element name
		 * 
		 * @since 0.1
		 */
		public string name { get; private set; }
		
		/**
		 * Element type
		 * 
		 * @since 0.1
		 */
		public string element_type { get; private set; }

		private int _consecutive = 1;
		/**
		 * Specifies how many consecutive events were emited
		 * 
		 * @since 0.1
		 */
		public int consecutive { 
			get { return (_consecutive); }
		}

		/**
		 * Increments consecutive counter
		 * 
		 * @since 0.1
		 */
		public void another()
		{
			_consecutive++;
			notify_property ("consecutive");
		}

		public void debug_str()
		{
			GLib.message ("Log element: type='%s', name='%s'".printf(element_type, name));
		}

		/**
		 * Creates new TrackLogElement
		 * 
		 * @since 0.1
		 * 
		 * @param element_type String representation of element type as it 
		 *                     should appear in log
		 * @param name Element name as it should appear in log
		 */
		public TrackLogElement (string element_type, string name)
		{
			this.element_type = element_type;
			this.name = name;
		}
	}
}
