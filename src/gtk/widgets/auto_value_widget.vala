using GData;

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
	 * value type, class type/property name or binding transfer
	 * 
	 * @since 0.1
	 */
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/auto_value_widget.ui")]
	public class AutoValueWidget : Gtk.Alignment, BindableCompositeWidget
	{
		private Type _created_for = GLib.Type.INVALID;
		private string _created_for_property = "";

		private EditMode _mode = EditMode.VIEW;
		public EditMode mode {
			get { return (_mode); }
		}

		private Gtk.Widget? _widget = null;

		private string _binding_property = "";

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
			_renew_for_binding_transfer ((BindingDataTransfer) BindingDefaults.get_instance().get_introspection_object_for (class_type, property_name, true));
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

		public signal void widget_renewed();

		public AutoValueWidget.with_property (Type class_type, string property_name, EditMode mode = EditMode.VIEW)
		{
			_mode = mode;
			renew_for_property (class_type, property_name);
			visible = true;
		}

		public AutoValueWidget.with_type (Type value_type, EditMode mode = EditMode.VIEW, DefaultWidgets? default_widgets = null)
		{
			_mode = mode;
			renew_for_type (value_type);
			visible = true;
		}
	}
}
