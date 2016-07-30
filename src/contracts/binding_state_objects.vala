//TODO, rename to BindingObjects
namespace G
{
	// Adds completely self-dependent functionality to be easily included in any class
	//
	// While set_data/get_data is slow, they only occur on adding/removing state objects, where there is
	// almost no use case binding contract could require more than 10 per contract where 10 is exaggerated.
	//
	// Once added to they are instantly taken over by direct signals and never rely on get_data/set_data 
	// for whole life time
	public interface IBindingStateObjects : Object
	{
		// these methods only practical use is to simplify code using them as it 
		// removes strain for application to keep the reference validity
		public void clean_state_objects()
		{
			GLib.Array<CustomBindingSourceState>? arr = get_data<GLib.Array<CustomBindingSourceState>> (BINDING_SOURCE_STATE_DATA);
			if (arr == null)
				return;
			while (arr.length > 0)	
				remove_state (arr.data[arr.length-1].name);
		}

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
