namespace G
{
	public class BindingContract : BindingPointer, IBindingStateObjects, IBindingValueObjects
	{
		private bool finalizing_in_progress = false;

		private GLib.Array<BindingInformationReference> _items = new GLib.Array<BindingInformationReference>();
		private WeakReference<Object?> last_source = new WeakReference<Object?>(null);

		public uint length {
			get { 
				if (_items == null)
					return (0);
				return (_items.length); 
			}
		}

		private bool _suspended = false;
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

		public bool can_bind {
			get { return ((_suspended == false) && (get_source() != null)); }
		}

		private bool _last_valid_state = false;
		public bool is_valid {
			get { return (_last_valid_state); }
		}

		private BindingPointer? _default_target = null;
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
		public Binder? binder {
			owned get { 
				if (_binder == null)
					return (Binder.get_default());
				return (_binder); 
			}
			set { binder = value; }
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
			// no check here as it needs to be avoided in upper levels or before call
			for (int i=0; i<_items.data.length; i++)
				_items.data[i].binding.unbind_connection();
			if (emit_contract_change == true)
				contract_changed (this);
		}

		private void bind_contract(bool emit_contract_change = true)
		{
			if (can_bind == false)
				return;
			for (int i=0; i<_items.length; i++)
				_items.data[i].binding.bind_connection();
			if (emit_contract_change == true)
				contract_changed (this);
			handle_is_valid (null);
		}

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

		public void bind_group (BindingGroup? group)
			requires (group != null)
		{
			for (int cnt = 0; cnt<group.length; cnt++)
				bind_information (group.get_item_at (cnt));
		}

		public void unbind_group (BindingGroup? group)
			requires (group != null)
		{
			for (int cnt = 0; cnt<group.length; cnt++)
				unbind (group.get_item_at (cnt));
		}

		public BindingInformationInterface? bind_information (BindingInformationInterface? info)
		{
			if (info == null)
				return (null);
			for (int cnt=0; cnt<_items.length; cnt++)
				if (_items.data[cnt].binding == info) {
					_items.data[cnt].lock();
					return (info);
				}
			_items.append_val (new BindingInformationReference (info));
			info.notify["is-valid"].connect (handle_is_valid);
			return (info);
		}

		public BindingInformation bind (string source_property, Object target, string target_property, BindFlags flags = BindFlags.DEFAULT, 
		                                owned PropertyBindingTransformFunc? transform_to = null, owned PropertyBindingTransformFunc? transform_from = null,
		                                owned SourceValidationFunc? source_validation = null)
			requires (source_property != "")
			requires (target_property != "")
		{
			return ((BindingInformation) bind_information (new BindingInformation (this, source_property, target, target_property, flags, (owned) transform_to, (owned) transform_from, (owned) source_validation)));
		}

		public BindingInformation bind_default (string source_property, string target_property, BindFlags flags = BindFlags.DEFAULT, 
		                                        owned PropertyBindingTransformFunc? transform_to = null, owned PropertyBindingTransformFunc? transform_from = null,
		                                        owned SourceValidationFunc? source_validation = null)
			requires (source_property != "")
			requires (target_property != "")
		{
			return ((BindingInformation) bind_information (new BindingInformation (this, source_property, _default_target, target_property, flags, (owned) transform_to, (owned) transform_from, (owned) source_validation)));
		}

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
					information.notify["is-valid"].disconnect (handle_is_valid);
					information.unbind_connection();
//					_items.data[i].reset();
					_items.remove_index (i);
					break;
				}
			}
		}

		public void unbind_all()
		{
			while (length > 0)
				unbind(get_item_at_index((int)length-1));
		}

		public signal void contract_changed (BindingContract contract);

		public signal void bindings_changed (BindingContract contract, ContractChangeType change_type, BindingInformation binding);

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

		public BindingContract.add_to_manager (ContractStorage contract_manager, string name, Object? data = null, BindingReferenceType reference_type = BindingReferenceType.WEAK, BindingPointerUpdateType update_type = BindingPointerUpdateType.PROPERTY)
		{
			this (data, reference_type, update_type);
			contract_manager.add (name, this);
		}

		public BindingContract.add_to_default_manager (string name, Object? data = null, BindingReferenceType reference_type = BindingReferenceType.WEAK, BindingPointerUpdateType update_type = BindingPointerUpdateType.PROPERTY)
		{
			this.add_to_manager (ContractStorage.get_default(), name, data, reference_type, update_type);
		}

		public BindingContract (Object? data = null, BindingReferenceType reference_type = BindingReferenceType.WEAK, BindingPointerUpdateType update_type = BindingPointerUpdateType.PROPERTY)
		{
			base (null, reference_type, update_type);
			before_source_change.connect((binding, is_same, next) => {
				if (get_source() != null) {
					disolve_contract (next == null);
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
