namespace G
{
	public interface BindingInterface : Object
	{
		public abstract Object? source { get; }
		public abstract string source_property { get; }
		public abstract Object? target { get; }
		public abstract string target_property { get; }
		public abstract BindFlags flags { get; }

		public abstract void unbind();

		public signal void dropped (BindingInterface binding);
	}
}
