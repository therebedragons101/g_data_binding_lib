namespace GData
{
	/**
	 * Specifies group monitoring of flags values and provides easy way to
	 * add specific monitoring states
	 * 
	 * @since 0.1
	 */
	public class ProxyPropertyGroup : Object, GLib.ListModel
	{
		private GLib.Array<StoredProperty> _proxy_connections = new GLib.Array<StoredProperty>();

		internal class StoredProperty
		{
			public string name { get; private set; }
			public ProxyProperty? property { get; private set; }

			public void reset()
			{
				name = "";
				property = null;
			}

			public StoredProperty (string name, ProxyProperty property)
			{
				this.name = name;
				this.property = property;
			}
		}

		private int _get_by_name (string property_name)
		{
			for (int i=0; i<_proxy_connections.length; i++)
				if (_proxy_connections.data[i].name == property_name)
					return (i);
			return (-1);
		}

		private int _get_by_instance (ProxyProperty property)
		{
			for (int i=0; i<_proxy_connections.length; i++)
				if (_proxy_connections.data[i].property == property)
					return (i);
			return (-1);
		}

		/**
		 * Creates proxy property to tracking one single property and
		 * allowing that tracking to respect pointer/contract source changes
		 * 
		 * @since 0.1
		 * 
		 * @param property Name under which property is stored, duplicates are
		 *                 not supported
		 * @param obj Object or pointer/contract that owns property
		 * @param property_name Property name
		 * @param invalid_value Specifies value which should be returned on
		 *                      momentary invalid state machine (aka. source
		 *                      being pointer/contract but pointing to null)
		 * @param bidirectional Specifies if state machines are bidirectional or
		 *                      not
		 * @param restrict_to Type safety. If property type is not transformable
		 *                    to that type it will act like connection never
		 *                    happened
		 */
		public ProxyProperty? add_property (string name, Object obj, string property_name, GLib.Value invalid_value, bool bidirectional = true, Type restrict_to = GLib.Type.INVALID)
		{
			if (name == "")
				return (null);
			if (_get_by_name(name) >= 0) {
				GLib.warning ("Property with name='%s' already exists", name);
				return (null);
			}
			return (add_proxy_property (name, new ProxyProperty (obj, property_name, invalid_value, bidirectional, restrict_to)));
		}

		/**
		 * Adds proxy property to group
		 * 
		 * @since 0.1
		 * 
		 * @param property Name under which property is stored, duplicates are
		 *                 not supported
		 * @param property Proxy property
		 * @return Newly added proxy property
		 */
		public ProxyProperty? add_proxy_property (string name, ProxyProperty? property)
		{
			if ((property == null) || (name == ""))
				return (null);
			int pos = _get_by_name(name);
			if (pos >= 0) {
				if (_proxy_connections.data[pos].property == property)
					return (property);
				GLib.warning ("Property with name='%s' already exists", name);
				return (null);
			}
			property.value_changed.connect (handle_value_changed);
			_proxy_connections.append_val (new StoredProperty (name, property));
			items_changed (_proxy_connections.length-1, 0, 1);
			property_added (property);
			return (property);
		}

		/**
		 * Returns property stored under specified name
		 * 
		 * @since 0.1
		 * 
		 * @param property_name Property name
		 * @return Proxy property or null if not found
		 */
		public ProxyProperty? get_by_name (string property_name)
		{
			int pos = _get_by_name(property_name);
			return ((pos >= 0) ? _proxy_connections.data[pos].property : null);
		}

		/**
		 * Returns property stored with specified instance
		 * 
		 * @since 0.1
		 * 
		 * @param property Property
		 * @return Proxy property name under which is stored or empty string
		 */
		public string get_by_instance (ProxyProperty? property)
		{
			int pos = _get_by_instance(property);
			return ((pos >= 0) ? _proxy_connections.data[pos].name : "");
		}

		private void _remove_property_at_index (int index)
		{
			if ((index<0) || (index>=_proxy_connections.length))
				return;
			ProxyProperty prop = _proxy_connections.data[index].property;
			_proxy_connections.data[index].reset();
			_proxy_connections.remove_index (index);
			items_changed (index, 1, 0);
			prop.value_changed.disconnect (handle_value_changed);
			property_removed (prop);
		}

		/**
		 * Removes proxy property from group
		 * 
		 * @since 0.1
		 * 
		 * @param property Proxy property
		 */
		public void remove_proxy_property_by_name (string property_name)
		{
			_remove_property_at_index (_get_by_name(property_name));
		}

		/**
		 * Removes proxy property from group
		 * 
		 * @since 0.1
		 * 
		 * @param property Proxy property
		 */
		public void remove_proxy_property (ProxyProperty? property)
		{
			if (property == null)
				return;
			_remove_property_at_index (_get_by_instance(property));
		}

		/**
		 * Removes all tracked properties
		 * 
		 * @since 0.1
		 */
		public void clean()
		{
			while (_proxy_connections.length > 0)
				_remove_property_at_index ((int) _proxy_connections.length-1);
		}

		private void handle_value_changed()
		{
			value_changed();
		}

		/**
		 * Evaluates if all properties in group are valid or not
		 * 
		 * @since 0.1
		 */
		public bool is_valid {
			get {
				for (int i=0; i<get_n_items(); i++)
					if (((ProxyProperty) get_item(i)).is_valid() == false)
						return (false);
				return (true);
			}
		}

		/**
		 * Get the item at position.
		 * 
		 * @since 0.1
		 * 
		 * @param position Position of item
		 * @return Item at specified position
		 */
		public Object? get_item (uint position)
		{
			return (_proxy_connections.data[position].property);
		}

		/**
		 * Gets the type of the items in this.
		 * 
		 * @since 0.1
		 * 
		 * @return Type being grouped
		 */
		public virtual Type get_item_type()
		{
			return (typeof (ProxyProperty));
		}

		/**
		 * Gets the number of items in this.
		 * 
		 * @since 0.1
		 * 
		 * @return Number of items
		 */
		public uint get_n_items()
		{
			return (_proxy_connections.length);
		}

		/**
		 * Signal emited when new proxy property is added
		 * 
		 * @since 0.1
		 * 
		 * @param property Property that was added
		 */
		public signal void property_added (ProxyProperty property);

		/**
		 * Signal emited when proxy property is removed
		 * 
		 * @since 0.1
		 * 
		 * @param property Property that was removed
		 */
		public signal void property_removed (ProxyProperty property);

		/**
		 * Signal emited when any of tracked properties changes
		 * 
		 * @since 0.1
		 */
		public signal void value_changed();

		/**
		 * Creates new ProxyPropertyGroup
		 * 
		 * @since 0.1
		 */
		public ProxyPropertyGroup ()
		{
			
		}
	}
}

