namespace DemoAddressBook
{
	public class DemoAddressBookApplication : Gtk.Application
	{
		private MainWindow window;

		public DemoAddressBookApplication ()
		{
			Object (flags: ApplicationFlags.FLAGS_NONE);
		}

		private void set_ui()
		{
			Gtk.Settings.get_default().gtk_application_prefer_dark_theme = true;

			Environment.set_application_name ("demo_address_book");

			window = new MainWindow();
			add_window (window);
		}

		protected override void startup ()
		{
			base.startup ();
			GDataGtk.DefaultWidgets.init();
			set_ui();
		}

		protected override void shutdown ()
		{
			base.shutdown ();
		}

		protected override void activate ()
		{
			window.present ();
		}

		public static int main(string[] args)
		{
			var app = new DemoAddressBookApplication ();
			return (app.run (args));
		}
	}
}
