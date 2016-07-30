namespace G
{
	/**
	 * Type simplification for KeyValueArray of KeyValueArrays. Generic 
	 * structure is just too complex (ObjectArray of KeyValuePair for key
	 * ObjectArray of KeyValuePairs
	 * 
	 * MK - master key
	 * K - slave key
	 * V - value 
	 * 
	 * @since 0.1
	 */
	public class MasterSlaveArray<MK,K,V> : KeyValueArray<MK, KeyValueArray<K, V>>
	{
	}
}
