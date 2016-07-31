namespace G
{
	/**
	 * IMPORTANT! Best and easiest method to understand binding pointers is to
	 * run tutorial demo. Demo focuses on visually exposing all internals and
	 * events and makes something complex something really trivial. It will be
	 * difference between minutes and god knows how long 
	 * 
	 * BindingPointer is the corner stone of complex databinding in this project 
	 * and it is absolute MUST UNDERSTAND> in order to proceed with the rest.
	 * Not understanding it would only lead to not understanding everything else 
	 * including the design of this project
	 * 
	 * NOTE! PropertyBinding intentionally doesn't work by treating 
	 * BindingPointer as advanced contract binding does and treats just as any 
	 * other object type with small exception that it resolves two things from
	 * it when initializing. Any change of "data" is not reflected in 
	 * PropertyBinding. Resolved values are
	 * - Pointer update type
	 * - Final link of its chain resolved with get_source()
	 * 
	 * This is a feature, not a bug
	 * 
	 * @since 0.1
	 */
	public class BindingPointer : Object
	{
		private static GLib.Object _SELF = new GLib.Object();
		/**
		 * Reference used when pointer needs to point at it self
		 * 
		 * @since 0.1
		 */
		[Description (nick="Self", blurb="Pointer to it self")]
		protected static GLib.Object SELF {
			get { return (_SELF); }
		}

		private bool data_disposed = false;

		private BindingReferenceType _reference_type = BindingReferenceType.DEFAULT;
		/**
		 * Specifies how references are being handled for data that is pointed
		 * with BindingPointer
		 * 
		 * WEAK - no reference is ever made on that object with exception of 
		 *        weak_ref(). This is default and suggested behaviour
		 * STRONG - exactly one reference is made to data object
		 * DEFAULT - handling is resolved from end of chain. Note that this can
		 *           end unpredictable if end of chain changes its handling.
		 *           use with extreme caution
		 * 
		 * @since 0.1
		 */
		[Description (nick="Reference type", blurb="Specifies reference type for binding pointer")]
		public virtual BindingReferenceType reference_type {
			get {
				if ((data != null) && 
				    (_reference_type == BindingReferenceType.DEFAULT) &&
				    (data.get_type().is_a(typeof(BindingPointer)) == true))
					return (((BindingPointer) data).reference_type);
				return (_reference_type); 
			}
		}

		private BindingPointerUpdateType _update_type = BindingPointerUpdateType.PROPERTY;
		/**
		 * Specifies mode with which data update events are dispatched
		 * 
		 * Value can be
		 * PROPERTY - connection to events is made on property notify
		 * MANUAL - events will be triggered manually by calling
		 *          data_changed() signal
		 * 
		 * @since 0.1
		 */
		[Description (nick="Update type", blurb="Specifies mode with which data update events are dispatched")]
		public BindingPointerUpdateType update_type {
			get {
				if ((data != null) && 
				    (data.get_type().is_a(typeof(BindingPointer)) == true))
					return (((BindingPointer) data).update_type);
				return (_update_type); 
			}
		}

		private StrictWeakReference<Object?> _data = null;
		/**
		 * Data being pointed with this pointer
		 * 
		 * There is extensive visual demonstration of internals in tutorial demo
		 * 
		 * @since 0.1
		 */
		[Description (nick="Data", blurb="Data object pointed by binding pointer")]
		public Object? data { 
			get { return (_data.target); } 
			set {
				if (get_source() != null)
					disconnect_notifications (get_source());
				if (handle_messages == true)
					before_source_change (this, is_same_type(data, value), value);
				unreference_data();
				if (data != null)
					unchain_pointer();
				if (value == this)
					_data = new StrictWeakReference<Object?>(SELF, handle_strict_ref);
				else
					_data = new StrictWeakReference<Object?>(value, handle_strict_ref);
				if (data != null)
					chain_pointer();
				reference_data();
				if (handle_messages == true) {
					source_changed (this);
					}
				if (get_source() != null)
					connect_notifications (get_source());
			}
		}

		/**
		 * Specifies if signals should be dispatched or not
		 * 
		 * @since 0.1
		 */
		protected virtual bool handle_messages {
			get { return ((get_source() != null) && (data_disposed == false)); }
		}

		/**
		 * One of two core subclassing capabilities. By overriding this method
		 * pointer can redirect its result or even break chain with completely
		 * different continuation. There is no limit on how many times chain
		 * is broken and redirected
		 * 
		 * This method is called as part of get_source() and when this method
		 * sets redirect_in_play to true does not return normal result, but 
		 * rather result provided in redirect_to()
		 * 
		 * BindingPointer subclass that implements this is 
		 * BindingPointerFromPropertyValue which is also featured in tutorial
		 * in order to be easy to understand
		 * 
		 * @since 0.1
		 * @param redirect_in_play If this is set to true, value of get_source()
		 *                         will be result of this method
		 * @return Object or null where pointer should be redirected 
		 */
		protected virtual Object? redirect_to (ref bool redirect_in_play)
		{
			redirect_in_play = false;
			return (null);
		}

		/**
		 * Returns real end of chain value for source object specified in data 
		 * where result can point to any relation as binding pointers specify
		 * 
		 * Note that this can be overriden by custom redirect_to() method
		 * override
		 * 
		 * @since 0.1
		 * @return Final link in the chain
		 */
		public virtual Object? get_source()
		{
			if (data == null)
				return (null);
			if (data == SELF)
				return (this);
			bool redirect = false;
			// note that custom pointers can break the chain if they are set to point something 
			// else, otherwise redirection would not be possible as it would always fall on original
			Object? obj = redirect_to (ref redirect);
			if (redirect == true) {
				if (is_binding_pointer(obj) == true)
					return (((BindingPointer) obj).get_source());
				return (obj);
			}
			// if redirection was not there, follow the chain
			if (is_binding_pointer(data) == true)
				return (((BindingPointer) data).get_source());
			return (data);
		}

		//TODO? Check if this can be simplified since move on StrictWeakReference
		protected virtual void handle_weak_ref (Object obj)
		{
			if (report_possible_binding_errors == true)
				stderr.printf ("Error? Last binding source reference is being dropped in WEAK mode!\n" +
				               "       This probably should never happen! This simply means weak source is handled by\n" +
				               "       weak contract binding. Set contract to STRONG mode unless there is specific reason\n" +
				               "       to handle it like this and dropping part is a feature\n");
			// check if data being disposed is real data. if data points to something else, data will stay the same
			if (obj == data) {
				data_disposed = true;
				data = null;
				data_disposed = false;
			}
		}

		private void handle_strict_ref()
		{
			data_disposed = true;
		}

		private void handle_store_weak_ref (Object obj)
		{
			unref();
		}

		private void sub_source_changed (BindingPointer pointer)
		{
			source_changed (this);
		}

		private void before_sub_source_change (BindingPointer pointer, bool is_same, Object? next)
		{
			before_source_change (this, is_same, next);
//			before_source_change (pointer, is_same, next);
		}

		private void data_dispatch_notify (Object obj, ParamSpec parm)
		{
			notify_property("data");
		}

		private void handle_data_changed (BindingPointer source, string data_change_cookie)
		{
			data_changed (this, data_change_cookie);
		}

		private void handle_connect_notifications (Object? obj)
		{
			connect_notifications (obj);
		}

		private void handle_disconnect_notifications (Object? obj)
		{
			disconnect_notifications (obj);
		}

		private void chain_pointer()
		{
			if (is_binding_pointer(data) == false)
				return;
			((BindingPointer) data).source_changed.connect (sub_source_changed);
			((BindingPointer) data).before_source_change.connect (before_sub_source_change);
			((BindingPointer) data).connect_notifications.connect (handle_connect_notifications);
			((BindingPointer) data).disconnect_notifications.connect (handle_disconnect_notifications);
			((BindingPointer) data).data_changed.connect (handle_data_changed);
			((BindingPointer) data).notify["data"].connect (data_dispatch_notify);
		}

		private void unchain_pointer()
		{
			if (is_binding_pointer(data) == false)
				return;
			((BindingPointer) data).source_changed.disconnect (sub_source_changed);
			((BindingPointer) data).before_source_change.disconnect (before_sub_source_change);
			((BindingPointer) data).connect_notifications.disconnect (handle_connect_notifications);
			((BindingPointer) data).disconnect_notifications.disconnect (handle_disconnect_notifications);
			((BindingPointer) data).data_changed.disconnect (handle_data_changed);
			((BindingPointer) data).notify["data"].disconnect (data_dispatch_notify);
		}

		/**
		 * Helper method to hold pointer reference without the need to either
		 * store it in storage or be assigned as local variable
		 * 
		 * This is useful for middle links of the chain as when holder gets
		 * unreferenced, all pointers being held by it get same treatment. If
		 * there is a need to undo it, method release() should be used
		 * 
		 * @since 0.1
		 * @param pointer Pointer being held
		 * @return Held pointer reference for convenience of possibility to 
		 *         chain API in objective languages
		 */  
		public BindingPointer hold (BindingPointer pointer)
		{
			pointer.ref();
			pointer.weak_ref (pointer.handle_store_weak_ref);
			return (pointer);
		}

		/**
		 * Helper method to release held pointer reference with hold()
		 * store it in storage or be assigned as local variable
		 * 
		 * This is useful for middle links of the chain as when holder gets
		 * unreferenced, all pointers being held by it get same treatment
		 * 
		 * @since 0.1
		 * @param pointer Pointer being released
		 */  
		public void release (BindingPointer pointer)
		{
			pointer.weak_unref (handle_store_weak_ref);
			pointer.unref();
		}

		/**
		 * Method called when new source is being held and there is a need to
		 * reference it.
		 * 
		 * Note that data can be null when called 
		 * 
		 * @since 0.1
		 */
		protected virtual bool reference_data()
		{
			if (data == null)
				return (false);
			data_disposed = false;
			if ((reference_type == BindingReferenceType.WEAK) || (reference_type == BindingReferenceType.DEFAULT))
				data.weak_ref (handle_weak_ref);
			else
				data.@ref();
			return (true);
		}

		/**
		 * Method called when old source is being released and there is a need 
		 * to unreference it.
		 * 
		 * Note that data can be null when called 
		 * 
		 * @since 0.1
		 */
		protected virtual bool unreference_data()
		{
			if (data == null)
				return (false);
			if ((reference_type == BindingReferenceType.WEAK) || (reference_type == BindingReferenceType.DEFAULT))
				data.weak_unref (handle_weak_ref);
			else
				data.unref();
			data_disposed = false;
			return (true);
		}

		/**
		 * Signal that emits notification data in pointer has changed. When 
		 * needed, this signal should be emited either from outside code or from 
		 * connections made in "connect-notifications". Later is 
		 * probably much better for retaining clean code
		 * 
		 * The major useful part here is that contract is already binding pointer
		 * 
		 * @since 0.1
		 * @param source Pointer emiting this notification
		 * @param data_change_cookie Notification description. Can be signal
		 *                           name, property name or anything 
		 */
		public signal void data_changed (BindingPointer source, string data_change_cookie);

		/** 
		 * Signal is called whenever binding pointer "get_source()" would start 
		 * pointing to new valid location and allows custom handling to control 
		 * emission of custom notifications with "data-changed" This signal is 
		 * only emited when "binding-type" is MANUAL
		 * 
		 * @since 0.1
		 * @param obj Object that currently end of chain
		 */
		public signal void connect_notifications (Object? obj);

		/**
		 * Signal is called when "get_source()" is just about to be starting 
		 * pointing to something else in order for custom binding pointer to be 
		 * able to disconnect emission of custom "data-changed" notifications 
		 * This signal is only emited when "binding-type" is MANUAL
		 * 
		 * @since 0.1
		 * @param obj Object that currently end of chain
		 */ 
		public signal void disconnect_notifications (Object? obj);

		/** 
		 * Signal specifies get_source() will be pointing to something else 
		 * after handling is over While it seems like a duplication of 
		 * "connect-notifications", it is not.
		 * 
		 * "connect-notifications" is only emited when "binding-type" is MANUAL 
		 * and there are a lot of cases when "connect-notifications" can retain 
		 * stable notifications trough whole application life, while 
		 * "before-source-change" will need to inform every interested part that 
		 * get_source() will now point to something new
		 * 
		 * @since 0.1
		 * @param source Pointer sending this notification
		 * @param same_type Specifies if next object is same type or not
		 * @param next_source Provides information which will be next end of
		 *                    chain
		 */
		public signal void before_source_change (BindingPointer source, bool same_type, Object? next_source);

		/** 
		 * Signal is sent after get_source() points to new data.
		 *  
		 * @since 0.1
		 * @param source Pointer sending this notification
		 */
		public signal void source_changed (BindingPointer source);

		/**
		 * Creates new BindingPointer
		 * 
		 * @since 0.1
		 * @param data Data used as initial source. If data is pointer or 
		 *             contract this leads to chaining them. More on chaining
		 *             in tutorial application
		 * @param reference_type Specifies how source reference should be 
		 *                       treated. Value can be WEAK, STRONG or DEFAULT
		 * @param update_type Defines if source can be treated by connecting to
		 *                    its properties or source will specify its own 
		 *                    handling. In case of chaining this is also taking
		 *                    effect in chain. More on chaining in tutorial 
		 *                    application
		 */
		public BindingPointer (Object? data = null, BindingReferenceType reference_type = BindingReferenceType.WEAK, BindingPointerUpdateType update_type = BindingPointerUpdateType.PROPERTY)
		{
			_data = new StrictWeakReference<Object?> (null, handle_strict_ref);
			_reference_type = reference_type;
			_update_type = update_type;
			this.data = data;
		}
	}
}
