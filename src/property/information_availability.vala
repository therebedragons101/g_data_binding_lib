namespace GData
{
	/**
	 * Specifies data transfer information availability in order to specify how
	 * information is available per specific type registered in BindingDefaults
	 * 
	 * Some bindable types are STATIC like GObject where properties are
	 * specified on time of its creation, while some types can be DYNAMIC like
	 * GSettings where type will be the same, but there is no guarantee keys
	 * will exist in each reference
	 * 
	 * @since 0.1
	 */
	public enum InformationAvailability
	{
		/**
		 * Unavailable means that data transfer could not be resolved for
		 * specific type
		 * 
		 * @since 0.1
		 */
		UNAVAILABLE,
		/**
		 * Defines statically available information like properties in GObject,
		 * where they are defined on type definition and available for whole
		 * time
		 * 
		 * @since 0.1
		 */
		STATIC,
		/**
		 * Dynamic information means that bindable parts are probably objects
		 * contents and not its properties, which means they can be completely
		 * different with each instance
		 * 
		 * @since 0.1
		 */
		DYNAMIC
	}
}

