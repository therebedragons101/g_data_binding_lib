namespace GData
{
	/**
	 * Singnal sent when contract is renewed/disolved or when source changes
	 * 
	 * @since 0.1
	 * @param contract Contract that changed
	 */
	public delegate void ContractChangedDelegate (BindingContract contract);

	/**
	 * Singnal sent when bindings in contract change
	 * 
	 * @since 0.1
	 * @param contract Contract that changed bindings
	 * @param change_type Specifies if binding was ADDED or REMOVED
	 * @param binding Binding that is subject of this signal
	 */
	public delegate void BindingsChangedDelegate (BindingContract contract, ContractChangeType change_type, BindingInformation binding);

	/**
	 * Signal that emits notification data in pointer has changed. When 
	 * needed, this signal should be emited either from outside code or from 
	 * connections made in "connect-notifications". Later is 
	 * probably much better for retaining clean code
	 * 
	 * The major useful part here is that contract is already binding pointer
	 * 
	 * @since 0.1
	 * @param source Pointer emiting this notification
	 * @param data_change_cookie Notification description. Can be signal
	 *                           name, property name or anything 
	 */
	public delegate void DataChangedDelegate (BindingPointer source, string data_change_cookie);

	/** 
	 * Signal is called whenever binding pointer "get_source()" would start 
	 * pointing to new valid location and allows custom handling to control 
	 * emission of custom notifications with "data-changed" This signal is 
	 * only emited when "binding-type" is MANUAL
	 * 
	 * @since 0.1
	 * @param obj Object that currently end of chain
	 */
	public delegate void ConnectNotificationsDelegate (Object? obj);

	/**
	 * Signal is called when "get_source()" is just about to be starting 
	 * pointing to something else in order for custom binding pointer to be 
	 * able to disconnect emission of custom "data-changed" notifications 
	 * This signal is only emited when "binding-type" is MANUAL
	 * 
	 * @since 0.1
	 * @param obj Object that currently end of chain
	 */ 
	public delegate void DisconnectNotificationsDelegate (Object? obj);

	/** 
	 * Signal specifies get_source() will be pointing to something else 
	 * after handling is over While it seems like a duplication of 
	 * "connect-notifications", it is not.
	 * 
	 * "connect-notifications" is only emited when "binding-type" is MANUAL 
	 * and there are a lot of cases when "connect-notifications" can retain 
	 * stable notifications trough whole application life, while 
	 * "before-source-change" will need to inform every interested part that 
	 * get_source() will now point to something new
	 * 
	 * @since 0.1
	 * @param source Pointer sending this notification
	 * @param same_type Specifies if next object is same type or not
	 * @param next_source Provides information which will be next end of
	 *                    chain
	 */
	public delegate void BeforeSourceChangeDelegate (BindingPointer source, bool same_type, Object? next_source);

	/** 
	 * Signal is sent after get_source() points to new data.
	 * 
	 * @since 0.1
	 * @param source Pointer sending this notification
	 */
	public delegate void SourceChangedDelegate (BindingPointer source);

	/**
	 * Signal emited when new Storage is added
	 * 
	 * @since 0.1
	 * 
	 * @param storage_name Name of new storage
	 */
	public delegate void NewStorageAddedDelegate (string storage_name);

	/**
	 * Signal emited when new contract is added to storage
	 * 
	 * @since 0.1
	 * @param name Name under which contract was stored
	 * @param obj Contract that was stored
	 */
	public delegate void ContractAddedToStorageDelegate (string name, BindingContract obj);

	/**
	 * Signal emited when contract is removed from storage
	 * 
	 * @since 0.1
	 * @param name Name under which contract was removed
	 * @param obj Contract that was removed
	 */
	public delegate void ContractRemovedFromStorageDelegate (string name, BindingContract obj);

	/**
	 * Signal emited when new pointer is added to storage
	 * 
	 * @since 0.1
	 * @param name Name under which pointer was stored
	 * @param obj Pointer that was stored
	 */
	public delegate void PointerAddedToStorageDelegate (string name, BindingPointer obj);

	/**
	 * Signal emited when pointer is removed from storage
	 * 
	 * @since 0.1
	 * @param name Name under which pointer was removed
	 * @param obj Pointer that was removed
	 */
	public delegate void PointerRemovedFromStorageDelegate (string name, BindingPointer obj);

	/**
	 * Signal emited when properties that are connected change in custom
	 * property notification source
	 * 
	 * @since 0.1
	 */ 
	public delegate void PropertiesChangedDelegate();

	/**
	 * Signal that can be emited when there is a need for custom in custom
	 * property notification source
	 * recalculation
	 * 
	 * @since 0.1
	 */ 
	public delegate void ManualRecalculationDelegate();

	/**
	 * Delegate used to connect to enumeration of for 3 tracking storages
	 * 
	 * @since 0.1
	 * 
	 * @param storage_name Storage name
	 */
	public delegate void StorageDelegateFunc (string storage_name);

	/**
	 * Delegate used to connect to enumeration of stored contracts
	 * 
	 * @since 0.1
	 * 
	 * @param name Contract name
	 * @param contract Contract reference
	 */
	public delegate void ContractStorageDelegateFunc (string name, BindingContract contract);

	/**
	 * Delegate used to connect to enumeration of stored contracts
	 * 
	 * @since 0.1
	 * 
	 * @param name Contract name
	 * @param pointer Pointer reference
	 */
	public delegate void PointerStorageDelegateFunc (string name, BindingPointer pointer);

	/**
	 * Delegate used to validate value of property in order to determine
	 * source data validity
	 * 
	 * @since 0.1
	 * @param source_value Value being checked
	 * @return true if valid, false if not
	 */
	public delegate bool SourceValidationFunc (Value? source_value);

	/**
	 * Delegate used to resolve value of state objects
	 * 
	 * @since 0.1
	 * @param source Pointer to source, use get_source() to get object reference
	 * @return true if state is valid, false if not
	 */
	public delegate bool CustomBindingSourceStateFunc (BindingPointer? source);

	/**
	 * Delegate used to evaluate value of value object
	 * 
	 * @since 0.1
	 * @param source Pointer to source, use get_source() to get object reference
	 * @return Value of value object 
	 */
	public delegate GLib.Value CustomBindingSourceValueFunc (BindingPointer? source);

	/**
	 * Delegate used to compare two values
	 * 
	 * @since 0.1
	 * 
	 * @param val1 First value
	 * @param val2 Second value
	 * @return -1 if lower, 0 if equal, 1 if greater
	 */
	public delegate int CompareValueFunc (GLib.Value val1, GLib.Value val2);
}
