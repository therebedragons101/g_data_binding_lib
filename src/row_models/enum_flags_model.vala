namespace GData
{
	public class EnumFlagsModel : Object, GLib.ListModel
	{
		private GLib.Array<EnumFlagsValueObject> _values = new GLib.Array<EnumFlagsValueObject>();

		private bool _is_flags = false;
		public bool is_flags {
			get { return (_is_flags); }
		}

		public Object? get_item (uint position)
		{
			return (_values.data[position]);
		}

		public Type get_item_type ()
		{
			return (typeof(EnumFlagsValueObject));
		}

		public uint get_n_items ()
		{
			return (_values.length);
		}

		public EnumFlagsModel (Type type)
		{
			if (type.is_enum() == true) {
				EnumClass ec = (EnumClass) type.class_ref();
				for (int i=0; i<ec.values.length; i++)
					_values.append_val (new EnumFlagsValueObject.as_enum(ec.values[i]));
			}
			else if (type.is_flags() == true) {
				_is_flags = true;
				FlagsClass fc = (FlagsClass) type.class_ref();
				for (int i=0; i<fc.values.length; i++)
					_values.append_val (new EnumFlagsValueObject.as_flags(fc.values[i]));
			}
			else
				GLib.error ("EnumFlagsModel can only be used with EnumClass or FlagsClass");
		}
	}
}
