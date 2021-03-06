namespace GData
{
	/**
	 * Binder class is multipurpose class that can be used for different reasons
	 * - Controlling property binding creation for either debugging purposes or
	 * simply because there is a need for different binding than the one 
	 * provided by PropertyBinding
	 * - It can be interchangeable and specified per contract
	 * 
	 * In most all cases Binder is probably not needed. BindingContract uses it
	 * internally and by default BindingContract uses get_default() unless 
	 * specified otherwise. If application never changes that kind of behaviour
	 * then tapping into events is trivial as all that application needs is 
	 * calling set_default(my_binder) that was created with handling that was 
	 * needed.
	 * 
	 * The only reason where more than one Binder is needed is when application
	 * requires fine grained tapping into events in only selected group of
	 * contracts
	 * 
	 * @since 0.1
	 */
	public class Binder : Object, HasDescription
	{
		private static Binder _default_silent_binder = null;
		private static Binder __default_binder = null;
		private static Binder _default_binder = null;

		private static BindingInterface? default_create (Object? source, string source_property, Object? target, string target_property,
		                                                 BindFlags flags, owned PropertyBindingTransformFunc? transform_to = null, 
		                                                 owned PropertyBindingTransformFunc? transform_from = null)
		{
			return ((BindingInterface?) PropertyBinding.bind (source, source_property, target, target_property, flags, (owned) transform_to, (owned) transform_from));
		}

		/**
		 * Creates or resolves basic silent binder that can be used for internal
		 * purposes
		 * 
		 * Note that this is by default used in BindingContract to resolve their
		 * binder property value unless specified otherwise
		 * 
		 * @since 0.1
		 * 
		 * @return Current default binder
		 */
		public static Binder get_default_silent()
		{
			if (_default_silent_binder == null)
				_default_silent_binder = new Binder.silent();
			return (_default_silent_binder);
		}

		/**
		 * Creates or resolves current default binder which is created in most 
		 * basic behaviour.
		 * 
		 * Note that this is by default used in BindingContract to resolve their
		 * binder property value unless specified otherwise
		 * 
		 * @since 0.1
		 * 
		 * @return Current default binder
		 */
		public static Binder get_default()
		{
			if (_default_binder == null) {
				if (__default_binder == null)
					__default_binder = new Binder().set_description(__DEFAULT__);
				_default_binder = __default_binder;
			}
			return (_default_binder);
		}

		/**
		 * Sets specified Binder as default Binder. This also changes it for all
		 * contracts that don't specify their own as their default behaviour is
		 * using Binder resolved by get_default() and that value is not cached
		 * on contract
		 * 
		 * Use this to either employ debugging per need or when custom Binder 
		 * is really needed
		 * 
		 * @since 0.1
		 * 
		 * @param binder Binder which is set default. If specified value is null
		 *               then new default binder is created as most basic Binder
		 *               possible
		 */
		public static void set_default (Binder? binder)
		{
			if (_default_binder == binder)
				return;
			_default_binder = (binder == null) ? new Binder() : binder;
		}

		private CreatePropertyBinding? _binding_create = null;

		/**
		 * Invokes binding creation as specified when Binder was created. 
		 * Default method used is wrapping PropertyBinding.bind(...), but if
		 * binder specifies its own method, then that one is created
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

		private string _description = "";
		/**
		 * Specifies binder description
		 * 
		 * @since 0.1
		 */
		[Description (name="Object description")]
		public string description {
			owned get { return (_description); }
		}

		/**
		 * Sets description string for Binder and returns Binder reference
		 * for convenience of method chaingin in objective oriented languages
		 * 
		 * @since 0.1
		 * 
		 * @param new_description Description text
		 * @return Reference to binder object
		 */
		public Binder set_description (string new_description)
		{
			if (new_description == _description)
				return (this);
			new_description = _description;
			notify_property ("description");
			return (this);
		}

		/**
		 * Specifies if bindings created by binder object should be published
		 * to binding namespace or not
		 * 
		 * @since 0.1
		 */
		[Description (name="Is silent")]
		public bool is_silent { get; private set; default = false; }

		/**
		 * Allows mapping to be redirected to specialized mappers which are more
		 * familiar with particular objects and know more about structure which
		 * allows things like group mapping
		 * 
		 * @since 0.1
		 * 
		 * @param mapper Binding mapper object
		 * @return Specified mapper object to enable api chaining in objective
		 *         oriented languages
		 */
		public BinderMapper set_mapper (BinderMapper mapper)
		{
			mapper.binder_object = this;
			return (mapper);
		}

		/**
		 * Signal emited upon successful call to Binder.bind(...)
		 * 
		 * Allows debug tapping in bindings to debug when binding goes up/down
		 * or even more if custom BindingInterface was created
		 * 
		 * Spplication should tap into BindingInterface.dropped or it can
		 * wrap its own variation of Binder BindingInterface creation
		 * 
		 * @since 0.1
		 * @param binding Newly created BindingInterface
		 */
		public signal void binding_created (BindingInterface? binding);
		/**
		 * Creates new instance of Binder class
		 * 
		 * @since 0.1
		 * 
		 * @param binding_create Method supplied by CreatePropertyBinding is 
		 *                       expected to do all safety checks. Binder does 
		 *                       absolutely nothing to guarantee safety.
		 *                       If supplied method is null, then 
		 *                       BindingInterface creation will be relayed to 
		 *                       PropertyBinding.bind
		 */
		private Binder.full (owned CreatePropertyBinding? binding_create = null, bool silent_binding)
		{
			is_silent = silent_binding;
			_binding_create = (owned) binding_create;
			if (is_silent == false)
				BindingNamespace.get_instance().register_binder (this);
		}

		/**
		 * Creates new instance of Binder class
		 * 
		 * @since 0.1
		 * 
		 * @param binding_create Method supplied by CreatePropertyBinding is 
		 *                       expected to do all safety checks. Binder does 
		 *                       absolutely nothing to guarantee safety.
		 *                       If supplied method is null, then 
		 *                       BindingInterface creation will be relayed to 
		 *                       PropertyBinding.bind
		 */
		public Binder.silent (owned CreatePropertyBinding? binding_create = null)
		{
			this.full ((owned) binding_create, true);
		}

		/**
		 * Creates new instance of Binder class
		 * 
		 * @since 0.1
		 * 
		 * @param binding_create Method supplied by CreatePropertyBinding is 
		 *                       expected to do all safety checks. Binder does 
		 *                       absolutely nothing to guarantee safety.
		 *                       If supplied method is null, then 
		 *                       BindingInterface creation will be relayed to 
		 *                       PropertyBinding.bind
		 */
		public Binder (owned CreatePropertyBinding? binding_create = null)
		{
			this.full ((owned) binding_create, false);
		}
	}
}
