namespace GData.Generics
{
	private static void add_alias (string s, AliasArray list)
	{
		KeyValueArray<Type, string> prop_list = new KeyValueArray<Type, string>();
		PropertyAlias alias = PropertyAlias.get_instance (s);
		alias.foreach ((t, p) => {
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
		PropertyAlias.signals.added_alias.connect ((s) => {
			add_alias (s, list);
		});
		return (list);
	}
}

