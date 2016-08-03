using GLib;

namespace GData
{
	public const int MAJOR_VERSION = 0;
	public const int MINOR_VERSION = 1;

	/**
	 * Returns string representation of library version
	 *
	 * Note that major version guarantees stable api, while
	 * minor version can represent only incremental updates
	 *
	 * If api needs to be broken, only way to do that is by
	 * bumping major release
	 *
	 * Note!
	 * Only temporary exception to break rule is major version 
	 * 0 as it would be best to bump to 1 after testing api
	 * in production
	 *
	 * @since 0.1
	 */
	public static string get_version()
	{
		return ("%i.%i".printf (MAJOR_VERSION, MINOR_VERSION));
	}

	[Flags]
	public enum DebugMessageType
	{
		NONE,
		INFORMATION,
		WARNING,
		CRITICAL,
		FATAL,
		ALL = INFORMATION | WARNING | CRITICAL | FATAL,
		ERRORS = CRITICAL | FATAL;
	}

	public delegate void DebugDelegate (DebugMessageType type, string facility, string message, string details);

	internal class DebugSignals : Object
	{
		private static DebugSignals _instance = null;

		internal static DebugSignals get_instance()
		{
			if (_instance == null)
				_instance = new DebugSignals();
			return (_instance);
		}

		internal int _internal_counter = 0;

		internal bool active = true;

		internal DebugMessageType enabled_types = DebugMessageType.ALL;

		internal signal void debug_message (DebugMessageType type, string facility, string message, string details);

		private DebugSignals()
		{
		}
	}

	private static void emit_information (bool emit, DebugMessageType type, string facility, string message, string details)
	{
		if (emit == false)
			return;
		if ((DebugSignals.get_instance()._internal_counter <= 0) || (DebugSignals.get_instance().active == false))
			return;
		if ((DebugSignals.get_instance().enabled_types & type) != type)
			return;
		DebugSignals.get_instance().debug_message (type, facility, message, details);
	}

	public static void INFORMATION (string facility, string message, string details = "")
	{
		emit_information (true, DebugMessageType.INFORMATION, facility, message, details);
	}

	public static void cond_INFORMATION (bool emit, string facility, string message, string details = "")
	{
		emit_information (emit, DebugMessageType.INFORMATION, facility, message, details);
	}

	public static void WARNING (string facility, string message, string details = "")
	{
		emit_information (true, DebugMessageType.WARNING, facility, message, details);
	}

	public static void cond_WARNING (bool emit, string facility, string message, string details = "")
	{
		emit_information (emit, DebugMessageType.WARNING, facility, message, details);
	}

	public static void CRITICAL (string facility, string message, string details = "")
	{
		emit_information (true, DebugMessageType.CRITICAL, facility, message, details);
	}

	public static void cond_CRITICAL (bool emit, string facility, string message, string details = "")
	{
		emit_information (emit, DebugMessageType.CRITICAL, facility, message, details);
	}

	public static void FATAL (string facility, string message, string details)
	{
		emit_information (true, DebugMessageType.FATAL, facility, message, details);
	}

	public static void cond_FATAL (bool emit, string facility, string message, string details = "")
	{
		emit_information (emit, DebugMessageType.FATAL, facility, message, details);
	}

/*	public static void connect_debug_tracer_method (DebugDelegate method)
	{
		DebugSignals.get_instance()._internal_counter++;
		DebugSignals.get_instance().debug_message.connect (method);
	}

	public static void disconnect_debug_tracer_method (DebugDelegate method)
	{
		DebugSignals.get_instance()._internal_counter--;
		DebugSignals.get_instance().debug_message.disconnect (method);
	}*/

	public static void set_debug_flags (DebugMessageType flags)
	{
		DebugSignals.get_instance().enabled_types = flags;
	}

	public static void GLIB_DEBUG_OUTPUT (DebugMessageType type, string facility, string message, string details)
	{
		if (type == DebugMessageType.INFORMATION)
			GLib.info ("INFO[%s]:%s%s", facility, message, (details != "") ? "\n%s".printf(details) : "");
		else if (type == DebugMessageType.WARNING)
			GLib.warning ("WARNING[%s]:%s%s", facility, message, (details != "") ? "\n%s".printf(details) : "");
		else if (type == DebugMessageType.CRITICAL)
			GLib.error ("CRITICAL[%s]:%s%s", facility, message, (details != "") ? "\n%s".printf(details) : "");
		else if (type == DebugMessageType.FATAL)
			GLib.critical ("FATAL[%s]:%s%s", facility, message, (details != "") ? "\n%s".printf(details) : "");
	}

	public static void set_debug_state (bool active)
	{
		DebugSignals.get_instance().active = active;
	}
}
