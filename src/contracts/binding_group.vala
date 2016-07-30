namespace G
{
	public interface BindingGroup : Object
	{
		public abstract int length { get; }
		public abstract BindingInformationInterface get_item_at (int index);
	}
}
