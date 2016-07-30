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

	/**
	 * Returns AliasArray for complete structure of defined aliases and at the
	 * same time taps into modifications as ObjectArray is also GLib.ListModel
	 * 
	 * @since 0.1
	 */ 
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

	/**
	 * Storage for property aliases for any of possible reasons.
	 * - Need for relation to differently named properties in different classes
	 * - Simple property registration 
	 * 
	 * Stored aliases will be valid for whole application lifetime
	 * 
	 * @since 0.1
	 */
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

		private static HashTable<string, PropertyAlias> _alias_hash = null;

		private HashTable<Type, string> _hash = null;

		private string _name = "";
		/**
		 * Alias name specifies name under which something needs to be 
		 * accessible
		 * 
		 * @since 0.1
		 */ 
		public string name {
			get { return (_name); }
		}

		/**
		 * Checks if alias storage exists or not
		 * 
		 * @since 0.1
		 * @param alias_name Name of property alias
		 * @return true if exists, false if not
		 */
		public static bool contains (string alias_name)
		{
			if (_alias_hash == null)
				init_prop_hash();
			return (_alias_hash.get(alias_name) != null);
		}

		private static void init_prop_hash()
		{
			if (_alias_hash == null)
				_alias_hash = new HashTable<string, PropertyAlias>(str_hash, str_equal);
		}

		/**
		 * Searches for specified PropertyAlias with searched name and if it
		 * does not exists, creates new one
		 * 
		 * @since 0.1
		 * @param alias_name Name of property alias
		 * @return PropertyAlias instance that was either found or created if
		 *         needed
		 */
		public static PropertyAlias get_instance (string alias_name)
		{
			if (_alias_hash == null)
				init_prop_hash();

			PropertyAlias? props = _alias_hash.get (alias_name);
			if (props == null) {
				props = new PropertyAlias (alias_name);
				_alias_hash.insert (alias_name, props);
				AliasSignal.get_instance().added_alias (alias_name);
			}
			return (props);
		}

		/**
		 * Registers existing property for specified type in PropertyAlias
		 * container
		 * 
		 * @since 0.1
		 * @param type Object type alias is registered for
		 * @param property Existing property in specified type that should be
		 *                 represented as alias container name
		 * @return This storage reference in order to allow chain method code
		 *         for objective languages
		 */
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

		/**
		 * Same as get_for() with one exception. If type is not found it returns
		 * original value instead
		 * 
		 * @since 0.1
		 * @param type Object type alias property name was requested for
		 * @param original_val Original value
		 * @return Alias if found and original value if not
		 */
		public string safe_get_for (Type type, string original_val)
		{
			string? res = _hash.get (type);
			if (res == null)
				GLib.warning ("DefaultProperties._get_for (%s) error. Already registered!", type.name());
			return ((res != null) ? res : original_val);
		}

		/**
		 * Searches for registered alias for specified type. If type is not 
		 * found it returns null
		 * 
		 * @since 0.1
		 * @param type Object type alias property name was requested for
		 * @param original_val Original value
		 * @return Alias if found and null if not
		 */
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
			if (_alias_hash != null)
				_alias_hash.for_each ((s,p) => {
					method(s);
				});
		}

		internal void foreach_registration (HFunc<Type, string> method)
		{
			if (_hash != null)
				_hash.for_each (method);
		}

		/**
		 * Signal emitted when new type property alias is registered
		 * 
		 * @since 0.1
		 * @param type Type alias was registered for
		 * @param property_name Name of property alias was registered for
		 */
		public signal void added_type_alias (Type type, string property_name);

		private PropertyAlias(string name)
		{
			_name = name;
			_hash = new HashTable<Type, string>(type_hash, type_equal);
		}
	}
}
