namespace GData
{
	/**
	 * Sets boolean flag
	 * 
	 * @since 0.1
	 * 
	 * @param flags Flags
	 * @param flag Flag being set
	 * @return Result value
	 */
	internal static uint set_flag (uint flags, uint flag)
	{
		return (flags | flag);
	}

	/**
	 * Sets boolean flag
	 * 
	 * @since 0.1
	 * 
	 * @param flags Flags
	 * @param flag Flag being set
	 * @return Result value
	 */
	internal static uint unset_flag (uint flags, uint flag)
	{
		return (flags & ~(flag));
	}

	/**
	 * Sets boolean flag
	 * 
	 * @since 0.1
	 * 
	 * @param do_set_flag Condition specifiying if flag should be set or unset
	 * @param flags Flags
	 * @param flag Flag being set
	 * @return Result value
	 */
	internal static uint cond_set_flag (bool do_set_flag, uint flags, uint flag)
	{
		if (do_set_flag == true)
			return (set_flag (flags, flag));
		else
			return (unset_flag (flags, flag));
	}

	/**
	 * Checks if specific flag is set or not
	 * 
	 * @since 0.1
	 * 
	 * @param set_flag Condition specifiying if flag should be set or unset
	 * @param flags Flags
	 * @param flag Flag being checked
	 * @return Result value
	 */
	internal static bool has_set_flag (uint flags, uint flag)
	{
		return ((flags & flag) == flag);
	}
}

