using GData;

namespace GDataGtk
{
	/**
	 * Data binding inspector window provides runtime information like 
	 * gtk-inspector does
	 * 
	 * @since 0.1
	 */
	public class InspectorWindow : Gtk.Window
	{
		private static bool inspector_is_visible { get; private set; default = false; }

		private static InspectorWindow? _window = null;
		public static InspectorWindow window {
			get {
				if ((inspector_is_visible == false) || (_window == null)) {
					_window = new InspectorWindow();
					_window.hide.connect (() => {
						_window.destroy();
						_window = null;
					});
					_window.show();
				}
				return (_window); 
			}
		}

		private Object? _current_data = null;

		public static void show_inspector (BindingPointer? inspect)
		{
			window.present();
			if (window._current_data != inspect)
				window._current_data = inspect;
		}

		public static void set_inspector_target (BindingPointer? inspect)
		{
			if (inspector_is_visible == false)
				show_inspector (inspect);
			else
				window._current_data = inspect;
		}

		private InspectorWindow()
		{
		}
	}
}

