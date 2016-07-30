namespace G
{
	public class BindingPointer : Object
	{
		private static GLib.Object _SELF = new GLib.Object();
		[Description (nick="Self", blurb="Pointer to it self")]
		protected static GLib.Object SELF {
			get { return (_SELF); }
		}

		private bool data_disposed = false;

		private BindingReferenceType _reference_type = BindingReferenceType.DEFAULT;
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
		public BindingPointerUpdateType update_type {
			get {
				if ((data != null) && 
				    (data.get_type().is_a(typeof(BindingPointer)) == true))
					return (((BindingPointer) data).update_type);
				return (_update_type); 
			}
		}

		private StrictWeakReference<Object?> _data = null;
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

		protected virtual bool handle_messages {
			get { return ((get_source() != null) && (data_disposed == false)); }
		}

		protected virtual Object? redirect_to (ref bool redirect_in_play)
		{
			redirect_in_play = false;
			return (null);
		}

		// Returns real end of chain value for source object specified in data where
		// result can point to any relation as binding pointers specify
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

		public void handle_data_changed (BindingPointer source, string data_change_cookie)
		{
			data_changed (this, data_change_cookie);
		}

		public void handle_connect_notifications (Object? obj)
		{
			connect_notifications (obj);
		}

		public void handle_disconnect_notifications (Object? obj)
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

		public BindingPointer hold (BindingPointer pointer)
		{
			pointer.ref();
			pointer.weak_ref (pointer.handle_store_weak_ref);
			return (pointer);
		}

		public void release (BindingPointer pointer)
		{
			pointer.weak_unref (handle_store_weak_ref);
		}

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

		// Signal that emits notification data in pointer has changed. When needed, this signal should be 
		// emited either from outside code or from connections made in "connect-notifications". Later is
		// probably much better for retaining clean code
		//
		// The major useful part here is that contract is already binding pointer
		public signal void data_changed (BindingPointer source, string data_change_cookie);

		// Signal is called whenever binding pointer "get_source()" would start pointing to new valid location
		// and allows custom handling to control emission of custom notifications with "data-changed"
		// This signal is only emited when "binding-type" is MANUAL
		public signal void connect_notifications (Object? obj);

		// Signal is called when "get_source()" is just about to be starting pointing to something else in
		// order for custom binding pointer to be able to disconnect emission of custom "data-changed" 
		// notifications
		// This signal is only emited when "binding-type" is MANUAL
		public signal void disconnect_notifications (Object? obj);

		// Signal specifies "get_source()" will be pointing to something else after handling is over
		// While it seems like a duplication of "connect-notifications", it is not.
		// "connect-notifications" is only emited when "binding-type" is MANUAL and there are a lot of
		// cases when "connect-notifications" can retain stable notifications trough whole application 
		// life, while "before-source-change" will need to inform every interested part that "get_source()"
		// will now point to something new
		public signal void before_source_change (BindingPointer source, bool same_type, Object? next_source);

		// Signal is sent after "get_source()" points to new data. 
		public signal void source_changed (BindingPointer source);

		public BindingPointer (Object? data = null, BindingReferenceType reference_type = BindingReferenceType.WEAK, BindingPointerUpdateType update_type = BindingPointerUpdateType.PROPERTY)
		{
			_data = new StrictWeakReference<Object?> (null, handle_strict_ref);
			_reference_type = reference_type;
			_update_type = update_type;
			this.data = data;
		}
	}
}
