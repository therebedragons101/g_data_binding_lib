namespace G
{
	public interface DataFloodDetection : Object
	{
		public abstract bool flood_detection { get; set; }
		public abstract uint flood_interval { get; set; }
		public abstract uint promote_flood_limit { get; set; }

		public signal void flood_detected (BindingInterface binding);
		public signal void flood_stopped (BindingInterface binding);
	}
}
