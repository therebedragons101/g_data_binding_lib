namespace GData
{
	public enum BindingSide
	{
		SOURCE,
		TARGET
	}

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
		 * Adds property to binding as notification its data has changed
		 * 
		 * @since 0.1
		 * 
		 * @param side Specifies side which property will be connected to
		 * @param property_names Specifies array of properties that need to be
		 *                       connected
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public abstract BindingInterface add_property_notification (BindingSide side, string property_name);

		/**
		 * Adds signal to binding as notification its data has changed
		 * 
		 * @since 0.1
		 * 
		 * @param side Specifies side which signal will be connected to
		 * @param signal_name Specifies signal that need to be connected
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public abstract BindingInterface add_signal (BindingSide side, string signal_name);

		/**
		 * Adds properties to binding as notification its data has changed
		 * 
		 * This just calls add_property_notification() for every specified 
		 * property name
		 * 
		 * @since 0.1
		 * 
		 * @param side Specifies side which property will be connected to
		 * @param property_names Specifies array of properties that need to be
		 *                       connected
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public BindingInterface add_property_notifications (BindingSide side, string[]? property_names)
		{
			if (property_names == null)
				return (this);
			for (int i=0; i<property_names.length; i++)
				add_property_notification (side, property_names[i]);
			return (this);
		}

		/**
		 * Adds signals to binding as notification its data has changed
		 * 
		 * This just calls add_signal() for every specified signal name
		 * 
		 * @since 0.1
		 * 
		 * @param side Specifies side which signal will be connected to
		 * @param signal_names Specifies array of signals that need to be
		 *                     connected
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public BindingInterface add_signals (BindingSide side, string[] signal_names)
		{
			if (signal_names == null)
				return (this);
			for (int i=0; i<signal_names.length; i++)
				add_signal (side, signal_names[i]);
			return (this);
		}

		/**
		 * Signal emited upon unbind of binding interface
		 * 
		 * @since 0.1
		 */
		public signal void dropping (BindingInterface binding);
	}
}
