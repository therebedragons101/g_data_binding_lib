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

	/**
	 * Checks if object is BindingContract or its subclass
	 * 
	 * @since 0.1
	 * @param obj Object being checked
	 * @return true if object is BindingContract or subclass, false if not
	 */
	public static bool is_binding_contract (Object? obj)
	{
		if (obj == null)
			return (false);
		return (obj.get_type().is_a(typeof(BindingContract)) == true);
	}

	/**
	 * Checks if object is ObjectInformation or its subclass
	 * 
	 * @since 0.1
	 * @param obj Object being checked
	 * @return true if object is ObjectInformation or subclass, false if not
	 */
	public static bool is_object_information (Object? obj)
	{
		if (obj == null)
			return (false);
		return (obj.get_type().is_a(typeof(ObjectInformation)) == true);
	}

	/**
	 * Checks if object is CustomBindingSourceState or its subclass
	 * 
	 * @since 0.1
	 * @param obj Object being checked
	 * @return true if object is CustomBindingSourceState or subclass, false if not
	 */
	public static bool is_state_object (Object? obj)
	{
		if (obj == null)
			return (false);
		return (obj.get_type().is_a(typeof(CustomBindingSourceState)) == true);
	}

	/**
	 * Checks if object is CustomPropertyNotificationBindingSource or its 
	 * subclass
	 * 
	 * @since 0.1
	 * @param obj Object being checked
	 * @return true if object is CustomPropertyNotificationBindingSource or 
	 *         subclass, false if not
	 */
	public static bool is_binding_object (Object? obj)
	{
		if (obj == null)
			return (false);
		return (obj.get_type().is_a(typeof(CustomPropertyNotificationBindingSource)) == true);
	}

	/**
	 * Checks if object is implementing HasDescription interface
	 * 
	 * @since 0.1
	 * @param obj Object being checked
	 * @return true if object is implementing HasDescription, false if not
	 */
	public static bool has_description (Object? obj)
	{
		if (obj == null)
			return (false);
		return (obj.get_type().is_a(typeof(HasDescription)) == true);
	}

	/**
	 * Casts object as BindingPointer
	 * 
	 * @since 0.1
	 * 
	 * @param obj Object
	 * @return Pointer if casting is possible
	 */
	public static BindingPointer? as_pointer (Object? obj)
	{
		if (is_binding_pointer(obj) == true)
			return ((BindingPointer) obj);
		return (null);
	}

	/**
	 * Casts object as BindingContract
	 * 
	 * @since 0.1
	 * 
	 * @param obj Object
	 * @return Contract if casting is possible
	 */
	public static BindingContract? as_contract (Object? obj)
	{
		if (is_binding_contract(obj) == true)
			return ((BindingContract) obj);
		return (null);
	}

	/**
	 * Safe casts object as BindingPointer and returns get_source() if possible
	 * 
	 * @since 0.1
	 * 
	 * @param obj Object
	 * @return Value of pointers get_source() if casting is possible, null if 
	 *         not
	 */
	public static Object? as_pointer_source (Object? obj)
	{
		if (is_binding_pointer(obj) == true)
			return (((BindingPointer) obj).get_source());
		return (null);
	}

	/**
	 * Safe casts object as BindingContract and returns "data" if possible
	 * 
	 * @since 0.1
	 * 
	 * @param obj Object
	 * @return Value of contracts "data" property or null if not contract
	 */
	public static Object? as_pointer_data (Object? obj)
	{
		if (is_binding_pointer(obj) == true)
			return (((BindingPointer) obj).get_source());
		return (null);
	}

	/**
	 * Safe casts object as BindingPointer and returns get_source() if possible
	 * 
	 * @since 0.1
	 * 
	 * @param obj Object
	 * @return Value of pointers get_source() if casting is possible, null if 
	 *         not
	 */
	public static Object? as_contract_source (Object? obj)
	{
		if (is_binding_pointer(obj) == true)
			return (((BindingPointer) obj).get_source());
		return (null);
	}

	/**
	 * Safe casts object as BindingPointer and returns "data" if possible
	 * 
	 * @since 0.1
	 * 
	 * @param obj Object
	 * @return Value of contracts "data" property or null if not contract
	 */
	public static Object? as_contract_data (Object? obj)
	{
		if (is_binding_pointer(obj) == true)
			return (((BindingPointer) obj).get_source());
		return (null);
	}

	/**
	 * Casts object as CustomBindingSourceState
	 * 
	 * @since 0.1
	 * 
	 * @param obj Object
	 * @return Pointer if casting is possible
	 */
	public static CustomBindingSourceState? as_state_object (Object? obj)
	{
		if (obj != null)
			if (is_state_object(obj) == true)
				return ((CustomBindingSourceState) obj);
		return (null);
	}

	/**
	 * Casts object as CustomPropertyNotificationBindingSource
	 * 
	 * @since 0.1
	 * 
	 * @param obj Object
	 * @return Pointer if casting is possible
	 */
	public static CustomPropertyNotificationBindingSource? as_binding_object (Object? obj)
	{
		if (obj != null)
			if (is_binding_object(obj) == true)
				return ((CustomPropertyNotificationBindingSource) obj);
		return (null);
	}

	/**
	 * Returns ref_count for pointer, its data and get_source()
	 * 
	 * Note that this returns +1 on reference. Call _get_reference_count() if 
	 * you need accurate
	 * 
	 * If not valid -1 is returned as specific reference
	 * 
	 * @since 0.1
	 * 
	 * @param pointer Binding pointer
	 * @param ptr_ref Binding pointer ref_count
	 * @param ptr_ref Binding pointers data ref_count
	 * @param ptr_ref Binding pointers get_source() ref_count
	 */
	public void get_reference_count (BindingPointer pointer, out int ptr_ref, out int data_ref, out int source_ref)
	{
		
		weak Object? __pointer = pointer;
		weak Object? __pointer_data = (__pointer != null) ? pointer.data : null;
		weak Object? __pointer_source = (__pointer != null) ? pointer.get_source() : null;
		ptr_ref = (__pointer == null) ? -1 : (int) __pointer.ref_count;
		data_ref = (__pointer_data == null) ? -1 : (int) __pointer_data.ref_count;
		source_ref = (__pointer_source == null) ? -1 : (int) __pointer_source.ref_count;
	}

	/**
	 * Returns ref_count for pointer, its data and get_source()
	 * 
	 * Unlike get_reference_count() this call can provide exact state but it
	 * has to stored in StrictWeakRef before call
	 * 
	 * If not valid -1 is returned as specific reference
	 * 
	 * @since 0.1
	 * 
	 * @param pointer Binding pointer
	 * @param ptr_ref Binding pointer ref_count
	 * @param ptr_ref Binding pointers data ref_count
	 * @param ptr_ref Binding pointers get_source() ref_count
	 */
	public void _get_reference_count (StrictWeakRef pointer, out int ptr_ref, out int data_ref, out int source_ref)
	{
		
		weak Object? __pointer = pointer.target;
		weak Object? __pointer_data = 
			((__pointer != null) && (is_binding_pointer(__pointer))) ? as_pointer(__pointer).data : null;
		weak Object? __pointer_source = 
			((__pointer != null) && (is_binding_pointer(__pointer))) ? as_pointer(__pointer).get_source() : null;
		ptr_ref = (__pointer == null) ? -1 : (int) __pointer.ref_count;
		data_ref = (__pointer_data == null) ? -1 : (int) __pointer_data.ref_count;
		source_ref = (__pointer_source == null) ? -1 : (int) __pointer_source.ref_count;
	}

	public void debug_references (string text, BindingPointer pointer)
	{
		int p, d, s;
		get_reference_count (pointer, out p, out d, out s);
		stdout.printf ("\t\tReferences(id=@%s)[\"%s\"]: pointer(%i), data(%i), source(%i)\n", (pointer == null) ? "null" : "%i".printf(as_pointer(pointer).id), text, p, d, s);
	}

	public void _debug_references (string text, StrictWeakRef pointer)
	{
		int p, d, s;
		_get_reference_count (pointer, out p, out d, out s);
		stdout.printf ("\t\tReferences(id=@%s)[\"%s\"]: pointer(%i), data(%i), source(%i)\n", (pointer.target == null) ? "null" : "%i".printf(as_pointer(pointer.target).id), text, p, d, s);
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
		while (t != typeof(Object)) {
			if (obj2.get_type().is_a(t) == true)
				return (t);
			t = t.parent();
		}
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
