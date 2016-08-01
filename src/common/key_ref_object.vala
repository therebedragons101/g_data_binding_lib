namespace G.Data
{
	/**
	 * KeyValueObject specifies class that contains key and value which can
	 * be used to map hierarcical resulting lists
	 * 
	 * @since 0.1
	 */
	public class KeyValueObject : Object
	{
		private GLib.Value _key;
		/**
		 * Key value
		 * 
		 * @since 0.1
		 */
		public GLib.Value key { 
			get { return (_key); } 
		}
		
		private StrictWeakRef _val;
		/**
		 * Value of the pair
		 * 
		 * @since 0.1
		 */
		public Object val { 
			get { return (_val.target); }
		}

		/**
		 * Creates KeyValueObject with assigned key and value
		 * 
		 * @since 0.1
		 */
		public KeyValueObject (GLib.Value key, Object value)
		{
			_key = key;
			_val = new StrictWeakRef(value);
		}
	}
}

