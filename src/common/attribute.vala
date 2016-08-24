namespace GData
{
	private const string __ELEMENT_ATTRIBUTE_QUARK_LOCK__ = "element-attribute-list-lock";
	private const string __ELEMENT_ATTRIBUTE_QUARK__ = "element-attributes";

	/**
	 * .Net like attribute object
	 * 
	 * @since 0.1
	 */
	public class Attribute : Object
	{
	}

	private static bool _get_lock (void* data)
	{
		if (data == null)
			return (false);
		return ((bool) data);
	}

	private GLib.Array<Attribute>? _get_property_attribute_array_and_lock (ParamSpec pspec, out Quark qattrs,
	                                                                       out Quark qlock, bool create)
	{
		qattrs = Quark.from_string (__ELEMENT_ATTRIBUTE_QUARK__);
		qlock = Quark.from_string (__ELEMENT_ATTRIBUTE_QUARK_LOCK__);
		while (_get_lock(pspec.get_qdata(qlock)) == true) {}
		pspec.set_qdata(qlock, (void*) true);
		GLib.Array<Attribute>? attrs = (GLib.Array<Attribute>) pspec.get_qdata(qattrs);
		if ((attrs == null) && (create == true)) {
			attrs = new GLib.Array<Attribute>();
			pspec.set_qdata(qattrs, attrs);
		}
		return (attrs);
	}

	private void _unlock_property_attribute_array (ParamSpec pspec, Quark qlock)
	{
		pspec.set_qdata(qlock, (void*) false);
	}

	private GLib.Array<Attribute>? _get_type_attribute_array_and_lock (Type class_type, out Quark qattrs,
	                                                                   out Quark qlock, bool create)
	{
		qattrs = Quark.from_string (__ELEMENT_ATTRIBUTE_QUARK__);
		qlock = Quark.from_string (__ELEMENT_ATTRIBUTE_QUARK_LOCK__);
		while (_get_lock(class_type.get_qdata(qlock)) == true) {}
		class_type.set_qdata(qlock, (void*) true);
		GLib.Array<Attribute>? attrs = (GLib.Array<Attribute>) class_type.get_qdata(qattrs);
		if ((attrs == null) && (create == true)) {
			attrs = new GLib.Array<Attribute>();
			class_type.set_qdata(qattrs, attrs);
		}
		return (attrs);
	}

	private void _unlock_type_attribute_array (Type class_type, Quark qlock)
	{
		class_type.set_qdata(qlock, (void*) false);
	}

	private GLib.Array<Attribute>? _get_instance_attribute_array_and_lock (Object? obj, out Quark qattrs,
	                                                                  out Quark qlock, bool create)
	{
		qattrs = Quark.from_string (__ELEMENT_ATTRIBUTE_QUARK__);
		qlock = Quark.from_string (__ELEMENT_ATTRIBUTE_QUARK_LOCK__);
		while (_get_lock(obj.get_qdata(qlock)) == true) {}
		obj.set_qdata(qlock, (void*) true);
		GLib.Array<Attribute>? attrs = obj.get_qdata<GLib.Array<Attribute>?>(qattrs);
		if ((attrs == null) && (create == true)) {
			attrs = new GLib.Array<Attribute>();
			obj.set_qdata(qattrs, attrs);
			Quark _qattrs = qattrs;
			obj.weak_ref (() => {
				while (attrs.length>0)
					attrs.remove_index(attrs.length-1);
				obj.set_qdata<int>(_qattrs, 0);
			});
		}
		return (attrs);
	}

	private void _unlock_instance_attribute_array (Object? obj, Quark qlock)
	{
		obj.set_qdata(qlock, (void*) false);
	}

	private static void _add_attribute (GLib.Array<Attribute> attrs, Attribute attr)
	{
		for (int i=0; i<attrs.length; i++)
			if (attrs.data[i] == attr)
				return;
		attrs.append_val (attr);
	}

	private static void _remove_attribute (GLib.Array<Attribute>? attrs, Attribute attr)
	{
		if (attrs == null)
			return;
		for (int i=0; i<attrs.length; i++)
			if (attrs.data[(uint)i] == attr) {
				attrs.remove_index((uint)i);
				return;
			}
	}

	private static void _remove_attribute_by_type (GLib.Array<Attribute>? attrs, Type attr_type)
	{
		if (attrs == null)
			return;
		for (int i=(int)attrs.length-1; i>=0; i++)
			if (safe_get_type(attrs.data[(uint)i]).is_a(attr_type) == true)
				attrs.remove_index((uint)i);
	}

	private static Attribute[] _find_attributes (GLib.Array<Attribute>? attrs, Type attr_type)
	{
		Attribute[] rattrs = new Attribute[0];
		if (attrs != null)
			for (int i=0; i<attrs.length; i++)
				if (safe_get_type(attrs.data[(uint)i]).is_a(attr_type)) {
					rattrs.resize (rattrs.length+1);
					rattrs[rattrs.length-1] = attrs.data[(uint)i];
				}
		return (rattrs);
	}

	/**
	 * Adds attribute to ParamSpec
	 * 
	 * @since 0.1
	 * 
	 * @param pspec Property ParamSpec
	 * @param attr Attribute being added to the list
	 */
	public static void add_property_attribute (ParamSpec pspec, Attribute attr)
	{
		Quark qattrs; Quark qlock;
		_add_attribute(_get_property_attribute_array_and_lock (pspec, out qattrs, out qlock, true), attr);
		_unlock_property_attribute_array (pspec, qlock);
	}

	/**
	 * Removes attribute from ParamSpec attributes
	 * 
	 * @since 0.1
	 * 
	 * @param pspec Property ParamSpec
	 * @param attr Attribute being removed from the list
	 */
	public static void remove_property_attribute (ParamSpec pspec, Attribute attr)
	{
		Quark qattrs; Quark qlock;
		_remove_attribute(_get_property_attribute_array_and_lock (pspec, out qattrs, out qlock, false), attr);
		_unlock_property_attribute_array (pspec, qlock);
	}

	/**
	 * Removes all attributes of specified type from ParamSpec attributes
	 * 
	 * @since 0.1
	 * 
	 * @param pspec Property ParamSpec
	 * @param attr_type Attribute type being removed from the list
	 */
	public static void remove_property_attribute_by_type (ParamSpec pspec, Type attr_type)
	{
		Quark qattrs; Quark qlock;
		_remove_attribute_by_type(_get_property_attribute_array_and_lock (pspec, out qattrs, out qlock, false), attr_type);
		_unlock_property_attribute_array (pspec, qlock);
	}

	/**
	 * Finds all attributes of specified type in ParamSpec attributes. If not
	 * found zero length array is returned
	 * 
	 * @since 0.1
	 * 
	 * @param pspec Property ParamSpec
	 * @param attr_type Attribute type being searched for from the list
	 */
	public static Attribute[] find_property_attributes (ParamSpec pspec, Type attr_type)
	{
		Quark qattrs; Quark qlock;
		Attribute[] rattrs = _find_attributes(_get_property_attribute_array_and_lock (pspec, out qattrs, out qlock, false), attr_type);
		_unlock_property_attribute_array (pspec, qlock);
		return (rattrs);
	}

	/**
	 * Adds attribute to Type
	 * 
	 * @since 0.1
	 * 
	 * @param data_type Data type
	 * @param attr Attribute being added to the list
	 */
	public static void add_type_attribute (Type data_type, Attribute attr)
	{
		Quark qattrs; Quark qlock;
		_add_attribute(_get_type_attribute_array_and_lock (data_type, out qattrs, out qlock, true), attr);
		_unlock_type_attribute_array (data_type, qlock);
	}

	/**
	 * Removes attribute from Type attributes
	 * 
	 * @since 0.1
	 * 
	 * @param data_type Data type
	 * @param attr Attribute being removed from the list
	 */
	public static void remove_type_attribute (Type data_type, Attribute attr)
	{
		Quark qattrs; Quark qlock;
		_remove_attribute(_get_type_attribute_array_and_lock (data_type, out qattrs, out qlock, false), attr);
		_unlock_type_attribute_array (data_type, qlock);
	}

	/**
	 * Removes all attributes of specified type from Type attributes
	 * 
	 * @since 0.1
	 * 
	 * @param data_type Data type
	 * @param attr_type Attribute type being removed from the list
	 */
	public static void remove_type_attribute_by_type (Type data_type, Type attr_type)
	{
		Quark qattrs; Quark qlock;
		_remove_attribute_by_type(_get_type_attribute_array_and_lock (data_type, out qattrs, out qlock, false), attr_type);
		_unlock_type_attribute_array (data_type, qlock);
	}

	/**
	 * Finds all attributes of specified type in Type attributes. If not
	 * found zero length array is returned
	 * 
	 * @since 0.1
	 * 
	 * @param data_type Data type
	 * @param attr_type Attribute type being searched for from the list
	 */
	public static Attribute[] find_type_attributes (Type data_type, Type attr_type)
	{
		Quark qattrs; Quark qlock;
		Attribute[] rattrs = _find_attributes(_get_type_attribute_array_and_lock (data_type, out qattrs, out qlock, false), attr_type);
		_unlock_type_attribute_array (data_type, qlock);
		return (rattrs);
	}

	/**
	 * Adds attribute to Object instance
	 * 
	 * @since 0.1
	 * 
	 * @param instance Object instance
	 * @param attr Attribute being added to the list
	 */
	public static void add_instance_attribute (Object? instance, Attribute attr)
	{
		if (instance == null)
			return;
		Quark qattrs; Quark qlock;
		_add_attribute(_get_instance_attribute_array_and_lock (instance, out qattrs, out qlock, true), attr);
		_unlock_instance_attribute_array (instance, qlock);
	}

	/**
	 * Removes attribute from Object instance attributes
	 * 
	 * @since 0.1
	 * 
	 * @param instance Object instance
	 * @param attr Attribute being removed from the list
	 */
	public static void remove_instance_attribute (Object? instance, Attribute attr)
	{
		if (instance == null)
			return;
		Quark qattrs; Quark qlock;
		_remove_attribute(_get_instance_attribute_array_and_lock (instance, out qattrs, out qlock, false), attr);
		_unlock_instance_attribute_array (instance, qlock);
	}

	/**
	 * Removes all attributes of specified type from Object instance attributes
	 * 
	 * @since 0.1
	 * 
	 * @param instance Object instance
	 * @param attr_type Attribute type being removed from the list
	 */
	public static void remove_instance_attribute_by_type (Object? instance, Type attr_type)
	{
		if (instance == null)
			return;
		Quark qattrs; Quark qlock;
		_remove_attribute_by_type(_get_instance_attribute_array_and_lock (instance, out qattrs, out qlock, false), attr_type);
		_unlock_instance_attribute_array (instance, qlock);
	}

	/**
	 * Finds all attributes of specified type in Object instance attributes. If
	 * not found zero length array is returned
	 * 
	 * @since 0.1
	 * 
	 * @param instance Object instance
	 * @param attr_type Attribute type being searched for from the list
	 */
	public static Attribute[] find_instance_attributes (Object? instance, Type attr_type)
	{
		if (instance == null)
			return (new Attribute[0]);
		Quark qattrs; Quark qlock;
		Attribute[] rattrs = _find_attributes(_get_instance_attribute_array_and_lock (instance, out qattrs, out qlock, false), attr_type);
		_unlock_instance_attribute_array (instance, qlock);
		return (rattrs);
	}
}

