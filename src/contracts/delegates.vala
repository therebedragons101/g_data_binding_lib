namespace G
{
	public delegate bool SourceValidationFunc (Value? source_value);

	public delegate bool CustomBindingSourceStateFunc (BindingPointer? source);

	public delegate T CustomBindingSourceDataFunc<T> (BindingPointer? source_data);
}
