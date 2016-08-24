namespace GData
{
	/**
	 * Creates introspection binding transfer interface. If registration does
	 * not specify this, then type is treated as DYNAMIC
	 * 
	 * @since 0.1
	 * 
	 * @param data_type Object type that needs to be introspected
	 * @param property_name Property name
	 * @return Introspectable information that cannot be used for later binding
	 */
	public delegate BindingDataTransferInterface? CreateIntrospectionDataTransferFunc (Type data_type, string property_name);

	/**
	 * Enables classes to specify its own way of property resolving and 
	 * signaling
	 * 
	 * @since 0.1
	 */
	public class BindingDefaults
	{
		private GLib.Array<CustomBindingDefaults> _register = new GLib.Array<CustomBindingDefaults>();

		private static BindingDefaults? _instance = null;

		/**
		 * Returns singleton instance of BindingDefaults
		 * 
		 * @since 0.1
		 */
		public static BindingDefaults get_instance()
		{
			if (_instance == null) {
				_instance = new BindingDefaults();
				// register GObject asap, since it specifies introspection, it
				// will be registered as STATIC
				_instance.register (typeof(Object),
					(o, p) => {
						return (new GObjectBindingDataTransfer (o, p));
					},
					(t, p) => {
						return (new GObjectBindingDataTransfer.introspection_only (t, p));
					});
				// register GSettings asap, since it specifies introspection, it
				// will be registered as DYNAMIC
				_instance.register (typeof(GLib.Settings), 
					(o, p) => {
						return (new GSettingsBindingDataTransfer (o, p));
					}, null);
			}
			return (_instance);
		}

		internal class CustomBindingDefaults
		{
			public InformationAvailability information_availability { get; private set; }
			public Type class_type { get; private set; }
			public CreateDataTransferFunc creation_method { get; private set; }
			public CreateIntrospectionDataTransferFunc? introspection_method { get; private set; }
			public Type original_type { get; private set; }

			public BindingDataTransfer create (Object? obj, string property_name)
			{
				return (creation_method (obj, property_name));
			}

			public CustomBindingDefaults (Type class_type, CreateDataTransferFunc creation_method, 
			                              CreateIntrospectionDataTransferFunc? introspection_method, 
			                              Type original_type=GLib.Type.INVALID)
			{
				this.information_availability = (introspection_method == null) ? InformationAvailability.DYNAMIC : InformationAvailability.STATIC;
				this.class_type = class_type;
				this.creation_method = creation_method;
				this.introspection_method = introspection_method;
				if (original_type == Type.INVALID)
					this.original_type = class_type;
				else
					this.original_type = original_type;
			}
		}

		/**
		 * Registration of custom data transfer method that can be used to 
		 * define classes with special properties or classes that are not 
		 * derived from GObject
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object containing property and whose type will be used for
		 *            discovery
		 * @param property_name Property name
		 * @param original_type When binding is specified with 
		 *                      SOURCE_USE_ORIGINAL or TARGET_USE_ORIGINAL
		 *                      then data transfer object is resolved for
		 *                      original_type instead of type. This makes it 
		 *                      usefull to be able to bind both types: original
		 *                      properties in specified object as well as
		 *                      custom ones. Example of this is GLib.Settings
		 *                      whose properties are most probably key-value
		 *                      instead of its properties, but in case when
		 *                      access to objects real properties is needed
		 *                      binding to original_type can be used
		 */
		public void register (Type class_type, 
		                      CreateDataTransferFunc creation_method, CreateIntrospectionDataTransferFunc? introspection_method, 
		                      Type original_type=GLib.Type.INVALID)
		{
			if (class_type == GLib.Type.INVALID)
				return;
			if (class_type.is_interface() == true) {
				GLib.warning ("BindingDefaults.register (%s) type is interface, which is not supported. Ignored!", class_type.name());
				return;
			}
			for (int i=0; i<_register.length; i++)
				if (class_type == _register.data[i].class_type) {
					GLib.warning ("BindingDefaults.register (%s) type is already registered. Ignored!", class_type.name());
					return;
				}
			_register.append_val (new CustomBindingDefaults (class_type, creation_method, introspection_method, original_type));
		}

		/**
		 * Resolves data transfer and signal control object for specified
		 * objects type or its original_type if use_original_type is specified
		 * 
		 * If type is not found then it returns closest possible match
		 * 
		 * @since 0.1
		 * 
		 * @param type Object type this registration is for
		 * @param creation_method BindingDataTransfer object creation method
		 *                        for specified type
		 * @param use_original_type Forces use of original type in discovery.
		 *                          When binding is specified with 
		 *                          SOURCE_USE_ORIGINAL or TARGET_USE_ORIGINAL
		 *                          then data transfer object is resolved for
		 *                          original_type instead of type. This makes it 
		 *                          usefull to be able to bind both types: 
		 *                          original properties in specified object as 
		 *                          well as custom ones. Example of this is 
		 *                          GLib.Settings whose properties are most 
		 *                          probably key-value instead of its properties, 
		 *                          but in case when access to objects real 
		 *                          properties is needed binding to 
		 *                          original_type can be used
		 */
		public BindingDataTransfer? get_transfer_object_for (Object? obj, string property_name, bool use_original_type)
		{
			if (obj == null)
				return (null);
			return (_get_transfer_object_for (obj, obj.get_type(), property_name, use_original_type));
		}

		private BindingDataTransfer? _get_transfer_object_for (Object? obj, Type class_type, string property_name, bool use_original_type)
		{
			CustomBindingDefaults? resolved = _get_defaults_object_for (class_type, use_original_type);
			return ((resolved != null) ? resolved.creation_method (obj, property_name) : null);
		}

		/**
		 * Resolves data transfer and signal control object for specified
		 * objects type or its original_type if use_original_type is specified
		 * 
		 * If type is not found then it returns closest possible match
		 * 
		 * @since 0.1
		 * 
		 * @param type Object type this registration is for
		 * @param creation_method BindingDataTransfer object creation method
		 *                        for specified type
		 * @param use_original_type Forces use of original type in discovery.
		 *                          When binding is specified with 
		 *                          SOURCE_USE_ORIGINAL or TARGET_USE_ORIGINAL
		 *                          then data transfer object is resolved for
		 *                          original_type instead of type. This makes it 
		 *                          usefull to be able to bind both types: 
		 *                          original properties in specified object as 
		 *                          well as custom ones. Example of this is 
		 *                          GLib.Settings whose properties are most 
		 *                          probably key-value instead of its properties, 
		 *                          but in case when access to objects real 
		 *                          properties is needed binding to 
		 *                          original_type can be used
		 */
		public BindingDataTransferInterface? get_introspection_object_for (Type? class_type, string property_name, bool use_original_type)
		{
			return (_get_introspection_object_for (class_type, property_name, use_original_type));
		}

		private BindingDataTransferInterface? _get_introspection_object_for (Type class_type, string property_name, bool use_original_type)
		{
			CustomBindingDefaults? resolved = _get_defaults_object_for (class_type, use_original_type);
			if ((resolved == null) || (resolved.information_availability == InformationAvailability.DYNAMIC))
				return (null);
			return (resolved.introspection_method (class_type, property_name));
		}

		public InformationAvailability get_transfer_information_type_for (Type class_type, bool use_original_type)
		{
			CustomBindingDefaults? res = _get_defaults_object_for (class_type, use_original_type);
			return ((res == null) ? InformationAvailability.UNAVAILABLE : res.information_availability);
		}

		private CustomBindingDefaults? _get_defaults_object_for (Type class_type, bool use_original_type)
		{
			CustomBindingDefaults? resolved = null;
			int gap = int.MAX;
			for (int i=0; i<_register.length; i++)
				if (class_type == _register.data[i].class_type) {
					if ((use_original_type == true) && (_register.data[i].class_type != _register.data[i].original_type))
						return (_get_defaults_object_for(_register.data[i].original_type, false));
					else
						return (_register.data[i]);
				}
				else {
					int tgap = get_hierarchy_gap(class_type, _register.data[i].class_type);
					if (tgap < gap) {
						resolved = _register.data[i];
						gap = tgap;
					}
				}
			if (resolved != null)
				if ((use_original_type == true) && (resolved.class_type != resolved.original_type))
					return (_get_defaults_object_for(resolved.original_type, false));
				else
					return (resolved);
			return (null);
		}

		private BindingDefaults()
		{
		}
	}
}

