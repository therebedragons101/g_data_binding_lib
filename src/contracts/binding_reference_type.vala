namespace G
{
	public enum BindingReferenceType
	{
		// In normal cases this means WEAK but certain parts need different operation
		// of that and handle it differently (binding pointer can resolve as contract
		// reference type in order to have uniform handling)
		DEFAULT,
		// Default way of handling references and also preferred. Only use strong
		// when there is no other way
		WEAK,
		// binding adds strong reference on data objects for the duration of activity. 
		// this requires binding to be either suspended or disposed in order to release
		// the reference it holds over source and target object
		STRONG
	}
}
