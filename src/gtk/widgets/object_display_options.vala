namespace GDataGtk
{
	[Flags]
	public enum ObjectDisplayOptions
	{
		PROPERTIES,
		SIGNALS;

		public PROPERTIES_VISIBLE()
		{
			return ((this & PROPERTIES) == PROPERTIES);
		}

		public SIGNALS_VISIBLE()
		{
			return ((this & PROPERTIES) == PROPERTIES);
		}
	}
}

