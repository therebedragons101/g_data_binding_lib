using GData;

namespace GDataGtk
{
	/**
	 * Simple edit mode control object for auto widgets in cases when there is 
	 * no actual data binding or when it needs to be manipulated externally
	 * 
	 * @since 0.1
	 */
	public class EditModeControl : Object, EditModeControlInterface
	{
		private BindingInterface? _mode_control_binding = null;

		private EditMode _mode = EditMode.VIEW;
		/**
		 * Specifies edit mode
		 * 
		 * @since 0.1
		 */
		public EditMode mode {
			get { return (_mode); }
			set {
				if (_mode == value)
					return;
				_mode = value;
				Signal.emit_by_name (this, "notify::editing");
			}
		}

		/**
		 * Sets mode control object which is redispatched to this one
		 * 
		 * @since 0.1
		 * 
		 * @param control Control object for EDIT/VIEW mode
		 */
		public EditModeControl set_mode_control (EditModeControlInterface? control)
		{
			if (_mode_control_binding != null) {
				_mode_control_binding.unbind();
				_mode_control_binding = null;
			}
			if (control != null)
				_mode_control_binding = _auto_binder().bind (control, "mode", this, "mode", BindFlags.SYNC_CREATE);
			notify_property ("mode");
			return (this);
		}

		/**
		 * Creates EditModeControl with initial state
		 * 
		 * @since 0.1
		 * 
		 * @param initial_mode Mode with which control object is started
		 */
		public EditModeControl (EditMode initial_mode = EditMode.VIEW)
		{
			mode = initial_mode;
		}
	}
}

