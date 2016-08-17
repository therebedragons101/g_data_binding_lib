namespace GDataGtk
{
	[Flags]
	public enum ObjectInspectorView
	{
		PROPERTIES,
		SIGNALS,
		ALL = PROPERTIES | SIGNALS;


		public bool PROPERTIES_VISIBLE()
		{
			return ((this & PROPERTIES) == PROPERTIES);
		}

		public bool SIGNALS_VISIBLE()
		{
			return ((this & PROPERTIES) == PROPERTIES);
		}
	}
}
