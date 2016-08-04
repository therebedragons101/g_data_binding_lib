namespace GDataGtk
{
	internal class WidgetDefaults : Object
	{
		private static WidgetDefaults? _instance = null;
		protected static WidgetDefaults instance {
			get {
				if (_instance == null)
					_instance = new WidgetDefaults();
				return (_instance);
			}
		}

		public static WidgetDefaults get_default()
		{
			if (_instance == null)
				_instance = new WidgetDefaults();
			return (_instance);
		}

		private Gtk.IconTheme _theme = null;
		public Gtk.IconTheme theme {
			get { 
				if (_theme == null)
					_theme = new Gtk.IconTheme();
				return (_theme); 
			}
		}

		public bool use_symbolic_icons { get; set; default = true; }

		public int get_icon_size (Gtk.IconSize size)
		{
			int x,y;
			Gtk.icon_size_lookup (size, out x, out y);
			return (x);
		}

		private WidgetDefaults()
		{
		}
	}
}

