namespace GData
{
	/**
	 * Specifies type of update which should be handled on source pointed out by
	 * pointer
	 * 
	 * @since 0.1
	 */
	public enum BindingPointerUpdateType
	{
		/** 
		 * Default value for property update is by properties since this is one
		 * reliable information that is always specified with binding 
		 * information
		 * 
		 * @since 0.1
		 */
		PROPERTY,
		/** 
		 * Not everywhere would be suitable just binding on properties and that
		 * is when source should specify MANUAL
		 * 
		 * There are a lot of cases when this kind of binding wouldn't fit the 
		 * purpose well in which case BindingPointer should be created as MANUAL
		 * - it might hammer data too much and cause unnecessary utilization
		 * - properties just wouldn't have notifications for specified 
		 *   properties.
		 * - binding on signals
		 * - binding on timers
		 * 
		 * @since 0.1
		 */
		MANUAL;

		public string get_str()
		{
			if (this == BindingPointerUpdateType.PROPERTY)
				return ("PROPERTY");
			else
				return ("MANUAL");
		}
	}
}
