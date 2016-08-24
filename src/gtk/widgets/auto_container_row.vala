using GData;

namespace GDataGtk
{
	public enum ObjectBoxEmptyStyle
	{
		NONE,
		REVEAL,
		USE_PLACEHOLDER
	}

	public delegate Gtk.Widget CreateLabelWidgetDelegate ();

	/**
	 * Provides ability to have autofilled widgets which use binding as their
	 * central point.
	 * 
	 * By default it shows all properties unless set_source_with_layout() was
	 * used
	 * 
	 * @since 0.1
	 */
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/auto_container_row.ui")]
	public class AutoContainerRow : Gtk.Alignment
	{
		[GtkChild] private Gtk.Box main_box;
		[GtkChild] private Gtk.Box value_box;
		[GtkChild] private Gtk.Alignment label_alignment;
		[GtkChild] private Gtk.Alignment label_contents_alignment;
		[GtkChild] private Gtk.Alignment value_alignment;
		[GtkChild] private Gtk.Alignment widget_alignment;
		[GtkChild] private Gtk.Alignment tool_alignment;

		private Gtk.Widget? _label_widget = null;
		private Gtk.Widget? _action_widget = null;
		private Gtk.Widget? _data_widget = null;

		private string _specified_label = "";
		/**
		 * AutoContainerRow only provides formated label text for labels based
		 * on AutoContainerControl settings. Assigning them to widget is
		 * purely responsability of application
		 * 
		 * @since 0.1
		 */
		public string label {
			owned get {
				if (_control.labels_use_markup == true)
					return (_control.label_markup_format.printf(_specified_label));
				else
					return (_specified_label);
			}
			set { _specified_label = value; }
		}

		private string _specified_tooltip = "";
		/**
		 * Tooltip text
		 * 
		 * @since 0.1
		 */
		public string data_tooltip {
			get { return ((_control.show_tooltips == true) ? _specified_tooltip : ""); }
			set { _specified_tooltip = value; }
		}

		private AutoContainerControl? _control = null;
		/**
		 * Access to central control of row widgets layout
		 * 
		 * @since 0.1
		 */
		public AutoContainerControl control {
			get { return (_control); }
		}

		private void set_tooltip ()
		{
			if (_data_widget != null)
				_data_widget.set_tooltip_markup (data_tooltip);
		}

		/**
		 * Sets data widget into appropriate alignment
		 * 
		 * @since 0.1
		 * 
		 * @param set_under_name Specifies widget name which can be used for
		 *                       automaping. In most common case it is equal
		 *                       to property it handles
		 * @param widget Widget which should be used for displaying or editing
		 */
		public void set_data_widget (string set_under_name, Gtk.Widget? widget)
		{
			if (_data_widget == widget)
				return;
			if (_data_widget != null) {
				value_alignment.remove (_data_widget);
				_data_widget.destroy();
				_data_widget = null;
			}
			_data_widget = widget;
			if (_data_widget != null) {
				value_alignment.add (_data_widget);
				if (_data_widget.get_type().is_a(typeof(Gtk.Buildable)) == true)
					((Gtk.Buildable) _data_widget).set_name (set_under_name);
				_data_widget.visible = true;
				set_tooltip();
			}
		}

		/**
		 * Returns current data widget
		 * 
		 * @since 0.1
		 * 
		 * @return Current data widget
		 */
		public Gtk.Widget? get_data_widget()
		{
			return (_data_widget);
		}

		/**
		 * Sets tool action widget into appropriate alignment
		 * 
		 * @since 0.1
		 * 
		 * @param widget Widget which is tool or container which is used to
		 *               contain them
		 */
		public void set_action_widget (Gtk.Widget? widget)
		{
			if (_action_widget == widget)
				return;
			if (_action_widget != null) {
				label_alignment.remove (_action_widget);
				_action_widget.destroy();
				_action_widget = null;
			}
			_action_widget = widget;
			if (_action_widget != null) {
				tool_alignment.add (_action_widget);
				_action_widget.visible = true;
			}
		}

		/**
		 * Returns current widget containing tools
		 * 
		 * @since 0.1
		 * 
		 * @return Current widget containing tools
		 */
		public Gtk.Widget? get_action_widget()
		{
			return (_action_widget);
		}

		/**
		 * Sets label widget into appropriate alignment. Note that handling
		 * label text is purely responsability of application
		 * 
		 * @since 0.1
		 * 
		 * @param Widget which is used as label
		 */
		public void set_label_widget (Gtk.Widget? widget)
		{
			if (_label_widget == widget)
				return;
			if (_label_widget != null) {
				label_alignment.remove (_label_widget);
				_label_widget.destroy();
				_label_widget = null;
			}
			_label_widget = widget;
			if (_label_widget != null) {
				label_alignment.add (_label_widget);
				_label_widget.visible = true;
			}
		}

		/**
		 * Returns current label widget
		 * 
		 * @since 0.1
		 * 
		 * @return Current label widget
		 */
		public Gtk.Widget? get_label_widget()
		{
			return (_label_widget);
		}

		/**
		 * Returns alignment that can be used to size labels
		 * 
		 * @since 0.1
		 * 
		 * @return Sizing alignment
		 */
		public Gtk.Alignment get_label_sizing_alignment()
		{
			return (label_contents_alignment);
		}

		/**
		 * Returns alignment that can be used to size value widgets
		 * 
		 * @since 0.1
		 * 
		 * @return Sizing alignment
		 */
		public Gtk.Alignment get_value_sizing_alignment()
		{
			return (value_alignment);
		}

		/**
		 * Returns alignment that can be used to tool actions
		 * 
		 * @since 0.1
		 * 
		 * @return Sizing alignment
		 */
		public Gtk.Alignment get_tools_sizing_alignment()
		{
			return (tool_alignment);
		}

		/**
		 * Creates new AutoContainerRow with specified control object
		 * 
		 * @since 0.1
		 */
		public AutoContainerRow (AutoContainerControl control)
		{
			this._control = control;
			if (_control != null) {
				_auto_binder().bind (_control, "orientation", main_box, "orientation", BindFlags.SYNC_CREATE);
				_auto_binder().bind (_control, "show-tools", tool_alignment, "visible", BindFlags.SYNC_CREATE);
				_auto_binder().bind (_control, "show-labels", label_contents_alignment, "visible", BindFlags.SYNC_CREATE);
				_auto_binder().bind (_control, "label-opacity", label_alignment, "opacity", BindFlags.SYNC_CREATE);
				_auto_binder().bind (_control, "label-halignment", label_alignment, "halign", BindFlags.SYNC_CREATE);
				_auto_binder().bind (_control, "label-halignment", label_alignment, "halign", BindFlags.SYNC_CREATE);
				_auto_binder().bind (this, "tooltip-text", this, "tooltip", BindFlags.SYNC_CREATE);
				_control.notify["show-tootips"].connect (() => { notify_property("tooltip-text"); });
				_control.notify["labels-use-markup"].connect (() => { notify_property("label"); });
			}
			this.notify["tootip-text"].connect (() => { set_tooltip(); });
		}
	}
}
