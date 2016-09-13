namespace GData
{
	/**
	 * Storage for property aliases for any of possible reasons.
	 * - Need for relation to differently named properties in different classes
	 * - Simple property registration 
	 * 
	 * Stored aliases will be valid for whole application lifetime
	 * 
	 * @since 0.1
	 */
	public class PropertyAlias : Object
	{
		public class Signals : Object
		{
			private static Signals? _instance = null;
			internal static Signals get_instance()
			{
				if (_instance == null)
					_instance = new Signals();
				return (_instance);
			}

			/**
			 * Signal is emited when new alias is declared
			 * 
			 * @since 0.1
			 * 
			 * @param alias_name Name of new alias
			 */
			public signal void added_alias (string alias_name);

			private Signals()
			{
			}
		}

		/**
		 * Access to global storage signals
		 * 
		 * @since 0.1
		 */
		public static Signals signals {
			owned get { return (Signals.get_instance()); }
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
		 * Finds closest hierarchy match for specied alias and type in its
		 * registrations.
		 * 
		 * @since 0.1
		 * 
		 * @param alias_name Alias name
		 * @param type Type that needs resolving
		 * @return Property name if found, null if not
		 */
		public static string? get_alias_property_for (string alias_name, Type type)
		{
			return (PropertyAlias.get_instance(alias_name).find_for (type));
		}

		/**
		 * Finds closest hierarchy match for default value alias and type in its
		 * registrations.
		 * 
		 * @since 0.1
		 * 
		 * @param type Type that needs resolving
		 * @return Property name if found, null if not
		 */
		public static string? get_default_value_property_for (Type type)
		{
			return (get_alias_property_for(ALIAS_DEFAULT, type));
		}

		/**
		 * Finds closest hierarchy match for visibility alias and type in its
		 * registrations.
		 * 
		 * @since 0.1
		 * 
		 * @param type Type that needs resolving
		 * @return Property name if found, null if not
		 */
		public static string? get_visibility_property_for (Type type)
		{
			return (get_alias_property_for(ALIAS_VISIBILITY, type));
		}

		/**
		 * Finds closest hierarchy match for sensitivity alias and type in its
		 * registrations.
		 * 
		 * @since 0.1
		 * 
		 * @param type Type that needs resolving
		 * @return Property name if found, null if not
		 */
		public static string? get_sensitivity_property_for (Type type)
		{
			return (get_alias_property_for(ALIAS_SENSITIVITY, type));
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
				signals.added_alias (alias_name);
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
		 * 
		 * @param type Object type alias property name was requested for
		 * @param original_val Original value
		 * @return Alias if found and original value if not
		 */
		public string safe_get_for (Type type, string original_val)
		{
			string? res = find_for (type);
			return ((res != null) ? res : original_val);
		}

		/**
		 * Searches for registered alias for specified type. If type is not 
		 * found it returns null
		 * 
		 * @since 0.1
		 * 
		 * @param type Object type alias property name was requested for
		 * @return Alias if found and null if not
		 */
		public string? get_for (Type type)
		{
			return (_hash.get (type));
		}

		/**
		 * Unlike get_for() which returns only exact match, find_for() returns
		 * nearest hierarchy match as well which makes it suitable for discovery
		 * 
		 * @since 0.1
		 * 
		 * @param type Object type alias property name was requested for
		 * @return Alias if found and null if not
		 */
		public string? find_for (Type type)
		{
			string? res = get_for (type);
			if (res != null)
				return (res);
			// Iterate trough types and find nearest match
			int hierarchy_gap = int.MAX;
			_hash.for_each ((k,v) => {
				int _hierarchy_gap = get_hierarchy_gap(type, k);
				if (_hierarchy_gap < hierarchy_gap) {
					res = v;
					hierarchy_gap = _hierarchy_gap;
				}
			});
			return (res);
		}

		private static uint type_hash (Type type)
		{
			return (str_hash (type.name()));
		}

		private static bool type_equal (Type type1, Type type2)
		{
			return (type1 == type2);
		}

		public static void foreach_alias (StorageDelegateFunc method)
		{
			if (_alias_hash != null)
				_alias_hash.for_each ((s,p) => {
					method(s);
				});
		}

		public void foreach (AliasStorageDelegateFunc method)
		{
			if (_hash != null)
				_hash.for_each ((k,v) => {
					method(k,v);
				});
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
