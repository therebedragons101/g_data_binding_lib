namespace G
{
	// result false can also be used differently by skipping value handling. method handler can simply
	// set property value as needed and then return false
	public delegate bool PropertyBindingTransformFunc (BindingInterface binding, Value source_value, ref Value target_value);

	public delegate BindingInterface? CreatePropertyBinding (Object? source, string source_property, Object? target, string target_property,
	                                                         BindFlags flags, owned PropertyBindingTransformFunc? transform_to = null, 
	                                                         owned PropertyBindingTransformFunc? transform_from = null);
}
