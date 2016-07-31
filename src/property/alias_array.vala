namespace G.Data
{
	/**
	 * AliasArray is merely type definition to simplify code where used
	 * 
	 * - MK (key type for master array)
	 * - K (key type for slave array)
	 * - V (value type for slave array)
	 * 
	 * @since 0.1
	 */
	public class AliasArray : MasterSlaveArray<string, Type, string>
	{
	}
}
