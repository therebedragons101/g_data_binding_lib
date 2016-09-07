namespace GData
{
	/**
	 * Delegate used to reset state in BooleanCondition
	 * 
	 * @since 0.1
	 * 
	 * @return If returned value is true, then signal trigger is emited
	 */
	public delegate bool BooleanConditionDelegate();

	/**
	 * Used to track property changes and provide their state.
	 * 
	 * In order to simplify everything, processing of values should be direct
	 * and not trough ProxyProperty values as main purpose of this class is not
	 * value resolving, but rather time when something needs to be reevaluated
	 * 
	 * Since ProxyProperty in nature allows tracking changes trough contracts
	 * and pointers, this also means that trigger is contract aware and if
	 * specified right way it can stay stable across whole application lifetime.
	 * Second thing that needs to be also noted is that each ProxyProperty can
	 * as well belong to different contract (or no contract at all) and trigger
	 * will still serve its notification job as it should
	 * 
	 * Note that nothing prevents one to have subclasses of ProxyProperty which
	 * provide value in more accessible way. Reason why they are not implemented
	 * is simple as this is best to be done in language extension. With Vala for
	 * example all that is needed is one generic class that can handle all types
	 * while in languages that don't support generics this might be more complex
	 * 
	 * @since 0.1
	 */
	public class BooleanCondition : ProxyPropertyGroup
	{
		private BooleanConditionDelegate? _method = null;
		/**
		 * Method used to reset state value property on changes
		 * 
		 * @since 0.1
		 */
		public BooleanConditionDelegate? method {
			get { return (_method); }
			set {
				if (_method == value)
					return;
				_method = value;
				check_state();
			}
		}

		private bool _state = false;
		/**
		 * Provides state property
		 * 
		 * @since 0.1
		 */
		public bool state {
			get { return (_state); }
			set {
				if (_state == value)
					return;
				_state = value;
			}
		}

		private void check_state()
		{
			if (_method == null)
				return;
			state = _method();
		}

		/**
		 * Creates new Trigger
		 * 
		 * @since 0.1
		 * 
		 * @param method Method used to reevaluate need for trigger emission
		 */
		public BooleanCondition (BooleanConditionDelegate? method = null)
		{
			_method = method;
			this.value_changed.connect (check_state);
		}
	}
}
