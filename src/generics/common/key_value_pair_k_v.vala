namespace GData.Generics
{
	/**
	 * KeyValuePair specifies class that contains key and value which can
	 * be used to map hierarcical resulting lists
	 * 
	 * @since 0.1
	 */
	public class KeyValuePair<K,V> : Object
	{
		private K _key;
		/**
		 * Key value
		 * 
		 * @since 0.1
		 */
		public K key { 
			get { return (_key); } 
		}
		
		private V _val;
		/**
		 * Value of the pair
		 * 
		 * @since 0.1
		 */
		public V val { 
			get { return (_val); }
		}

		/**
		 * Creates KeyValuePair with assigned key and value
		 * 
		 * @since 0.1
		 */
		public KeyValuePair (K key, V value)
		{
			_key = key;
			_val = value;
		}
	}
}

