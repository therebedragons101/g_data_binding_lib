using GData;
using GData.Generics;

namespace Demo
{
	public void example_custom_property_binding (DemoAndTutorial demo, Gtk.Builder ui_builder)
	{
		PropertyBinding.bind (ui_builder.get_object ("custom_binding_l1"), "text", 
		                      ui_builder.get_object ("custom_binding_r1"), "label", 
		                      BindFlags.SYNC_CREATE, 
			((b, src, ref tgt) => {
				tgt.set_string("value=" + src.get_string());
				return (true);
			}));

		PropertyBinding.bind (ui_builder.get_object ("custom_binding_l2"), "text", 
		                      ui_builder.get_object ("custom_binding_r2"), "text", 
		                      BindFlags.SYNC_CREATE | BindFlags.BIDIRECTIONAL, 
			((binding, src, ref tgt) => {
				((Gtk.Entry) binding.target).text = ((Gtk.Entry) binding.source).text;
				return (false);
			}),
			((binding, src, ref tgt) => {
				((Gtk.Entry) binding.source).text = ((Gtk.Entry) binding.target).text;
				return (false);
			}));

		GLib.Value.register_transform_func (typeof(string), typeof(bool), ((src, ref tgt) => {
			tgt.set_boolean ((src.get_string() != "") && (src.get_string() != null));
		}));

		PropertyBinding.bind (ui_builder.get_object ("custom_binding_l3"), "text", 
		                      ui_builder.get_object ("custom_binding_r3"), "active", BindFlags.SYNC_CREATE);

		PropertyBinding.bind (ui_builder.get_object ("custom_binding_l4"), "text", 
		                      ui_builder.get_object ("custom_binding_r4"), "active", 
		                      BindFlags.SYNC_CREATE | BindFlags.INVERT_BOOLEAN);
	}
}

