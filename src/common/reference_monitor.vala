namespace GData
{
	/**
	 * Taps into reference lifetime and sends signal when reference is deleted.
	 * This monitor object has its own lifetime controlled by object being 
	 * watched and as such any additional ref/unref is completely unwarranted or
	 * unecessary.
	 * 
	 * Although it can be used standalone it is probably better to be used 
	 * trough ReferenceMonitorGroup
	 * 
	 * @since 0.1
	 */
	public class ReferenceMonitor : Object
	{
		public static GetObjectDescriptionStringDelegate? __get_object_description = null;

		private string _notification = "";
		/**
		 * Notification message when reference is deleted
		 * 
		 * @since 0.1
		 */
		public string notification {
			get { return (_notification); }
		}
		
		private StrictWeakRef? _wr = null;
		/**
		 * Object whose lifetime is being monitored
		 * 
		 * @since 0.1
		 */
		public Object? watched_object {
			get { return (_wr.target); }
		}

		/**
		 * Removes reference monitor
		 * 
		 * @since 0.1
		 */
		public void remove()
		{
			_wr.set_new_target (null);
			unref();
		}

		/**
		 * Returns current reference count for monitored object
		 * 
		 * @since 0.1
		 */
		public int reference_count {
			get {
				if (_wr.is_valid_ref() == false)
					return (0);
				weak Object? object = _wr.target;
				return ((int) object.ref_count);
			}
		}

		/**
		 * Specifies if object name should use markup or not
		 * 
		 * @since 0.1
		 */
		public bool use_markup { get; set; default = true; }

		/**
		 * Signal being sent when reference is deleted
		 * 
		 * @since 0.1
		 * 
		 * @param notification Notification message
		 */
		public signal void reference_deleted (string notification);

		private string _object_name = "";
		public string object_name {
			get { return (_object_name); }
		}

		private int old_ref_count = 0;

		/**
		 * Updates object description and reference count
		 * 
		 * @since 0.1
		 */
		public void update()
		{
			int rcount = reference_count;
			if (rcount != old_ref_count)
				notify_property ("reference-count");
			old_ref_count = rcount;

			if (_wr.is_valid_ref() == false) {
				if (_object_name != "") {
					_object_name = "";
					notify_property ("object-name");
				}
				return;
			}
			string ds;
			if (__get_object_description == null)
				ds = _wr.target.get_type().name();
			else
				ds = __get_object_description(_wr.target, use_markup);
			if (ds.contains("\n") == true) {
				int pos = ds.last_index_of("\n");
				ds = ds.splice(pos, pos+"\n".length, " (") + ")";
			}
			if (_object_name != ds) {
				_object_name = ds;
				notify_property ("object-name");
			}
		}

		/**
		 * Creates new reference monitor
		 * 
		 * @since 0.1
		 * 
		 * @param notification Notification message
		 * @param obj Object whose lifetime is being monitored
		 */
		public ReferenceMonitor (string notification, Object? obj)
		{
			_wr = new StrictWeakRef(obj, (() => {
				reference_deleted (notification);
				unref();
			}));
			_notification = notification;
			ref();
		}
	}
}

