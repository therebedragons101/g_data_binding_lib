namespace GData
{
	/**
	 * IMPORTANT! Best and easiest method to understand binding pointers is to
	 * run tutorial demo. Demo focuses on visually exposing all internals and
	 * events and makes something complex something really trivial. It will be
	 * difference between minutes and god knows how long
	 * 
	 * BindingPointerFromPropertyValue provides ability to redirect data to
	 * object that is presented by property inside of normal "data"
	 * 
	 * @since 0.1
	 */
	public class BindingPointerFromPropertyValue : BindingPointer
	{
		private bool data_disposed = true;
		private bool property_connected = false;
		private StrictWeakReference<Object?> _last = null;

		private string _data_property_name = "";
		/**
		 * Property name in object pointed with get_source() whose value should
		 * be returned as redirection source
		 * 
		 * @since 0.1
		 */
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

		/**
		 * One of two core subclassing capabilities. By overriding this method
		 * pointer can redirect its result or even break chain with completely
		 * different continuation. There is no limit on how many times chain
		 * is broken and redirected
		 * 
		 * This method is called as part of get_source() and when this method
		 * sets redirect_in_play to true does not return normal result, but 
		 * rather result provided in redirect_to()
		 * 
		 * BindingPointer subclass that implements this is 
		 * BindingPointerFromPropertyValue which is also featured in tutorial
		 * in order to be easy to understand
		 * 
		 * @since 0.1
		 * @param redirect_in_play If this is set to true, value of get_source()
		 *                         will be result of this method
		 * @return Object or null where pointer should be redirected 
		 */
		protected override Object? redirect_to (ref bool redirect_in_play)
		{
			redirect_in_play = true;
			if (_last == null)
				renew_data();
			return (_last.target);
		}

		/**
		 * Method called when new source is being held and there is a need to
		 * reference it.
		 * 
		 * Note that data can be null when called 
		 * 
		 * @since 0.1
		 */
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

		/**
		 * Method called when old source is being released and there is a need 
		 * to unreference it.
		 * 
		 * Note that data can be null when called 
		 * 
		 * @since 0.1
		 */
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
		/**
		 * Creates new BindingPointerFromPropertyValue
		 * 
		 * @since 0.1
		 * @param data Data used as initial source. If data is pointer or 
		 *             contract this leads to chaining them. More on chaining
		 *             in tutorial application
		 * @param data_property_name Property name which is used for redirect
		 * @param reference_type Specifies how source reference should be 
		 *                       treated. Value can be WEAK, STRONG or DEFAULT
		 * @param update_type Defines if source can be treated by connecting to
		 *                    its properties or source will specify its own 
		 *                    handling. In case of chaining this is also taking
		 *                    effect in chain. More on chaining in tutorial 
		 *                    application
		 */

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
