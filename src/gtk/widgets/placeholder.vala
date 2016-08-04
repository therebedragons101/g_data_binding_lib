using GData;
using GData.Generics;

namespace GDataGtk
{
	public const string STOP_ICON = "action-unavailable-symbolic.symbolic";
	public const string PROCESSING_ICON = "system-run-symbolic.symbolic";

	[GtkTemplate (ui="/org/gtk/g_data_binding_gtk/data/placeholder.ui")]
	public class Placeholder : Gtk.Box
	{
		private string _label_css = """
			* {
				font-size: %ipx;
			}
		""";

		private Gtk.CssProvider? _provider = null;
		internal string label_css {
			set {
				if (_provider != null)
					wlabel.get_style_context().remove_provider (_provider);
				_provider = assign_css (wlabel, value);
			}
		}

		[GtkChild]
		private Gtk.Label wlabel;
		[GtkChild]
		private Gtk.Box image_box;

		public bool use_markup { get; set; }

		private Gtk.IconSize _size = Gtk.IconSize.DIALOG;
		internal Gtk.IconSize size {
			get { return (_size); }
			set { 
				_size = value;
				label_css = _label_css.printf(WidgetDefaults.get_default().get_icon_size(size)/4);
			}
		}

		private string label {
			get { return (wlabel.label); }
			set {
				if (use_markup == true)
					wlabel.set_markup (value);
				else
					wlabel.label = value;
			}
		}

		private Gtk.Image? _image = null;
		public Gtk.Image? image {
			get { return (_image); }
			set {
				if (_image == value)
					return;
				if (_image != null)
					image_box.remove (_image);
				_image = value;
				if (_image != null) {
					image_box.add (_image);
					_image.opacity = 0.5;
				}
			}
		}

		public Placeholder.from_icon (string label = "No items found", 
		                              Gtk.IconSize size = Gtk.IconSize.DIALOG,
		                              string icon_name = STOP_ICON) 
		{
			this(label, size, 
				create_image_from_icon (icon_name, null, null, WidgetDefaults.get_default().get_icon_size(size), false));
		}

		public Placeholder (string label, Gtk.IconSize size, Gtk.Image image)
		{
			this.label = label;
			this.image = image;
			this.size = size;
		}
	}
}

