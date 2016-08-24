namespace GData
{
	/**
	 * Constant used to define CustomPropertyNotificationBindingSource to track
	 * all properties without the need to name them
	 * 
	 * @since 0.1
	 */
	public const string[]? ALL_PROPERTIES = {};
	/**
	 * Constant used to define CustomPropertyNotificationBindingSource to not track
	 * 
	 * @since 0.1
	 */
	public const string[]? NO_PROPERTY = { "" };

	/**
	 * Default mapping alias which specifies mapping should look up alias
	 * for property in class that is specified as default
	 * 
	 * @since 0.1
	 */
	public const string ALIAS_DEFAULT = "map::alias::default-value-property";

	/**
	 * Default mapping alias which specifies mapping should look up alias
	 * for property in class that is specified to control visibility
	 * 
	 * @since 0.1
	 */
	public const string ALIAS_VISIBILITY = "map::alias::visibility";

	/**
	 * Default mapping alias which specifies mapping should look up alias
	 * for property in class that is specified to control sensitivity
	 * 
	 * @since 0.1
	 */
	public const string ALIAS_SENSITIVITY = "map::alias::sensitivity";

	/**
	 * Default mapping alias which specifies mapping should look up alias
	 * for property in class that is specified to control min value
	 * 
	 * @since 0.1
	 */
	public const string ALIAS_MIN = "map::alias::minimum";

	/**
	 * Default mapping alias which specifies mapping should look up alias
	 * for property in class that is specified to control max value
	 * 
	 * @since 0.1
	 */
	public const string ALIAS_MAX = "map::alias::maximum";

	/**
	 * Default mapping alias which specifies mapping should look up alias
	 * for property in class that is specified to control length
	 * 
	 * @since 0.1
	 */
	public const string ALIAS_LENGTH = "map::alias::length";

	/**
	 * Default mapping alias which specifies mapping should look up alias
	 * for property in class that is specified to control secret
	 * 
	 * @since 0.1
	 */
	public const string ALIAS_SECRET = "map::alias::secret";
}

