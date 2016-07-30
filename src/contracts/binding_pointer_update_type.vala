namespace G
{
	public enum BindingPointerUpdateType
	{
		// default value for property update is by properties since this is one
		// reliable information that is always specified with binding information
		PROPERTY,
		// not everywhere would be suitable just binding on properties
		//
		// there are a lot of cases when this kind of binding wouldn't fit the purpose
		// well in which case BindingPointer should be created as MANUAL
		// - it might hammer data too much and cause unnecessary utilization
		// - properties just wouldn't have notifications for specified properties.
		// - binding on signals
		// - binding on timers
		MANUAL
	}
}
