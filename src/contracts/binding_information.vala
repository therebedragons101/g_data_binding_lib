namespace G
{
	public class BindingInformation : Object, BindingInformationInterface
	{
		private BindingInterface? binding = null;

		private WeakReference<BindingContract?> _contract;
		public BindingContract? contract {
			get { return (_contract.target); }
		}

		public bool can_bind {
			get { return (!((contract == null) || (contract.can_bind == false) || (target == null))); }
		}

		private bool? last_valid_state = null;
		public bool is_valid {
			get {
				if (last_valid_state == null)
					check_validity();
				return (last_valid_state);
			}
		}

		private string _source_property = "";
		public string source_property {
			get { return (_source_property); }
		}

		private WeakReference<Object?> _target;
		public Object? target {
			get { return (_target.target); }
		}

		private string _target_property = "";
		public string target_property {
			get { return (_target_property); }
		}

		private BindFlags _flags = BindFlags.DEFAULT;
		public BindFlags flags {
			get { return (_flags); }
		}

		private PropertyBindingTransformFunc? _transform_to = null;
		public PropertyBindingTransformFunc? transform_to {
			get { return (_transform_to); }
		}

		private PropertyBindingTransformFunc? _transform_from = null;
		public PropertyBindingTransformFunc? transform_from {
			get { return (_transform_from); }
		}

		private SourceValidationFunc? _source_validation = null;
		public SourceValidationFunc? source_validation {
			get { return (_source_validation); }
		}

		public void remove()
		{
			if (contract != null)
				contract.unbind (this);
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
			unbind_connection();
		}

		private void handle_target_source_changed (BindingPointer target)
		{
			bind_connection();
		}

		public void bind_connection()
		{
			Object? tgt = target;
			if (is_binding_pointer(tgt) == true)
				tgt = ((BindingPointer) tgt).get_source();
			if (can_bind == false)
				return;
			if (binding != null)
				unbind_connection();
			if (tgt == null)
				return;
			// Check for property existance in both source and target 
			if (((ObjectClass) tgt.get_type().class_ref()).find_property(target_property) == null)
				if (PropertyAlias.get_instance(target_property).get_for(tgt.get_type()) == null)
					return;
			if (((ObjectClass) contract.get_source().get_type().class_ref()).find_property(source_property) == null)
				if (PropertyAlias.get_instance(source_property).get_for(contract.get_source().get_type()) == null)
					return;
			binding = contract.binder.bind (contract.get_source(), source_property, tgt, target_property, flags, (owned) _transform_to, (owned) _transform_from);
			check_validity();
			contract.get_source().notify[source_property].connect (check_source_property_validity);
		}

		public void unbind_connection()
		{
			if (contract.get_source() != null)
				contract.get_source().notify[source_property].disconnect (check_source_property_validity);
			if (binding != null)
				binding.unbind();
			binding = null;
		}

		// purpose of this is to have nice chaining API as keeping BindingInformation is not always necessary
		// note that this should only be called when you handle contract as whole and drop all bindings
		// whenever source changes
		// case and point example of that to happen is when source can be different types of data and you 
		// need to adapt editor in full   
		public BindingInformation bind (string source_property, Object target, string target_property, BindFlags flags = BindFlags.DEFAULT, 
		                                owned PropertyBindingTransformFunc? transform_to = null, owned PropertyBindingTransformFunc? transform_from = null, 
		                                owned SourceValidationFunc? source_validation = null)
		{
			return (contract.bind (source_property, target, target_property, flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
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
			_contract = new WeakReference<BindingContract?>(owner_contract);
			_source_property = source_property;
			_target = new WeakReference<Object?>(target);
			_target_property = target_property;
			_flags = flags;
			_transform_to = (owned) transform_to;
			_transform_from = (owned) transform_from;
			_source_validation = (owned) source_validation;
			if (is_binding_pointer(target) == true) {
				((BindingPointer) target).before_source_change.connect (handle_before_target_source_change);
				((BindingPointer) target).source_changed.connect (handle_target_source_changed);
			}
			bind_connection();
		}
	}
}
