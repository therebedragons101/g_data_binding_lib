using GData;

namespace GDataGtk
{
	/**
	 * Provides easy mapping with composite widgets or layouts loaded from Glade
	 * In case of this mapper target should be parent container or composite
	 * widget which contains widgets specifying correct Gtk.Buildable names
	 * (ID in Glade)
	 * 
	 * @since 0.1
	 */
	public class GtkBuildableMapper : Object, BinderMapper
	{
		/**
		 * Mapper will connect on either composite widget property or default
		 * value property on widget with buildable name that is the same as
		 * property with prefix/suffix pattern
		 * 
		 * This specifies order or resolving in case of clash between buildable
		 * internal widget name and composite widgets property
		 * 
		 * @since 0.1
		 */
		public bool widgets_first { get; set; default = true; }

		/**
		 * Specifies if for some reason property binding to layout owner is
		 * disabled or not. By default property binding is enabled.
		 * 
		 * @since 0.1
		 */
		public bool property_binding_disabled { get; set; default = false; }

		/**
		 * Binder object that instigated this interface
		 * 
		 * @since 0.1
		 */
		public Binder binder_object { get; set; }

		private Gtk.Widget? _find_widget (Gtk.Widget widget, string widget_buildable_name, Gtk.Widget? cache_result)
		{
			if (cache_result != null)
				return (cache_result);
			if (widget.get_type().is_a(typeof(Gtk.Buildable)) == true)
				if (((Gtk.Buildable) widget).get_name() == widget_buildable_name)
					return (widget);
			Gtk.Widget? res = null;
			if (widget.get_type().is_a(typeof(Gtk.Container)) == true)
				((Gtk.Container) widget).foreach ((w) => {
					Gtk.Widget? ww = _find_widget (w, widget_buildable_name, res);
					res = (res == null) ? ww : res;
				});
			return (res);
		}

		private Object? _get_target_widget (Object? widget, string property)
		{
			if ((widget == null) || (property != ALIAS_DEFAULT))
				return (widget);
			if (widget.get_type().is_a(typeof(BindableCompositeWidget)) == true)
				return (((BindableCompositeWidget) widget).get_bindable_widget());
			return (widget);
		}

		private string _get_target_property (Object? widget, string property)
		{
			if (property != ALIAS_DEFAULT)
				return (property);
			if (widget.get_type().is_a(typeof(BindableCompositeWidget)) == true) {
				string? nm = ((BindableCompositeWidget) widget).get_value_binding_property();
				return ((nm != null) ? nm : property);
			}
			return (property);
		}

		private static BindingDataTransfer[] resolve_layout (Object? source, string[] properties)
		{
			if (source == null)
				return (new BindingDataTransfer[0]);
			string[] layout;
			if (properties.length == 0)
				layout = TypeInformation.get_instance().get_all_type_property_names (source.get_type());
			else {
				layout = new string[properties.length];
				for (int i=0; i<properties.length; i++)
					layout[i] = properties[i];
			}
			BindingDataTransfer[] res = new BindingDataTransfer[0];
			if (layout.length == 0)
				return (res);
			for (int i=0; i<layout.length; i++) {
				BindingDataTransfer iface = BindingDefaults.get_instance().get_transfer_object_for (source, layout[i], false);
				if (iface.is_valid == true) {
					res.resize (res.length+1);
					res[res.length-1] = iface;
				}
			}
			return (res);
		}

		/**
		 * Maps only specific properties or sublayouts from source to target. In
		 * case of this mapper target should be parent container or composite
		 * widget which contains widgets specifying correct Gtk.Buildable names
		 * (ID in Glade)
		 * 
		 * @since 0.1
		 * 
		 * @param source Source object
		 * @param target Target object
		 * @param properties Names of properties or layouts that need to
		 *                   be binded
		 * @param common_target_property_alias Common target property alias
		 * @param flags Binding flags
		 * @param prefix Prefix for widget names during discovery
		 * @param suffix Suffix for widget names during discovery
		 * @return Array of created bindings
		 */
		public BindingInterface[] map_properties (Object? source, Object? target, string[] properties, string common_target_property_alias,
		                                          BindFlags flags=BindFlags.SYNC_CREATE, string prefix = "", string suffix = "")
		{
			BindingInterface[] res = new BindingInterface[0];
			if ((source == null) || (target == null))
				return (res);
			if (target.get_type().is_a(typeof(Gtk.Widget)) == false) {
				GLib.warning ("GtkBuildableMapper called with target(%s) that is not Gtk.Widget ", target.get_type().name());
				return (res);
			}
			BindingDataTransfer[] trs = resolve_layout (source, properties);
			Gtk.Widget parent = (Gtk.Widget) target;
			for (int i=0; i<trs.length; i++) {
				BindingInterface? iface = null;
				BindingDataTransfer? trt = null;
				ParamSpec? parm;
				if ((widgets_first == false) && (property_binding_disabled == false)) {
					trt = BindingDefaults.get_instance().get_transfer_object_for (target, trs[i].property_name, false);
					if ((trt != null) && (trt.is_valid == true))
						iface = bind_transfers (trs[i], trt, flags);
				}
				if (iface == null) {
					Gtk.Widget? w = _find_widget(parent, prefix + trs[i].property_name + suffix, null);
					if (w != null) {
						trt = BindingDefaults.get_instance().get_transfer_object_for (_get_target_widget(w, common_target_property_alias), _get_target_property (w, common_target_property_alias), false);
						if ((trt != null) && (trt.is_valid == true))
							iface = bind_transfers (trs[i], trt, flags);
					}
				}
				if ((widgets_first == true) && (iface == null) && (property_binding_disabled == false)) {
					trt = BindingDefaults.get_instance().get_transfer_object_for (target, trs[i].property_name, false);
					if ((trt != null) && (trt.is_valid == true))
						iface = bind_transfers (trs[i], trt, flags);
				}
				if (iface != null) {
					res.resize(res.length+1);
					res[res.length-1] = iface;
				}
			}
			return (res);
		}

		public BindingInterface[] map_single (Object? source, string source_property, Object? target, string[] layout,
		                                      string common_target_property_alias, BindFlags flags=BindFlags.SYNC_CREATE,
		                                      string prefix = "", string suffix = "", owned PropertyBindingTransformFunc? transform_to = null, 
		                                      owned PropertyBindingTransformFunc? transform_from = null)
		{
			BindingInterface[] res = new BindingInterface[0];
			if ((source == null) || (target == null) || (layout.length == 0))
				return (res);
			if (target.get_type().is_a(typeof(Gtk.Widget)) == false) {
				GLib.warning ("GtkBuildableMapper called with target(%s) that is not Gtk.Widget ", target.get_type().name());
				return (res);
			}
			BindingDataTransfer? trs = BindingDefaults.get_instance().get_transfer_object_for (source, source_property, false);
			if ((trs == null) || (trs.is_valid == false))
				return (res);
			Gtk.Widget parent = (Gtk.Widget) target;
			for (int i=0; i<layout.length; i++) {
				BindingDataTransfer? trt = null;
				BindingInterface? iface = null;
				Gtk.Widget? w = _find_widget(parent, prefix + layout[i] + suffix, null);
				if (w != null) {
					trt = BindingDefaults.get_instance().get_transfer_object_for (_get_target_widget(w, common_target_property_alias), _get_target_property (w, common_target_property_alias), false);
					if ((trt != null) && (trt.is_valid == true))
						iface = bind_transfers (trs, trt, flags, transform_to, transform_from);
				}
				if (iface != null) {
					res.resize(res.length+1);
					res[res.length-1] = iface;
				}
			}
			return (res);
		}
	}
}

