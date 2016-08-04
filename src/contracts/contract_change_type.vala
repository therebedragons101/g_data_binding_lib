namespace GData
{
	/**
	 * Specifies type of change that happened in contract for binding
	 * 
	 * @since 0.1
	 */
	public enum ContractChangeType
	{
		/**
		 * Binding was added
		 * 
		 * @since 0.1
		 */
		ADDED,
		/**
		 * Binding was removed
		 * 
		 * @since 0.1
		 */
		REMOVED,
		/**
		 * Binding state changed
		 * 
		 * @since 0.1
		 */
		STATE_CHANGED;

		/**
		 * Returns string representation of flags
		 * 
		 * @since 0.1
		 */
		public string get_state_str()
		{
			string str = "ADDED";
			if (this == ContractChangeType.REMOVED)
				str = "REMOVED";
			else if (this == ContractChangeType.STATE_CHANGED)
				str = "STATE_CHANGED";
			return (str);
		}
	}
}
