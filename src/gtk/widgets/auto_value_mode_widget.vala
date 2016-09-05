using GData;
using GData.Generics;

namespace GDataGtk
{
	/**
	 * Provides simplest possible automatic widget which can be created by
	 * value type, class type/property name or binding transfer
	 * 
	 * AutoValueWidget is very much similar to this widget, but lighter and
	 * lacking certain bang. When AutoValueModeWidget switches mode, it does
	 * that with animation and can provide invalid state as well
	 * 
	 * This widget is probably not suggested to use in listboxes as it is
	 * heavy composite widget.
	 * 
	 * TODO, ability to prebuild cached generation where needs like listbox rows
	 * can cache creation which would bring it to most optimized state since all
	 * discovery is eliminated. Needs BindingDataTransfer optimization first
	 * 
	 * TODO, investigate AutoValueWidget.preset and implement the same
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

		private StrictWeakReference<SizeGroupCollection?>? _size_collection = null;
		private BindingInterface? _mode_control_binding = null;
		private BindingInterface? _internal_binding = null;
		private Type _created_for = GLib.Type.INVALID;
		private string _created_for_property = "";

		private EditMode _current_edit_mode = EditMode.VIEW;
		/**
		 * Specifies current edit mode in which widget is in
		 * 
		 * @since 0.1
		 */
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

		/**
		 * Specifies if widget is currently in valid state or not. Invalid state
		 * means that it is showing fallback warning in stack
		 * 
		 * @since 0.1
		 */
		public bool is_valid {
			get { return (mode_stack.visible_child != no_mode_available); }
		}

		private CreationEditMode _creation_mode = CreationEditMode.FULL;
		/**
		 * Creation mode that defines EDIT/VIEW mode which was specified at the
		 * time of creation
		 * 
		 * @since 0.1
		 */
		public CreationEditMode creation_mode {
			get { return (_creation_mode); }
		}

		private Gtk.Widget? _read_widget = null;
		private Gtk.Widget? _write_widget = null;

		private string _read_binding_property = "";
		private string _write_binding_property = "";

		private DefaultWidgets? _default_widgets = null;
		/**
		 * Specifies DefaultWidgets object which was used to create widget. This
		 * can be changed at any time and widget will simply adapt to be
		 * recreated in new mode.
		 * 
		 * If this is changed during runtime, then value store/assign falls
		 * solely into applications responsability. If widget was bound to some
		 * data this shouldn't be problem, only case when this is needed is when
		 * for some reason data was manipulated directly on widgets
		 * 
		 * @since 0.1
		 */
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

		/**
		 * Returns value widget for specific mode
		 * 
		 * @since 0.1
		 * 
		 * @param mode EDIT/VIEW mode can be specified
		 * @return Widget that is responsible for that mode
		 */
		public Gtk.Widget? get_widget(EditMode mode)
		{
			return ((mode == EditMode.VIEW) ? _read_widget : _write_widget);
		}

		/**
		 * Returns widget which is responsible for binding data. If this is
		 * handling both modes, then EDIT widget is returned. Otherwise, it
		 * returns the one widget available or null if (is_valid == false)
		 * 
		 * @since 0.1
		 * 
		 * @return Bindable widget
		 */
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

		/**
		 * Returns current property name in bindable widget that is handling
		 * data.
		 * 
		 * @since 0.1
		 * 
		 * @return Current bindable widgets property which is responsible for
		 *         data binding
		 */
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

		private void _renew_for_binding_transfer (BindingDataTransfer? tr)
		{
			if (tr == null)
				return;
			if ((has_set_flag(_creation_mode, CreationEditMode.VIEW) == true) && (has_set_flag(tr.get_property_flags(), ParamFlags.READABLE) == true))
				_read_widget = default_widgets.create_binding_transfer_widget (EditMode.VIEW, tr, out _read_binding_property);
			if ((has_set_flag(_creation_mode, CreationEditMode.EDIT) == true) && (has_set_flag(tr.get_property_flags(), ParamFlags.WRITABLE) == true))
				_write_widget = default_widgets.create_binding_transfer_widget (EditMode.EDIT, tr, out _write_binding_property);
			_set_widget();
		}

		/**
		 * Renews whole widget for new binding transfer
		 * 
		 * @since 0.1
		 * 
		 * @param transfer Binding data transfer object
		 */
		public void renew_for_binding_transfer (BindingDataTransfer? transfer)
		{
			_created_for = transfer.get_introspection_type();
			_created_for_property = transfer.get_name();
			_remove_contents();
			_renew_for_binding_transfer (transfer);
		}

		/**
		 * Renews whole widget for new set of type/property name
		 * 
		 * @since 0.1
		 * 
		 * @param class_type Class type
		 * @param property_name Property name
		 */
		public void renew_for_property (Type class_type, string property_name)
		{
			_remove_contents();
			_created_for = class_type;
			_created_for_property = property_name;
			_renew_for_binding_transfer ((BindingDataTransfer) BindingDefaults.get_instance().get_introspection_object_for (_created_for, _created_for_property, true));
		}

		/**
		 * Renews whole widget for new value type
		 * 
		 * @since 0.1
		 * 
		 * @param value_type Value type
		 */
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

		/**
		 * Sets mode control object which is shared amongs all widgets of this
		 * type for certain group
		 * 
		 * @since 0.1
		 * 
		 * @param control Control object for EDIT/VIEW mode
		 */
		public AutoValueModeWidget set_mode_control (EditModeControlInterface? control)
		{
			if (_mode_control_binding != null) {
				_mode_control_binding.unbind();
				_mode_control_binding = null;
			}
			if (control != null)
				_mode_control_binding = _auto_binder().bind (control, "mode", this, "mode", BindFlags.SYNC_CREATE);
			return (this);
		}

		/**
		 * Completely resets contents of widget
		 * 
		 * @since 0.1
		 */
		public void reset_contents()
		{
			if (_created_for_property == "")
				renew_for_type (_created_for);
			else
				renew_for_property (_created_for, _created_for_property);
		}

		private void _set_size_group (SizeGroupCollection? size_control)
		{
			_size_collection = new StrictWeakReference<SizeGroupCollection?> (size_control);
//			if (_size_collection.is_valid_ref() == true)
//				_size_collection.target.add_widget (this);
		}

		/**
		 * Signal sent when widget contents are renewed. This is not about data
		 * being handled, but about widgets that handle it
		 * 
		 * @since 0.1
		 */
		public signal void widget_renewed();

		/**
		 * Creates new AutoValueModeWidget for specified property
		 * 
		 * @since 0.1
		 * 
		 * @param class_type Class type
		 * @param property_name Property name
		 * @param mode Starting mode (VIEW/EDIT)
		 * @param creation_mode Creation mode description which can be VIEW, 
		 *                      EDIT or both.
		 * @param default_widgets Specifies widget creation mechanism, this can
		 *                        be reset at anytime by setting default_widgets
		 *                        property. If specified value is null, then
		 *                        its value will be resolved trough
		 *                        DefaultWidgets.get_default()
		 */
		public AutoValueModeWidget.with_property (Type class_type, string property_name, EditMode mode = EditMode.VIEW, CreationEditMode creation_mode = CreationEditMode.FULL, DefaultWidgets? default_widgets = null, SizeGroupCollection? size_control = null)
		{
			this.set_common (mode, creation_mode, default_widgets, size_control);
			_creation_mode = creation_mode;
			renew_for_property (class_type, property_name);
			this.mode = mode;
			visible = true;
		}

		/**
		 * Creates new AutoValueModeWidget for specified value type
		 * 
		 * @since 0.1
		 * 
		 * @param value_type Value type
		 * @param mode Starting mode (VIEW/EDIT)
		 * @param creation_mode Creation mode description which can be VIEW, 
		 *                      EDIT or both.
		 * @param default_widgets Specifies widget creation mechanism, this can
		 *                        be reset at anytime by setting default_widgets
		 *                        property. If specified value is null, then
		 *                        its value will be resolved trough
		 *                        DefaultWidgets.get_default()
		 */
		public AutoValueModeWidget.with_type (Type value_type, EditMode mode = EditMode.VIEW, CreationEditMode creation_mode = CreationEditMode.FULL, DefaultWidgets? default_widgets = null, SizeGroupCollection? size_control = null)
		{
			this.set_common (mode, creation_mode, default_widgets, size_control);
			renew_for_type (value_type);
			this.mode = mode;
			visible = true;
		}

		private AutoValueModeWidget.set_common (EditMode mode = EditMode.VIEW, CreationEditMode creation_mode = CreationEditMode.FULL, DefaultWidgets? default_widgets = null, SizeGroupCollection? size_control = null)
		{
			_default_widgets = default_widgets;
			_current_edit_mode = mode;
			_creation_mode = creation_mode;
			_set_size_group (size_control);
		}
	}
}

