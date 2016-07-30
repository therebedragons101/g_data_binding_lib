namespace G
{
	/**
	 * Most basic property binding requirement
	 * 
	 * Main use is to define custom property binding objects when controlling
	 * events with Binder
	 * 
	 * @since 0.1
	 */ 
	public interface BindingInterface : Object
	{
		/**
		 * Source object
		 * 
		 * @since 0.1
		 */
		public abstract Object? source { get; }
		/**
		 * Source property name
		 * 
		 * @since 0.1
		 */
		public abstract string source_property { get; }
		/**
		 * Target object
		 * 
		 * @since 0.1
		 */
		public abstract Object? target { get; }
		/**
		 * Target property name
		 * 
		 * @since 0.1
		 */
		public abstract string target_property { get; }
		/**
		 * Flags that describe property binding creation and status
		 * 
		 * @since 0.1
		 */
		public abstract BindFlags flags { get; }

		/**
		 * Unbind drops property binding and stops data transfer. It also
		 * drops its own permanent holding reference which means that if there
		 * is no other live reference, object will be disposed
		 * 
		 * @since 0.1
		 */
		public abstract void unbind();

		/**
		 * Signal emited upon unbind
		 * 
		 * @since 0.1
		 */
		public signal void dropped (BindingInterface binding);
	}
}
