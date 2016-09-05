namespace GData
{
	/**
	 * PropertyBinding is reimplementation of GBinding with added functionality.
	 * Main purpose for this class is handling data transfer between two
	 * properties based on how they were connected
	 * 
	 * @since 0.1
	 */
	public class PropertyBinding : Object, BindingInterface, DataFloodDetection
	{
		private const string DEBUG_STR = "		binding: ";

		internal class SignalInfo
		{
			public ulong signal_handler_id;
			public string signal_name;
			public StrictWeakRef object;
			public Callback callback;

			public void connect_signal (Object caller)
			{
				if ((signal_handler_id != 0) || (object.is_valid_ref() == false))
					return;
				signal_handler_id = Signal.connect_swapped (object.target, signal_name, callback, caller);
			}

			public void disconnect_signal()
			{
				if (object.is_valid_ref() == true)
					if (SignalHandler.is_connected(object.target, signal_handler_id) == true)
						SignalHandler.disconnect (object.target, signal_handler_id);
				signal_handler_id = 0;
			}

			public SignalInfo (ulong signal_handler_id, string signal_name, Object object, Callback callback)
			{
				this.signal_handler_id = signal_handler_id;
				this.signal_name = signal_name;
				this.object = new StrictWeakRef(object);
				this.callback = callback;
			}
		}

		GLib.Array<SignalInfo> _signals = new GLib.Array<SignalInfo>();

		// used to avoid delay on sync, no relation with thread safety
		private bool data_sync_in_process = false;

		// only case when this is false is when reference to either source or
		// target is dropped
		private bool is_valid = true;
		private bool unbound = true;
		private bool ref_alive = true;

		// flood detection
		private bool events_flooding = false;
		private int64 last_event = 0;
		private int events_in_flood = 0;
		private bool last_direction_from_source = true;

		private bool delay_active = false;

		// lock counter that prevents updating to happen if not 0, no realtion with thread safety
		// purely internal lock from your self situation
		private int is_locked = 0;

		// freeze counter, set with freeze()/unfreeze()
		private int freeze_counter = 0;

		/**
		 * Flood detection active or not
		 * 
		 * @since 0.1
		 */
		public bool flood_detection { 
			get { return (_flags.HAS_FLOOD_DETECTION()); } 
			set {
				if (value == true)
					_flags = _flags | BindFlags.FLOOD_DETECTION;
				else
					_flags = _flags & ~(BindFlags.FLOOD_DETECTION);
			}
		}

		/**
		 * Flood detection activation interval (in ms)
		 * 
		 * Flooding will be activated if promote_flood_limit consecutive amount
		 * of events happen in shorter intervals than specified with 
		 * flood_interval.
		 * 
		 * Note that flood_interval specifies amount for one event, not all 
		 * 
		 * @since 0.1
		 */
		public uint flood_interval { get; set; default = 100; }

		private uint _promote_flood_limit = 5;
		/**
		 * Sets amount of needed consecutive events in order to promote flood
		 * 
		 * Flooding will be activated if promote_flood_limit consecutive amount
		 * of events happen in shorter intervals than specified with 
		 * flood_interval.
		 * 
		 * Note that flood_interval specifies amount for one event, not all 
		 * 
		 * @since 0.1
		 */
		public uint promote_flood_limit { 
			get { return (_promote_flood_limit); }
			set { _promote_flood_limit = value; }
		}

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

		private bool __is_active() 
		{
			return ((freeze_counter == 0) && 
			        ((flags & BindFlags.INACTIVE) != BindFlags.INACTIVE) &&
			         (is_valid == true));
		}

		/**
		 * Returns if binding is active or not
		 * 
		 * @since 0.1
		 */
		public bool is_active {
			// same as __is_active except not reflecting. Just slower
			get { return (__is_active()); }
		}

		private static bool default_transform (Value value_a,
		                                       ref Value value_b)
		{
			if ((value_a.type().is_a(value_b.type()) == true) ||
			    (Value.type_compatible(value_a.type(), value_b.type()) == true)) {
				value_a.copy (ref value_b);
				return (true);
			}

			if ((Value.type_transformable(value_a.type(), value_b.type()) == true) &&
			    (value_a.transform(ref value_b) == true))
				return (true);

			GLib.warning ("%s: Unable to convert a value of type %s to a value of type %s",
			              "default_transform()",
			              value_a.type().name(),
			              value_b.type().name());
			return (false);
		}

		private static bool do_invert_boolean (ref Value val)
		{
			GLib.assert (val.holds(typeof(bool)));

			val.set_boolean (! (val.get_boolean()));
			return (true);
		}

		private BindingDataTransfer? _source_transfer = null;
		private BindingDataTransfer? _target_transfer = null;

		/**
		 * Returns full binding information about source
		 * 
		 * @since 0.1
		 * 
		 * @return Full binding information about source.
		 */
		public BindingDataTransferInterface get_source_binding_data_transfer_information()
		{
			return (_source_transfer);
		}

		/**
		 * Returns full binding information about target
		 * 
		 * @since 0.1
		 * 
		 * @return Full binding information about target
		 */
		public BindingDataTransferInterface get_target_binding_data_transfer_information()
		{
			return (_target_transfer);
		}

		/**
		 * Source object data is being transfered from
		 * 
		 * @delay 0.1
		 */
		public Object? source {
			get { return (_source_transfer.get_object()); }
		}

		/**
		 * Source property name
		 * 
		 * @since 0.1
		 */
		public string source_property { 
			owned get {	return (_source_transfer.get_name()); }
		}

		/**
		 * Target object data is being transfered to
		 * 
		 * @delay 0.1
		 */
		public Object? target {
			get { return (_target_transfer.get_object()); }
		}

		/**
		 * Target property name
		 * 
		 * @since 0.1
		 */
		public string target_property { 
			owned get {	return (_target_transfer.get_name()); }
		}

		private BindFlags _flags = BindFlags.DEFAULT;
		/**
		 * Binding flags that represent how binding was created and also
		 * state binding is in as well
		 * 
		 * @since 0.1
		 */
		public BindFlags flags { 
			get { return (_flags); }
		}

		private PropertyBindingTransformFunc? _transform_to = null;
		/**
		 * Custom method to transform data from source value to target value
		 * 
		 * @since 0.1
		 */
		public PropertyBindingTransformFunc? transform_to {
			get { return (_transform_to); }
		}

		private PropertyBindingTransformFunc? _transform_from = null;
		/**
		 * Custom method to transform data from target value to source value
		 * 
		 * @since 0.1
		 */
		public PropertyBindingTransformFunc? transform_from {
			get { return (_transform_from); }
		}

		private void initial_data_update()
		{
			if (_flags.HAS_SYNC_CREATE() == false)
				return;
			data_sync_in_process = true;
			if (_flags.IS_REVERSE() == false)
				__update_from_source (!__is_active());
			else
				__update_from_target (!__is_active());
			data_sync_in_process = false;
		}

		private void notify_transfer_from_source (Object obj, ParamSpec prop)
		{
			__update_from_source (false);
		}

		private void notify_transfer_from_target (Object obj, ParamSpec prop)
		{
			__update_from_target (false);
		}

		private void ___update_from_source()
		{
			__update_from_source (false);
		}

		private void ___update_from_target()
		{
			__update_from_target (false);
		}

		// notify signals should already be as notify::property_name
		private void connect_signal (Object? obj, string detailed_signal, bool emit_update_from_source)
		{
			Callback callback = (emit_update_from_source == true) ? 
				(Callback) ___update_from_source : (Callback) ___update_from_target;
			for (int i=0; i<_signals.length; i++)
				if ((_signals.data[i].object.target == obj) &&
				    (_signals.data[i].callback == callback) &&
				    (_signals.data[i].signal_name == detailed_signal)) {
					if (has_set_flag(flags, BindFlags.DEBUG) == true)
						GLib.message (DEBUG_STR + "connecting signal: " + detailed_signal + " from " + ((emit_update_from_source == true) ? "source" : "target"));
					_signals.data[i].connect_signal(this);
					return;
				}
			ulong signal_handler_id = Signal.connect_swapped (obj, detailed_signal, callback, this);
			if (signal_handler_id != 0)
				_signals.append_val (new SignalInfo (signal_handler_id, detailed_signal, obj, callback));
		}

		private void connect_signals()
		{
			if (__is_active() == false)// || (unbound == false))
				return;
			if (_flags.HAS_MANUAL_UPDATE() == true)
				return;
			if (unbound == false)
				return;
			if (has_set_flag(flags, BindFlags.DEBUG) == true)
				GLib.message (DEBUG_STR + "connect_signals()");
			unbound = false;
			if (_source_transfer.is_valid_ref() == true) {
				if ((_flags.IS_BIDIRECTIONAL() == true) ||
				    (_flags.IS_REVERSE() == false)) {
					if (_flags.IS_CUSTOM_EVENTS_ONLY() == false)
						_source_transfer.connect_signal();
					// Connect additional events
				}
			}
			if (_target_transfer.is_valid_ref() == true) {
				if ((_flags.IS_BIDIRECTIONAL() == true) ||
				    (_flags.IS_REVERSE() == true)) {
					if (_flags.IS_CUSTOM_EVENTS_ONLY() == false)
						_target_transfer.connect_signal();
					// Connect additional events
				}
			}
		}

		private void disconnect_signals()
		{
			if (_flags.HAS_MANUAL_UPDATE() == true)
				return;
			if (has_set_flag(flags, BindFlags.DEBUG) == true)
				GLib.message (DEBUG_STR + "disconnect_signals()");
			unbound = true;
			_source_transfer.disconnect_signal();
			_target_transfer.disconnect_signal();
			for (int i=0; i<_signals.length; i++)
				_signals.data[i].disconnect_signal();
		}

		/**
		 * Increments freeze counter by 1 and stops transfer of data. Transfer
		 * can be restored with equal amount of calls to unfreeze()
		 * 
		 * @since 0.1
		 * @param hard_freeze Specifies how freeze should act. Soft freeze is
		 *                    just ignoring signals and not transfering data,
		 *                    while hard freeze drops signals completely. This
		 *                    is aiming for cases when there is need for best 
		 *                    performance possible
		 */
		public void freeze(bool hard_freeze = false)
		{
			freeze_counter++;
			if (freeze_counter == 1) {
				if (is_valid == true) {
					_flags = flags | BindFlags.INACTIVE;
					notify_property ("is-active");
				}
			}
			if (hard_freeze == true)
				disconnect_signals();
			if (has_set_flag(flags, BindFlags.DEBUG) == true)
				GLib.message (DEBUG_STR + "freeze(%i)".printf(freeze_counter));
		}

		/**
		 * Decrements freeze counter by 1 and if counter is 0 it restores it to
		 * normal functionality. Hard/soft freeze() does not play role here.
		 * Transfer will be restored in both cases
		 * 
		 * @since 0.1
		 */
		public bool unfreeze()
		{
			if (freeze_counter <= 0)
				return (true);
			freeze_counter--;
			if (freeze_counter == 0) {
				_flags = flags & ~BindFlags.INACTIVE;
				notify_property ("is-active");
				connect_signals();
				initial_data_update();
			}
			if (has_set_flag(flags, BindFlags.DEBUG) == true)
				GLib.message (DEBUG_STR + "unfreeze(%i)".printf(freeze_counter));
			return (__is_active());
		}

		private void target_set_value (bool set_default)
		{
			if (has_set_flag(flags, BindFlags.DEBUG) == true)
				GLib.message (DEBUG_STR + "target_set_value()");
			Value srcval = Value(_source_transfer.get_value_type());
			Value tgtval = Value(_target_transfer.get_value_type());
			_source_transfer.get_value (ref srcval);

			bool res = true;
			if (_transform_to != null) {
				res = _transform_to (this, srcval, ref tgtval);
			}
			else {
				// do not check types or validity here, fix initialization so it won't happen
				default_transform (srcval, ref tgtval);
				if (_flags.HAS_INVERT_BOOLEAN() == true)
					do_invert_boolean (ref tgtval);
			}
			if (res == true)
				_target_transfer.set_value (tgtval);
		}

		private void source_set_value (bool set_default)
		{
			if (has_set_flag(flags, BindFlags.DEBUG) == true)
				GLib.message (DEBUG_STR + "source_set_value()");
			Value srcval = Value(_source_transfer.get_value_type());
			Value tgtval = Value(_target_transfer.get_value_type());
			_target_transfer.get_value (ref tgtval);

			bool res = true;
			if (_transform_from != null) {
				res = _transform_from (this, tgtval, ref srcval);
			}
			else {
				// do not check types or validity here, fix initialization so it won't happen
				default_transform (tgtval, ref srcval);
				if (_flags.HAS_INVERT_BOOLEAN() == true)
					do_invert_boolean (ref srcval);
			}
			if (res == true)
				_source_transfer.set_value (srcval);
		}

		private bool flood_timeout()
		{
			if ((data_sync_in_process == true) || (_source_transfer.is_valid_ref() == false) || (_target_transfer.is_valid_ref() == false))
				return (false);
			int64 ctime = GLib.get_monotonic_time()/1000;
			if (ctime > (last_event+flood_interval)) {
				events_flooding = false;
				events_in_flood = 0;
				flood_stopped (this);

				// since it is unknown if this flood resulted in manual or automatic
				// process, it is best to just update this with all checks. the fact
				// that direction is random, handling it with freeze()/unfreeze() and
				// relying on SYNC_CREATE is not possible
				if (last_direction_from_source == true)
					update_from_source();
				else
					update_from_target();
				if (has_set_flag(flags, BindFlags.DEBUG) == true)
					GLib.message (DEBUG_STR + "flood stopped");
				return (false);
			}
			return (true);
		}

		private bool process_flood (bool from_source)
		{
			// handle flood if needed
			if (_flags.HAS_FLOOD_DETECTION() == true) {
				int64 current_time = GLib.get_monotonic_time()/1000;
				if (events_flooding == true) {
					last_direction_from_source = from_source;
					last_event = current_time;
					return (false);
				}
				if ((last_event + flood_interval) > current_time) {
					last_event = current_time;
					events_in_flood++;
					if (events_in_flood >= _promote_flood_limit) {
						events_flooding = true;
						flood_detected (this);
						GLib.Timeout.add ((flood_interval), flood_timeout, GLib.Priority.DEFAULT);
						if (has_set_flag(flags, BindFlags.DEBUG) == true)
							GLib.message (DEBUG_STR + "flood detected");
						return (false);
					}
				}
				else
					last_event = current_time;
			}
			return (true);
		}

		private bool delay_timeout()
		{
			if ((_source_transfer.is_valid_ref() == false) || (_target_transfer.is_valid_ref() == false))
				return (false);
			int64 ctime = GLib.get_monotonic_time()/1000;
			if (ctime > (last_event+delay_interval)) {
				// since it is unknown if this delay resulted in manual or automatic
				// process, it is best to just update this with all checks. the fact
				// that direction is random, handling it with freeze()/unfreeze() and
				// relying on SYNC_CREATE is not possible
				data_sync_in_process = true;
				if (last_direction_from_source == true)
					update_from_source();
				else
					update_from_target();
				data_sync_in_process = false;
				delay_active = false;
				return (false);
			}
			return (true);
		}

		private bool process_delay (bool from_source)
		{
			if (data_sync_in_process == true)
				return (true);
			if (_flags.IS_DELAYED() == true) {
				int64 current_time = GLib.get_monotonic_time()/1000;
				last_direction_from_source = from_source;
				last_event = current_time;
				if (delay_active == false) {
					delay_active = true;
					GLib.Timeout.add ((delay_interval), delay_timeout, GLib.Priority.DEFAULT);
				}
				return (false);
			}
			return (true);
		}

		private void __update_from_source (bool set_default = false)
		{
			if (has_set_flag(flags, BindFlags.DEBUG) == true)
				GLib.message (DEBUG_STR + "__update_from_source()");
			if (_target_transfer.is_valid_ref() == false)
				return;
			if (((set_default == false) && (__is_active() == false)) || (is_locked > 0))
				return;
			if (process_flood(true) == false)
				return;
			if (process_delay(true) == false)
				return;
			is_locked++;
			if (has_set_flag(flags, BindFlags.DEBUG) == true)
				GLib.message (DEBUG_STR + "__update_from_source().passed_checks");
			target_set_value (set_default);
			is_locked--;
		}

		private void _update_from_source (bool set_default = false)
		{
			if ((_target_transfer.is_valid_ref() == false) && (set_default == false)) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Source object %s is not alive", _source_transfer.get_object_type_name());
				return;
			}
			if (_target_transfer.is_valid_ref() == false) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Target object %s is not alive", _target_transfer.get_object_type_name());
				return;
			}
			if ((_target_transfer.get_property_flags() & ParamFlags.WRITABLE) != ParamFlags.WRITABLE) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Property (target) %s.\"%s\" is not writable", _target_transfer.get_object_type_name(), target_property);
				return;
			}
			if ((set_default == false) && ((_source_transfer.get_property_flags() & ParamFlags.READABLE) != ParamFlags.READABLE)) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Property (source) %s.\"%s\" is not readable", _source_transfer.get_object_type_name(), source_property);
				return;
			}
			__update_from_source (set_default);
		}

		/**
		 * Triggers manual update from source 
		 * 
		 * @since 0.1
		 */
		public void update_default_from_source()
		{
			_update_from_source (true);
		}

		/**
		 * Triggers manual update from source 
		 * 
		 * @since 0.1
		 */
		public void update_from_source()
		{
			_update_from_source (false);
		}

		private void __update_from_target (bool set_default = false)
		{
			if (has_set_flag(flags, BindFlags.DEBUG) == true)
				GLib.message (DEBUG_STR + "__update_from_target()");
			if (_source_transfer.is_valid_ref() == false)
				return;
			if ((__is_active() == false) || (is_locked > 0))
				return;
			if (process_flood(false) == false)
				return;
			if (process_delay(false) == false)
				return;
			is_locked++;
			if (has_set_flag(flags, BindFlags.DEBUG) == true)
				GLib.message (DEBUG_STR + "__update_from_target().passed_checks");
			source_set_value (set_default);
			is_locked--;
		}

		private void _update_from_target (bool set_default = false)
		{
			if (_source_transfer.is_valid_ref() == false) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Source object %s is not alive", _source_transfer.get_object_type_name());
				return;
			}
			if ((_target_transfer.is_valid_ref() == false) && (set_default == false)) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Target object %s is not alive", _target_transfer.get_object_type_name());
				return;
			}
			if ((_source_transfer.get_property_flags() & ParamFlags.WRITABLE) != ParamFlags.WRITABLE) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Property (source) %s.\"%s\" is not writable", _source_transfer.get_object_type_name(), source_property);
				return;
			}
			if ((set_default == false) && ((_target_transfer.get_property_flags() & ParamFlags.READABLE) != ParamFlags.READABLE)) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Property (target) %s.\"%s\" is not readable", _target_transfer.get_object_type_name(), target_property);
				return;
			}
			__update_from_target (set_default);
		}

		/**
		 * Triggers manual update from target 
		 * 
		 * @since 0.1
		 */
		public void update_default_from_target()
		{
			_update_from_target (true);
		}

		/**
		 * Triggers manual update from target 
		 * 
		 * @since 0.1
		 */
		public void update_from_target()
		{
			_update_from_target (false);
		}

		private void initiate_connection()
		{
			if ((_source_transfer.is_valid_ref() == false) || (_target_transfer.is_valid_ref() == false))
				return;
			connect_signals();
			initial_data_update();
		}

		/**
		 * Invokes binding creation and connection. Note that this is default
		 * method being called by Binder.bind()
		 * 
		 * The main requirement for this is that creation must be strict and 
		 * fail if passed parameters are wrong
		 * 
		 * NOTE!
		 * transform_from and transform_to can work in two ways. If value return
		 * is true, then newly converted value is assigned to property, if
		 * return is false, then that doesn't happen which can be used to assign
		 * property values directly and avoiding value conversion
		 *   
		 * @since 0.1
		 * @param source Source object
		 * @param source_property Source property name
		 * @param target Target object
		 * @param target_property Target property name
		 * @param flags Flags describing property binding creation
		 * @param transform_to Custom method to transform data from source value
		 *                     to target value
		 * @param transform_from Custom method to transform data from source 
		 *                       value to target value
		 * @return Newly create BindingInterface (note that PropertyBinding is
		 *         implementing it) or null if creation failed
		 */
		public static PropertyBinding? bind (Object? source, string source_property, Object? target, string target_property, 
		                                     BindFlags bind_flags = BindFlags.DEFAULT, owned PropertyBindingTransformFunc? transform_to = null, 
		                                     owned PropertyBindingTransformFunc? transform_from = null)
		{
			BindFlags flags = bind_flags;
			string srcprop = source_property;
			string tgtprop = target_property;
			bool srcread = false;
			bool srcwrite = false;
			bool tgtread = false;
			bool tgtwrite = false;
			if (source == null) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Specified source is NULL");
				return (null);
			}
			if (target == null) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Specified target is NULL");
				return (null);
			}
			if (source == target) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("(source == target), there is probably better way to bind the properties");
				return (null);
			}

			BindingDataTransfer? _source_transfer = BindingDefaults.get_instance().get_transfer_object_for (source, srcprop, flags.IS_ORIGINAL_SOURCE());
			if (_source_transfer == null) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Could not allocate BindingDataTransfer for source(%s)", source.get_type().name());
				return (null);
			}
			BindingDataTransfer? _target_transfer = BindingDefaults.get_instance().get_transfer_object_for (target, tgtprop, flags.IS_ORIGINAL_TARGET());
			if (_target_transfer == null) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Could not allocate BindingDataTransfer for target(%s)", target.get_type().name());
				return (null);
			}
			if ((_source_transfer.get_name() == "") ||
			    ((_source_transfer.get_property_flags() & ParamFlags.CONSTRUCT_ONLY) == ParamFlags.CONSTRUCT_ONLY)) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Type %s (source) does not contain property with name \"%s\"", source.get_type().name(), srcprop);
				return (null);
			}
			if ((_target_transfer.get_name() == "") ||
			    ((_target_transfer.get_property_flags() & ParamFlags.CONSTRUCT_ONLY) == ParamFlags.CONSTRUCT_ONLY)) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Type %s (target) does not contain property with name \"%s\"", target.get_type().name(), tgtprop);
				return (null);
			}
			if (flags.IS_BIDIRECTIONAL() == true) {
				srcread = true;
				srcwrite = true;
				tgtread = true;
				tgtwrite = true;
			}
			else if (flags.IS_REVERSE() == true) {
				srcwrite = true;
				tgtread = true;
			}
			else {
				srcread = true;
				tgtwrite = true;
			}
			if ((srcread == true) &&
			    ((_source_transfer.get_property_flags() & ParamFlags.READABLE) != ParamFlags.READABLE)) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Type %s (source) does not contain READABLE property with name \"%s\"", source.get_type().name(), srcprop);
				return (null);
			}
			if ((srcwrite == true) &&
			    ((_source_transfer.get_property_flags() & ParamFlags.WRITABLE) != ParamFlags.WRITABLE)) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Type %s (source) does not contain WRITABLE property with name \"%s\"", source.get_type().name(), srcprop);
				return (null);
			}
			if ((tgtread == true) &&
			    ((_target_transfer.get_property_flags() & ParamFlags.READABLE) != ParamFlags.READABLE)) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Type %s (target) does not contain READABLE property with name \"%s\"", target.get_type().name(), tgtprop);
				return (null);
			}
			if ((tgtwrite == true) &&
			    ((_target_transfer.get_property_flags() & ParamFlags.WRITABLE) != ParamFlags.WRITABLE)) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("Type %s (target) does not contain WRITABLE property with name \"%s\"", target.get_type().name(), tgtprop);
				return (null);
			}
			if ((flags.IS_DELAYED() == true) &&
			    (flags.HAS_FLOOD_DETECTION() == true)) {
				if (flags.IS_CONDITIONAL() == false)
					GLib.warning ("FLOOD_DETECTION and DELAYED are incompatible. Ignoring FLOOD_DETECTION");
				flags = flags & ~(BindFlags.FLOOD_DETECTION);
			}
			// only do checks on writable parts as boolean might be result of translation
			if (flags.HAS_INVERT_BOOLEAN() == true) {
				if ((srcwrite == true) &&
				    (_source_transfer.get_value_type() != typeof(bool))) {
					if (flags.IS_CONDITIONAL() == false)
						GLib.warning ("Type %s (source) does not contain WRITABLE boolean property with name \"%s\"", source.get_type().name(), srcprop);
					return (null);
				}
				if ((tgtwrite == true) &&
				    (_target_transfer.get_value_type() != typeof(bool))) {
					if (flags.IS_CONDITIONAL() == false)
						GLib.warning ("Type %s (target) does not contain WRITABLE boolean property with name \"%s\"", target.get_type().name(), tgtprop);
					return (null);
				}
			}
			if (has_set_flag(flags, BindFlags.DEBUG) == true)
				GLib.message (DEBUG_STR + "Binding initiated()");
			return (new PropertyBinding (_source_transfer, _target_transfer, flags, (owned) transform_to, (owned) transform_from));
		}

		/**
		 * Adds property to binding as notification its data has changed
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object containing the property
		 * @param property_name Specifies array of properties that need to be
		 *                       connected
		 * @param trigger_update_from Specifies side which property will be 
		 *                            connected to
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public BindingInterface add_custom_property_notification (Object? obj, string property_name, BindingSide trigger_update_from)
		{
			return (add_custom_signal (obj, "notify::" + property_name, trigger_update_from));
		}

		/**
		 * Adds signal to binding as notification its data has changed
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object containing the property
		 * @param signal_name Specifies signal that need to be connected
		 * @param trigger_update_from Specifies side which property will be 
		 *                            connected to
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public BindingInterface add_custom_signal (Object? obj, string signal_name, BindingSide trigger_update_from)
		{
			connect_signal (obj, signal_name, (trigger_update_from == BindingSide.SOURCE));
			return (this);
		}

		private void _unbind()
		{
			if (unbound == false) {
				unbound = true;
				disconnect_signals();
				if (_source_transfer != null) {
					_source_transfer.changed.disconnect (___update_from_source);
					_source_transfer.reference_dropped.disconnect (handle_source_dead);
					_source_transfer = null;
				}
				if (_target_transfer != null) {
					_target_transfer.changed.disconnect (___update_from_target);
					_target_transfer.reference_dropped.disconnect (handle_target_dead);
					_target_transfer = null;
				}
			}
		}

		/**
		 * Unbind drops property binding and stops data transfer. It also
		 * drops its own permanent holding reference which means that if there
		 * is no other live reference, object will be disposed
		 * 
		 * @since 0.1
		 */
		public void unbind()
		{
			if (ref_alive == true)
				dropping (this);
			_unbind();
			if (ref_alive == true) {
				ref_alive = false;
				unref();
			}
		}

		private void handle_source_dead()
		{
			// source is already null here since handling of weak_unref was before dispatching this
			is_valid = false;
			unbind();
		}

		private void handle_target_dead()
		{
			// target is already null here since handling of weak_unref was before dispatching this
			is_valid = false;
			unbind();
		}

		~PropertyBinding()
		{
			_unbind();
		}

		private PropertyBinding (BindingDataTransfer? source, BindingDataTransfer? target, 
		                         BindFlags flags = BindFlags.DEFAULT, owned PropertyBindingTransformFunc? transform_to = null, 
		                         owned PropertyBindingTransformFunc? transform_from = null)
		{
			// no need for error checking as it had been done in create() which is only public accessible
			// way of creation

			_source_transfer = source;
			_target_transfer = target;
			_source_transfer.changed.connect (___update_from_source);
			_target_transfer.changed.connect (___update_from_target);
			_source_transfer.reference_dropped.connect (handle_source_dead);
			_target_transfer.reference_dropped.connect (handle_target_dead);

			_transform_to = (owned) transform_to;
			_transform_from = (owned) transform_from;

			_flags = flags;

			if ((flags & BindFlags.INACTIVE) == BindFlags.INACTIVE)
				freeze_counter = 1;

			initiate_connection();
			// add reference to keep your self alive until unbind
			ref();
		}
	}
}
