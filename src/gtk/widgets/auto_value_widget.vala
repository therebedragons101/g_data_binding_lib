using GData;
using GData.Generics;

namespace GDataGtk
{
	private static Binder? __auto_binder = null;
	internal static Binder _auto_binder()
	{
		if (__auto_binder == null)
			__auto_binder = new Binder.silent();
		return (__auto_binder);
	}

	/**
	 * Provides simplest possible automatic widget which can be created by
	 * value type, class type/property name or binding transfer. This is meant
	 * to add ability to autocreate row handlers for listbox or other similar
	 * needs.
	 * 
	 * This is similar to AutoValueModeWidget, but more lightweight as it
	 * doesn't handle different modes (although mode can be changed on the fly).
	 * Main difference is that it lacks certain bang that AutoValueModeWidget
	 * has by animating when mode is changed or lack of displying invalid state
	 * 
	 * TODO, ability to prebuild cached generation where needs like listbox rows
	 * can cache creation which would bring it to most optimized state since all
	 * discovery is eliminated. Needs BindingDataTransfer optimization first
	 * 
	 * @since 0.1
	 */
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/auto_value_widget.ui")]
	public class AutoValueWidget : Gtk.Alignment, BindableCompositeWidget
	{
		private StrictWeakReference<SizeGroupCollection?>? _size_collection = null;
		private Type _created_for = GLib.Type.INVALID;
		private string _created_for_property = "";

		private EditMode _mode = EditMode.VIEW;
		/**
		 * Specifies mode which widget is handling. Note that this can be
		 * changed at any time and widget will be swapped with new one that
		 * handles that mode. At this point there are two options, if widget
		 * was bound then all is good, if value was handled directly assigning
		 * correct value is solely responsability of application.
		 * 
		 * @since 0.1
		 */
		public EditMode mode {
			get { return (_mode); }
			set {
				if (_mode == value)
					return;
				_mode = value;
				reset_contents();
			}
		}

		private Gtk.Widget? _widget = null;

		private string _binding_property = "";

		private BindingInterface? _mode_control_binding = null;

		private DefaultWidgets? _default_widgets = null;
		public DefaultWidgets default_widgets {
			owned get {
				if (_default_widgets == null)
					return (DefaultWidgets.get_default());
				return (_default_widgets);
			}
			set {
				if (_default_widgets == value)
					return;
				_default_widgets = value;
				reset_contents();
			}
		}

		private string _data_tooltip = "";
		/**
		 * Specifies tooltip that should be shown on widgets
		 * 
		 * @since 0.1
		 */
		public string data_tooltip {
			get { return (_data_tooltip); }
			set {
				if (_data_tooltip == value)
					return;
				_data_tooltip = value;
				if (_widget != null)
					_widget.set_tooltip_text (_data_tooltip);
			}
		}

		public Gtk.Widget? get_widget()
		{
			return (_widget);
		}

		public Gtk.Widget? get_bindable_widget()
		{
			return (_widget);
		}

		public string? get_value_binding_property()
		{
			if (_widget == null)
				return (null);
			if (_binding_property == "")
				return (PropertyAlias.get_default_value_property_for (_widget.get_type()));
			return (_binding_property);
		}

		private void remove_contents()
		{
			if (_widget != null) {
				remove (_widget);
				_widget.destroy();
				_widget = null;
			}
		}

		private void _set_widget()
		{
			if (_widget != null) {
				_widget.visible = true;
				add (_widget);
			}
			widget_renewed();
			if (_widget != null)
				_widget.set_tooltip_text (_data_tooltip);
		}

		public void _renew_for_binding_transfer (BindingDataTransfer? tr)
		{
			if (tr == null)
				return;
			_widget = default_widgets.create_binding_transfer_widget (mode, tr, out _binding_property);
			_set_widget();
		}

		public void renew_for_binding_transfer (BindingDataTransfer? tr)
		{
			remove_contents();
			_created_for = tr.get_introspection_type();
			_created_for_property = tr.get_name();
			_renew_for_binding_transfer (tr);
		}

		public void renew_for_property (Type class_type, string property_name)
		{
			remove_contents();
			_created_for = class_type;
			_created_for_property = property_name;
			_renew_for_binding_transfer ((BindingDataTransfer) BindingDefaults.get_instance().get_introspection_object_for (_created_for, _created_for_property, true));
		}

		public void renew_for_type (Type value_type)
		{
			remove_contents();
			_created_for = value_type;
			_created_for_property = "";
			_widget = default_widgets.create_type_widget (mode, value_type, out _binding_property);
			_set_widget();
		}

		public void reset_contents()
		{
			if (_created_for_property == "")
				renew_for_type (_created_for);
			else 
				renew_for_property (_created_for, _created_for_property);
		}

		/**
		 * Sets mode control object which is shared amongs all widgets of this
		 * type for certain group
		 * 
		 * @since 0.1
		 * 
		 * @param control Control object for EDIT/VIEW mode
		 */
		public AutoValueWidget set_mode_control (EditModeControlInterface? control)
		{
			if (_mode_control_binding != null) {
				_mode_control_binding.unbind();
				_mode_control_binding = null;
			}
			if (control != null)
				_mode_control_binding = _auto_binder().bind (control, "mode", this, "mode", BindFlags.SYNC_CREATE);
			return (this);
		}

		public signal void widget_renewed();

		private void _set_size_group (SizeGroupCollection? size_control)
		{
			_size_collection = new StrictWeakReference<SizeGroupCollection?> (size_control);
//			if (_size_collection.is_valid_ref() == true)
//				_size_collection.target.add_widget (this);
		}

		//TODO, investigate this further to end up with best possible implementation
		// from the start
		public AutoValueWidget.preset (BindingDataTransferInterface transfer, CustomCreationDescription? creation_description, DefaultWidgets? _default_widgets = null, SizeGroupCollection? size_control = null)
		{
			this.set_common (((creation_description != null) ? creation_description.mode : EditMode.VIEW), default_widgets, size_control);
		}

		public AutoValueWidget.with_property (Type class_type, string property_name, EditMode mode = EditMode.VIEW, DefaultWidgets? default_widgets = null, SizeGroupCollection? size_control = null)
		{
			this.set_common (mode, default_widgets, size_control);
			renew_for_property (class_type, property_name);
			visible = true;
		}

		public AutoValueWidget.with_type (Type value_type, EditMode mode = EditMode.VIEW, DefaultWidgets? default_widgets = null, SizeGroupCollection? size_control = null)
		{
			this.set_common (mode, default_widgets, size_control);
			renew_for_type (value_type);
			visible = true;
		}

		private AutoValueWidget.set_common (EditMode mode = EditMode.VIEW, DefaultWidgets? default_widgets = null, SizeGroupCollection? size_control = null)
		{
			_default_widgets = default_widgets;
			_mode = mode;
			_set_size_group (size_control);
		}
	}
}

