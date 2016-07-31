namespace G.Data
{
	/**
	 * DataFloodDetection interface defines basic flood detection functionality
	 * 
	 * @since 0.1
	 */
	public interface DataFloodDetection : Object
	{
		/**
		 * Flood detection active or not
		 * 
		 * @since 0.1
		 */
		public abstract bool flood_detection { get; set; }
		/**
		 * Flood detection activation interval (in ms)
		 * 
		 * Flooding will be activated if promote_flood_limit consecutive amount
		 * of events happen in shorter intervals than specified with 
		 * flood_interval.
		 * 
		 * Note that flood_interval specifies amount for one event, not all 
		 * 
		 * @since 0.1
		 */
		public abstract uint flood_interval { get; set; }
		/**
		 * Sets amount of needed consecutive events in order to promote flood
		 * 
		 * Flooding will be activated if promote_flood_limit consecutive amount
		 * of events happen in shorter intervals than specified with 
		 * flood_interval.
		 * 
		 * Note that flood_interval specifies amount for one event, not all 
		 * 
		 * @since 0.1
		 */
		public abstract uint promote_flood_limit { get; set; }

		/**
		 * Signal sent when flood was detected
		 * 
		 * @since 0.1
		 * @param binding BindingInterface on which flood was detected
		 */
		public signal void flood_detected (BindingInterface binding);

		/**
		 * Signal sent when previously detected flood stops
		 * 
		 * @since 0.1
		 * @param binding BindingInterface on which flood was detected
		 */
		public signal void flood_stopped (BindingInterface binding);
	}
}
