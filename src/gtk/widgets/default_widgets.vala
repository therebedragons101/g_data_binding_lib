using GData;

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
	public delegate Gtk.Widget? CreateCustomTypeWidgetDelegate (EditMode mode, Type data_type, out string widget_value_property);

	/**
	 * Specifies extended circumstances to type resolving. Some types like flags
	 * or enums cannot be treated equally exact as string or bool
	 * 
	 * @since 0.1
	 * 
	 * @param data_type Type being checked
	 * @return True if type fulfills condition, false if not
	 */
	public delegate bool ConditionCheckDelegate (Type data_type);

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
	 * as many custom creations as wanted and never impact the application,
	 * while at the same time take advantage of all custom defaults made by
	 * application.
	 * 
	 * @since 0.1
	 */
	public class DefaultWidgets
	{
		private GLib.Array<CustomCreationDescription> _registrations = new GLib.Array<CustomCreationDescription>();

		private static DefaultWidgets? _instance = null;
		/**
		 * Returns singleton instance for DefaultWidgetRegister. Note that 
		 * default already registers some defaults. This is easy to override
		 * with custom DefaultWidgets class
		 * 
		 * Note that get_default() not only instances singleton if needed, it
		 * also calls init(). This does not happen when instance is set 
		 * differently with set_default() and calling init() falls solely into
		 * applications responsability.
		 * 
		 * @since 0.1
		 */
		public static DefaultWidgets get_default()
		{
			if (_instance == null) {
				_instance = new DefaultWidgets();
				_instance._default_fallback = __default_fallback;
				init();
			}
			return (_instance);
		}

		/**
		 * Sets new default widgets creation mechanism. If this is called then
		 * only right moment is before init() or get_instance(). If either of
		 * those two was called before this was set application will throw
		 * error and quit
		 * 
		 * @since 0.1
		 */
		public static void set_default(DefaultWidgets instance)
		{
			if (_instance != null) {
				GLib.error ("DefaultWidgets.set_default() called too late");
				return;
			}
			_instance = instance;
		}

		private static void _initialize_default_widgets()
		{
			// VIEW mode
			_instance.register_for_data_type (EditMode.VIEW, typeof(bool), __create_switch_state_checkbox);
			_instance.register_for_data_type (EditMode.VIEW, typeof(string), __create_label);
			//TODO replace these with better labels or images
			_instance.register_for_data_type (EditMode.VIEW, typeof(int), __create_label);
			_instance.register_for_data_type (EditMode.VIEW, typeof(uint), __create_label);
			_instance.register_for_data_type (EditMode.VIEW, typeof(long), __create_label);
			_instance.register_for_data_type (EditMode.VIEW, typeof(ulong), __create_label);
			_instance.register_for_data_type (EditMode.VIEW, typeof(float), __create_label);
			_instance.register_for_data_type (EditMode.VIEW, typeof(double), __create_label);
			_instance.register_for_data_type (EditMode.VIEW, typeof(short), __create_label);
			_instance.register_for_data_type (EditMode.VIEW, typeof(ushort), __create_label);
			// any type should do for enum and flags as they have conditional check
			_instance.register_for_data_type (EditMode.VIEW, typeof(EditMode), __create_enum_flags_button, (t) => { return(t.is_enum()); });
			_instance.register_for_data_type (EditMode.VIEW, typeof(CreationEditMode), __create_enum_flags_button, (t) => { return(t.is_flags()); });
			// EDIT mode
			_instance.register_for_data_type (EditMode.EDIT, typeof(bool), __create_check_button);
			_instance.register_for_data_type (EditMode.EDIT, typeof(string), __create_entry);
			_instance.register_for_data_type (EditMode.EDIT, typeof(int), __create_spin_button);
			_instance.register_for_data_type (EditMode.EDIT, typeof(uint), __create_spin_button);
			_instance.register_for_data_type (EditMode.EDIT, typeof(long), __create_spin_button);
			_instance.register_for_data_type (EditMode.EDIT, typeof(ulong), __create_spin_button);
			_instance.register_for_data_type (EditMode.EDIT, typeof(float), __create_spin_button);
			_instance.register_for_data_type (EditMode.EDIT, typeof(double), __create_spin_button);
			_instance.register_for_data_type (EditMode.EDIT, typeof(short), __create_spin_button);
			_instance.register_for_data_type (EditMode.EDIT, typeof(ushort), __create_spin_button);
			// any type should do for enum and flags as they have conditional check
			_instance.register_for_data_type (EditMode.EDIT, typeof(EditMode), __create_enum_flags_button, (t) => { return(t.is_enum()); });
			_instance.register_for_data_type (EditMode.EDIT, typeof(CreationEditMode), __create_enum_flags_button, (t) => { return(t.is_flags()); });
		}

		private static void _initialize_default_properties()
		{
			PropertyAlias.get_instance(ALIAS_DEFAULT)
				.register (typeof(Gtk.Entry), "text")
				.register (typeof(Gtk.Label), "label")
				.register (typeof(Gtk.SpinButton), "value")
				.register (typeof(Gtk.Switch), "active")
				.register (typeof(Gtk.ComboBox), "active")
				.register (typeof(Gtk.ColorButton), "rgba")
				.register (typeof(Gtk.Adjustment), "value")
				.register (typeof(Gtk.ProgressBar), "fraction")
				.register (typeof(Gtk.LevelBar), "value")
				.register (typeof(Gtk.ToggleButton), "active")
				.register (typeof(Gtk.CheckButton), "active")
				.register (typeof(Gtk.RadioButton), "active");
			PropertyAlias.get_instance(ALIAS_VISIBILITY)
				.register (typeof(Gtk.Widget), "visible");
			PropertyAlias.get_instance(ALIAS_SENSITIVITY)
				.register (typeof(Gtk.Widget), "sensitive");
		}

		/**
		 * Initializes default registrations. Init can be called even if 
		 * default instance was swapped with set_default() at which point Init
		 * will add default registrations to that specific instance
		 * 
		 * @since 0.1
		 */
		public static void init()
		{
			if (_instance == null)
				get_default();
			else {
				_initialize_default_widgets();
				_initialize_default_properties();
			}
		}

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

		private CreateCustomTypeWidgetDelegate _default_fallback;
		/**
		 * Specifies method which can create fallback widget. By default this
		 * creates simple label widget, but this can be replaced anytime by
		 * changing this property
		 * 
		 * @since 0.1
		 */
		public CreateCustomTypeWidgetDelegate default_fallback {
			get { return (_default_fallback); }
			set { _default_fallback = value; }
		}

		private static Gtk.Widget? __default_fallback (EditMode mode, Type data_type, out string widget_value_property)
		{
			Gtk.Label label = new Gtk.Label ("No content");
			label.visible = true;
			widget_value_property = "label";
			return (label);
		}

		private static Gtk.Widget? __create_switch_state_image (EditMode mode, Type data_type, out string widget_value_property)
		{
			StateImage widget = new StateImage.checkbox();
			widget.visible = true;
			widget_value_property = "state";
			return (widget);
		}

		private static Gtk.Widget? __create_switch_state_checkbox (EditMode mode, Type data_type, out string widget_value_property)
		{
			StateImage widget = new StateImage.checkbox();
			widget.visible = true;
			widget.hexpand = false;
			widget.halign = Gtk.Align.START;
			widget_value_property = "state";
			return (widget);
		}

		private static Gtk.Widget? __create_label (EditMode mode, Type data_type, out string widget_value_property)
		{
			Gtk.Label widget = new Gtk.Label ("");
			widget.visible = true;
			widget.ellipsize = Pango.EllipsizeMode.END;
			widget.xalign = (data_type != typeof(string)) ? 1.0f : 0.0f;
			widget_value_property = "label";
			return (widget);
		}

		private static Gtk.Widget? __create_entry (EditMode mode, Type data_type, out string widget_value_property)
		{
			Gtk.Entry widget = new Gtk.Entry ();
			widget.visible = true;
			widget.editable = (mode == EditMode.EDIT);
			widget_value_property = "text";
			return (widget);
		}

		private static Gtk.Widget? __create_spin_button (EditMode mode, Type data_type, out string widget_value_property)
		{
			Gtk.Adjustment adjust;
			uint digits = ((data_type == typeof(double)) || (data_type == typeof(float))) ? 4 : 0;
			if (data_type == typeof(int))
				adjust = new Gtk.Adjustment (0, (double)int.MIN, (double)int.MAX, 1, 10, 10);
			else if (data_type == typeof(uint))
				adjust = new Gtk.Adjustment (0, (double)uint.MIN, (double)uint.MAX, 1, 10, 10);
			else if (data_type == typeof(long))
				adjust = new Gtk.Adjustment (0, (double)long.MIN, (double)long.MAX, 1, 10, 10);
			else if (data_type == typeof(ulong))
				adjust = new Gtk.Adjustment (0, (double)ulong.MIN, (double)ulong.MAX, 1, 10, 10);
			else if (data_type == typeof(float))
				adjust = new Gtk.Adjustment (0, (double)float.MIN, (double)float.MAX, 1, 10, 10);
			else if (data_type == typeof(double))
				adjust = new Gtk.Adjustment (0, double.MIN, double.MAX, 1, 10, 10);
			else if (data_type == typeof(short))
				adjust = new Gtk.Adjustment (0, (double)short.MIN, (double)short.MAX, 1, 10, 10);
			else if (data_type == typeof(ushort))
				adjust = new Gtk.Adjustment (0, (double)ushort.MIN, (double)ushort.MAX, 1, 10, 10);
			else 
				// just some number to obviously show something is wrong
				adjust = new Gtk.Adjustment (0, -13.0f, 13.0f, 1, 10, 10);
			Gtk.SpinButton widget = new Gtk.SpinButton (adjust, 1, digits);
			widget.visible = true;
			widget_value_property = "value";
			widget.editable = (mode == EditMode.EDIT);
			return (widget);
		}

		private static Gtk.Widget? __create_switch (EditMode mode, Type data_type, out string widget_value_property)
		{
			Gtk.Switch widget = new Gtk.Switch ();
			widget.visible = true;
			widget.sensitive = (mode == EditMode.EDIT);
			widget_value_property = "active";
			return (widget);
		}

		private static Gtk.Widget? __create_check_button (EditMode mode, Type data_type, out string widget_value_property)
		{
			Gtk.CheckButton widget = new Gtk.CheckButton ();
			widget.visible = true;
			widget.sensitive = (mode == EditMode.EDIT);
			widget_value_property = "active";
			return (widget);
		}

		private static Gtk.Widget? __create_enum_flags_button (EditMode mode, Type data_type, out string widget_value_property)
		{
			EnumFlagsMenuButton widget = new EnumFlagsMenuButton (data_type);
			widget.visible = true;
			widget.sensitive = (mode == EditMode.EDIT);
			widget_value_property = (data_type.is_enum() == true) ? "int-value" : "uint-value";
			return (widget);
		}

		
		private bool __type_is_enum (Type data_type)
		{
			return (data_type.is_enum());
		}

		private bool __type_is_flags (Type data_type)
		{
			return (data_type.is_flags());
		}

		/**
		 * This should be called when resolving correct widget was not possible
		 * 
		 * @since 0.1
		 * 
		 * @param mode Editing mode
		 * @param param Property ParamSpec or null
		 * @param widget_value_property Filled with property name that is used
		 *                              for binding contents
		 */
		public Gtk.Widget? create_default_fallback (EditMode mode, ParamSpec? param, out string widget_value_property)
		{
			return (_default_fallback (mode, (param == null) ? Type.INVALID : param.value_type, out widget_value_property));
		}

		private CustomCreationDescription? _get_for_property (EditMode mode, ParamSpec pspec, bool go_deep = false)
		{
			for (int i=0; i<_registrations.length; i++)
				if (_registrations.data[i].creates_for_property() == true)
					if ((_registrations.data[i].mode == mode) && (_registrations.data[i].pspec == pspec))
						return (_registrations.data[i]);
			if ((go_deep == true) && (_fallback != null))
				return (_fallback._get_for_property(mode, pspec, go_deep));
			return (null);
		}

		private CustomCreationDescription? _get_for_type (EditMode mode, Type data_type, bool go_deep = false)
		{
			// iterate trough condition checks firs. this provides ability to discern flags, enums and similar in global scale
			for (int i=0; i<_registrations.length; i++)
				if (_registrations.data[i].creates_for_property() == false)
					if (_registrations.data[i].mode == mode)
						if ((_registrations.data[i].condition_check != null) && (_registrations.data[i].condition_check(data_type) == true))
							return (_registrations.data[i]);
			// iterate trough types next
			for (int i=0; i<_registrations.length; i++)
				if (_registrations.data[i].creates_for_property() == false)
					if ((_registrations.data[i].mode == mode) && (_registrations.data[i].data_type == data_type))
						if (_registrations.data[i].condition_check == null)
							return (_registrations.data[i]);
			if ((go_deep == true) && (_fallback != null))
				return (_fallback._get_for_type(mode, data_type, go_deep));
			return (null);
		}

		/**
		 * Checks if specified property registered specific widget creation or
		 * not
		 * 
		 * @since 0.1
		 * 
		 * @param mode Specifies VIEW/EDIT mode
		 * @param param Property widget creation is requested for
		 * @param go_deep Specifies if fallback should be used to resolve when
		 *                this instance doesn't have correct registration
		 */
		public bool property_widget_registered (EditMode mode, ParamSpec param, bool go_deep = false)
		{
			return (_get_for_property(mode, param, go_deep) != null);
		}

		/**
		 * Creates widget for specific object property if registered. If 
		 * not found and DefaultWidgets instance specifies fallback then that
		 * one is used as continuation and so on until the end of the 
		 * registration chain. Since this specifies binding transfer data
		 * it also means this is safe to call even for foreign objects depending
		 * on the fact that they have registered data handler
		 * 
		 * When finding exact override for exact property and type is not 
		 * successful, type widget is resolved in same way, but first it tries
		 * to get exact object::property match trough create_property_widget()
		 * 
		 * Note that if unsuccessful, this does not invoke 
		 * create_default_fallback() so application can be aware of this fact. 
		 * Calling last stage default creation is solely up to implementation
		 * 
		 * @since 0.1
		 * 
		 * @param mode Specifies VIEW/EDIT mode
		 * @param binding_transfer Binding data transfer object description
		 * @param widget_value_property Property in widget that specifies data
		 *                              content
		 */
		public Gtk.Widget? create_binding_transfer_widget (EditMode mode, BindingDataTransferInterface? binding_transfer, out string widget_value_property)
		{
			if ((binding_transfer == null) || (binding_transfer.is_introspectable == false))
				return (null);

			//TODO, this is not adequate
			ParamSpec? pspec = TypeInformation.get_instance().find_property_from_type (binding_transfer.get_introspection_type(), binding_transfer.get_name());
			if (pspec != null)
				return (create_property_widget (mode, pspec, out widget_value_property));
			else
				return (create_type_widget (mode, binding_transfer.get_value_type(), out widget_value_property));
		}

		/**
		 * Creates widget for specific object property if registered. If 
		 * not found and DefaultWidgets instance specifies fallback then that
		 * one is used as continuation and so on until the end of the 
		 * registration chain
		 * 
		 * When finding exact override for exact property and type is not 
		 * successful, type widget is resolved in same way
		 * 
		 * Note that if unsuccessful, this does not invoke 
		 * create_default_fallback() so application can be aware of this fact. 
		 * Calling last stage default creation is solely up to implementation
		 * 
		 * @since 0.1
		 * 
		 * @param mode Specifies VIEW/EDIT mode
		 * @param param Property widget creation is requested for
		 * @param widget_value_property Property in widget that specifies data
		 *                              content
		 */
		public Gtk.Widget? create_property_widget (EditMode mode, ParamSpec? param, out string widget_value_property)
		{
			if (param == null)
				return (null);
			CustomCreationDescription? desc = _get_for_property(mode, param, true);
			if (desc != null)
				return (desc.specific_property_delegate(mode, param, out widget_value_property));
			desc = _get_for_type (mode, param.value_type, true);
			if (desc != null)
				return (desc.specific_type_delegate(mode, param.value_type, out widget_value_property));
			return (null);
		}

		/**
		 * Checks if specified data type registered specific widget creation or
		 * not.
		 * 
		 * @since 0.1
		 * 
		 * @param mode Specifies VIEW/EDIT mode
		 * @param data_type Data type creation is requested for
		 * @param go_deep Specifies if fallback should be used to resolve when
		 *                this instance doesn't have correct registration
		 */
		public bool type_widget_registered (EditMode mode, Type data_type, bool go_deep = false)
		{
			return (_get_for_type(mode, data_type, go_deep) != null);
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
			if (data_type == GLib.Type.INVALID)
				return (null);
			CustomCreationDescription desc = _get_for_type (mode, data_type, true);
			if (desc != null)
				return (desc.specific_type_delegate(mode, data_type, out widget_value_property));
			return (null);
		}

		/**
		 * Registers creation method for specific property in specific object.
		 * If creation already exists GLib.error is reported. If there is the
		 * need to specify another method for same thing, then different 
		 * instances of DefaultWidgets should be used instead
		 * 
		 * @since 0.1
		 * 
		 */
		public void register_for_property (EditMode mode, ParamSpec? param, CreateCustomWidgetDelegate method)
		{
			if (param == null)
				return;
			if (property_widget_registered(mode, param, false) == true) {
				GLib.error ("Double registration of default widget for [%s] (%s) %s",
				            (mode == EditMode.VIEW) ? "VIEW" : "EDIT",
				            param.owner_type.name(), param.name);
				return;
			}
			CustomCreationDescription desc = new CustomCreationDescription.for_property (mode, param, method);
			if (desc.is_valid == true)
				_registrations.append_val (desc);
		}

		/**
		 * Registers creation method for specific data type
		 * 
		 * @since 0.1
		 * 
		 */
		public void register_for_data_type (EditMode mode, Type data_type, CreateCustomTypeWidgetDelegate method, ConditionCheckDelegate? condition_check = null)
		{
			if (data_type == Type.INVALID)
				return;
			if (type_widget_registered(mode, data_type, false) == true) {
				GLib.error ("Double registration of default widget for [%s] %s",
				            (mode == EditMode.VIEW) ? "VIEW" : "EDIT",
				            data_type.name());
				return;
			}
			CustomCreationDescription desc = new CustomCreationDescription.for_type (mode, data_type, method, condition_check);
			if (desc.is_valid == true)
				_registrations.append_val (desc);
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

