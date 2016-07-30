namespace G
{
	public class Binder
	{
		private static Binder _default_binder = null;

		private static BindingInterface? default_create (Object? source, string source_property, Object? target, string target_property,
		                                                 BindFlags flags, owned PropertyBindingTransformFunc? transform_to = null, 
		                                                 owned PropertyBindingTransformFunc? transform_from = null)
		{
			return ((BindingInterface?) PropertyBinding.bind (source, source_property, target, target_property, flags, (owned) transform_to, (owned) transform_from));
		}

		public static Binder get_default()
		{
			if (_default_binder == null)
				_default_binder = new Binder();
			return (_default_binder);
		}

		// use this to either employ debugging per need or
		// when custom Binder is really needed
		public static void set_default (Binder? binder)
		{
			if (_default_binder == binder)
				return;
			_default_binder = (binder == null) ? new Binder() : binder;
		}

		private CreatePropertyBinding? _binding_create = null;

		public BindingInterface? bind (Object? source, string source_property, Object? target, string target_property,
		                               BindFlags flags, owned PropertyBindingTransformFunc? transform_to = null, 
		                               owned PropertyBindingTransformFunc? transform_from = null)
		{
			BindingInterface? binding = null;
			if (_binding_create != null)
				binding = _binding_create (source, source_property, target, target_property, flags,
				                           (owned) transform_to, (owned) transform_from);
			else
				binding = default_create (source, source_property, target, target_property, flags,
				                          (owned) transform_to, (owned) transform_from);

			if (binding != null)
				binding_created (binding);
			return (binding);
		}

		// allows debug tapping in bindings. to debug when binding goes down
		// application should tap into BindingInterface.dropped or it can
		// wrap its own variation of Binder BindingInterface creation
		public signal void binding_created (BindingInterface binding);

		// method supplied by CreatePropertyBinding is expected to do all safety checks.
		// Binder does absolutely nothing to provide safety
		//
		// if supplied method is null, then it will be relayed to PropertyBinding.bind
		public Binder (owned CreatePropertyBinding? binding_create = null)
		{
			_binding_create = (owned) binding_create;
		}
	}
}
