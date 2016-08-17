namespace GData
{
	/**
	 * BindingInformation holds information about binding as well as controls
	 * its creation and unbinding.
	 * 
	 * Unlike PropertyBinding BindingInformation is alive even when binding
	 * is not possible and has no cached property type in order to allow
	 * flexible binding with different object types.
	 * 
	 * @since 0.1
	 */
	public class BindingInformation : Object, BindingInformationInterface
	{
		private bool is_enabled = false;
	
		private StrictWeakReference<BindingInterface?>? _binding = null;
		public BindingInterface? binding {
			get { return (_binding.target); }
		}

		/**
		 * Returns true if binding is currently active for data transfer
		 * 
		 * @since 0.1
		 */
		public bool activated { 
			get { return (binding != null); } 
		}

		private StrictWeakReference<BindingContract?> _contract;
		/**
		 * Contract BindingInformation belongs to
		 * 
		 * @since 0.1
		 */
		public BindingContract? contract {
			get { return (_contract.target); }
		}

		/**
		 * Returns possibility of binding
		 * 
		 * @since 0.1
		 */
		public bool can_bind {
			get { return (!((_contract.is_valid_ref() == false) || (contract.can_bind == false) || (_target.is_valid_ref() == false))); }
		}

		private bool? last_valid_state = null;
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
		 * Note that contract value of "is-valid" will be cumulative of all
		 * conditions on all properties
		 * 
		 * @since 0.1
		 */
		public bool is_valid {
			get {
				if (last_valid_state == null)
					check_validity();
				return (last_valid_state);
			}
		}

		private string _source_property = "";
		/**
		 * Source property name
		 * 
		 * @since 0.1
		 */
		public string source_property {
			get { return (_source_property); }
		}

		private StrictWeakReference<Object?> _target;
		/**
		 * Target object
		 * 
		 * Note that there is no definition of source object in 
		 * BindingInformation as that value is taken from "contract"
		 * 
		 * @since 0.1
		 */
		public Object? target {
			get { return (_target.target); }
		}

		private string _target_property = "";
		/**
		 * Target property name
		 *
		 * @since 0.1
		 */
		public string target_property {
			get { return (_target_property); }
		}

		private BindFlags _flags = BindFlags.DEFAULT;
		/**
		 * Binding flags specifiying how BindingInterface should be created
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

		private SourceValidationFunc? _source_validation = null;
		/**
		 * Source property validation method
		 * 
		 * @since 0.1
		 */ 
		public SourceValidationFunc? source_validation {
			get { return (_source_validation); }
		}

		/**
		 * Removes it self from contract
		 * 
		 * @since 0.1
		 */
		public void remove()
		{
			if (contract != null)
				contract.unbind (this);
		}

		private void handle_binding_dropped()
		{
			if (is_enabled == false)
				return;
			is_enabled = false;
			contract.bindings_changed (contract, ContractChangeType.STATE_CHANGED, this);
			notify_property("activated");
		}

		private void check_validity()
		{
			bool validity = true;
			if (can_bind == true) {
				GLib.Value val = GLib.Value(typeof(string));
				contract.get_source().get_property (source_property, ref val);
				if (check_if_valid_source_data(val) == false)
					validity = false;
			}
			else
				validity = false;
			if (last_valid_state != validity) {
				last_valid_state = validity;
				if (contract != null)
					notify_property ("is-valid");
			}
		}

		private bool check_if_valid_source_data (Value? data)
		{
			if (binding == null)
				return (false);
			if (can_bind == false)
				return (false);
			if (_source_validation == null)
				return (true);
			return (source_validation (data));
		}

		private void check_source_property_validity (GLib.ParamSpec parm)
		{
			check_validity();
		}

		private void handle_before_target_source_change (BindingPointer target, bool is_same_type, Object? next_target)
		{
//			unbind_connection();
		}

		private void handle_target_source_changed (BindingPointer target)
		{
//			bind_connection();
		}

		/**
		 * Activates binding if possible. This executes contract.binder.bind()
		 * method in order to generate BindingInterface
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object being connected and can be used to check sanity.
		 *            This is obtained as part of notifications during "data"
		 *            changes
		 */
		public void bind_connection (Object? obj)
		{
			Object? tgt = target;
			if (is_binding_pointer(tgt) == true)
				tgt = ((BindingPointer) tgt).get_source();
			if (can_bind == false)
				return;
			if (binding != null) {
				GLib.critical ("Binding %s→%s was not undone! INVESTIGATE", source_property, target_property);
				unbind_connection(obj);
			}
			if (tgt == null)
				return;
			// Check for property existance in both source and target 
			if (((ObjectClass) tgt.get_type().class_ref()).find_property(target_property) == null)
				if (PropertyAlias.get_instance(target_property).get_for(tgt.get_type()) == null)
					return;
			if (((ObjectClass) contract.get_source().get_type().class_ref()).find_property(source_property) == null)
				if (PropertyAlias.get_instance(source_property).get_for(contract.get_source().get_type()) == null)
					return;
			_binding.set_new_target (contract.binder.bind (contract.get_source(), source_property, tgt, target_property, flags, (owned) _transform_to, (owned) _transform_from));
			check_validity();
			if (_contract.is_valid_ref() == true)
				contract.get_source().notify[source_property].connect (check_source_property_validity);
			if (is_enabled == true)
				return;
			is_enabled = true;
			if ((_binding.is_valid_ref() == true) && (_contract.is_valid_ref() == true))
				contract.bindings_changed (contract, ContractChangeType.STATE_CHANGED, this);
			notify_property("activated");
		}

		/**
		 * Unbinds active connection between properties
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object being connected and can be used to check sanity.
		 *            This is obtained as part of notifications during "data"
		 *            changes
		 */
		public void unbind_connection (Object? obj)
		{
			if (_contract.is_valid_ref() == true)
				if (contract.get_source() != null)
					contract.get_source().notify[source_property].disconnect (check_source_property_validity);
			if (_binding.is_valid_ref() == true) {
				binding.unbind();
				_binding.set_new_target(null);
			}
			if (is_enabled == false)
				return;
			is_enabled = false;
			if (_contract.is_valid_ref() == true)
				contract.bindings_changed (contract, ContractChangeType.STATE_CHANGED, this);
			notify_property("activated");
		}

		~BindingInformation()
		{
			if (is_binding_pointer(target) == true) {
				((BindingPointer) target).before_source_change.disconnect (handle_before_target_source_change);
				((BindingPointer) target).source_changed.disconnect (handle_target_source_changed);
			}
			_target = null;
		}
		
		internal BindingInformation (BindingContract owner_contract, string source_property, Object target, string target_property, 
		                             BindFlags flags = BindFlags.DEFAULT, owned PropertyBindingTransformFunc? transform_to = null, 
		                             owned PropertyBindingTransformFunc? transform_from = null, owned SourceValidationFunc? source_validation = null)
		{
			_binding = new StrictWeakReference<BindingInterface?>(null, handle_binding_dropped);
			_contract = new StrictWeakReference<BindingContract?>(owner_contract);
			_source_property = source_property;
			_target = new StrictWeakReference<Object?>(target);
			_target_property = target_property;
			_flags = flags;
			_transform_to = (owned) transform_to;
			_transform_from = (owned) transform_from;
			_source_validation = (owned) source_validation;
			if (is_binding_pointer(target) == true) {
				((BindingPointer) target).before_source_change.connect (handle_before_target_source_change);
				((BindingPointer) target).source_changed.connect (handle_target_source_changed);
			}
			bind_connection (owner_contract.get_source());
		}
	}
}
