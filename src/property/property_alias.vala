namespace G
{
	private static void add_alias (string s, AliasArray list)
	{
		KeyValueArray<Type, string> prop_list = new KeyValueArray<Type, string>();
		PropertyAlias alias = PropertyAlias.get_instance (s);
		alias.foreach_registration ((t, p) => {
			prop_list.add (new KeyValuePair<Type, string> (t, p));
		});
		alias.added_type_alias.connect ((t, p) => {
			prop_list.add (new KeyValuePair<Type, string> (t, p));
		});
		KeyValuePair<string, KeyValueArray<Type, string>> alias_pair = 
			new KeyValuePair<string, KeyValueArray<Type, string>>(s, prop_list);
		list.add (alias_pair);
	}

	public static AliasArray track_property_aliases()
	{
		AliasArray list = new AliasArray();
		PropertyAlias.foreach_alias ((s) => {
			add_alias (s, list);
		});
		PropertyAlias.AliasSignal.get_instance().added_alias.connect ((s) => {
			add_alias (s, list);
		});
		return (list);
	}

	public class PropertyAlias
	{
		internal class AliasSignal
		{
			private static AliasSignal? _instance = null;
			public static AliasSignal get_instance()
			{
				if (_instance == null)
					_instance = new AliasSignal();
				return (_instance);
			}

			public signal void added_alias (string alias_name);
		}

		private static HashTable<string, PropertyAlias> _property_hash = null;

		private HashTable<Type, string> _hash = null;

		private string _name = "";
		public string name {
			get { return (_name); }
		}

		public static bool contains (string property_name)
		{
			if (_property_hash == null)
				init_prop_hash();
			return (_property_hash.get(property_name) != null);
		}

		private static void init_prop_hash()
		{
			if (_property_hash == null)
				_property_hash = new HashTable<string, PropertyAlias>(str_hash, str_equal);
		}

		public static PropertyAlias get_instance (string alias_name)
		{
			if (_property_hash == null)
				init_prop_hash();

			PropertyAlias? props = _property_hash.get (alias_name);
			if (props == null) {
				props = new PropertyAlias (alias_name);
				_property_hash.insert (alias_name, props);
				AliasSignal.get_instance().added_alias (alias_name);
			}
			return (props);
		}

		public PropertyAlias register (Type type, string property)
		{
			string? res = _hash.get (type);
			if (res != null) {
				GLib.warning ("DefaultProperties.register (%s, %s) error. Already registered!", type.name(), property);
				return (this);
			}

			ParamSpec? parm = ((ObjectClass) type.class_ref()).find_property (property);
			if (parm == null) {
				GLib.warning ("DefaultProperties.register (%s, %s) error. Property does not exist!", type.name(), property);
				return (this);
			}

			_hash.insert (type, property);
			added_type_alias (type, property);
			return (this);
		}

		public string safe_get_for (Type type, string original_val)
		{
			string? res = _hash.get (type);
			if (res == null)
				GLib.warning ("DefaultProperties._get_for (%s) error. Already registered!", type.name());
			return ((res != null) ? res : original_val);
		}

		public string? get_for (Type type)
		{
			return (_hash.get (type));
		}

		private static uint type_hash (Type type)
		{
			return (str_hash (type.name()));
		}

		private static bool type_equal (Type type1, Type type2)
		{
			return (type1 == type2);
		}

		internal static void foreach_alias (Func<string> method)
		{
			if (_property_hash != null)
				_property_hash.for_each ((s,p) => {
					method(s);
				});
		}

		internal void foreach_registration (HFunc<Type, string> method)
		{
			if (_hash != null)
				_hash.for_each (method);
		}

		public signal void added_type_alias (Type type, string property_name);

		private PropertyAlias(string name)
		{
			_name = name;
			_hash = new HashTable<Type, string>(type_hash, type_equal);
		}
	}
}
