namespace G
{
	// Adds completely self-dependent functionality to be easily included in any class
	//
	// While set_data/get_data is slow, they only occur on adding/removing state objects, where there is
	// almost no use case binding contract could require more than 10 per contract where 10 is exaggerated.
	//
	// Once added to they are instantly taken over by direct signals and never rely on get_data/set_data 
	// for whole life time
	public interface IBindingValueObjects : Object
	{
		public void clean_source_values()
		{
			GLib.Array<CustomPropertyNotificationBindingSource>? arr = get_data<GLib.Array> (BINDING_SOURCE_VALUE_DATA);
			if (arr == null)
				return;
			while (arr.length > 0)
				remove_source_value (arr.data[arr.length-1].name);
		}

		public CustomPropertyNotificationBindingSource add_source_value (CustomPropertyNotificationBindingSource data_object)
		{
			GLib.Array<CustomPropertyNotificationBindingSource>? arr = get_data<GLib.Array<CustomPropertyNotificationBindingSource>> (BINDING_SOURCE_VALUE_DATA);
			if (arr == null) {
				arr = new GLib.Array<CustomPropertyNotificationBindingSource>();
				set_data<GLib.Array<CustomPropertyNotificationBindingSource>> (BINDING_SOURCE_VALUE_DATA, arr);
			}
			for (int i=0; i<arr.length; i++)
				if (arr.data[i].name == data_object.name)
					return (arr.data[i]);
			arr.append_val (data_object);
			return (data_object);
		}

		public CustomPropertyNotificationBindingSource? get_source_value (string name)
		{
			GLib.Array<CustomPropertyNotificationBindingSource>? arr = get_data<GLib.Array<CustomPropertyNotificationBindingSource>> (BINDING_SOURCE_VALUE_DATA);
			if (arr == null)
				return (null);
			for (int i=0; i<arr.length; i++)
				if (arr.data[i].name == name)
					return (arr.data[i]);
			return (null);
		}

		public void remove_source_value (string name)
		{
			GLib.Array<CustomPropertyNotificationBindingSource>? arr = get_data<GLib.Array<CustomPropertyNotificationBindingSource>> (BINDING_SOURCE_VALUE_DATA);
			if (arr == null)
				return;
			for (int i=0; i<arr.length; i++) {
				if (arr.data[i].name == name) {
					arr.data[i].disconnect_object();
					arr.remove_index (i);
					return;
				}
			}
		}
	}
}
