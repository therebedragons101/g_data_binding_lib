using GData;
using GData.Generics;

namespace GDataGtk
{
	private static Binder? inspector_binder = null;

	internal Binder? _binder()
	{
		if (inspector_binder == null)
			inspector_binder = new Binder.silent();
		return (inspector_binder);
	}

	internal void get_reference_markup (BindingPointer pointer, out string ptr_ref, out string data_ref, out string source_ref)
	{
		int p, d, s;
		get_reference_count (pointer, out p, out d, out s);
		ptr_ref = ((p == -1) ? _null() : bold("%i").printf(p));
		data_ref = ((d == -1) ? _null() : bold("%i").printf(d));
		source_ref = ((s == -1) ? _null() : bold("%i").printf(s));
	}

	internal void _get_reference_markup (StrictWeakRef pointer, out string ptr_ref, out string data_ref, out string source_ref)
	{
		int p, d, s;
		_get_reference_count (pointer, out p, out d, out s);
		ptr_ref = ((p == -1) ? _null() : bold("%i").printf(p));
		data_ref = ((d == -1) ? _null() : bold("%i").printf(d));
		source_ref = ((s == -1) ? _null() : bold("%i").printf(s));
	}

	internal string _get_type_str (Object? obj)
	{
		return ((obj == null) ? _null() : "%s(%s)".printf(RESERVED_WORD("typeof"), obj.get_type().name()));
	}

	internal string _get_stored_as (BindingPointer? pointer)
	{
		if (pointer == null)
			return (_null());
		string? stor = pointer.get_data<string?>("stored-as");
		if ((stor == null) || (stor == ""))
			return (INSENSITIVE("** NOT STORED **"));
		return (bold(stor));
	}

	internal string get_pointer_namespace (BindingPointer? pointer)
	{
		if (pointer == null)
			return ("");
		string? stor = pointer.get_data<string?>("stored-as");
		if ((stor == null) || (stor == ""))
			return ("@%i".printf(pointer.id));
		return ("%s @%i".printf(stor, pointer.id));
	}

	internal string? _get_pointer_namespace (BindingPointer? pointer)
	{
		if (pointer == null)
			return (null);
		string? stor = pointer.get_data<string?>("stored-as");
		if ((stor == null) || (stor == ""))
			return (null);
		return ("%s".printf(stor));
	}

	//TODO bad provisional implementation. only first or last should be replaced
	internal string get_pointer_namespace_markup (BindingPointer? pointer)
	{
		if (pointer == null)
			return ("");
		string? stor = pointer.get_data<string?>("stored-as");
		if ((stor == null) || (stor == ""))
			return ("@<b>%i</b>".printf(pointer.id));
		return ("%s @<b>%i</b>".printf(stor.replace("/", "/<b>") + "</b>", pointer.id));
	}

	internal string get_self_ref_equality (Object? obj1, Object? obj2)
	{
		return ((obj1 == obj2) ? "THIS" : "OTHER");
	}

	internal string bool_str (bool val)
	{
		return ((val == true) ? "TRUE" : "FALSE");
	}

	internal string bool_strc (bool val)
	{
		return ((val == true) ? ACTIVE_COLOR(bold("TRUE")) : INACTIVE_COLOR(bold("FALSE")));
	}

	internal static string get_info_str (Object? obj, bool markup = true)
	{
		return (((obj == null) || (obj.get_type().is_a(typeof(ObjectInformation)) == false)) ? "" : "\"%s\"".printf(((ObjectInformation) obj).get_info()));
	}

	internal static string get_description_str (Object? obj, bool markup = true)
	{
		if ((obj != null) && 
		    (obj.get_type().is_a(typeof(HasDescription)) == false) && 
		    (obj.get_type().is_a(typeof(Gtk.Buildable)) == true))
			return (((Gtk.Buildable) obj).get_name());
		return (((obj == null) || (obj.get_type().is_a(typeof(HasDescription)) == false)) ? "" : bold("%s", markup).printf(((HasDescription) obj).description));
	}

	internal static string get_object_type (Object? obj, bool markup = true)
	{
		return ((obj == null) ? __null(markup) : get_type_str(obj.get_type()));
	}

	internal static string get_type_str (Type? type, bool markup = true)
	{
		return ((type == null) ? __null(markup) : "%s".printf(bold(TYPE_COLOR(type.name(), markup), markup)));
	}

	internal static string get_object_str (Object? obj, bool markup = true)
	{
		if (obj == null)
			return (__null(markup));
		string s = get_description_str(obj, markup);
		if (s != "")
			return (s);
		if (is_object_information(obj) == true)
			return (get_info_str((ObjectInformation) obj));
		return ((obj == null) ? _null() : "[%s]".printf(TYPE_COLOR(obj.get_type().name(), markup)));
	}

	internal static string _get_object_str (Object? obj, bool markup = true)
	{
		string s = get_description_str(obj, markup);
		if (s != "")
			return (s);
		if (is_object_information(obj) == true)
			return (get_info_str((ObjectInformation) obj));
		return (get_object_type(obj, markup));
	}

	internal static string _get_object_str_desc (Object? obj, bool markup = true)
	{
		string d = "";
		string i = "";
		d = get_description_str(obj, false);
		if (is_object_information(obj) == true) {
			i = get_info_str((ObjectInformation) obj);
			return ("%s%s".printf((d != "") ? (bold(d, markup) + "\n") : "", i));
		}
		if (d != "")
			return (bold(d, markup));
		return ((obj == null) ? _null(markup) : "%s".printf(TYPE_COLOR(obj.get_type().name(), markup)));
	}

	internal static string _get_full_object_str_desc (Object? obj, bool markup = true)
	{
		string d = "";
		string i = "";
		d = get_description_str(obj, false);
		if (is_object_information(obj) == true)
			i = get_info_str((ObjectInformation) obj);
		string t = ((obj == null) ? _null(markup) : "%s".printf(TYPE_COLOR(obj.get_type().name(), markup)));
		string res = "%s%s%s".printf (
			(d != "") ? ((bold(d, markup)) + "\n") : "",
			(i != "") ? (bold(i) + "\n") : "",
			t
		);
		return (res);
	}

	internal static string get_pointer_info_str (BindingPointer? obj)
	{
		return ((obj == null) ? _null() : "%s→\"%s\"".printf(TYPE_COLOR(obj.get_type().name()), (obj.data != null) ? obj.data.get_type().name() : _null()));
	}

	internal string get_current_source (Object? obj)
	{
		return ("\n\t\t%s".printf(_get_current_source(obj)));
	}

	internal string _get_current_source (Object? obj)
	{
		return ("currently pointing → %s".printf (__get_current_source (obj)));
	}

	internal string __get_current_source (Object? obj)
	{
		if (is_binding_pointer(obj) == true)
			return ("%s".printf (get_pointer_info_str((BindingPointer?) obj)));
		else
			return ("%s".printf (get_object_str(obj)));
	}

	internal static int __get_icon_size (Gtk.IconSize size)
	{
		int x,y;
		Gtk.icon_size_lookup (size, out x, out y);
		return (x);
	}

	internal void bind_linear_source_chain (Gtk.ListBox listbox, BindingInspector? inspector = null, string property_name = "")
	{
		//TODO, model
		int cid = (inspector.current_data != null) ? inspector.current_data.id : -1;
		GLib.Array<Gtk.Widget> arr = new GLib.Array<Gtk.Widget>();
		bool found = false;
		listbox.@foreach ((w) => {
			arr.append_val (w);
			int? ri = w.get_data<int> ("pointer");
			if (ri == cid)
				found = true;
		});
		if (found == true)
			return;
		for (int i=0; i<arr.length; i++)
			listbox.remove (arr.data[i]);
		PointerInfo[] ptrs = PointerInfo.get_linear_chain (inspector.main_contract, inspector.current_data);
		for (int i=0; i<ptrs.length; i++) {
			Gtk.ListBoxRow r = new Gtk.ListBoxRow();
			r.set_data<int> ("pointer", ptrs[i].pointer.id);
			r.visible = true;
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			box.expand = true;
			box.visible = true;
			r.add (box);
			box.pack_start (ptrs[i], true, true, 0);
			ptrs[i].visible = true;
			listbox.add (r);
		}
	}

	internal void bind_event_listbox (Gtk.ListBox listbox, ObjectArray<EventDescription> events, BindingInspector? inspector = null, string property_name = "")
	{
		listbox.bind_model (events, ((o) => {
			Gtk.ListBoxRow r = new Gtk.ListBoxRow();
			r.visible = true;
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
			box.expand = true;
			box.visible = true;
			r.add (box);
			Gtk.Label title = new Gtk.Label("");
			title.visible = true;
			title.hexpand = true;
			title.xalign = 0;
			title.use_markup = true;
			title.set_markup(((EventDescription) o).title);
			Gtk.Label description = new Gtk.Label("");
			description.visible = true;
			description.use_markup = true;
			description.hexpand = true;
			description.xalign = 0;
			description.set_markup(((EventDescription) o).description);
			if (inspector != null)
				_binder().bind (inspector, property_name, description, "visible", BindFlags.SYNC_CREATE);
			box.pack_start (title, false, false, 0);
			box.pack_start (description, false, false, 0);
			return (r);
		}));
	}

	internal void bind_namespace_listbox (Gtk.ListBox listbox)
	{
		listbox.bind_model (PointerNamespace.get_instance(), ((o) => {
			Gtk.ListBoxRow r = new Gtk.ListBoxRow();
			BindingPointer obj = (BindingPointer) o;
			r.set_data<int> ("pointer", obj.id);
			r.set_data<string> ("name", get_pointer_namespace(obj));

			r.visible = true;
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
			box.expand = true;
			box.visible = true;
			r.add (box);
			Gtk.Image image = create_image_from_icon (((is_binding_contract(obj) == true) ? CONTRACT_ICON : POINTER_ICON), 
				null, null, __get_icon_size(Gtk.IconSize.SMALL_TOOLBAR), false);
			r.set_data<WeakReference<Gtk.Image?>> ("image", new WeakReference<Gtk.Image?>(image));
			image.visible = true;
			Gtk.Label title = new Gtk.Label("");
			title.visible = true;
			title.hexpand = true;
			title.xalign = 0;
			title.use_markup = true;
			title.set_markup(get_pointer_namespace_markup((BindingPointer) obj));
/*			Gtk.Label description = new Gtk.Label("");
			description.visible = true;
			description.use_markup = true;
			description.hexpand = true;
			description.xalign = 0;
			description.set_markup(((EventDescription) o).description);
			if (inspector != null)
				inspector.binder.bind (inspector, property_name, description, "visible", BindFlags.SYNC_CREATE);*/
			box.pack_start (image, false, false, 0);
			box.pack_start (title, true, true, 0);
//			box.pack_start (description, false, false, 0);
			return (r);
		}));
	}

	internal void bind_bindings_listbox (Gtk.ListBox listbox, BindingPointer? pointer, BindingInspector? inspector = null, string property_name = "")
	{
		if ((pointer == null) || (is_binding_contract(pointer) == false)) {
			listbox.bind_model (new ObjectArray<Object?>(), (o) => {
				return (new Gtk.ListBoxRow());
			});
			return;
		}
		listbox.bind_model (as_contract(pointer), ((o) => {
			Gtk.ListBoxRow r = new Gtk.ListBoxRow();
			BindingInformationInterface obj = (BindingInformationInterface) o;
			r.visible = true;
			r.set_data<WeakReference<BindingInformationInterface?>> ("binding", 
				new WeakReference<BindingInformationInterface?>(obj));
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
			box.expand = true;
			box.visible = true;
			r.add (box);
			Gtk.Image image = create_image_from_icon (((obj.activated == true) ? TRUE_ICON : FALSE_ICON), 
				null, null, __get_icon_size(Gtk.IconSize.SMALL_TOOLBAR), false);
			_binder().bind (obj, "activated", image, "pixbuf", BindFlags.SYNC_CREATE, 
				(binding, src, ref dest) => {
					assign_image_from_icon (image, (src.get_boolean() ? TRUE_ICON : FALSE_ICON), 
					                        null, null, __get_icon_size(Gtk.IconSize.SMALL_TOOLBAR), false);
					return (false);
				});
			r.set_data<WeakReference<Gtk.Image?>> ("image", 
				new WeakReference<Gtk.Image?>(image));
			image.visible = true;
			Gtk.Label title = new Gtk.Label("");
			title.visible = true;
			title.hexpand = true;
			title.xalign = 0;
			title.use_markup = true;
			title.set_markup(obj.as_short_str(true));
/*			Gtk.Label description = new Gtk.Label("");
			description.visible = true;
			description.use_markup = true;
			description.hexpand = true;
			description.xalign = 0;
			description.set_markup(((EventDescription) o).description);
			if (inspector != null)
				inspector.binder.bind (inspector, property_name, description, "visible", BindFlags.SYNC_CREATE);*/
			box.pack_start (image, false, false, 0);
			box.pack_start (title, true, true, 0);
//			box.pack_start (description, false, false, 0);
			return (r);
		}));
	}

	internal void bind_bindings_namespace_listbox (Gtk.ListBox listbox, BindingInspector? inspector = null, string property_name = "")
	{
		BindingNamespace.get_instance().clean_null();
		listbox.bind_model (BindingNamespace.get_instance(), ((o) => {
			Gtk.ListBoxRow r = new Gtk.ListBoxRow();
			WeakRefWrapper? wr = ((WeakRefWrapper?) o);
			r.visible = ((wr != null) && (wr.target != null));
			if (wr.target != null) {
				BindingInterface? obj = ((BindingInterface?) wr.target);
				r.visible = true;
				r.set_data<WeakReference<BindingInterface?>> ("binding", new WeakReference<BindingInterface?>(obj));
				Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
				box.expand = true;
				box.visible = true;
				r.add (box);
				Gtk.Label title = new Gtk.Label("");
				title.visible = true;
				title.hexpand = true;
				title.xalign = 0;
				title.use_markup = true;
				title.set_markup(obj.as_str(true));
				box.pack_start (title, true, true, 0);
			}
			return (r);
		}));
		BindingNamespace.get_instance().clean_null();
	}

	internal void bind_binding_object_listbox (Gtk.ListBox listbox, BindingPointer? pointer, bool is_value, BindingInspector? inspector = null, string property_name = "")
	{
		if ((pointer == null) || (is_binding_contract(pointer) == false)) {
			listbox.bind_model (new GObjectArray(), (o) => {
				return (new Gtk.ListBoxRow());
			});
			return;
		}
		GObjectArray? arr = null;
		if (is_value == true)
			arr = pointer.get_data<GObjectArray> (BINDING_SOURCE_VALUE_DATA);
		else
			arr = pointer.get_data<GObjectArray> (BINDING_SOURCE_STATE_DATA);
		if (arr == null)
			arr = new GObjectArray();
		listbox.bind_model (arr, ((o) => {
			Gtk.ListBoxRow r = new Gtk.ListBoxRow();
			r.visible = true;
			CustomPropertyNotificationBindingSource obj = (CustomPropertyNotificationBindingSource) o;
			r.set_data<WeakReference<Object?>> ("binding-object", new WeakReference<Object?>(obj));
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
			box.expand = true;
			box.visible = true;
			r.add (box);
			Gtk.Label title = new Gtk.Label("");
			title.visible = true;
			title.hexpand = true;
			title.xalign = 0;
			title.use_markup = true;
			title.set_markup(fix_markup2(small(italic("Name: ")) + bold("\"%s\"".printf(obj.name))));
			Gtk.Label description = new Gtk.Label("");
			description.visible = ((obj.description != null) && (obj.description != ""));
			description.use_markup = true;
			description.hexpand = true;
			description.xalign = 0;
			if (description.visible == true)
				description.set_markup(fix_markup2(small(italic("Description: ")) + italic(small(obj.description))));
			description.opacity = 0.6f;
			box.pack_start (title, true, true, 0);
			box.pack_start (description, true, true, 0);
			return (r);
		}));
	}

	private delegate string GetKeyValueString (Object obj);

	internal void bind_kv_listbox<MK, K, V> (Gtk.ListBox listbox, GLib.ListModel events, GetKeyValueString method, bool sublist)
	{
		listbox.bind_model ((GLib.ListModel) events, ((o) => {
			Gtk.ListBoxRow r = new Gtk.ListBoxRow();
			if (sublist == true)
				r.set_data<GLib.ListModel> ("sublist", ((KeyValuePair<MK, KeyValueArray<K, V>>) o).val);
			else {
				if (typeof(V).is_a(typeof(WeakReference)) == true) {
					WeakReference<BindingPointer> refs = (WeakReference<BindingPointer>) ((KeyValuePair<K,V>) o).val;
					if (is_binding_pointer(refs.target) == true)
						r.set_data<int>("pointer", refs.target.id);
				}
			}
			r.visible = true;
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
			box.expand = true;
			box.visible = true;
			r.add (box);
			Gtk.Label title = new Gtk.Label("");
			title.visible = true;
			title.hexpand = true;
			title.xalign = 0;
			title.use_markup = true;
			title.set_markup(method(o));
			box.pack_start (title, false, false, 0);
			return (r);
		}));
	}

	internal void on_master_selected<MK,K,V> (Gtk.ListBox list_box, Gtk.ListBox slave_list_box, GetKeyValueString method)
	{
		list_box.row_selected.connect ((row) => {
			bind_kv_listbox<MK, K, V>(
				slave_list_box,
				(row == null) ? new ObjectArray<Object>() : row.get_data<GLib.ListModel>("sublist"),
				method,
				false);
		});
	}
}

