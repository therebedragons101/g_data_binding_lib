namespace GData
{
	//TODO, finalize contract group activities
	/**
	 * IMPORTANT! Best and easiest method to understand binding contracts is to
	 * run tutorial demo. Demo focuses on visually exposing all internals and
	 * events and makes something complex something really trivial. It will be
	 * difference between minutes and god knows how long 
	 * 
	 * BindingContract is derived from BindingPointer which makes it versatile 
	 * in how data chain can be specified and how data source notifications are 
	 * presented in order to keep that chain as flexible as possible.
	 * 
	 * Binding contract extends the Binding Pointer by adding possibility to 
	 * handle property bindings on specified source by adding/removing. Bindings
	 * can either be added/removed as single entity or as group. Their addition 
	 * checks if reference for specified binding already exists or not. If 
	 * binding is present its lock counter is increased by 1, if not binding 
	 * is added to the contract. when removing binding does not get removed if 
	 * lock counter didn't reach 0. this and group handling makes it available 
	 * for groups to share bindings with no worry
	 * 
	 * @since 0.1
	 */
	public class BindingContract : GData.BindingPointer, BindingStateObjects, BindingValueObjects, BindingGroup, GLib.ListModel
	{
		private bool finalizing_in_progress = false;
		private bool bound = false;

		private GLib.Array<BindingInformationReference> _items = new GLib.Array<BindingInformationReference>();
		private WeakReference<Object?> last_source = new WeakReference<Object?>(null);

		public Object? get_item (uint position)
		{
			return (_items.data[position].binding);
		}

		public Type get_item_type()
		{
			return (typeof(BindingInformationInterface));
		}

		public uint get_n_items ()
		{
			return (length);
		}

		/**
		 * Number of bindings in contract
		 * 
		 * @since 0.1
		 */
		public uint length {
			get { 
				if (_items == null)
					return (0);
				return (_items.length); 
			}
		}

		private bool _suspended = false;
		/**
		 * Controls contract suspension state. When contract enters suspension
		 * all active bindings are removed and they are restored back when
		 * contract exits suspension state
		 * 
		 * @since 0.1
		 */
		public bool suspended {
			get { return (_suspended == true); }
			set {
				if (_suspended == value)
					return;
				_suspended = value;
				if (can_bind == true)
					bind_contract();
				else
					disolve_contract(true);
			}
		}

		/**
		 * Returns true if binding is possible, false if not
		 * 
		 * @since 0.1
		 */
		public bool can_bind {
			get { return ((_suspended == false) && (get_source() != null)); }
		}

		private bool _last_valid_state = false;
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
		 * Note that there is no way to check if whole source is valid or not by
		 * design. If that is needed then binding state objects should be used
		 * instead.
		 * 
		 * This is usefull to have static binding to button "Apply" or similar
		 * uses and removes all the need for validity check. If source is
		 * changed, bindings added/removed or data is edited then "is-valid" is
		 * recalculated
		 * 
		 * @since 0.1
		 */
		public bool is_valid {
			get { return (_last_valid_state); }
		}

		private BindingPointer? _default_target = null;
		/**
		 * Setting default target is mere convenience for handling other side
		 * when binding two object with multiple properties.
		 * 
		 * Internally it creates binding pointer and when properties are bound
		 * to it, they can be updated with same efficiency as when binding with
		 * normal BindingPointer while allowing to control target with single 
		 * point of action.
		 * 
		 * There is no limit on mixing default and non default properties.
		 * 
		 * This is automatically used when calling contract.bind_default()
		 * 
		 * @since 0.1
		 */
		public Object? default_target {
			get { return (_default_target.data); }
			set {
				if (_default_target == null)
					_default_target = new BindingPointer (null, reference_type);
				if (default_target == value)
					return;
				_default_target.data = value;
			}
		}

		private Binder? _binder = null;
		/**
		 * Binder object which is used to create property bindings. If binder
		 * is not specified then Binder.get_default() is used.
		 * 
		 * Note that contract does not cache this value and this is why it is 
		 * possible to control binder with Binder.set_default() even when it is
		 * not specified.
		 * 
		 * This allows easy tapping into binding internals
		 * 
		 * @since 0.1 
		 */
		public Binder? binder {
			owned get { 
				if (_binder == null)
					return (Binder.get_default());
				return (_binder); 
			}
			set { _binder = value; }
		}

		private void disconnect_lifetime()
		{
			if (data == null)
				return;
			if (is_binding_pointer(data) == true) {
				sub_source_changed(this);

				before_source_change.disconnect (master_before_sub_source_change);
				((BindingPointer) data).source_changed.connect (sub_source_changed);
				((BindingPointer) data).before_source_change.connect (before_sub_source_change);
			}
			handle_is_valid (null);
		}

		private void sub_source_changed (BindingPointer src)
		{
			bind_contract(false);
			handle_is_valid (null);
		}

		private void before_sub_source_change (BindingPointer src, bool same_type, Object? next_source)
		{
			disolve_contract (false);//next_source == null);
			handle_is_valid (null);
		}

		private void master_before_sub_source_change (BindingPointer src, bool same_type, Object? next_source)
		{
			if (data == null)
				return;
		}

		//TODO? Remove this????? It is supperset of already existing structure
		protected override void handle_weak_ref(Object obj)
		{
			disolve_contract(get_source() == null);
			base.handle_weak_ref (obj);
		}

		private void connect_lifetime()
		{
			if (data == null)
				return;

			// connect to lifetime if this is a case for source chaining 
			if (is_binding_pointer(data) == true) {
				sub_source_changed(this);

				before_source_change.connect (master_before_sub_source_change);
			}
			handle_is_valid (null);
		}

		private void disolve_contract (bool emit_contract_change)
		{
			bound = false;
			if (emit_contract_change == true)
				contract_changed (this);
		}

		private void bind_contract(bool emit_contract_change = true)
		{
			if (can_bind == false)
				return;
			if (bound == true)
				return;
			bound = true;
			if (emit_contract_change == true)
				contract_changed (this);
			handle_is_valid (null);
		}

		/**
		 * Resolves binding at specified index
		 * 
		 * @since 0.1
		 * @param index Index at which binding was requested
		 */
		public BindingInformationInterface? get_item_at_index (int index)
		{
			if ((index < 0) || (index >= length))
				return (null);
			return (_items.data[index].binding);
		}

		private void handle_is_valid (ParamSpec? parm)
		{
			bool validity = true;
			if (get_source() != null)
				for (int i=0; i<_items.data.length; i++) {
					if (_items.data[i].binding.is_valid == false) {
						validity = false;
						break;
					}
				}
			else
				validity = false;
			if (validity != _last_valid_state) {
				_last_valid_state = validity;
				notify_property ("is-valid");
			}
		}

		/**
		 * Adds group to contract
		 * 
		 * In case of specified overlapping bindings, they increase counter
		 * and these bindings are only removed once counter reaches 0. This 
		 * makes overlapping possible
		 * 
		 * @since 0.1
		 * @param group BindingGroup being added to contract
		 */
		public void bind_group (BindingGroup? group)
			requires (group != null)
		{
			for (int cnt = 0; cnt<group.length; cnt++)
				bind_information (group.get_item_at_index (cnt));
		}

		/**
		 * Removes group from contract
		 * 
		 * In case of specified overlapping bindings, they decrease counter
		 * and these bindings are only removed once counter reaches 0. This 
		 * makes overlapping possible
		 * 
		 * @since 0.1
		 * @param group BindingGroup being removed from contract
		 */
		public void unbind_group (BindingGroup? group)
			requires (group != null)
		{
			for (int cnt = 0; cnt<group.length; cnt++)
				unbind (group.get_item_at_index (cnt));
		}

		/**
		 * This method does nothing else but just injecting redirection for
		 * API chaining in objective oriented languages
		 * 
		 * @since 0.1
		 * 
		 * @param mapper Mapper object
		 */
		public ContractMapperInterface set_binding_mapper (ContractMapperInterface mapper)
		{
			return (mapper);
		}

		/**
		 * Binds specific BindingInformationInterface and activates it
		 * 
		 * @since 0.1
		 * @param information Binding information being added
		 * @return Reference to BindingInformationInterface
		 */
		public BindingInformationInterface? bind_information (BindingInformationInterface? information)
		{
			if (information == null)
				return (null);
			for (int cnt=0; cnt<_items.length; cnt++)
				if (_items.data[cnt].binding == information) {
					_items.data[cnt].lock();
					return (information);
				}
			
			_items.append_val (new BindingInformationReference (information));
			connect_notifications.connect (information.bind_connection);
			disconnect_notifications.connect (information.unbind_connection);
			information.notify["is-valid"].connect (handle_is_valid);
			items_changed (_items.length, 0, 1);
			bindings_changed (this, ContractChangeType.ADDED, information);
			return (information);
		}

		/**
		 * Invokes creation of BindingInformation for specified parameters.
		 * If contract is active and everything is in order this also creates
		 * BindingInterface and activates data transfer 
		 * 
		 * Main reasoning for this method is to allow chain API in objective 
		 * languages which makes code much simpler to follow 
		 * 
		 * NOTE!
		 * transform_from and transform_to can work in two ways. If value return
		 * is true, then newly converted value is assigned to property, if
		 * return is false, then that doesn't happen which can be used to assign
		 * property values directly and avoiding value conversion
		 *   
		 * @since 0.1
		 * @param source_property Source property name
		 * @param target Target object
		 * @param target_property Target property name
		 * @param flags Flags describing property binding creation
		 * @param transform_to Custom method to transform data from source value
		 *                     to target value
		 * @param transform_from Custom method to transform data from source 
		 *                       value to target value
		 * @param source_validation Specifies custom method to validate this
		 *                          particular property in source object. When
		 *                          this is not specified, validity is true
		 * @return Newly create BindingInformationInterface
		 */
		public BindingInformationInterface bind (string source_property, Object target, string target_property, BindFlags flags = BindFlags.DEFAULT, 
		                                         owned PropertyBindingTransformFunc? transform_to = null, owned PropertyBindingTransformFunc? transform_from = null,
		                                         owned SourceValidationFunc? source_validation = null)
			requires (source_property != "")
			requires (target_property != "")
		{
			return (bind_information (new BindingInformation (this, source_property, target, target_property, flags, (owned) transform_to, (owned) transform_from, (owned) source_validation)));
		}

		/**
		 * Invokes creation of BindingInformation for specified parameters with
		 * exception of using default_target as the target object.
		 * 
		 * If contract is active and everything is in order this also creates
		 * BindingInterface and activates data transfer 
		 * 
		 * Main reasoning for this method is to allow chain API in objective 
		 * languages which makes code much simpler to follow 
		 * 
		 * NOTE!
		 * transform_from and transform_to can work in two ways. If value return
		 * is true, then newly converted value is assigned to property, if
		 * return is false, then that doesn't happen which can be used to assign
		 * property values directly and avoiding value conversion
		 *   
		 * @since 0.1
		 * @param source_property Source property name
		 * @param target_property Target property name
		 * @param flags Flags describing property binding creation
		 * @param transform_to Custom method to transform data from source value
		 *                     to target value
		 * @param transform_from Custom method to transform data from source 
		 *                       value to target value
		 * @param source_validation Specifies custom method to validate this
		 *                          particular property in source object. When
		 *                          this is not specified, validity is true
		 * @return Newly create BindingInformationInterface
		 */
		public BindingInformationInterface bind_default (string source_property, string target_property, BindFlags flags = BindFlags.DEFAULT, 
		                                                 owned PropertyBindingTransformFunc? transform_to = null, owned PropertyBindingTransformFunc? transform_from = null,
		                                                 owned SourceValidationFunc? source_validation = null)
			requires (source_property != "")
			requires (target_property != "")
		{
			return (bind_information (new BindingInformation (this, source_property, _default_target, target_property, flags, (owned) transform_to, (owned) transform_from, (owned) source_validation)));
		}

		/**
		 * Removes binding from set of its bindings
		 * 
		 * @since 0.1
		 * @param information Binding information being removed
		 * @param all_references Ignore internal lock count and remove if true
		 */
		public void unbind (BindingInformationInterface information, bool all_references = false)
		{
			for (int i=0; i<length; i++) {
				if (_items.data[i].binding == information) {
					if (all_references == false) {
						if (_items.data[i].lock_count > 1)
							_items.data[i].unlock();
					}
					else
						_items.data[i].full_unlock();
					connect_notifications.disconnect (information.bind_connection);
					disconnect_notifications.disconnect (information.unbind_connection);
					information.notify["is-valid"].disconnect (handle_is_valid);
					information.unbind_connection (get_source());
					_items.remove_index (i);
					bindings_changed (this, ContractChangeType.REMOVED, information);
					items_changed (i, 1, 0);
					break;
				}
			}
		}

		/**
		 * Unbinds all added bindings
		 * 
		 * @since 0.1
		 */
		public void unbind_all()
		{
			while (length > 0)
				unbind(get_item_at_index((int)length-1));
		}

		/**
		 * Singnal sent when contract is renewed/disolved or when source changes
		 * 
		 * @since 0.1
		 * @param contract Contract that changed
		 */
		public signal void contract_changed (BindingContract contract);

		/**
		 * Singnal sent when bindings in contract change
		 * 
		 * @since 0.1
		 * @param contract Contract that changed bindings
		 * @param change_type Specifies if binding was ADDED or REMOVED
		 * @param binding Binding that is subject of this signal
		 */
		public signal void bindings_changed (BindingContract contract, ContractChangeType change_type, BindingInformationInterface binding);

		/**
		 * Handles contract disconnection on object reference being destroyed
		 * 
		 * @since 0.1
		 */
		protected virtual void disconnect_contract()
		{
			if (finalizing_in_progress == true)
				return;
			finalizing_in_progress = true;
			clean_state_objects();
			clean_source_values();
			unbind_all();
			data = null;
		}

		~BindingContract()
		{
			if (finalizing_in_progress == true)
				return;
			disconnect_contract();
		}

		/**
		 * Creates new BindingContract and adds it to specified ContractStorage
		 * 
		 * @since 0.1
		 * @param contract_storage Storage where contract should be stored into
		 * @param name Name under which contract is added to ContractStorage
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
		public BindingContract.add_to_storage (ContractStorage contract_storage, string name, Object? data = null, BindingReferenceType reference_type = BindingReferenceType.WEAK, BindingPointerUpdateType update_type = BindingPointerUpdateType.PROPERTY)
		{
			this (data, reference_type, update_type);
			contract_storage.add (name, this);
		}

		/**
		 * Creates new BindingContract and adds it to 
		 * ContractStorage.get_default()
		 * 
		 * @since 0.1
		 * @param name Name under which contract is added to ContractStorage
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
		public BindingContract.add_to_default_storage (string name, Object? data = null, BindingReferenceType reference_type = BindingReferenceType.WEAK, BindingPointerUpdateType update_type = BindingPointerUpdateType.PROPERTY)
		{
			this.add_to_storage (ContractStorage.get_default(), name, data, reference_type, update_type);
		}

		/**
		 * Creates new BindingContract
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
		public BindingContract (Object? data = null, BindingReferenceType reference_type = BindingReferenceType.WEAK, BindingPointerUpdateType update_type = BindingPointerUpdateType.PROPERTY)
		{
			base (null, reference_type, update_type);
			before_source_change.connect((binding, is_same, next) => {
				if (get_source() != null) {
					disolve_contract (true);//next == null);
					disconnect_lifetime();
				}
			});
			contract_changed.connect ((src) => { 
				if (last_source.target == src.get_source())
					return;
				last_source = new WeakReference<Object?>(src.get_source());
			});
			source_changed.connect ((binding) => {
				if (get_source() != null) {
					connect_lifetime();
					bind_contract();
				}
			});
			this.data = data;
			// no binding here yet, so nothing else is required
		}
	}
}
