namespace GDataGtk
{
	/**
	 * Provides automatic widget creation for either registration or caching
	 * purposes. For caching, correct description can be resolved at any time
	 * trough DefaultWidgets
	 * 
	 * @since 0.1
	 */
	public class CustomCreationDescription : Object
	{
		/**
		 * Mode this registration is for
		 * 
		 * @since 0.1
		 */
		public EditMode mode { get; set; default = EditMode.VIEW; }
		/**
		 * TODO, Replace this with introspection transfer object
		 * 
		 * @since 0.1
		 */
		public ParamSpec? pspec { get; set; default = null; }
		/**
		 * Value type this registration is handling
		 * 
		 * @since 0.1
		 */
		public Type data_type { get; set; default = GLib.Type.INVALID; }
		/**
		 * Registered delegate that creates new widget instance for class
		 * and property
		 * 
		 * Note that specific_property_delegate and specific_type_delegate are
		 * mutually exclusive. Object can either describe value type handling
		 * or property handling. This can be resolved with 
		 * creates_for_property()
		 * 
		 * TODO, Replace this with BindingDataTransfer logic to enable
		 * introspection
		 * 
		 * @since 0.1
		 */
		public CreateCustomWidgetDelegate? specific_property_delegate { get; set; default = null; }
		/**
		 * Registered delegate method for creation of widget that only handles
		 * value type
		 * 
		 * Note that specific_property_delegate and specific_type_delegate are
		 * mutually exclusive. Object can either describe value type handling
		 * or property handling. This can be resolved with 
		 * creates_for_property()
		 * 
		 * @since 0.1
		 */
		public CreateCustomTypeWidgetDelegate? specific_type_delegate { get; set; default = null; }
		/**
		 * Corner case value type handling that takes precedence over exact
		 * match. Examples for this are enum and flags which are specified with
		 * different type each time, but all types share the ability to resolve
		 * as flags/enum trough Type.is_flags
		 * 
		 * @since 0.1
		 */
		public ConditionCheckDelegate? condition_check { get; set; default = null; }

		/**
		 * Checks if description is valid or not. If it is not valid then it is
		 * not available for widget creation
		 * 
		 * @since 0.1
		 */
		public bool is_valid {
			get { return (((creates_for_property() == true) && (pspec != null) && (specific_property_delegate != null)) ||
			              ((creates_for_property() == false) && (data_type != GLib.Type.INVALID) && (specific_type_delegate != null))); }
		}

		/**
		 * Resolves if description is describing creation of widget for specific
		 * class/property or it is describing simple value type handling
		 * 
		 * @since 0.1
		 */
		public bool creates_for_property()
		{
			return (_specific_property_delegate != null);
		}

		/**
		 * Creates description for property widget generation
		 * 
		 * TODO, Add another version of this with BindingDataTransfer
		 * 
		 * @since 0.1
		 * 
		 * @param mode Mode this widget generation is for (VIEW/EDIT)
		 * @param pspec ParamSpec for certain widget which needs special
		 *              treatment on widget generation
		 * @param method Method creating new widget
		 */
		public CustomCreationDescription.for_property (EditMode mode, ParamSpec pspec, CreateCustomWidgetDelegate method)
		{
			this.mode = mode;
			this.pspec = pspec;
			this.data_type = pspec.value_type;
			this.specific_property_delegate = method;
		}

		/**
		 * Creates description for value type widget generation
		 * 
		 * @since 0.1
		 * 
		 * @param mode Mode this widget generation is for (VIEW/EDIT)
		 * @param data_type Value type handled by generated widget
		 * @param method Method creating new widget
		 * @param condition_check Condition check delegate method
		 */
		public CustomCreationDescription.for_type (EditMode mode, Type data_type, CreateCustomTypeWidgetDelegate method, ConditionCheckDelegate? condition_check)
		{
			this.mode = mode;
			this.data_type = data_type;
			this.specific_type_delegate = method;
			this.condition_check = condition_check;
		}

		private CustomCreationDescription()
		{
		}
	}
}

