namespace G
{
	public class BindingPointerFromPropertyValue : BindingPointer
	{
		private bool data_disposed = true;
		private bool property_connected = false;
		private StrictWeakReference<Object?> _last = null;

		private string _data_property_name = "";
		public string data_property_name { 
			get { return (_data_property_name); }
		}

		private void handle_property_change (Object obj, ParamSpec prop)
		{
			_last = null;
			renew_data();
			if (_last.target != null)
				before_source_change (this, false, _last.target);
			if (_last.target != null)
				source_changed (this);
		}

		private void handle_before_source_change (BindingPointer pointer, bool is_same, Object? next)
		{
			if (_last.target != null) {
				if ((property_connected == true) || (data_disposed == false)) {
					get_source().notify[_data_property_name].disconnect (handle_property_change);
				}
				property_connected = false;
			}
			_last = null;
		}

		private void handle_source_changed (BindingPointer pointer)
		{
			_last = null;
			renew_data();
			if (_last.target != null) {
				if ((property_connected == true) || (data_disposed == false)) {
					_last.target.notify[_data_property_name].connect (handle_property_change);
					property_connected = false;
				}
			}
		}

		private void handle_strict_ref()
		{
			data_disposed = true;
			_last = null;
		}

		private void renew_data()
		{
			data_disposed = true;
			_last = new StrictWeakReference<Object?>(null);
			Object? obj;
			if (is_binding_pointer(data) == true)
				obj = ((BindingPointer) data).get_source();
			else
				obj = data;
			if (obj == null)
				return;
			ParamSpec? parm = ((ObjectClass) obj.get_type().class_ref()).find_property (_data_property_name);
			if (parm == null) {
				string? nn = PropertyAlias.get_instance(_data_property_name).get_for(obj.get_type());
				if (nn != null)
					parm = ((ObjectClass) obj.get_type().class_ref()).find_property (nn);
				if (parm == null)
					return;
			}
			if (parm.value_type.is_a(typeof(GLib.Object)) == false)
				return;
			GLib.Value val = GLib.Value(typeof(GLib.Object));
			obj.get_property (parm.name, ref val);
			Object oobj = val.get_object();
			data_disposed = false;
			_last = new StrictWeakReference<Object?>(oobj, handle_strict_ref);
		}

		protected override Object? redirect_to (ref bool redirect_in_play)
		{
			redirect_in_play = true;
			if (_last == null)
				renew_data();
			return (_last.target);
		}

		protected override bool reference_data()
		{
			bool res = base.reference_data();
			if (res == true) {
/*
				if ((reference_type == BindingReferenceType.WEAK) || (reference_type == BindingReferenceType.DEFAULT))
					data.weak_ref (handle_weak_ref);
				else
					data.@ref();
*/
			}
			return (true);
		}

		protected override bool unreference_data()
		{
			bool res = base.reference_data();
			if (res == true) {
			/*
				if ((reference_type == BindingReferenceType.WEAK) || (reference_type == BindingReferenceType.DEFAULT))
					data.weak_unref (handle_weak_ref);
				else
					data.unref();
					*/
			}
			data_disposed = false;
			return (true);
		}

		public BindingPointerFromPropertyValue (Object? data, string data_property_name, BindingReferenceType reference_type = BindingReferenceType.DEFAULT, BindingPointerUpdateType update_type = BindingPointerUpdateType.PROPERTY)
			requires (data_property_name != "")
		{
			base (data, reference_type, update_type);
			_data_property_name = data_property_name;
			before_source_change.connect (handle_before_source_change);
			source_changed.connect (handle_source_changed);
		}
	}
}
