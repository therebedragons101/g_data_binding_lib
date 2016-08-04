namespace GData
{
	/**
	 * Flags specified upon creation of new BindingInterface to describe how
	 * binding should act
	 * 
	 * @since 0.1
	 */ 
	[Flags]
	public enum BindFlags
	{
		/**
		 * Default is simply automated transferal from source to target without
		 * initial syncing
		 * 
		 * @since 0.1
		 */
		DEFAULT,
		/**
		 * Specifies that data should be synced upon creation from source to 
		 * target. This direction is reversed if there is also specified flag
		 * REVERSE_DIRECTION.
		 * 
		 * SYNC_CREATE is as well recalled on every effective unfreeze() (when
		 * freeze counter reaches 0)
		 * 
		 * @since 0.1
		 */
		SYNC_CREATE,
		/**
		 * Specifies data is transfered both ways. 
		 * 
		 * @since 0.1
		 */
		BIDIRECTIONAL,
		/**
		 * Specifies boolean inversion when assigning boolean value.
		 * 
		 * @since 0.1
		 */
		INVERT_BOOLEAN,
		/**
		 * Controls direction of SYNC_CREATE and data transfer, default 
		 * direction is from source to target and this flag reverses that.
		 * 
		 * This flag is ignored when binding is not BIDIRECTIONAL
		 * 
		 * @since 0.1
		 */
		REVERSE_DIRECTION,
		/**
		 * Specifies that binding should not connect to source events as they
		 * will be provided manually by triggering update_from_source()
		 * 
		 * @since 0.1
		 */
		MANUAL_EVENTS_FROM_SOURCE, //TODO handling
		/**
		 * Specifies that binding should not connect to target events as they
		 * will be provided manually by triggering update_from_target()
		 * 
		 * @since 0.1
		 */
		MANUAL_EVENTS_FROM_TARGET, //TODO handling
		/**
		 * This is equal to specified both MANUAL_EVENTS_FROM_SOURCE and
		 * MANUAL_EVENTS_FROM_TARGET
		 * 
		 * In this cases all data transfer relies on manual triggering
		 * 
		 * @since 0.1
		 */
		MANUAL_UPDATE = MANUAL_EVENTS_FROM_SOURCE | MANUAL_EVENTS_FROM_TARGET,
		/**
		 * Specifies active status and is update by freeze()/unfreeze() 
		 * Binding created with this flag must call unfreeze manually
		 * 
		 * When this flag state changes SYNC_CREATE is processed. if that was
		 * due to calling freeze()/unfreeze() SYNC_CREATE is processed again
		 * 
		 * @since 0.1
		 */ 
		 INACTIVE,
		/**
		 * Specifies that data transfer from target should be checked for data
		 * flooding
		 * 
		 * WARNING! flood data detection is disabled by default
		 * 
		 * Detects data flood and emits signal flood_detected to enable gui
		 * to reflect that state. once flood is over flood_stopped is emited
		 * and last data transfer is processed
		 * 
		 * Control of data flood detection is done by
		 * - flood_detection     (bool) enable/disable this flag in binding
		 * - flood_interval      (uint) which specifies minimum interval between
		 *                              processing data transfers
		 * - promote_flood_limit (uint) defines how many events should be 
		 *                              processed before flooding takes effect
		 * 
		 * Main purpose of flood detection is having option to detect when gui
		 * updates would be hogging cpu in some unwanted manner
		 * 
		 * There are lot of cases when spaming is normal behaviour like having
		 * tracking process of something like current frame in animation or
		 * having job status actively updated. There are also a lot of cases
		 * when this is not wanted like for example when you scroll over list
		 * of objects, spaming gui updates is not really something useful unless
		 * hogging cpu is desired action
		 * 
		 * @since 0.1
		 */
		SOURCE_UPDATE_FLOOD_DETECTION, //TODO handling
		/**
		 * Specifies that data transfer from source should be checked for data
		 * flooding
		 * 
		 * WARNING! flood data detection is disabled by default
		 * 
		 * Detects data flood and emits signal flood_detected to enable gui
		 * to reflect that state. once flood is over flood_stopped is emited
		 * and last data transfer is processed
		 * 
		 * Control of data flood detection is done by
		 * - flood_detection     (bool) enable/disable this flag in binding
		 * - flood_interval      (uint) which specifies minimum interval between
		 *                              processing data transfers
		 * - promote_flood_limit (uint) defines how many events should be 
		 *                              processed before flooding takes effect
		 * 
		 * Main purpose of flood detection is having option to detect when gui
		 * updates would be hogging cpu in some unwanted manner
		 * 
		 * There are lot of cases when spaming is normal behaviour like having
		 * tracking process of something like current frame in animation or
		 * having job status actively updated. There are also a lot of cases
		 * when this is not wanted like for example when you scroll over list
		 * of objects, spaming gui updates is not really something useful unless
		 * hogging cpu is desired action
		 * 
		 * @since 0.1
		 */
		TARGET_UPDATE_FLOOD_DETECTION, //TODO handling
		/**
		 * FLOOD_DETECTION is equal to specifying both 
		 * SOURCE_UPDATE_FLOOD_DETECTION and TARGET_UPDATE_FLOOD_DETECTION
		 *  
		 * WARNING! flood data detection is disabled by default
		 * 
		 * Detects data flood and emits signal flood_detected to enable gui
		 * to reflect that state. once flood is over flood_stopped is emited
		 * and last data transfer is processed
		 * 
		 * Control of data flood detection is done by
		 * - flood_detection     (bool) enable/disable this flag in binding
		 * - flood_interval      (uint) which specifies minimum interval between
		 *                              processing data transfers
		 * - promote_flood_limit (uint) defines how many events should be 
		 *                              processed before flooding takes effect
		 * 
		 * Main purpose of flood detection is having option to detect when gui
		 * updates would be hogging cpu in some unwanted manner
		 * 
		 * There are lot of cases when spaming is normal behaviour like having
		 * tracking process of something like current frame in animation or
		 * having job status actively updated. There are also a lot of cases
		 * when this is not wanted like for example when you scroll over list
		 * of objects, spaming gui updates is not really something useful unless
		 * hogging cpu is desired action
		 * 
		 * @since 0.1
		 */
		FLOOD_DETECTION = SOURCE_UPDATE_FLOOD_DETECTION | TARGET_UPDATE_FLOOD_DETECTION,
		/**
		 * Similar to flood detection this provides static delay to data 
		 * transfer if another event occurs during delay, delay is prolonged for
		 * another delay_interval. example usecase is binding search controls 
		 * where you don't want to spam search requests
		 * 
		 * @since 0.1
		 */
		DELAYED;

		/**
		 * Checks if FLOOD_DETECTION flag is enabled or not
		 * 
		 * @since 0.1
		 */
		public bool HAS_FLOOD_DETECTION()
		{
			return ((this & BindFlags.FLOOD_DETECTION) == BindFlags.FLOOD_DETECTION);
		}

		/**
		 * Checks if INACTIVE flag is not set
		 * 
		 * @since 0.1
		 */
		public bool IS_ACTIVE()
		{
			return ((this & BindFlags.INACTIVE) != BindFlags.INACTIVE);
		}

		/**
		 * Checks if DELAYED flag is set
		 * 
		 * @since 0.1
		 */
		public bool IS_DELAYED()
		{
			return ((this & BindFlags.DELAYED) == BindFlags.DELAYED);
		}

		/**
		 * Checks if SYNC_CREATE flag is set
		 * 
		 * @since 0.1
		 */
		public bool HAS_SYNC_CREATE()
		{
			return ((this & BindFlags.SYNC_CREATE) == BindFlags.SYNC_CREATE);
		}

		/**
		 * Checks if REVERSE_DIRECTION flag is set
		 * 
		 * @since 0.1
		 */
		public bool IS_REVERSE()
		{
			return ((this & BindFlags.REVERSE_DIRECTION) == BindFlags.REVERSE_DIRECTION);
		}

		/**
		 * Checks if BIDIRECTIONAL flag is set
		 * 
		 * @since 0.1
		 */
		public bool IS_BIDIRECTIONAL()
		{
			return ((this & BindFlags.BIDIRECTIONAL) == BindFlags.BIDIRECTIONAL);
		}

		/**
		 * Checks if MANUAL_UPDATE flag is set
		 * 
		 * @since 0.1
		 */
		public bool HAS_MANUAL_UPDATE()
		{
			return ((this & BindFlags.MANUAL_UPDATE) == BindFlags.MANUAL_UPDATE);
		}

		/**
		 * Checks if INVERT_BOOLEAN flag is set
		 * 
		 * @since 0.1
		 */
		public bool HAS_INVERT_BOOLEAN()
		{
			return ((this & BindFlags.INVERT_BOOLEAN) == BindFlags.INVERT_BOOLEAN);
		}
		
		public string get_direction_arrow()
		{
			string dir = "→";
			if (this.IS_BIDIRECTIONAL() == true)
				dir = "↔";
			else if (this.IS_REVERSE() == true)
				dir = "←";
			return (dir);
		}
	}
}
