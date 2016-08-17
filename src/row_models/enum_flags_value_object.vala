namespace GData
{
	public class EnumFlagsValueObject : Object
	{
		private EnumValue? _enum = null;
		private FlagsValue? _flags = null;

		public int value { 
			get { return ((_enum != null) ? _enum.value : (int) _flags.value); }
		}

		public unowned string name {
			get { return ((_enum != null) ? _enum.value_name : _flags.value_name); }
		}

		public unowned string nick {
			get { return ((_enum != null) ? _enum.value_nick : _flags.value_nick); }
		}

		public EnumFlagsValueObject.as_enum (EnumValue val)
		{
			_enum = val;
		}

		public EnumFlagsValueObject.as_flags (FlagsValue val)
		{
			_flags = val;
		}
	}
}
