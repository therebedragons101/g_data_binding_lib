namespace G
{
	/**
	 * Interface designed for handling group add/remove of property bindings
	 * on contract.
	 * 
	 * There is no official implementation as this is most probably different 
	 * for each use case. Class that wants to promote binding groups must 
	 * implement this interface.
	 * 
	 * Elements are created by calling BindingContract.bind() which returns
	 * BindingInformation as its result.
	 * 
	 * Even though there is no official implementation, BindingContract is also
	 * implementing this interface, except it probably is not the best case of
	 * this functionality
	 * 
	 * @since 0.1
	 */
	public interface BindingGroup : Object
	{
		/**
		 * Returns amount of bindings in group
		 * 
		 * @since 0.1
		 */
		public abstract uint length { get; }
		/**
		 * Returns binding at specified index
		 * 
		 * @since 0.1
		 * @param index Index at which Binding is requested
		 * @return Bindine at specified index
		 */
		public abstract BindingInformationInterface? get_item_at_index (int index);
		
		/**
		 * Signal sent whenever group changes
		 * 
		 * @since 0.1
		 * @param group Group that changed
		 * @param change_type Specifies if binding was ADDED or REMOVED
		 * @param binding Binding that was added or removed
		 */
		public signal void group_changed (BindingGroup group, ContractChangeType change_type, BindingInformationInterface binding);
	}
}
