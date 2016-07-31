namespace G
{
	/**
	 * Specifies how BindingPointer should handle reference on data that it 
	 * points to
	 * 
	 * @since 0.1
	 */
	public enum BindingReferenceType
	{
		/**
		 * In normal cases this means WEAK but certain parts need different 
		 * operation of that and handle it differently (binding pointer can 
		 * resolve as contract reference type in order to have uniform handling)
		 * 
		 * @since 0.1
		 */
		DEFAULT,
		/** 
		 * Default way of handling references and also preferred. Only use 
		 * strong when there is no other way
		 * 
		 * @since 0.1
		 */
		WEAK,
		/** 
		 * Binding adds strong reference on data objects for the duration of 
		 * activity. This requires binding to be either suspended or disposed in 
		 * order to release the reference it holds over source and target object
		 * 
		 * @since 0.1
		 */
		STRONG
	}
}
