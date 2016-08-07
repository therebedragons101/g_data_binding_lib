namespace GData
{
	internal static string _null(bool markup = true)
	{
		return ("[%s]".printf(bold(red("null", markup), markup)));
	}

	internal static string color (string color, string str, bool markup = true)
	{
		if (markup == false)
			return (str);
		return ("<span color='%s'>%s</span>".printf(color, str));
	}

	internal static string green (string str, bool markup = true)
	{
		if (markup == false)
			return (str);
		return (color ("green", str));
	}

	internal static string red (string str, bool markup = true)
	{
		if (markup == false)
			return (str);
		return (color ("red", str));
	}

	internal static string yellow (string str, bool markup = true)
	{
		if (markup == false)
			return (str);
		return (color ("yellow", str));
	}

	internal static string blue (string str, bool markup = true)
	{
		if (markup == false)
			return (str);
		return (color ("blue", str));
	}

	internal static string italic (string str, bool markup = true)
	{
		if (markup == false)
			return (str);
		return ("<i>%s</i>".printf(str));
	}

	internal static string bold (string str, bool markup = true)
	{
		if (markup == false)
			return (str);
		return ("<b>%s</b>".printf(str));
	}

	internal static string small (string str, bool markup = true)
	{
		if (markup == false)
			return (str);
		return ("<small>%s</small>".printf(str));
	}

	internal static string big (string str, bool markup = true)
	{
		if (markup == false)
			return (str);
		return ("<big>%s</big>".printf(str));
	}

	internal string fix_markup (string str, bool markup = true)
	{
		if (markup == false)
			return (str);
		return (str.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"));
	}

	internal string bool_activity (bool state, bool markup = true)
	{
		return ((state == true) ? green(bold("ACTIVE", markup), markup) : red(bold("INACTIVE", markup), markup));
	}
}

