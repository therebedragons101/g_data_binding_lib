namespace GData
{
	/**
	 * Interface for needed functionality in BindingInformation. This is only
	 * intended when there is a need to supply custom binding information and
	 * it is also used in BindingGroup
	 * 
	 * since 0.1
	 */
	public interface BindingInformationInterface : Object
	{
		/**
		 * Returns if source data is valid or not.
		 * 
		 * Validity is checked first against valid source and then updated on
		 * each property value transfer where bind() specified specific way to
		 * check if data is valid or not. This way source validity always checks
		 * for correct conditions even when property bindings are added or 
		 * removed. When property binding is added, so is its condition and same
		 * for removal where property binding condition is removed as well
		 * 
		 * Note that contract value of "is-valid" will be cumulative of all
		 * conditions on all properties
		 * 
		 * @since 0.1
		 */
		public abstract bool is_valid { get; }
		/**
		 * Activates binding if possible. This executes contract.binder.bind()
		 * method in order to generate BindingInterface
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object being connected and can be used to check sanity.
		 *            This is obtained as part of notifications during "data"
		 *            changes
		 */
		public abstract void bind_connection (Object? obj);
		/**
		 * Unbinds active connection between properties
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object being connected and can be used to check sanity.
		 *            This is obtained as part of notifications during "data"
		 *            changes
		 */
		public abstract void unbind_connection (Object? obj);
	}
}
