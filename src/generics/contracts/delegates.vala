namespace G.Data.Generics
{
	/**
	 * Delegate used to evaluate value of value object
	 * 
	 * @since 0.1
	 * @param source Pointer to source, use get_source() to get object reference
	 * @return Value of value object 
	 */
	public delegate T CustomBindingSourceDataFunc<T> (BindingPointer? source);
}

