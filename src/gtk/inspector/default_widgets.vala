namespace GDataGtk
{
	/**
	 * Delegate method used to register creation of specific widget for specific
	 * property in some object
	 * 
	 * @since 0.1
	 * 
	 * @param mode Specifies VIEW/EDIT mode
	 * @param param Property widget creation is requested for
	 * @param widget_value_property Property in widget that specifies data
	 *                              content
	 */
	public delegate Gtk.Widget? CreateCustomWidgetDelegate (EditMode mode, ParamSpec? param, out string widget_value_property);

	/**
	 * Delegate method used to register creation of specific widget for specific
	 * data type
	 * 
	 * @since 0.1
	 * 
	 * @param mode Specifies VIEW/EDIT mode
	 * @param data_type Data type creation is requested for
	 * @param widget_value_property Property in widget that specifies data
	 *                              content
	 */
	public delegate Gtk.Widget? CreateCustomTypeWidgetDelegate (EditMode mode, Type? data_type, out string widget_value_property);

	/**
	 * Registration container for methods that can be used to automate gui
	 * creation per object properties or per data types
	 * 
	 * Application it self should more or less always use get_default() unless
	 * there is a need for specific conditional chaining in which case it can
	 * create new instance and set that one as fallback
	 * 
	 * This allows impacting creation at any level
	 * 
	 * Libraries should most probably generate following structure
	 * - its own registry instance
	 * - that has fallback in get_default(). With this setup library can set up
	 *   as many custom creations as wanted and never impact the application,
	 *   while at the same time take advantage of all custom defaults made by
	 *   application.
	 * 
	 * @since 0.1
	 */
	public class DefaultWidgets
	{
		private static DefaultWidgets? _instance = null;

		private DefaultWidgets? _fallback = null;
		/**
		 * Allows chaining of default widget regirars. If requested generation
		 * fails then fallback is the next choice.
		 * 
		 * @since 0.1
		 */
		public DefaultWidgets? fallback {
			get { return (_fallback); }
			set { _fallback = value; }
		}

		/**
		 * Returns singleton instance for DefaultWidgetRegister
		 * 
		 * @since 0.1
		 */
		public static DefaultWidgets get_default()
		{
			if (_instance == null)
				_instance = new DefaultWidgets();
			return (_instance);
		}

		/**
		 * Checks if specified property registered specific widget creation or
		 * not
		 * 
		 * @since 0.1
		 * 
		 * @param mode Specifies VIEW/EDIT mode
		 * @param param Property widget creation is requested for
		 */
		public bool property_widget_registered (EditMode mode, ParamSpec param)
		{
			return (false);
		}

		/**
		 * Creates widget for specific object property if registered
		 * 
		 * @since 0.1
		 * 
		 * @param mode Specifies VIEW/EDIT mode
		 * @param param Property widget creation is requested for
		 * @param widget_value_property Property in widget that specifies data
		 *                              content
		 */
		public Gtk.Widget? create_property_widget (EditMode mode, ParamSpec param, out string widget_value_property)
		{
			return (null);
		}

		/**
		 * Checks if specified data type registered specific widget creation or
		 * not
		 * 
		 * @since 0.1
		 * 
		 * @param mode Specifies VIEW/EDIT mode
		 * @param data_type Data type creation is requested for
		 */
		public bool type_widget_registered (EditMode mode, Type data_type)
		{
			return (false);
		}

		/**
		 * Creates widget for specific data type if registered
		 * 
		 * @since 0.1
		 * 
		 * @param mode Specifies VIEW/EDIT mode
		 * @param data_type Data type creation is requested for
		 * @param widget_value_property Property in widget that specifies data
		 *                              content
		 */
		public Gtk.Widget? create_type_widget (EditMode mode, Type data_type, out string widget_value_property)
		{
			return (null);
		}

		/**
		 * Registers creation method for specific property in specific object
		 * 
		 * @since 0.1
		 * 
		 */
		public void register_for_property (EditMode mode, ParamSpec param, CreateCustomWidgetDelegate method)
		{
			
		}

		/**
		 * Registers creation method for specific data type
		 * 
		 * @since 0.1
		 * 
		 */
		public void register_for_data_type (EditMode mode, ParamSpec param, CreateCustomTypeWidgetDelegate method)
		{
			
		}

		/**
		 * Creates custom default widget creation registrar
		 * 
		 * @since 0.1
		 * 
		 * @return Custom registrar instance
		 */
		public static DefaultWidgets create_custom_instance()
		{
			return (new DefaultWidgets());
		}

		private DefaultWidgets()
		{
		}
	}
}

