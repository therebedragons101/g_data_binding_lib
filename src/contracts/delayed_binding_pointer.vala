namespace GData
{
	/**
	 * DelayedBindingPointer serves throtling data refresh with most basic
	 * delay.
	 * 
	 * Each time new source is assigned, DelayedBindingPointer waits for
	 * specified interval and then submits it. If another assigning happened
	 * during that interval, then DelayedBindingPointer issues new interval
	 * of waiting.
	 * 
	 * This is not to be confused with ThrotlingBindingPointer. Unlike that one,
	 * DelayedBindingPointer delays each pointer redirection where
	 * ThrotlingBindingPointer only does if it detects redirections are
	 * happening too fast consecutively
	 * 
	 * @since 0.1
	 */
	public class DelayedBindingPointer : BindingPointer
	{
		/**
		 * Delay interval (in ms)
		 * 
		 * Delays data transfer by specified amount of time on each event. If
		 * next event is emited in shorter interval than delay, then another
		 * delay wait is added
		 * 
		 * Note that flood_interval specifies amount for one event, not all 
		 * 
		 * @since 0.1
		 */
		public uint delay_interval { get; set; default = 400; }
	}
}

