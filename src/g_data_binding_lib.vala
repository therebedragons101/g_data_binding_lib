using GLib;

namespace G
{
	public const int MAJOR_VERSION = 0;
	public const int MINOR_VERSION = 1;

	public static string get_version()
	{
		return (@"$MAJOR_VERSION.$MINOR_VERSION");
	}
}
