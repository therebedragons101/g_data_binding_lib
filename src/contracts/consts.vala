namespace G.Data
{
	internal const string __DEFAULT__ = "**DEFAULT**";
	internal const string BINDING_SOURCE_STATE_DATA = "binding-source-state-data";
	internal const string BINDING_SOURCE_VALUE_DATA = "binding-source-value-data";

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
	public const string[]? NO_PROPERTY = null;

	internal static bool report_possible_binding_errors = false;
}
