namespace G
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
	 * Main purpose of state objects is giving possibility of static state 
	 * binding (visibility/sensitivity) and completely remove all need to track 
	 * which source is now active. State object refreshes whenever either source 
	 * in application. changes or notification for one of its registered 
	 * properties was emitted. this allows having single simple PropertyBinding 
	 * to buttons like Apply or other similar conditions.
	 *
	 * This also simplifies bindings as main objects don't need to be cluttered 
	 * with all sorts of random properties to support all the needed checks. 
	 * State objects can be added/removed per contract without slightest regard
	 * to state contract is in
	 *  
	 * NOTE!
	 * While set_data()/get_data() is slow, they only occur on adding/removing 
	 * state objects, where there is almost no use case binding contract could 
	 * require more than 10 per contract where 10 is greatly exaggerated.
	 * 
	 * Once added to they are instantly taken over by direct signals and never 
	 * rely on get_data/set_data for whole life time
	 * 
	 * @since 0.1
	 */
	public interface BindingStateObjects : Object
	{
		/**
		 * Cleans all state objects from activity and lifetime
		 * 
		 * @since 0.1
		 */
		public void clean_state_objects()
		{
			GLib.Array<CustomBindingSourceState>? arr = get_data<GLib.Array<CustomBindingSourceState>> (BINDING_SOURCE_STATE_DATA);
			if (arr == null)
				return;
			while (arr.length > 0)	
				remove_state (arr.data[arr.length-1].name);
		}

		/**
		 * Adds state object to implementor
		 * 
		 * @since 0.1
		 * @param state_object State object being added
		 * @returns Reference to added object in order to allow possibility of
		 *          chain API in objective languages
		 */
		public CustomBindingSourceState add_state (CustomBindingSourceState state_object)
		{
			GLib.Array<CustomBindingSourceState>? arr = get_data<GLib.Array<CustomBindingSourceState>> (BINDING_SOURCE_STATE_DATA);
			if (arr == null) {
				arr = new GLib.Array<CustomBindingSourceState>();
				set_data<GLib.Array<CustomBindingSourceState>> (BINDING_SOURCE_STATE_DATA, arr);
			}
			for (int i=0; i<arr.length; i++)
				if (arr.data[i].name == state_object.name)
					return (arr.data[i]);
			arr.append_val (state_object);
			return (state_object);
		}

		/**
		 * Resolves state object by name and returns its reference
		 * 
		 * @since 0.1
		 * @param name Name of needed state object
		 * @return State object reference if found or null if not
		 */
		public CustomBindingSourceState? get_state_object (string name)
		{
			GLib.Array<CustomBindingSourceState>? arr = get_data<GLib.Array<CustomBindingSourceState>> (BINDING_SOURCE_STATE_DATA);
			if (arr == null)
				return (null);
			for (int i=0; i<arr.length; i++)
				if (arr.data[i].name == name)
					return ((CustomBindingSourceState?) arr.data[i]);
			return (null);
		}

		/**
		 * Removes state object from implementor
		 * 
		 * @since 0.1
		 * @param name Name of state object being removed
		 */
		public void remove_state (string name)
		{
			GLib.Array<CustomBindingSourceState>? arr = get_data<GLib.Array<CustomBindingSourceState>> (BINDING_SOURCE_STATE_DATA);
			if (arr == null)
				return;
			for (int i=0; i<arr.length; i++) {
				if (arr.data[i].name == name) {
					arr.data[i].disconnect_object();
					arr.remove_index (i);
					return;
				}
			}
		}
	}
}
