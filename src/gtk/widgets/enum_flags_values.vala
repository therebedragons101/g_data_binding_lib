using GData;
using GData.Generics;

namespace GDataGtk
{
	/**
	 * This enum is treated same as null value for EnumFlagsValues
	 * 
	 * @since 0.1
	 */
	public enum UnspecifiedEnumType
	{
		/**
		 * Only value in UnspecifiedEnumType
		 * 
		 * @since 0.1
		 */
		UNSPECIFIED
	}

	/**
	 * Provides editable items for EnumClass or FlagsClass in list box as 
	 * a method of controlling the value.
	 * 
	 * Since value is int or uint, it is expected to be used as part of 
	 * something else
	 * 
	 * @since 0.1
	 */
	[GtkTemplate (ui="/org/gtk/g_data_binding_gtk/data/enum_flags_values.ui")]
	public class EnumFlagsValues : Gtk.Box, EnumFlagsValueInterface
	{
		private bool assigning = false;
		private bool toggle_assigning = false;

		[GtkChild] private Gtk.ScrolledWindow scrolled_window;
		[GtkChild] private Gtk.ListBox list_box;

		private Type? _model_type = null;
		/**
		 * Enum or Flags type being handled
		 * 
		 * @since 0.1
		 */
		public Type? model_type {
			get { return (_model_type); }
			private set {
				_model_type = value;
				if (_model_type == null)
					bind_type (typeof(UnspecifiedEnumType));
				else
					bind_type (_model_type); 
			}
		}

		private int _int_value = 0;
		/**
		 * int representation of flags or enum value
		 * 
		 * @since 0.1
		 */
		public int int_value {
			get { return (_int_value); }
			set {
				if ((assigning == true) || (_int_value == value))
					return;
				assigning = true;
				_int_value = value;
				assigning = false;
			}
		}

		/**
		 * uint representation of flags or enum value
		 * 
		 * @since 0.1
		 */
		public uint uint_value {
			get { return ((uint) _int_value); }
			set { 
				int_value = (int) value;
				// Return in order to avoid double notification
				return;
			}
		}

		private string convert_to_type_name (string str)
		{
			string res = "";
			for (int i=0; i<str.length; i++) {
				string p = str.substring(i, 1);
				if ((res != "") && (p == p.up()) && ((res.length > 1) &&(res.substring(res.length-2,1) != "_")))
					res += "_" + p;
				else
					res += p.up();
			}
			return (res + "_");
		}

		/**
		 * Binds specific type to internal listbox and assigns correct state of
		 * internal items
		 * 
		 * @since 0.1
		 * 
		 * @param type Enum or Flags type being displayed
		 */
		protected virtual void bind_type (Type type)
		{
			EnumFlagsModel model = new EnumFlagsModel (type);
			list_box.bind_model (model, (o) => {
				EnumFlagsValueObject obj = (EnumFlagsValueObject) o;
				Gtk.ListBoxRow row = new Gtk.ListBoxRow();
				row.set_data<int> ("item-value", obj.value);
				Gtk.CheckButton check = new Gtk.CheckButton.with_label (obj.name.replace(convert_to_type_name(type.name()), ""));
				check.set_data<int> ("item-value", obj.value);
				row.set_data<StrictWeakReference<Gtk.CheckButton?>> ("check", new StrictWeakReference<Gtk.CheckButton?>(check));
				check.visible = true;
				bool skip_notification = false;
				notify["int-value"].connect (() => {
					skip_notification = true;
					if (model.is_flags == true)
						check.active = ((int_value & obj.value) == obj.value);
					else
						check.active = (int_value == obj.value);
					skip_notification = false;
				});
				check.toggled.connect (() => {
					if ((toggle_assigning == true) || (skip_notification == true))
						return;
					toggle_assigning = true;
					if (model.is_flags == true) {
						if (check.active == true)
							int_value = int_value | obj.value;
						else
							int_value = int_value & ~(obj.value);
					}
					else {
						// Prevent state where nothing is checked
						if (check.active == false)
							check.active = true;
						else
							int_value = obj.value;
					}
					toggle_assigning = false;
				});
				row.add (check);
				return (row);
			});
			list_box.row_activated.connect ((r) => {
				StrictWeakReference<Gtk.CheckButton?> check = r.get_data<StrictWeakReference<Gtk.CheckButton?>> ("check");
				if ((check != null) && (check.is_valid_ref() == true))
					check.target.active = !check.target.active;
			});
			notify_property ("int-value");
		}

		/**
		 * Creates new EnumFlagsValues
		 * 
		 * @since 0.1
		 * 
		 * @param type Enum or Flags value being displayed
		 * @param val Value being assigned initially
		 */
		public EnumFlagsValues(Type type = typeof(UnspecifiedEnumType), int val = 0)
		{
			this.notify["int-value"].connect (() => { notify_property ("uint-value"); });
			this.model_type = type;
			this.int_value = val;
		}
	}
}
