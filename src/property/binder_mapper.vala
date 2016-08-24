namespace GData
{
	/**
	 * Interface that allows easier mapping of object
	 * 
	 * @since 0.1
	 */
	public interface BinderMapper : Object
	{
		/**
		 * Binder object that instigated this interface
		 * 
		 * @since 0.1
		 */
		public abstract Binder binder_object { get; set; }

		/**
		 * Maps complete object structure from source to target
		 * 
		 * @since 0.1
		 * 
		 * @param source Source object
		 * @param target Target object
		 * @param flags Binding flags
		 * @return Array of created bindings
		 */
		public abstract BindingInterface[] map (Object? source, Object? target, BindFlags flags=BindFlags.SYNC_CREATE);

		/**
		 * Maps only specific properties or sublayouts from source to target
		 * 
		 * @since 0.1
		 * 
		 * @param source Source object
		 * @param target Target object
		 * @param layout Names of properties or layouts that need to be binded
		 * @param flags Binding flags
		 * @return Array of created bindings
		 */
		public abstract BindingInterface[] map_properties (Object? source, Object? target, string[] layout, BindFlags flags=BindFlags.SYNC_CREATE);

		/**
		 * Returns binder object for chaining
		 * 
		 * @since 0.1
		 */
		public Binder binder()
		{
			return (binder_object);
		}
	}
}
