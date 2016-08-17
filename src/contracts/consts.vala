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
	public const string MAP_ALIAS_DEFAULT = "map::alias::default";

	/**
	 * Default mapping alias which specifies mapping should look up alias
	 * for property in class that is specified to control visibility
	 * 
	 * @since 0.1
	 */
	public const string MAP_ALIAS_VISIBILITY = "map::alias::visibility";

	/**
	 * Default mapping alias which specifies mapping should look up alias
	 * for property in class that is specified to control sensitivity
	 * 
	 * @since 0.1
	 */
	public const string MAP_ALIAS_SENSITIVITY = "map::alias::sensitivity";
}
