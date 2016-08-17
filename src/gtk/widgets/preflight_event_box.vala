namespace GDataGtk
{
	/**
	 * simple preflight event box that manipulates opacity based on where 
	 * mouse is. When mouse is hovering over event box, full_opacity is used,
	 * when not, then inactive_opacity is used
	 * 
	 * @since 0.1
	 */
	public class PreflightEventBox : Gtk.EventBox
	{
		private bool pressed = false;

		private float _inactive_opacity = 0.5f;
		/**
		 * Specifies opacity when mouse is not hovering over event box
		 * 
		 * @since 0.1
		 */
		public float inactive_opacity {
			get { return (_inactive_opacity); }
			set { 
				_inactive_opacity = value;
				if (opacity != full_opacity)
					opacity = value;
			}
		}

		private float _full_opacity = 1.0f;
		/**
		 * Specifies opacity when mouse is hovering over event box
		 * 
		 * @since 0.1
		 */
		public float full_opacity {
			get { return (_full_opacity); }
			set { 
				_full_opacity = value;
				if (opacity != inactive_opacity)
					opacity = value;
			}
		}

		/**
		 * Signal emited when event box is clicked
		 * 
		 * @since 0.1
		 */
		public signal void clicked();

		/**
		 * Creates new PreflightEventBox
		 * 
		 * @since 0.1
		 */
		public PreflightEventBox()
		{
			button_press_event.connect((e) => { pressed = true; return (false); });
			button_release_event.connect((e) => { 
				if (pressed == true)
					clicked();
				pressed = false; 
				return (false); 
			});
			enter_notify_event.connect((e) => { opacity = full_opacity; return (false); });
			leave_notify_event.connect((e) => { opacity = inactive_opacity; return (false); });
			opacity = inactive_opacity;
		}
	}
}
