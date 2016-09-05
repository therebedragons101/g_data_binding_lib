namespace GData
{
	/**
	 * Delegate used to check if trigger needs to be emited or not
	 * 
	 * @since 0.1
	 * 
	 * @return If returned value is true, then signal trigger is emited
	 */
	public delegate bool TriggerEmissionDelegate();

	/**
	 * Simple database like trigger for application purposes. Being that trigger
	 * is derived from ProxyPropertyGroup its value gets reevaluated whenever
	 * any property in group changes and if conditions are right then trigger
	 * is emited.
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
	 * @since 0.1
	 */
	public class Trigger : ProxyPropertyGroup
	{
		private TriggerEmissionDelegate? _method = null;
		/**
		 * Method used to verify need for trigger emission. If method returns 
		 * true, then trigger will be emited.
		 * 
		 * @since 0.1
		 */
		public TriggerEmissionDelegate? method {
			get { return (_method); }
			set {
				if (_method == value)
					return;
				_method = value;
				check_trigger();
			}
		}

		private void check_trigger()
		{
			if (_method == null)
				return;
			if (_method() == true)
				trigger();
		}

		/**
		 * Signal is emited when any property in group changes and on
		 * reevaluation trough method true is returned
		 * 
		 * @since 0.1
		 */
		public signal void trigger();

		/**
		 * Creates new Trigger
		 * 
		 * @since 0.1
		 * 
		 * @param method Method used to reevaluate need for trigger emission
		 */
		public Trigger (TriggerEmissionDelegate? method = null)
		{
			_method = method;
			this.value_changed.connect (check_trigger);
		}
	}
}
