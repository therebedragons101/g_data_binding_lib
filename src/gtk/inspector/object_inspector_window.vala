using GData;
using GData.Generics;

namespace GDataGtk
{
	internal static bool object_inspector_is_visible = false;
//	internal ObjectInspectorWindow object_inspector_window = null;

	internal static void __add_to_object_inspector(Object? obj)
	{
		ObjectInspectorWindow.add (obj);
	}

	internal static void __remove_from_object_inspector(Object? obj)
	{
		ObjectInspectorWindow.remove (obj);
	}

	internal static void __clean_object_inspector()
	{
		ObjectInspectorWindow.clean_objects();
	}

	internal class ObjectInspectorWindow : Object
	{
		private bool ignore_selection = false;
		private bool left_side = true;
		private ObjectArray<WeakRefWrapper> _objects = new ObjectArray<WeakRefWrapper>();

		private static ObjectInspectorWindow? _instance = null;
		internal static ObjectInspectorWindow get_instance() 
		{
			if (_instance == null) {
				object_inspector_is_visible = true;
				_instance = new ObjectInspectorWindow();
				_instance.window.show();
			}
			return (_instance);
		}

		private Gtk.Window window;
		private Gtk.MenuButton select_object;
		private Gtk.MenuButton select_comparison_object;
		private Gtk.ToggleButton enable_comparison;
		private Gtk.Box object_inspector_container;
		private Gtk.Box object_inspector_comparison_container;
		private Gtk.Box object_selector;
		private Gtk.ListBox object_items;
		private ObjectInspector selection;
		private ObjectInspector comparison;
		private Gtk.ToggleButton link_views;
		private Gtk.MenuButton add_from_source;
		private Gtk.MenuButton properties;

		private void reparent_selector (Gtk.Popover new_owner)
		{
			if (object_selector.get_parent() == new_owner)
				return;
			if (object_selector.get_parent() != null)
				object_selector.get_parent().remove (object_selector);
			new_owner.add (object_selector);
		}

		private Object? get_selection (Gtk.ListBoxRow row)
		{
			WeakRefWrapper? w = row.get_data<WeakRefWrapper> ("object");
			if (w != null)
				return (w.target);
			return (null);
		}

		private void set_null_selection ()
		{
			ignore_selection = true;
			object_items.select_row (null);
			ignore_selection = false;
		}

		internal static void clean_objects()
		{
			for (int i=0; i<get_instance()._objects.length; i++)
				get_instance()._objects.data[i].set_new_target(null);
			get_instance()._objects.clear();
			get_instance().selection.inspected_object = null;
			get_instance().comparison.inspected_object = null;
		}

		private static void handle_null()
		{
			for (int i=get_instance()._objects.length-1; i>=0; i++)
				if (get_instance()._objects.data[i].target == null)
					get_instance()._objects.remove_at_index(i);
		}

		internal static void add (Object? obj)
		{
			if (obj == null)
				return;
stdout.printf ("Add\n");
			for (int i=0; i<get_instance()._objects.length; i++)
				if (get_instance()._objects.data[i].target == obj)
					return;
			get_instance()._objects.add (new WeakRefWrapper(obj, handle_null));
			get_instance().selection.inspected_object = obj;
		}

		internal static void remove (Object? obj)
		{
			if (obj == null)
				return;
stdout.printf ("Remove\n");
			for (int i=0; i<get_instance()._objects.length; i++)
				if (get_instance()._objects.data[i].target == obj)
					get_instance()._objects.remove_at_index(i);
		}

/*		private void sync_views()
		{
			comparison.inspected_object = selection.inspected_object;
			
		}*/

		private ObjectInspectorWindow()
		{
			object_inspector_is_visible = true;

			var ui_builder = new Gtk.Builder ();
			try {
				ui_builder.add_from_resource ("/org/gtk/g_data_binding_gtk/data/object_inspector_window.ui");
			}
			catch (Error e) { warning ("Could not load demo UI: %s", e.message); }
			window = (Gtk.Window) ui_builder.get_object ("object_inspector_window");

			Gtk.HeaderBar hbar = (Gtk.HeaderBar) ui_builder.get_object ("object_inspector_window_headerbar");
			window.set_titlebar (hbar);
			window.show();

			select_object = (Gtk.MenuButton) ui_builder.get_object ("select_object");
			select_comparison_object = (Gtk.MenuButton) ui_builder.get_object ("select_comparison_object");
			enable_comparison = (Gtk.ToggleButton) ui_builder.get_object ("enable_comparison");
			object_inspector_container = (Gtk.Box) ui_builder.get_object ("object_inspector_container");
			object_inspector_comparison_container = (Gtk.Box) ui_builder.get_object ("object_inspector_comparison_container");
			object_selector = (Gtk.Box) ui_builder.get_object ("object_selector");
			object_items = (Gtk.ListBox) ui_builder.get_object ("object_items");
			link_views = (Gtk.ToggleButton) ui_builder.get_object ("link_views");
			add_from_source = (Gtk.MenuButton) ui_builder.get_object ("add_from_source");
			properties = (Gtk.MenuButton) ui_builder.get_object ("properties");

			selection = new ObjectInspector();
			comparison = new ObjectInspector();
			object_inspector_container.pack_start (selection, true, true);
			object_inspector_comparison_container.pack_start (comparison, true, true);

			select_object.popover = new Gtk.Popover(select_object);
			select_comparison_object.popover = new Gtk.Popover(select_comparison_object);
			select_object.popover.show.connect (() => {
				reparent_selector(select_object.popover);
				left_side = true;
			});
			select_comparison_object.popover.show.connect (() => {
				reparent_selector(select_comparison_object.popover);
				left_side = false;
			});
			select_object.popover.hide.connect (() => {
				set_null_selection();
			});
			select_comparison_object.popover.hide.connect (() => {
				set_null_selection();
			});
			object_items.row_selected.connect ((r) => {
				if (ignore_selection == true)
					return;
				Object o = (left_side == true) ? selection.inspected_object : comparison.inspected_object;
				if (o != get_selection(r))
					((left_side == true) ? selection : comparison).inspected_object = get_selection(r);
			});
			_binder().bind (enable_comparison, "active", select_comparison_object, "visible", BindFlags.SYNC_CREATE);
			_binder().bind (enable_comparison, "active", link_views, "visible", BindFlags.SYNC_CREATE);
			_binder().bind (enable_comparison, "active", object_inspector_comparison_container, "visible", BindFlags.SYNC_CREATE);
			_binder().bind (link_views, "active", select_comparison_object, "sensitive", BindFlags.SYNC_CREATE | BindFlags.INVERT_BOOLEAN);
			link_views.toggled.connect (() => {
				if (link_views.active == true)
					comparison.sync_to (selection);
				else
					comparison.unsync();
			});
			object_items.bind_model (_objects, (o) => {
				SmoothListBoxRow r = new SmoothListBoxRow.with_delete(o);
				WeakRefWrapper wr = (WeakRefWrapper) o;
				if ((wr != null) && (wr.target != null)) {
					r.set_data<WeakRefWrapper> ("object", wr);
					Gtk.Label title = new Gtk.Label("");
					title.visible = true;
					title.hexpand = true;
					title.xalign = 0;
					title.use_markup = true;
					string ds = _get_full_object_str_desc(wr.target);
					if (ds.contains("\n") == true) {
						int pos = ds.last_index_of("\n");
						ds = ds.splice(pos, pos+"\n".length, " (") + ")";
					}
					title.set_markup(ds);
					r.get_container().pack_start (title, true, true);
				}
				else
					r.visible = false;
				r.action_taken.connect ((action, obj) => {
					if (action == ACTION_DELETE)
						__remove_from_object_inspector (wr.target);
				});
				return (r);
			});

			window.hide.connect (() => {
				for (int i=0; i<_objects.length; i++)
					_objects.data[i].set_new_target(null);
				selection.inspected_object = null;
				comparison.inspected_object = null;
				get_instance().window.destroy();
				_instance = null;
				object_inspector_is_visible = false;
			});
		}
	}
}

