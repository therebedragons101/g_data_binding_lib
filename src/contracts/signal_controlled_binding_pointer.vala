namespace GData
{
	/**
	 * BindingPointer subclass that defines data change dispatch is being
	 * maintained manually
	 * 
	 * Everything needed is already supported by basic BindingPointer and all
	 * this class does is that it limits creation to MANUAL
	 * 
	 * When SignalControlledBindingPointer is created it only needs to connect
	 * to its own connect_notifications() and disconnect_notifications().
	 * These two signals are emited whenever source changes, where there is no
	 * guarantee that source is still alive in disconnect_notifications()
	 * 
	 * Example:
	 * 
	 * void handle_signal()
	 * {
	 *     myptr.data_changed (myptr, "something-chaged");
	 * }
	 * 
	 * myptr = new SignalControlledBindingPointer();
	 * myptr.connect_notifications ((obj) => {
	 *     if (get_source() != null)
	 *         ((MyType) get_source()).some_signal.connect (handle_signal);
	 * ));
	 * myptr.disconnect_notifications ((obj) => {
	 *     if (get_source() != null)
	 *         ((MyType) get_source()).some_signal.disconnect (handle_signal);
	 * ));
	 * 
	 * This is all that is needed to understand how custom signals per binding
	 * source work as this simple code guaratees that every time pointer will
	 * change "data" or end of its chain will start pointing elsewhere signals
	 * will be disconnected and reconnected to new one
	 * 
	 * @since 0.1
	 */
	public class SignalControlledBindingPointer : BindingPointer
	{
		/**
		 * Creates new SignalControlledBindingPointer
		 * 
		 * @since 0.1
		 * @param data Data used as initial source. If data is pointer or 
		 *             contract this leads to chaining them. More on chaining
		 *             in tutorial application
		 * @param reference_type Specifies how source reference should be 
		 *                       treated. Value can be WEAK, STRONG or DEFAULT
		 */
		public SignalControlledBindingPointer (Object? data = null, BindingReferenceType reference_type = BindingReferenceType.WEAK)
		{
			base (data, reference_type, BindingPointerUpdateType.MANUAL);
		}
	}
}
