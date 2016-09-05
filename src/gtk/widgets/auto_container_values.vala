namespace GDataGtk
{
	private static Binder? __container_binder = null;
	internal static Binder _container_binder()
	{
		if (__container_binder == null)
			__container_binder = new Binder.silent();
		return (__container_binder);
	}

	/**
	 * Provides simplest modeled container that can be used to easily create
	 * and map ListBox rows
	 * 
	 * The main feature of this container is the fact that it is also
	 * implementing BinderMapper interface where there is a difference in the
	 * fact that it autocreates appropriate widgets on the fly and then binds
	 * them afterwards
	 * 
	 * @since 0.1
	 */
	[GtkTemplate(ui="/org/gtk/g_data_binding_gtk/data/auto_container_values.ui")]
	public class AutoContainerValues : Gtk.Alignment, BinderMapper
	{
		[GtkChild] Gtk.Box main_box;

		private Binder? _binder_object = null;
		/**
		 * Binder object that instigated this interface
		 * 
		 * @since 0.1
		 */
		public Binder binder_object {
			get {
				if (_binder_object == null)
					return (_container_binder());
				return (_binder_object);
			}
			set { _binder_object = value; }
		}

		/**
		 * Specifies orientation of values
		 * 
		 * @since 0.1
		 */
		public Gtk.Orientation orientation {
			get { return (main_box.orientation); }
			set { main_box.orientation = value; }
		}

		/**
		 * Specifies spacing between values
		 * 
		 * @since 0.1
		 */
		public uint spacing {
			get { return (main_box.spacing); }
			set { main_box.spacing = value; }
		}

		/**
		 * Returns content container
		 * 
		 * @since 0.1
		 * 
		 * @return Content container
		 */
		public Gtk.Box get_content_container()
		{
			return (main_box);
		}

		/**
		 * Maps only specific properties or sublayouts from source to target
		 * 
		 * @since 0.1
		 * 
		 * @param source Source object
		 * @param target Target object
		 * @param layout Names of properties or layouts that need to be binded
		 * @param common_target_property_alias Common target property alias
		 * @param flags Binding flags
		 * @param prefix Prefix for widget names during discovery
		 * @param suffix Suffix for widget names during discovery
		 * @return Array of created bindings
		 */
		public BindingInterface[] map_properties (Object? source, Object? target, string[] layout, string common_target_property_alias,
		                                          BindFlags flags=BindFlags.SYNC_CREATE, string prefix = "", string suffix = "")
		{
			BindingInterface[] res = new BindingInterface[0];
			return (res);
		}

		public BindingInterface[] map_single (Object? source, string source_property, Object? target, string[] layout,
		                                      string common_target_property_alias, BindFlags flags=BindFlags.SYNC_CREATE,
		                                      string prefix = "", string suffix = "", owned PropertyBindingTransformFunc? transform_to = null, 
		                                      owned PropertyBindingTransformFunc? transform_from = null)
		{
			BindingInterface[] res = new BindingInterface[0];
			return (res);
		}

		/**
		 * Specifies internal content margins
		 * 
		 * @since 0.1
		 * 
		 * @param left Left margin
		 * @param top Top margin
		 * @param right Right margin
		 * @param bottom Bottom margin
		 */
		public void set_content_margins (int left, int top, int right, int bottom)
		{
			main_box.margin_left = left;
			main_box.margin_right = right;
			main_box.margin_top = top;
			main_box.margin_bottom = bottom;
		}

		public AutoContainerValues (Gtk.Orientation orientation = Gtk.Orientation.HORIZONTAL, uint spacing = 8)
		{
			this.orientation = orientation;
			this.spacing = spacing;
		}
	}
}

