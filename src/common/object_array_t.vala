namespace G
{
	public class ObjectArray<T> : Object, ListModel
	{
		// ListModel implementation
		public Object? get_item (uint position)
		{
			return (((position < 0) || (position >= length)) ? null : (Object?) data[position]);
		}
		
		public Type get_item_type ()
		{
			return (typeof(T));
		}
		
		public uint get_n_items()
		{
			return ((uint) length);
		}
		// ListModel implementation end
		
		private bool _dont_dispatch_signals = false;

		public bool force_unique { get; set; default = false; }
		
		private GLib.Array<T>? _array = new GLib.Array<T>();
		public GLib.Array<T> array {
			get { return (_array); }
		}

		public T[] data {
			get { return (_array.data); }
		}

		public int length {
			get { return ((int) _array.length); }
		}

		public void swap (int index1, int index2)
		{
			if ((index1 < 0) || (index1 >= length))
				return;
			if ((index2 < 0) || (index2 >= length))
				return;
			T tmp = _array.data[index1];
			_array.data[index1] = _array.data[index2];
			_array.data[index2] = tmp;
		}

		public int find (T object)
		{
			for (int i=0; i<_array.length; i++)
				if (_compare_delegate(_array.data[i], object) == 0)
					return (i);
			return (-1);
		}

		public int search_for (FindObjectDelegate<T> func)
		{
			for (int i=0; i<length; i++)
				if (func(data[i]) == true)
					return (i);
			return (-1);
		}

		public void add (T object)
		{
			if (force_unique == true)
				add_unique (object);
			else {
				_array.append_val (object);
				items_changed (length-1, 0, 1);
				element_added (object);
			}
		}

		public T add_unique (T object, bool nosearch = false)
		{
			if (nosearch == false) {
				int i = find (object);
				if (i >= 0)
					return (data[i]);
			}
			_array.append_val (object);
			items_changed (length-1, 0, 1);
			element_added (object);
			return (object);
		}

		public void remove (T object)
		{
			int i = find(object);
			if (i >= 0)
				remove_at_index(i);
		}

		public void remove_at_index (int index)
		{
			if ((index < 0) || (index >= length))
				return;
			T element = _array.data[index];
			before_removing_element (element, index);
			items_changed (index, 1, 0);
			_array.remove_index (index);
			element_removed (element);
		}

		public void clear()
		{
			_dont_dispatch_signals = true;
			while (length > 0)
				remove_at_index(0);
			_dont_dispatch_signals = false;

			array_cleared();
		}

		public void sort()
		{
			custom_sort (_compare_delegate);
		}

		public void custom_sort (CompareFunc func)
		{
			_array.sort (func);
			array_sorted();
		}

		public void foreach (Func<T> func, bool backwards = false)
		{
			if (backwards == true) {
				for (int i=(length-1); i>=0; i++)
					func (data[i]);
			}
			else {
				for (int i=0; i<length; i++)
					func (data[i]);
			}
		}

		private CompareFunc<T> _compare_delegate;

		private static int compare___by_reference (T object1, T object2)
		{
			return ((object1 == object2) ? 0 : -1);
		}

		private static int compare___by_properties (T object1, T object2)
		{
			return (((UniqueByProperies) object1).compare_to ((UniqueByProperies) object2));
		}

		public signal void element_added (T element);		

		public signal void before_removing_element (T element, int index);		

		public signal void element_removed (T element);		

		public signal void array_cleared();		

		public signal void array_sorted();		

		public ObjectArray.unique (CompareDataBy compare_by = CompareDataBy.REFERENCE, owned CompareFunc<T>? compare_method = null)
		{
			this (compare_by, compare_method);
			force_unique = true;
		}

		public ObjectArray.from_array (GLib.Array<T> from_array, CompareDataBy compare_by = CompareDataBy.REFERENCE, owned CompareFunc<T>? compare_method = null)
		{
			this (compare_by, compare_method);
			_array = from_array;
		}
		
		public ObjectArray.unique_from_array (GLib.Array<T> from_array, CompareDataBy compare_by = CompareDataBy.REFERENCE, owned CompareFunc<T>? compare_method = null)
		{
			this (compare_by, compare_method);
			force_unique = true;
			_array = from_array;
		}
		
		public ObjectArray (CompareDataBy compare_by = CompareDataBy.REFERENCE, CompareFunc<T>? compare_method = null)
		{
			if (compare_by == CompareDataBy.REFERENCE)
				_compare_delegate = ((a, b) => { return (compare___by_reference (a, b)); });
			else if (compare_by == CompareDataBy.UNIQUE_OBJECTS)
				_compare_delegate = ((a, b) => { return (compare___by_properties (a, b)); });
			else if (compare_by == CompareDataBy.FUNCTION)
				_compare_delegate = compare_method;
		}
	}
}
