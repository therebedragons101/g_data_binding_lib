[CCode (cheader_filename = "glib.h", cprefix = "G", gir_namespace = "GObject", gir_version = "2.0", lower_case_cprefix = "g_")]
namespace GLib
{
	[CCode (has_target = false)]
	public delegate void GObjectGetPropertyFunc (Object object, uint property_id, GLib.Value value, GLib.ParamSpec pspec)
	[CCode (has_target = false)]
	public delegate void GObjectSetPropertyFunc (Object object, uint property_id, Value value, ParamSpec pspec);
	[CCode (has_target = false)]
	public delegate void ObjectConstructorDelegate (GLib.Type type, uint n_construct_properties, ref GObjectConstructParam[] construct_properties);
	[CCode (has_target = false)]
	public delegate void ObjectDisposeFunc (Object object);
	[CCode (has_target = false)]
	public delegate void ObjectFinalizeFunc (Object object);
	[CCode (has_target = false)]
	public delegate void DispatchPropertiesChangedFunc (Object object, uint n_pspecs, ref ParamSpec[] pspecs);
	[CCode (has_target = false)]
	public delegate void NotifyFunc (Object object, ParamSpec pspec);
	[CCode (has_target = false)]
	public delegate void Constructed (Object object);

	public struct GObjectConstructParam
	{
		ParamSpec pspec;
		GLib.Value value;
	}

	[CCode (lower_case_csuffix = "object_class")]
	public class FullObjectClass : GLib.TypeClass {
		public GObjectConstructorDelegate constructor;
		public GObjectSetPropertyFunc set_property;
		public GObjectGetPropertyFunc get_property;
		public GObjectDisposeFunc dispose;
		public GObjectFinalizeFunc finalize;
		public GDispatchPropertiesChangedFunc dispatch_properties_changed;
		public GNotifyFunc notify;
		public GConstructed constructed;
		//void g_object_class_install_properties ()
		public void install_property (uint property_id, GLib.ParamSpec pspec);
		//GParamSpec * g_object_class_find_property ()
		public unowned GLib.ParamSpec? find_property (string property_name);
		//GParamSpec ** g_object_class_list_properties ()
		[CCode (array_length_type = "guint")]
#if VALA_0_26
		public (unowned GLib.ParamSpec)[] list_properties ();
#else
		public unowned GLib.ParamSpec[] list_properties ();
#endif
		//void g_object_class_override_property ()
		public void override_property (uint property_id, GLib.ParamSpec pspec);
		//void g_object_interface_install_property ()
		public void interface_install_property (uint property_id, GLib.ParamSpec pspec);
		//GParamSpec * g_object_interface_find_property ()
		public unowned GLib.ParamSpec? interface_find_property (string property_name);
		//GParamSpec ** g_object_interface_list_properties ()
		[CCode (array_length_type = "guint")]
#if VALA_0_26
		public (unowned GLib.ParamSpec)[] interface_list_properties ();
#else
		public unowned GLib.ParamSpec[] interface_list_properties ();
#endif
	}
}
