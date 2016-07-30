namespace G
{
	public class KeyValuePair<K,V> : Object
	{
		public K key { get; private set; }
		public V val { get; private set; }

		public KeyValuePair (K key, V value)
		{
			this.key = key;
			this.val = value;
		}
	}
}
