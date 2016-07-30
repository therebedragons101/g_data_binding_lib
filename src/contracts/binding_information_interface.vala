namespace G
{
	public interface BindingInformationInterface : Object
	{
		public abstract bool is_valid { get; }
		public abstract void bind_connection();
		public abstract void unbind_connection();
	}
}
