namespace G.Data
{
	/**
	 * Delegate used to validate value of property in order to determine
	 * source data validity
	 * 
	 * @since 0.1
	 * @param source_value Value being checked
	 * @return true if valid, false if not
	 */
	public delegate bool SourceValidationFunc (Value? source_value);

	/**
	 * Delegate used to resolve value of state objects
	 * 
	 * @since 0.1
	 * @param source Pointer to source, use get_source() to get object reference
	 * @return true if state is valid, false if not
	 */
	public delegate bool CustomBindingSourceStateFunc (BindingPointer? source);

	/**
	 * Delegate used to evaluate value of value object
	 * 
	 * @since 0.1
	 * @param source Pointer to source, use get_source() to get object reference
	 * @return Value of value object 
	 */
	public delegate T CustomBindingSourceDataFunc<T> (BindingPointer? source);
}
