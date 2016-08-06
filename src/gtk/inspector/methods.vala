using GData;
using GData.Generics;

namespace GDataGtk
{
	internal void get_reference_markup (BindingPointer pointer, out string ptr_ref, out string data_ref, out string source_ref)
	{
		int p, d, s;
		get_reference_count (pointer, out p, out d, out s);
		ptr_ref = ((p == -1) ? bold(red("null")) : bold("%i").printf(p));
		data_ref = ((d == -1) ? bold(red("null")) : bold("%i").printf(d));
		source_ref = ((s == -1) ? bold(red("null")) : bold("%i").printf(s));
	}

	internal void _get_reference_markup (StrictWeakRef pointer, out string ptr_ref, out string data_ref, out string source_ref)
	{
		int p, d, s;
		_get_reference_count (pointer, out p, out d, out s);
		ptr_ref = ((p == -1) ? bold(red("null")) : bold("%i").printf(p));
		data_ref = ((d == -1) ? bold(red("null")) : bold("%i").printf(d));
		source_ref = ((s == -1) ? bold(red("null")) : bold("%i").printf(s));
	}

	internal string fix_markup (string str)
	{
		return (str.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"));
	}

	internal string _get_type_str (Object? obj)
	{
		return ((obj == null) ? bold(red("null")) : "typeof(%s)".printf(obj.get_type().name()));
	}

	internal string _get_stored_as (BindingPointer? pointer)
	{
		if (pointer == null)
			return (red(bold("null")));
		string? stor = pointer.get_data<string?>("stored-as");
		if ((stor == null) || (stor == ""))
			return (green(bold("** NOT STORED **")));
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
		return ((val == true) ? green(bold("TRUE")) : red(bold("FALSE")));
	}
	
	/**
	 * Checks if object is BindingPointer or its subclass
	 * 
	 * @since 0.1
	 * @param obj Object being checked
	 * @return true if object is BindingPointer or subclass, false if not
	 */
	internal static bool is_object_information (Object? obj)
	{
		if (obj == null)
			return (false);
		return (obj.get_type().is_a(typeof(ObjectInformation)) == true);
	}

	internal static string get_info_str (ObjectInformation? obj)
	{
		return ((obj == null) ? _null() : "[%s]->\"%s\"".printf(green(obj.get_type().name()), obj.get_info()));
	}

	internal static string get_object_str (Object? obj)
	{
		if (is_object_information(obj) == true)
			return (get_info_str((ObjectInformation) obj));
		return ((obj == null) ? _null() : "[%s]".printf(green(obj.get_type().name())));
	}

	internal static string _get_object_str (Object? obj)
	{
		if (is_object_information(obj) == true)
			return (get_info_str((ObjectInformation) obj));
		return ((obj == null) ? "null" : "%s".printf(green(obj.get_type().name())));
	}

	internal static string get_pointer_info_str (BindingPointer? obj)
	{
		return ((obj == null) ? _null() : "[%s]->\"%s\"".printf(green(obj.get_type().name()), (obj.data != null) ? obj.data.get_type().name() : _null()));
	}

	internal static string _null()
	{
		return ("[%s]".printf(bold(red("null"))));
	}

	internal static string color (string color, string str)
	{
		return ("<span color='%s'>%s</span>".printf(color, str));
	}

	internal static string green (string str)
	{
		return (color ("green", str));
	}

	internal static string red (string str)
	{
		return (color ("red", str));
	}

	internal static string yellow (string str)
	{
		return (color ("yellow", str));
	}

	internal static string blue (string str)
	{
		return (color ("blue", str));
	}

	internal static string italic (string str)
	{
		return ("<i>%s</i>".printf(str));
	}

	internal static string bold (string str)
	{
		return ("<b>%s</b>".printf(str));
	}

	internal static string small (string str)
	{
		return ("<small>%s</small>".printf(str));
	}

	internal static string big (string str)
	{
		return ("<big>%s</big>".printf(str));
	}

	internal string get_current_source (Object? obj)
	{
		return ("\n\t\t%s".printf(_get_current_source(obj)));
	}

	internal string _get_current_source (Object? obj)
	{
		return ("currently pointing => %s".printf (__get_current_source (obj)));
	}

	internal string __get_current_source (Object? obj)
	{
		if (is_binding_pointer(obj) == true)
			return ("%s".printf (get_pointer_info_str((BindingPointer?) obj)));
		else
			return ("%s".printf (get_object_str(obj)));
	}

	internal void connect_binding_pointer_events (BindingPointer pointer, ObjectArray<EventDescription> events)
	{
		pointer.data_changed.connect ((binding, cookie) => {
			events.add (
				new EventDescription.as_signal (
					"data_changed", 
					"(binding=%s, data_change_cookie=%s)".printf (get_self_ref_equality(binding, pointer), cookie),
					yellow("\tSource object change notification. Note that this is event triggered from outside when BindingPointer is MANUAL\n") +
					"\t\tbinding (BindingPointer emiting the notification)\n" +
					"\t\tdata_change_cookie (description of data change as passed on by triggering event)" +
					get_current_source (binding.get_source())
				)
			);
		});
		pointer.before_source_change.connect ((binding, is_same, next) => {
			events.add (
				new EventDescription.as_signal (
					"before_source_change", 
					"(binding=%s, is_same=%i, next=%s)".printf (get_self_ref_equality(binding, pointer), (int) is_same, (next != null) ? get_object_str(next) : _null()),
					yellow("\tObject being pointed is about to change. In case if reference was not dropped it can still be accessed trough binding\n") +
					"\t\tbinding (BindingPointer emiting the notification)\n" +
					"\t\tis_same (specifies if type of next source being pointed to is the same)\n" +
					"\t\tnext (reference to next object being pointed to)" +
					get_current_source (binding.get_source())
				)
			);
		});
		pointer.source_changed.connect ((binding) => {
			events.add (
				new EventDescription.as_signal (
					"source_changed", 
					"(binding=%s)".printf(get_self_ref_equality(binding, pointer)),
					yellow("\tObject being pointed has changed.\n") +
					"\t\tbinding (BindingPointer emiting the notification)" +
					get_current_source (binding.get_source())
				)
			);
		});
		pointer.connect_notifications.connect ((obj) => {
			events.add (
				new EventDescription.as_signal (
					"connect_notifications", 
					"(obj = %s)".printf (__get_current_source (obj)),
					yellow("\tSignal to connect anything application needs connected beside basic requirements when data source changes.")
				)
			);
		});
		pointer.disconnect_notifications.connect ((obj) => {
			events.add (
				new EventDescription.as_signal (
					"disconnect_notifications", 
					"(obj = %s)".printf (__get_current_source (obj)),
					yellow("\tSignal to disconnect anything application needs connected beside basic requirements when data source changes.")
				)
			);
		});
		pointer.notify["data"].connect ((binding) => {
			events.add (
				new EventDescription.as_property (
					"data", 
					" = %s => %s".printf (__get_current_source (pointer.data), _get_current_source (pointer.get_source()))
				)
			);
		});
	}

	internal void connect_binding_contract_events (BindingContract contract, ObjectArray<EventDescription> events)
	{
		connect_binding_pointer_events (contract, events);

		contract.contract_changed.connect ((ccontract) => {
			events.add (
				new EventDescription.as_signal (
					"contract_changed", 
					"(contract=%s)".printf(get_self_ref_equality(ccontract, contract)),
					yellow("\tEmited when contract is disolved or renewed after source change.\n") +
					"\t\tcontract (BindingContract emiting the notification)" +
					get_current_source (contract.get_source())
				)
			);
		});
		contract.bindings_changed.connect ((ccontract, change_type, binding) => {
			events.add (
				new EventDescription.as_signal (
					"bindings_changed", 
					"(contract=%s, change_type=%s, binding)".printf(get_self_ref_equality(ccontract, contract), change_type.get_state_str()),
					yellow("\tEmited when bindings are changed by adding or removing.\n") +
					"\t\tcontract (BindingContract emiting the notification)\n" +
					"\t\tchange_type (binding ADDED or REMOVED)\n" +
					"\t\tbinding (BindingContract emiting the notification)" +
					get_current_source (contract.get_source())
				)
			);
		});
		contract.notify["is-valid"].connect ((c) => {
			events.add (
				new EventDescription.as_property (
					"is_valid", 
					" = %s".printf (bool_str(contract.is_valid == true))
				)
			);
		});
		contract.notify["length"].connect ((c) => {
			events.add (
				new EventDescription.as_property (
					"is_valid", 
					" = %i".printf ((int) contract.length)
				)
			);
		});
		contract.notify["suspended"].connect ((c) => {
			events.add (
				new EventDescription.as_property (
					"is_valid", 
					" = %s".printf (bool_str(contract.suspended == true))
				)
			);
		});
	}

	internal static int __get_icon_size (Gtk.IconSize size)
	{
		int x,y;
		Gtk.icon_size_lookup (size, out x, out y);
		return (x);
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
				inspector.binder.bind (inspector, property_name, description, "visible", BindFlags.SYNC_CREATE);
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
			r.set_data<WeakReference<Gtk.Image?>> ("image", 
				new WeakReference<Gtk.Image?>(image));
			image.visible = true;
			Gtk.Label title = new Gtk.Label("");
			title.visible = true;
			title.hexpand = true;
			title.xalign = 0;
			title.use_markup = true;
			string dir = obj.flags.get_direction_arrow();
			title.set_markup(
				"%s%s%s".printf (bold(fix_markup((obj).source_property)), dir, bold(fix_markup((obj).target_property))));
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

	private delegate string GetKeyValueString (Object obj);

	internal void bind_kv_listbox<MK, K, V> (Gtk.ListBox listbox, GLib.ListModel events, GetKeyValueString method, bool sublist)
	{
		listbox.bind_model ((GLib.ListModel) events, ((o) => {
			Gtk.ListBoxRow r = new Gtk.ListBoxRow();
			if (sublist == true)
				r.set_data<GLib.ListModel> ("sublist", ((KeyValuePair<MK, KeyValueArray<K, V>>) o).val);
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

