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

