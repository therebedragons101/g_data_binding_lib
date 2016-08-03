namespace GData
{
	/**
	 * Checks if object is BindingPointer or its subclass
	 * 
	 * @since 0.1
	 * @param obj Object being checked
	 * @return true if object is BindingPointer or subclass, false if not
	 */
	public static bool is_binding_pointer (Object? obj)
	{
		if (obj == null)
			return (false);
		return (obj.get_type().is_a(typeof(BindingPointer)) == true);
	}

	internal static bool is_same_type (Object? obj1, Object? obj2)
	{
		return (type_is_same_as ((obj1 == null) ? (Type?) null : obj1.get_type(),
		                         (obj2 == null) ? (Type?) null : obj2.get_type()));
	}

	internal static Type? get_common_type (Object? obj1, Object? obj2)
	{
		if ((obj1 == null) || (obj2 == null))
			return (null);
		if (obj1.get_type().is_a(obj2.get_type()) == true)
			return (obj2.get_type());
		if (obj2.get_type().is_a(obj1.get_type()) == true)
			return (obj1.get_type());
		Type t = obj1.get_type().parent();
		while (t != typeof(Object))
			if (obj2.get_type().is_a(t) == true)
				return (t);
		return (typeof(Object));
	}

	internal static bool type_is_same_as (Type? type1, Type? type2)
	{
		if (type1 == type2)
			return (true);
		if ((type1 == null) || (type2 == null))
			return (false);
		return (type1.is_a(type2));
	}
}
