using GData;

namespace DemoAndTutorial
{
	private BindingPointer my_pointer;

	public void example_pointer_hold()
	{
		// my pointer reference is being held by global variable here
		my_pointer = new BindingPointer();

		// now to create pointer that is only middle chain link
		// note that since declaration is local, its reference count
		// would be 0 at the end of this method. hold() on the other
		// hand locks its lifetime to it self. as such middle_pointer
		// will be released exactly when my_pointer is
		BindingPointer middle_pointer = my_pointer.hold (new BindingPointer());

		// from here on we could build the rest of the chain
	}
}
