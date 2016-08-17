namespace GData
{
	internal class TextColors
	{
		private static TextColors? _instance = null;
		
		public static TextColors get_instance()
		{
			if (_instance == null)
				_instance = new TextColors();
			return (_instance);
		}

		public string __TYPE_COLOR__ = "yellow";
		public string __ACTIVE_COLOR__ = "green";
		public string __INACTIVE_COLOR__ = "red";
		public string __NULL_COLOR__ = "red";
		public string __RESERVED_WORD__ = "red";
		public string __INSENSITIVE__ = "gray";
		public string __INFORMATION__ = "yellow";
	}

	internal static string INFORMATION_COLOR (string str, bool markup = true)
	{
		return (color (TextColors.get_instance().__INFORMATION__, str, markup));
	}

	internal static string INSENSITIVE (string str, bool markup = true)
	{
		return (color (TextColors.get_instance().__INSENSITIVE__, str, markup));
	}

	internal static string RESERVED_WORD (string str, bool markup = true)
	{
		return (color (TextColors.get_instance().__RESERVED_WORD__, str, markup));
	}

	internal static string TYPE_COLOR (string str, bool markup = true)
	{
		return (color (TextColors.get_instance().__TYPE_COLOR__, str, markup));
	}

	internal static string ACTIVE_COLOR (string str, bool markup = true)
	{
		return (color (TextColors.get_instance().__ACTIVE_COLOR__, str, markup));
	}

	internal static string INACTIVE_COLOR (string str, bool markup = true)
	{
		return (color (TextColors.get_instance().__INACTIVE_COLOR__, str, markup));
	}

	internal static string NULL_COLOR (string str, bool markup = true)
	{
		return (color (TextColors.get_instance().__NULL_COLOR__, str, markup));
	}

	internal static string _null(bool markup = true)
	{
		return ("[%s]".printf(bold(NULL_COLOR("null", markup), markup)));
	}

	internal static string __null(bool markup = true)
	{
		return ("%s".printf(bold(NULL_COLOR("null", markup), markup)));
	}

	internal static string color (string color, string str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return ("<span color='%s'>%s</span>".printf(color, str));
	}

	internal static string gray (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return (color ("gray", str));
	}

	internal static string green (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return (color ("green", str));
	}

	internal static string red (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return (color ("red", str));
	}

	internal static string yellow (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return (color ("yellow", str));
	}

	internal static string darkyellow (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return (color ("darkyellow", str));
	}

	internal static string blue (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return (color ("blue", str));
	}

	internal static string italic (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return ("<i>%s</i>".printf(str));
	}

	internal static string underline (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return ("<u>%s</u>".printf(str));
	}

	internal static string bold (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return ("<b>%s</b>".printf(str));
	}

	internal static string small (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return ("<small>%s</small>".printf(str));
	}

	internal static string big (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return ("<big>%s</big>".printf(str));
	}

	internal string fix_markup (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return (str.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"));
	}

	internal string fix_markup2 (string? str, bool markup = true)
	{
		if ((markup == false) || (str == null))
			return (str);
		return (str.replace("&", "&amp;"));
	}

	internal string bool_activity (bool state, bool markup = true)
	{
		if (markup == false)
			return ((state == true) ? "ACTIVE" : "INACTIVE");
		return ((state == true) ? green(ACTIVE_COLOR("ACTIVE", markup), markup) : INACTIVE_COLOR(bold("INACTIVE", markup), markup));
	}
}

