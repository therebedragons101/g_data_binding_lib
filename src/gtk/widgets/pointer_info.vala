using GData;
using GData.Generics;

namespace GDataGtk
{
	public const string POINTER_ICON = "document-revert-symbolic-rtl.symbolic";
	public const string CONTRACT_ICON = "open-menu-symbolic.symbolic";
	public const string LINK_ICON = "/org/gtk/g_data_binding_gtk/data/chain-link-16.png";
	public const string RELAY_ICON = "/org/gtk/g_data_binding_gtk/data/chain-relay-16.png";

	/**
	 * Custom widget to display pointer information for chain display
	 * 
	 * @since 0.1
	 */
	[GtkTemplate (ui="/org/gtk/g_data_binding_gtk/data/pointer_info.ui")]
	public class PointerInfo : Gtk.Box
	{
		private string _title_css = """
			* {
				border: solid 2px gray;
				border-bottom-style: none;
				padding: 2px 2px 2px 2px;
				border-radius: 5px 5px 0px 0px;
				color: rgba (255,255,255,0.9);
				background-color: rgba(0,0,0,1.0);
			}
		""";

		private string _description_css = """
			* {
				border: solid 2px gray;
				border-top-style: none;
				padding: 2px 2px 2px 2px;
				border-radius: 0px 0px 5px 5px;
				color: rgba (255,255,255,0.7);
				background-color: rgba(25,25,25,1.0);
			}
		""";

		private string _item_css = """
			* {
				border: solid 2px gray;
				border-top-style: none;
				padding: 2px 2px 2px 2px;
				border-radius: 0px 0px 5px 5px;
				color: rgba (255,255,255,0.7);
				background-color: rgba(40,40,40,1.0);
			}
		""";

		private string _state_css = """
			* {
				border: solid 2px gray;
				border-top-style: none;
				padding: 2px 2px 2px 2px;
				border-radius: 0px 0px 5px 5px;
				color: rgba (255,255,255,0.7);
				background-color: rgba(60,60,60,1.0);
			}
		""";

		private string _value_css = """
			* {
				border: solid 2px gray;
				border-top-style: none;
				padding: 2px 2px 2px 2px;
				border-radius: 0px 0px 5px 5px;
				color: rgba (255,255,255,0.7);
				background-color: rgba(80,80,80,1.0);
			}
		""";
//				background-color: rgba(0,0,0,1.0);

		private StrictWeakReference<BindingPointer?> _pointer;
		/**
		 * Pointer being displayed
		 * 
		 * @since 0.1
		 */
		public BindingPointer? pointer {
			get { return (_pointer.target); }
			set { 
				if (_pointer.target == value)
					return;
				if (_pointer.is_valid_ref() == true) {
					if (is_binding_contract(pointer) == true)
						as_contract(pointer).bindings_changed.disconnect (reset_display);
					pointer.source_changed.disconnect (reset_display);
					pointer.notify["data"].disconnect (reset_display);
				}
				_pointer.set_new_target (value);
				if (_pointer.is_valid_ref() == true) {
					if (is_binding_contract(pointer) == true)
						as_contract(pointer).bindings_changed.connect (reset_display);
					pointer.source_changed.connect (reset_display);
					pointer.notify["data"].connect (reset_display);
				}
				reset_display();
				reset_link_icon();
				reset_opacity();
			}
		}

		private StrictWeakReference<BindingPointer?> _selection_check;
		public BindingPointer? selection_check {
			get { return (_selection_check.target); }
			set { 
				if (_selection_check.target == value)
					return;
				if (_selection_check.is_valid_ref() == true) {
					selection_check.notify["data"].disconnect (reset_opacity);
				}
				_selection_check.set_new_target (value);
				if (_selection_check.is_valid_ref() == true) {
					selection_check.notify["data"].connect (reset_opacity);
				}
				reset_opacity();
			}
		}

		/**
		 * Controls display of pointer selection in chain
		 * 
		 * @since 0.1
		 */
		public bool is_selected {
			get {
				if ((_pointer.is_valid_ref() == false) || (_selection_check.is_valid_ref() == false))
					return (false);
				return (_pointer.target == selection_check.data);
			}
		}

		[GtkChild] private Gtk.EventBox event_box;
		[GtkChild] private Gtk.Box widget_box;
		[GtkChild] private Gtk.Box title_padding_box;
		[GtkChild] private Gtk.Box description_padding_box;
		[GtkChild] private Gtk.Box item_padding_box;
		[GtkChild] private Gtk.Box value_padding_box;
		[GtkChild] private Gtk.Box state_padding_box;
		[GtkChild] private Gtk.Image icon;
		[GtkChild] private Gtk.Label title;
		[GtkChild] private Gtk.Label description;
		[GtkChild] private Gtk.Label items;
		[GtkChild] private Gtk.Label values;
		[GtkChild] private Gtk.Label states;
		[GtkChild] private Gtk.Image chain_link_type;

		private void reset_link_icon()
		{
			if (_pointer.is_valid_ref() == false)
				return;
				
			string ricon = LINK_ICON;
			if (is_binding_pointer(pointer.data) == true)
				if (as_pointer(pointer.data).is_relay == true)
					ricon = RELAY_ICON;
			chain_link_type.pixbuf = new Gdk.Pixbuf.from_resource (ricon);
			chain_link_type.opacity = 0.5f;
		}

		private void reset_opacity()
		{
			opacity = (is_selected == true) ? 1.0f : 0.5f;
		}

		private string section_title (string str)
		{
			return (bold(color("chocolate", underline("%s\n".printf(str)))));
		}

		private void reset_display()
		{
			if (pointer == null) {
				title.set_markup(__null());
				description.set_markup(__null());
				chain_link_type.visible = false;
				return;
			}
			Object? dest = pointer.data;
			bool b = false;
			if (pointer.is_relay == true)
				dest = pointer.redirect_to (ref b);
			title.set_markup(fix_markup2(bold(_get_object_str_desc(pointer))));
			string desc = small("UID: @<b>%i</b>".printf(pointer.id));
			string? ns = _get_pointer_namespace(pointer);
			chain_link_type.visible = (is_binding_pointer(dest) == true);
			if (ns != null)
				desc = "%s\nStored as: %s".printf (desc, bold(ns));
			if (is_binding_pointer(dest) == false) {
				string dsc = "";
				if (dest != null)
					dsc = "Type: typeof(%s)\nReference: %s"
						.printf (bold(pointer.get_type().name()), bold(_get_object_str (dest)));
				else
					dsc = bold("Reference: %s".printf(__null()));
				desc = "%s\n%s".printf (desc, dsc);
			}
			description.set_markup (small(desc));
			// safe cast
			BindingContract? c = as_contract(pointer);
			string _items_ = "";
			if (is_binding_contract(pointer) == true) {
				// properties
				for (int i=0; i<c.length; i++)
					_items_ = "%s%s%s".printf(_items_, (_items_ == "") ? "" : "\n", c.get_item_at_index(i).as_str(true));
				items.set_markup (small("%s%s".printf(section_title("PROPERTIES"), _items_)));
			}
			item_padding_box.visible = !((is_binding_contract(pointer) == false) || (_items_ == ""));
			// value objects
			_items_ = "";
			if (is_binding_contract(pointer) == true) {
				GObjectArray? sarr = c.get_data<GObjectArray> (BINDING_SOURCE_STATE_DATA);
				if (sarr != null)
					for (int i=0; i<sarr.length; i++)
						_items_ = "%s%s%s".printf(_items_, (_items_ == "") ? "" : "\n", bold("\"%s\"").printf(as_state_object(sarr.data[i]).name));
				states.set_markup (small("%s%s".printf(section_title("STATE OBJECTS"), _items_)));
			}
			value_padding_box.visible = !((is_binding_contract(pointer) == false) || (_items_ == ""));
			// state objects
			_items_ = "";
			if (is_binding_contract(pointer) == true) {
				GObjectArray? varr = c.get_data<GObjectArray> (BINDING_SOURCE_VALUE_DATA);
				if (varr != null)
					for (int i=0; i<varr.length; i++)
						_items_ = "%s%s%s".printf(_items_, (_items_ == "") ? "" : "\n", bold("\"%s\"").printf(as_binding_object(varr.data[i]).name));
				values.set_markup (small("%s%s".printf(section_title("VALUE OBJECTS"), _items_)));
			}
			state_padding_box.visible = !((is_binding_contract(pointer) == false) || (_items_ == ""));
		}

		private void handle_pointer_invalid()
		{
			reset_display();
		}

		private void handle_selection_check_invalid()
		{
			reset_opacity();
		}

		/**
		 * Returns array of linear chain elements based on new pointer and 
		 * checks if currently displayed chain already contains new element in
		 * order to avoid refresh
		 * 
		 * @since 0.1
		 * 
		 * @param selection_check Pointer being checked
		 * @param pointer Pointer whose chain needs to be built
		 */
		public static PointerInfo[]? get_linear_chain (BindingPointer selection_check, BindingPointer? pointer)
		{
			if (pointer == null)
				return (new PointerInfo[0]);
			GLib.Array<WeakReference<BindingPointer>> arr = new GLib.Array<WeakReference<BindingPointer>>();
			arr.append_val (new WeakReference<BindingPointer>(pointer));
			Object? obj;
			if (pointer.is_relay == true) {
				if (is_binding_pointer(pointer.data) == true)
					arr.append_val (new WeakReference<BindingPointer>(as_pointer(pointer.data)));
				obj = pointer.get_source();
			}
			else
				obj = pointer.data;
			bool b = false;
			while (is_binding_pointer(obj) == true) {
				arr.append_val (new WeakReference<BindingPointer>(as_pointer(obj)));
				if (as_pointer(obj).is_relay == true) {
					if (is_binding_pointer(pointer.data) == true)
						arr.append_val (new WeakReference<BindingPointer>(as_pointer(pointer.data)));
					obj = as_pointer(obj).redirect_to(ref b);
				}
				else
					obj = as_pointer(obj).data;
			}
			//TODO, add pre-chain until linear
			PointerInfo[] res = new PointerInfo[arr.length];
			for (int i=0; i<arr.length; i++)
				res[i] = new PointerInfo (selection_check, arr.data[i].target);
			return (res);
		}

		/**
		 * Emited when mouse selection occurs
		 * 
		 * @since 0.1
		 * 
		 * @param pointer BindingPointer being selected
		 */
		public signal void selected (BindingPointer? pointer);

		/**
		 * Pointer chain display widget
		 * 
		 * @since 0.1
		 * 
		 * @param selection_check Existance check to avoid rebuilding of chain
		 * @param pointer Pointer being displayed
		 */
		public PointerInfo(BindingPointer selection_check, BindingPointer pointer)
		{
			_pointer = new StrictWeakReference<BindingPointer?> (null, handle_pointer_invalid);
			_selection_check = new StrictWeakReference<BindingPointer?> (null, handle_selection_check_invalid);
			this.selection_check = selection_check;
			this.pointer = pointer;
			assign_css (title_padding_box, _title_css);
			assign_css (description_padding_box, _description_css);
			assign_css (item_padding_box, _item_css);
			assign_css (value_padding_box, _value_css);
			assign_css (state_padding_box, _state_css);
			assign_image_from_icon (icon, ((is_binding_contract(pointer) == true) ? CONTRACT_ICON : POINTER_ICON), 
				null, null, __get_icon_size(Gtk.IconSize.SMALL_TOOLBAR), false);
			event_box.button_press_event.connect ((e) => {
				selection_check.data = pointer;
				return (false);
			});
		}
	}
}
