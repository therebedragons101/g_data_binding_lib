namespace GData
{
	/**
	 * Delegate used to connect to enumeration of stored aliases
	 * 
	 * @since 0.1
	 * 
	 * @param type Type that registered property alias
	 * @param property_name Real property name
	 */
	public delegate void AliasStorageDelegateFunc (Type type, string property_name);

	/**
	 * Delegate used to transform one value into another during binding
	 * 
	 * NOTE!
	 * Result false can also be used differently by skipping value handling. 
	 * Method handler can simply set property value directly as needed and then
	 * return false. If value was assigned directly and return was true value
	 * will be wrongly overriden
	 * 
	 * @since 0.1
	 */
	public delegate bool PropertyBindingTransformFunc (BindingInterface binding, Value source_value, ref Value target_value);

	/**
	 * Delegate used to specify BindingInterface creation in Binder class
	 * 
	 * @since 0.1
	 */ 
	public delegate BindingInterface? CreatePropertyBinding (
		Object? source, string source_property, Object? target, 
		string target_property, BindFlags flags, 
		owned PropertyBindingTransformFunc? transform_to = null, 
		owned PropertyBindingTransformFunc? transform_from = null
	);
}
