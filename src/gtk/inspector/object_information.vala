namespace GDataGtk
{
	// note that this interface is in no way required for databinding
	// its whole purpose is having uniform way of displaying events
	// for this demo in order to be able to propagate more descriptive
	// events
	public interface ObjectInformation : Object
	{
		public abstract string get_info();
	}
}
