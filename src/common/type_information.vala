namespace GData
{
	public delegate void ParamSpecDelegate (ParamSpec pspec);

	public static bool can_translate_value_type (Type val1, Type val2)
	{
		return ((GLib.Value.type_compatible(val1, val2) == true) ||
		        (GLib.Value.type_transformable(val1, val2) == true));
	}

	public static bool can_translate_value (GLib.Value val1, GLib.Value val2)
	{
		return (can_translate_value_type (val2.type(), val2.type()));
	}

	public static bool copy_or_transform_value (GLib.Value val1, ref GLib.Value val2)
	{
		if (GLib.Value.type_compatible(val1.type(), val2.type()) == true)
			val1.copy (ref val2);
		else if (GLib.Value.type_transformable(val1.type(), val2.type()) == true)
			val1.transform (ref val2);
		else
			return (false);
		return (true);
	}

	public static int get_hierarchy_gap (Type from, Type to)
	{
		if ((from.is_classed() == false) || (to.is_classed() == false))
			return (int.MAX);
		int count = 0;
		Type c = from;
		while (c != to) {
			count++;
			if (c.parent() == Type.INVALID)
				return (int.MAX);
			c = c.parent();
		}
		return (count);
	}

	public class TypeInformation
	{
		private static TypeInformation? _instance = null;

		public static TypeInformation get_instance()
		{
			if (_instance == null)
				_instance = new TypeInformation();
			return (_instance);
		}

		/*
		 * Methods inteded for discovery of properties and signals abstracted into
		 * one singular point that is easy to extend
		 * 
		 * Everything crucial should go trough these as it brings consistency to
		 * internal application for things like PropertyAlias or any other internal
		 * extension
		 */

		/**
		 * Finds property trough type and if unsucessful, tries finding one
		 * trough property aliases
		 * 
		 * @since 0.1
		 * 
		 * @param type Object type property is searhed for
		 * @param property_name Property name
		 * @return ParamSpec of found property or null if not found
		 */
		public ParamSpec? find_property_from_type (Type type, string property_name)
		{
			string prop = property_name;
			ParamSpec? _property = ((ObjectClass) type.class_ref()).find_property (prop);
			if ((_property == null) && (PropertyAlias.contains(prop) == true)) {
				prop = PropertyAlias.get_instance(property_name).safe_get_for (type, property_name);
				_property = ((ObjectClass) type.class_ref()).find_property (prop);
			}
			return (_property);
		}

		/**
		 * Finds property trough objects type and if unsucessful, tries finding
		 * one trough property aliases
		 * 
		 * @since 0.1
		 * 
		 * @param type Object type property is searhed for
		 * @param property_name Property name
		 * @return ParamSpec of found property or null if not found
		 */
		public ParamSpec? find_property_from_ref (Object? obj, string property_name)
		{
			if ((obj == null) || (property_name == ""))
				return (null);
			return (find_property_from_type (obj.get_type(), property_name));
		}


		/**
		 * Finds property trough type and if unsucessful, tries finding one
		 * trough property aliases
		 * 
		 * @since 0.1
		 * 
		 * @param type Object type property is searhed for
		 * @param property_name Property name
		 * @param restrict_to Restricts result to specified type, if it is not
		 *                    transformable, null is returned
		 * @return ParamSpec of found property or null if not found
		 */
		public ParamSpec? find_typesafe_property_from_type (Type type, string property_name, Type restrict_to=GLib.Type.INVALID)
		{
			string prop = property_name;
			ParamSpec? _property = ((ObjectClass) type.class_ref()).find_property (prop);
			if ((_property == null) && (PropertyAlias.contains(prop) == true)) {
				prop = PropertyAlias.get_instance(property_name).safe_get_for (type, property_name);
				_property = ((ObjectClass) type.class_ref()).find_property (prop);
			}
			if ((restrict_to != Type.INVALID) && (_property != null))
				if ((GLib.Value.type_compatible(_property.value_type, restrict_to) == true) ||
					(GLib.Value.type_transformable(_property.value_type, restrict_to) == true))
					return (_property);
				else
					return (null);
			return (_property);
		}

		/**
		 * Finds property trough objects type and if unsucessful, tries finding
		 * one trough property aliases
		 * 
		 * @since 0.1
		 * 
		 * @param type Object type property is searhed for
		 * @param property_name Property name
		 * @param restrict_to Restricts result to specified type, if it is not
		 *                    transformable, null is returned
		 * @return ParamSpec of found property or null if not found
		 */
		public ParamSpec? find_typesafe_property_from_ref (Object? obj, string property_name, Type restrict_to=GLib.Type.INVALID)
		{
			if ((obj == null) || (property_name == ""))
				return (null);
			return (find_typesafe_property_from_type (obj.get_type(), property_name));
		}

		/**
		 * Connects callback to specified property
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object which is target of connection
		 * @param property_name Property name
		 * @param method Callback method
		 * @return True if connection was successful, false if not
		 */
		public ulong connect_notify_event (Object? obj, string property_name, Callback method)
		{
			if ((obj == null) || (property_name == ""))
				return (0);
			ParamSpec? pspec = find_property_from_ref(obj, property_name);
			return (_connect_notify_event (obj, pspec, method));
		}

		/**
		 * Connects callback to specified property ParamSpec
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object which is target of connection
		 * @param pspec Property ParamSpec
		 * @param method Callback method
		 * @return True if connection was successful, false if not
		 */
		public ulong _connect_notify_event (Object? obj, ParamSpec? pspec, Callback method)
		{
			if ((pspec == null) || (obj == null))
				return (0);
		
	//		obj.notify[pspec.name].connect (method);
			return (1);
		}

		/**
		 * Disconnects callback from specified property
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object which is target of connection
		 * @param property_name Property name
		 * @param method Callback method
		 * @return True if disconnection was successful, false if not
		 */
		public void disconnect_notify_event (Object? obj, ulong signal_handler_id)
		{
			if (obj == null)
				return;
			disconnect_signal (obj, signal_handler_id);
	//		ParamSpec? pspec = find_property_from_ref(obj, property_name);
	//		_disconnect_notify_event (obj, pspec, method);
		}

		/**
		 * Disconnects callback from specified property ParamSpec
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object which is target of connection
		 * @param pspec Property ParamSpec
		 * @param method Callback method
		 * @return True if disconnection was successful, false if not
		 */
	/*	public static void _disconnect_notify_event (Object? obj, ulong signal_handler_id)
		{
			if ((pspec == null) || (obj == null))
				return;
	//		obj.notify[pspec.name].disconnect (method);
			return;
		}*/

		/**
		 * Iterates trough type properties by calling specified delegate method
		 * TODO add matching
		 * @since 0.1
		 * 
		 * @param type Type being iterated
		 * @param method Method being called for each property
		 */
		public void iterate_type_properties (Type type, ParamSpecDelegate method)
		{
			ObjectClass ocl = (ObjectClass) type.class_ref ();
			foreach (ParamSpec pspec in ocl.list_properties ())
				method (pspec);
		}


		/**
		 * Iterates trough reference type properties by calling specified delegate 
		 * method
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object whose properties are being iterated
		 * @param method Method being called for each property
		 */
		public void iterate_ref_properties (Object? obj, ParamSpecDelegate method)
		{
			if (obj == null)
				return;
			iterate_type_properties (obj.get_type(), method);
		}

		/**
		 * Returns signals for specified type.
		 * 
		 * Note that this only returns its own signals, not signals from parent
		 * classes or interfaces. If that is needed then 
		 * get_full_signal_list_from_type() should be used
		 * 
		 * @since 0.1
		 * 
		 * @param type Type
		 * @return Signal id array
		 */
		public uint[] get_signal_list_from_type (Type type)
		{
			return (Signal.list_ids (type));
		}

		/**
		 * Returns signals for specified objects type.
		 * 
		 * Note that this only returns its own signals, not signals from parent
		 * classes or interfaces. If that is needed then 
		 * get_full_signal_list_from_ref() should be used
		 * 
		 * @since 0.1
		 * 
		 * @param type Type
		 * @return Signal id array
		 */
		public uint[] get_signal_list_from_ref (Object? obj)
		{
			if (obj == null)
				return (new uint[0]);
			return (get_signal_list_from_type (obj.get_type()));
		}

		private void __add_signals (Type type, GLib.Array<uint> _signals, GLib.Array<Type> _cache)
		{
			for (int i=0; i<_cache.length; i++)
				if (_cache.data[i] == type)
					return;
			_cache.append_val (type);
			uint[] ids = Signal.list_ids (type);
			foreach (uint id in ids)
				_signals.append_val(id);
			Type[] ints = type.interfaces();
			for (int i=0; i<ints.length; i++)
				if (ints[i] != Type.INVALID)
					__add_signals (ints[i], _signals, _cache);
			if (type.parent() != Type.INVALID)
				__add_signals(type.parent(), _signals, _cache);
		}

		/**
		 * Returns all signals for specified type, including signals from parent
		 * classes or interfaces. 
		 * 
		 * @since 0.1
		 * 
		 * @param type Type
		 * @return Signal id array
		 */
		public uint[] get_full_signal_list_from_type (Type type)
		{
			GLib.Array<uint> _signals = new GLib.Array<uint>();
			GLib.Array<Type> _cache = new GLib.Array<Type>();
			__add_signals (type, _signals, _cache);
			uint[] res = new uint[_signals.length];
			for (int i=0; i<_signals.length; i++)
				res[i] = _signals.data[i];
			return (res);
		}

		/**
		 * Returns all signals for specified type, including signals from parent
		 * classes or interfaces.
		 * 
		 * @since 0.1
		 * 
		 * @param type Type
		 * @return Signal id array
		 */
		public uint[] get_full_signal_list_from_ref (Object? obj)
		{
			if (obj == null)
				return (new uint[0]);
			return (get_full_signal_list_from_type (obj.get_type()));
		}

		/**
		 * Returns signal id if found (searches whole hierarchy if necessary)
		 * 
		 * @since 0.1
		 * 
		 * @param type Object type
		 * @param signal_name
		 * @return Signal id or 0 if not found
		 */
		public uint get_signal_by_name_from_type (Type type, string signal_name)
		{
			return (Signal.lookup(signal_name, type));
		}

		/**
		 * Returns detailed signal name in form of "signal_name::quark"
		 * 
		 * @since 0.1
		 * 
		 * @param signal_name Signal name
		 * @param quark Signal quark name
		 * @return Detailed signal name
		 */
		public string get_detailed_signal_name (string signal_name, string quark)
		{
			return ("%s%s".printf(signal_name, "%s%s".printf((quark != "") ? "::" : "", quark)));
		}

		/**
		 * Returns signal id if found (searches whole hierarchy if necessary)
		 * 
		 * @since 0.1
		 * 
		 * @param type Object type
		 * @param signal_name
		 * @return Signal id or 0 if not found
		 */
		public uint get_signal_by_name_from_ref (Object? obj, string signal_name)
		{
			if (obj == null)
				return (0);
			return (Signal.lookup(signal_name, obj.get_type()));
		}

		public ulong connect_signal (Object? obj, string signal_name, SimpleDelegate? callback, string quark = "")
		{
stdout.printf ("connect_signal (%i, %s, %i, %s)\n", (int) (obj != null), signal_name, (int) (callback != null), quark);
			if ((obj == null) || (signal_name == ""))
				return (0);
stdout.printf ("connect_signal2 (%s, %s, %i, %s\n", obj.get_type().name(), signal_name, (int) (callback != null), quark);
//			Call s = (c) => { call(c); };
/*() => {
				call(callback);
			};*/
//	return(__connect_signal (obj, signal_name, s, callback, quark));
			return (Signal.connect(obj, get_detailed_signal_name(signal_name, quark), (Callback) callback, null));
/*			Callback c = () => {
				(owned) s();
			};
			return (Signal.connect(obj, get_detailed_signal_name(signal_name, quark),
				() => {
					callback();
				}, null));*/
		}

		public ulong connect_signal_by_id (Object? obj, uint signal_id, SimpleDelegate callback, string quark = "")
		{
			return (connect_signal (obj, Signal.name(signal_id), callback, quark));
		}

		public void disconnect_signal (Object? obj, ulong signal_handler_id)
		{
			GLib.SignalHandler.disconnect (obj, signal_handler_id);
		}
	}
}

