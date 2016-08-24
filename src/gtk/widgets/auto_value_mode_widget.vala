using GData;

namespace GDataGtk
{
	/**
	 * Provides simplest possible automatic widget which can be created by
	 * value type, class type/property name or binding transfer
	 * 
	 * @since 0.1
	 */
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/auto_value_mode_widget.ui")]
	public class AutoValueModeWidget : Gtk.Alignment, BindableCompositeWidget
	{
		[GtkChild] Gtk.Stack mode_stack;
		[GtkChild] Gtk.Alignment read_alignment;
		[GtkChild] Gtk.Alignment write_alignment;
		[GtkChild] Gtk.Label no_mode_available;

		private BindingInterface? _mode_control_binding = null;
		private BindingInterface? _internal_binding = null;
		private Type _created_for = GLib.Type.INVALID;
		private string _created_for_property = "";

		private EditMode _current_edit_mode = EditMode.VIEW;
		public EditMode mode {
			get { return ((mode_stack.visible_child == read_alignment) ? EditMode.VIEW : EditMode.EDIT); }
			set {
				_current_edit_mode = value;
				if ((_read_widget == null) && (_write_widget == null))
					mode_stack.visible_child = no_mode_available;
				else if ((value == EditMode.VIEW) && (_read_widget != null))
					mode_stack.visible_child = read_alignment;
				else if ((value == EditMode.EDIT) && (_write_widget != null))
					mode_stack.visible_child = write_alignment;
				else if (_read_widget != null)
					mode_stack.visible_child = read_alignment;
				else
					mode_stack.visible_child = write_alignment;
			}
		}

		public bool is_valid {
			get { return (mode_stack.visible_child != no_mode_available); }
		}

		private CreationEditMode _creation_mode = CreationEditMode.FULL;
		public CreationEditMode creation_mode {
			get { return (_creation_mode); }
		}

		private Gtk.Widget? _read_widget = null;
		private Gtk.Widget? _write_widget = null;

		private string _read_binding_property = "";
		private string _write_binding_property = "";

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

		public Gtk.Widget? get_widget(EditMode mode)
		{
			return ((mode == EditMode.VIEW) ? _read_widget : _write_widget);
		}

		public Gtk.Widget? get_bindable_widget()
		{
			return ((_write_widget != null) ? _write_widget : _read_widget);
		}

		private string? _get_value_binding_property(EditMode mode)
		{
			string binding_property = "";
			if (mode == EditMode.EDIT)
				binding_property = (_write_widget != null) ? _write_binding_property : "";
			else
				binding_property = (_read_widget != null) ? _read_binding_property : "";
			if (binding_property == "")
				return (PropertyAlias.get_default_value_property_for (((mode == EditMode.VIEW) ? _read_widget : _write_widget).get_type()));
			return (binding_property);
		}

		public string? get_value_binding_property()
		{
			string binding_property = "";
			if (_write_widget != null)
				binding_property = _write_binding_property;
			else
				binding_property = (_read_widget != null) ? _read_binding_property : "";
			if (binding_property == "")
				return (PropertyAlias.get_default_value_property_for (((_write_widget == null) ? _read_widget : _write_widget).get_type()));
			return (binding_property);
		}

		private Gtk.Widget? __remove_contents(Gtk.Alignment alignment, Gtk.Widget? widget)
		{
			if (widget != null) {
				alignment.remove (widget);
				widget.destroy();
			}
			return (null);
		}

		private void _remove_contents()
		{
			if (_internal_binding != null) {
				_internal_binding.unbind();
				_internal_binding = null;
			}
			_read_widget = __remove_contents (read_alignment, _read_widget);
			_write_widget = __remove_contents (write_alignment, _write_widget);
		}

		private void __set_widget(Gtk.Alignment alignment, Gtk.Widget? widget)
		{
			if (widget != null) {
				widget.visible = true;
				alignment.add (widget);
			}
		}

		private void _set_widget()
		{
			__set_widget (read_alignment, _read_widget);
			__set_widget (write_alignment, _write_widget);
			if ((_read_widget != null) && (_write_widget != null))
				_internal_binding = _auto_binder().bind (_write_widget, _get_value_binding_property(EditMode.EDIT),
				                                         _read_widget, _get_value_binding_property(EditMode.VIEW), BindFlags.SYNC_CREATE);
			widget_renewed();
		}

		public void _renew_for_binding_transfer (BindingDataTransfer? tr)
		{
			if (tr == null)
				return;
			if ((has_set_flag(_creation_mode, CreationEditMode.VIEW) == true) && (has_set_flag(tr.get_property_flags(), ParamFlags.READABLE) == true))
				_read_widget = default_widgets.create_binding_transfer_widget (EditMode.VIEW, tr, out _read_binding_property);
			if ((has_set_flag(_creation_mode, CreationEditMode.EDIT) == true) && (has_set_flag(tr.get_property_flags(), ParamFlags.WRITABLE) == true))
				_write_widget = default_widgets.create_binding_transfer_widget (EditMode.EDIT, tr, out _write_binding_property);
			_set_widget();
		}

		public void renew_for_binding_transfer (BindingDataTransfer? tr)
		{
			_created_for = tr.get_introspection_type();
			_created_for_property = tr.get_name();
			_remove_contents();
			_renew_for_binding_transfer (tr);
		}

		public void renew_for_property (Type class_type, string property_name)
		{
			_remove_contents();
			_created_for = class_type;
			_created_for_property = property_name;
			_renew_for_binding_transfer ((BindingDataTransfer) BindingDefaults.get_instance().get_introspection_object_for (_created_for, _created_for_property, true));
		}

		public void renew_for_type (Type value_type)
		{
			_remove_contents();
			_created_for = value_type;
			_created_for_property = "";
			if (has_set_flag(_creation_mode, CreationEditMode.VIEW) == true)
				_read_widget = default_widgets.create_type_widget (EditMode.VIEW, _created_for, out _read_binding_property);
			if (has_set_flag(_creation_mode, CreationEditMode.EDIT) == true)
				_write_widget = default_widgets.create_type_widget (EditMode.EDIT, _created_for, out _write_binding_property);
			_set_widget();
		}

		public AutoValueModeWidget set_mode_control (EditModeControl control)
		{
			if (_mode_control_binding != null) {
				_mode_control_binding.unbind();
				_mode_control_binding = null;
			}
			if (control != null)
				_mode_control_binding = _auto_binder().bind (control, "mode", this, "mode", BindFlags.SYNC_CREATE);
			return (this);
		}

		public void reset_contents()
		{
			if (_created_for_property == "")
				renew_for_type (_created_for);
			else
				renew_for_property (_created_for, _created_for_property);
		}

		public signal void widget_renewed();

		public AutoValueModeWidget.with_property (Type class_type, string property_name, EditMode mode = EditMode.VIEW, CreationEditMode creation_mode = CreationEditMode.FULL)
		{
			_creation_mode = creation_mode;
			renew_for_property (class_type, property_name);
			this.mode = mode;
			visible = true;
		}

		public AutoValueModeWidget.with_type (Type value_type, EditMode mode = EditMode.VIEW, DefaultWidgets? default_widgets = null, CreationEditMode creation_mode = CreationEditMode.FULL)
		{
			_creation_mode = creation_mode;
			renew_for_type (value_type);
			this.mode = mode;
			visible = true;
		}
	}
}

