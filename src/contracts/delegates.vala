namespace G.Data
{
	/**
	 * Delegate used to connect to enumeration of for 3 tracking storages
	 * 
	 * @since 0.1
	 * 
	 * @param storage_name Storage name
	 */
	public delegate void StorageDelegateFunc (string storage_name);

	/**
	 * Delegate used to connect to enumeration of stored contracts
	 * 
	 * @since 0.1
	 * 
	 * @param name Contract name
	 * @param contract Contract reference
	 */
	public delegate void ContractStorageDelegateFunc (string name, BindingContract contract);

	/**
	 * Delegate used to connect to enumeration of stored contracts
	 * 
	 * @since 0.1
	 * 
	 * @param name Contract name
	 * @param pointer Pointer reference
	 */
	public delegate void PointerStorageDelegateFunc (string name, BindingPointer pointer);

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
