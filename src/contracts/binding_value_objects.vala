namespace GData
{
	/**
	 * IMPORTANT! Best and easiest method to understand state/value objects is 
	 * to run tutorial demo. Demo focuses on visually exposing all internals and
	 * events and makes something complex something really trivial. It will be
	 * difference between minutes and god knows how long 
	 * 
	 * Adds completely self-dependent functionality to be easily included in any 
	 * class
	 * 
	 * Much like state objects, main purpose of value objects is giving 
	 * possibility of static binding and completely remove all need to track 
	 * which source is now active. Value object refreshes whenever either source 
	 * in application. changes or notification for one of its registered 
	 * properties was emitted. this allows having single simple PropertyBinding 
	 * to specific value that is automatically updated this also simplifies 
	 * bindings as main objects don't need to be cluttered with all sorts of 
	 * random properties to support all the needed functionality per case. 
	 * Value objects can be added/removed without slightest regard to state 
	 * contract is in
	 * 
	 * Note that CustomPropertyNotificationBindingSource is used as type for
	 * value objects. This is intentional decision to make more flexible custom
	 * value object classes 
	 * 
	 * NOTE!
	 * While set_data/get_data is slow, they only occur on adding/removing state 
	 * objects, where there is almost no use case binding contract could require 
	 * more than 10 per contract where 10 is exaggerated.
	 * 
	 * Once added to they are instantly taken over by direct signals and never 
	 * rely on get_data/set_data for whole life time
	 * 
	 * @since 0.1
	 */
	public interface BindingValueObjects : Object
	{
		/**
		 * Cleans all value objects from activity and lifetime
		 * 
		 * @since 0.1
		 */
		public void clean_source_values()
		{
			GObjectArray? arr = get_data<GObjectArray> (BINDING_SOURCE_VALUE_DATA);
			if (arr == null)
				return;
			while (arr.length > 0)
				remove_source_value (as_binding_object(arr.data[arr.length-1]).name);
		}

		/**
		 * Adds value object to implementor
		 * 
		 * @since 0.1
		 * @param data_object State object being added
		 * @returns Reference to added object in order to allow possibility of
		 *          chain API in objective languages
		 */
		public CustomPropertyNotificationBindingSource add_source_value (CustomPropertyNotificationBindingSource data_object)
		{
			GObjectArray? arr = get_data<GObjectArray> (BINDING_SOURCE_VALUE_DATA);
			if (arr == null) {
				arr = new GObjectArray();
				set_data<GObjectArray> (BINDING_SOURCE_VALUE_DATA, arr);
			}
			for (int i=0; i<arr.length; i++)
				if (as_binding_object(arr.data[i]).name == data_object.name)
					return (as_binding_object(arr.data[i]));
			arr.add (data_object);
			value_objects_changed (data_object, ContractChangeType.ADDED);
			return (data_object);
		}

		/**
		 * Resolves value object by name and returns its reference
		 * 
		 * @since 0.1
		 * @param name Name of needed state object
		 * @return Value object reference if found or null if not
		 */
		public CustomPropertyNotificationBindingSource? get_source_value (string name)
		{
			GObjectArray? arr = get_data<GObjectArray> (BINDING_SOURCE_VALUE_DATA);
			if (arr == null)
				return (null);
			for (int i=0; i<arr.length; i++)
				if (as_binding_object(arr.data[i]).name == name)
					return (as_binding_object(arr.data[i]));
			return (null);
		}

		/**
		 * Removes value object from implementor
		 * 
		 * @since 0.1
		 * @param name Name of state object being removed
		 */
		public void remove_source_value (string name)
		{
			GObjectArray? arr = get_data<GObjectArray> (BINDING_SOURCE_VALUE_DATA);
			if (arr == null)
				return;
			for (int i=0; i<arr.length; i++) {
				if (as_binding_object(arr.data[i]).name == name) {
					CustomPropertyNotificationBindingSource obj = as_binding_object(arr.data[i]);
					arr.remove_at_index (i);
					value_objects_changed (obj, ContractChangeType.REMOVED);
					obj.disconnect_object();
					obj = null;
					return;
				}
			}
		}

		/**
		 * Signal is sent whenever value object is added or removed. Value 
		 * change is never signaled here. For state change it is better to rely
		 * on "state" property value and binding to the object
		 * 
		 * @since 0.1
		 * 
		 * @param object Object being added or removed
		 * @param change_type Type of change
		 */
		public signal void value_objects_changed (CustomPropertyNotificationBindingSource object, ContractChangeType change_type);
	}
}
