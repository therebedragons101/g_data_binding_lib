namespace G
{
	[Flags]
	public enum BindFlags
	{
		DEFAULT,
		SYNC_CREATE,
		BIDIRECTIONAL,
		INVERT_BOOLEAN,
		// controls direction of SYNC_CREATE, default is source to target,
		// if this is specified it assumes pipeline is from target to source
		// also controls direction when binding is not BIDIRECTIONAL
		REVERSE_DIRECTION,
		// specifies all binding is done externally and Binding will just be
		// used trough update_from_source and update_from_target
		MANUAL_EVENTS_FROM_SOURCE, //TODO handling
		MANUAL_EVENTS_FROM_TARGET, //TODO handling
		MANUAL_UPDATE = MANUAL_EVENTS_FROM_SOURCE | MANUAL_EVENTS_FROM_TARGET,
		// specifies active status and is update by freeze/unfreeze
		// Binding created with this flag must call unfreeze manually
		//
		// when this flag state changes SYNC_CREATE is processed. if that was
		// due to calling freeze()/unfreeze() SYNC_CREATE is processed again
		INACTIVE,
		// NOTE! flood data detection is disabled by default
		//
		// detects data flood and emits signal flood_detected to enable gui
		// to reflect that state. once flood is over flood_stopped is emited
		// and last data transfer is processed
		//
		// control of data flood detection is done by
		// - flood_detection    (bool) enable/disable this flag in binding
		// - flood_interval     (uint) which specifies minimum interval between
		//                             processing data transfers
		// - flood_enable_after (uint) defines how many events should be processed
		//                             before flooding takes effect
		//
		// main purpose of flood detection is having option to detect when gui 
		// updates would be hogging cpu in some unwanted manner
		//
		// there are lot of cases when spaming is normal behaviour like having 
		// tracking process of something like current frame in animation or 
		// having job status actively updated. but, there are a lot of cases 
		// when this is not wanted like for example when you scroll over list
		// of objects, spaming gui updates is not really something useful unless
		// hogging cpu is desired action
		SOURCE_UPDATE_FLOOD_DETECTION, //TODO handling
		TARGET_UPDATE_FLOOD_DETECTION, //TODO handling
		FLOOD_DETECTION = SOURCE_UPDATE_FLOOD_DETECTION | TARGET_UPDATE_FLOOD_DETECTION,
		// much like flood detection this provides static delay to data transfer
		// if another event occurs during delay, delay is prolonged for another
		// delay_interval. example usecase is binding search controls where you
		// don't want to spam search requests
		DELAYED;

		public bool HAS_FLOOD_DETECTION()
		{
			return ((this & BindFlags.FLOOD_DETECTION) == BindFlags.FLOOD_DETECTION);
		}

		public bool IS_ACTIVE()
		{
			return ((this & BindFlags.INACTIVE) != BindFlags.INACTIVE);
		}

		public bool IS_DELAYED()
		{
			return ((this & BindFlags.DELAYED) == BindFlags.DELAYED);
		}

		public bool HAS_SYNC_CREATE()
		{
			return ((this & BindFlags.SYNC_CREATE) == BindFlags.SYNC_CREATE);
		}

		public bool IS_REVERSE()
		{
			return ((this & BindFlags.REVERSE_DIRECTION) == BindFlags.REVERSE_DIRECTION);
		}

		public bool IS_BIDIRECTIONAL()
		{
			return ((this & BindFlags.BIDIRECTIONAL) == BindFlags.BIDIRECTIONAL);
		}

		public bool HAS_MANUAL_UPDATE()
		{
			return ((this & BindFlags.MANUAL_UPDATE) == BindFlags.MANUAL_UPDATE);
		}

		public bool HAS_INVERT_BOOLEAN()
		{
			return ((this & BindFlags.INVERT_BOOLEAN) == BindFlags.INVERT_BOOLEAN);
		}
	}
}
