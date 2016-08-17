using GData;
using GData.Generics;

namespace GDataGtk
{
	public class ListModelStore : Object, Gtk.TreeModel
	{
		private GLib.ListModel data;
		private int stamp = 0;

		private Gtk.TreeModelFlags _flags;

		public ListModelStore (owned GLib.ListModel? data = null)
		{
			if (data == null)
				this.data = new ObjectArray<Object>();
			else
				this.data = (owned) data;
		}

		public Type get_column_type (int index)
		{
			return (typeof(Object));
		}

		public Gtk.TreeModelFlags get_flags()
		{
			return (_flags);
		}

		private Object? iter_to_object (Gtk.TreeIter iter)
		{
			return ((Object?) iter.user_data);
		}

		private Gtk.TreeIter object_to_iter (Object? obj)
		{
			Gtk.TreeIter iter = Gtk.TreeIter();
			iter.user_data = obj;
		}

		public void get_value (Gtk.TreeIter iter, int column, out Value val)
		{
			Object? node = data.get ((Object?) iter.user_data);
			val = Value (typeof(Object));
			val.set_object (node);
		}

		public bool get_iter (out Gtk.TreeIter iter, Gtk.TreePath path)
		{
			Object? obj = data.get_object(path.indices[0]);
			for (int i=1; i<path.indices.length; i++)
				if (obj.is_a(typeof(GLib.ListModel)) == true)
					obj = ((GLib.ListModel) obj).get_object(path.indices[i]);
				else
					return invalid_iter (out iter);

			iter = object_to_iter (obj);
			return (true);
		}

		public int get_n_columns()
		{
			return (1);
		}

		public Gtk.TreePath? get_path (Gtk.TreeIter iter)
		{
			assert (iter.stamp == stamp);

			Gtk.TreePath path = new Gtk.TreePath ();
			path.append_index ((int) iter.user_data);
			return path;
		}

		public int iter_n_children (Gtk.TreeIter? iter)
		{
			Object? obj = iter_to_object (iter);
			if ((obj == null) || (obj.get_type().is_a(GLib.ListModel) == false))
				return (0);
			return (((GLib.ListModel) obj).length);
		}

		public bool iter_has_child (Gtk.TreeIter iter)
		{
			if ((_flags & Gtk.TreeModelFlags.LIST_ONLY) == Gtk.TreeModelFlags.LIST_ONLY)
				return (false);
			return (iter_n_children(iter) > 0);
		}

		public bool iter_next (ref Gtk.TreeIter iter) {
			assert (iter.stamp == stamp);

			int pos = ((int) iter.user_data) + 1;
			if (pos >= data.length) {
				return false;
			}
			iter.user_data = pos.to_pointer ();
			return true;
		}

		public bool iter_previous (ref Gtk.TreeIter iter) {
			assert (iter.stamp == stamp);

			int pos = (int) iter.user_data;
			if (pos >= 0) {
				return false;
			}

			iter.user_data = (--pos).to_pointer ();
			return true;
		}

		public bool iter_nth_child (out Gtk.TreeIter iter, Gtk.TreeIter? parent, int n) {
			assert (parent == null || parent.stamp == stamp);
			
			if (parent == null && n < data.length) {
				iter = Gtk.TreeIter ();
				iter.stamp = stamp;
				iter.user_data = n.to_pointer ();
				return true;
			}

			// Only used for trees
			return invalid_iter (out iter);
		}

		public bool iter_children (out Gtk.TreeIter iter, Gtk.TreeIter? parent) {
			assert (parent == null || parent.stamp == stamp);
			// Only used for trees
			return invalid_iter (out iter);
		}

		public bool iter_parent (out Gtk.TreeIter iter, Gtk.TreeIter child) {
			assert (child.stamp == stamp);
			// Only used for trees
			return invalid_iter (out iter);
		}

		private bool invalid_iter (out Gtk.TreeIter iter) {
			iter = Gtk.TreeIter ();
			iter.stamp = -1;		
			return false;
		}
	}

