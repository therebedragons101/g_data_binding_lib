namespace GDataGtk
{
	/**
	 * Simple Image that has two pixbufs that switch based on value of "state".
	 * Once state pixbuf is loaded it is permanently cached and reused per size
	 * 
	 * @since 0.1
	 */
	public class StateImage : Gtk.Image
	{
		private static HashTable<string, Gdk.Pixbuf> _hash = null;

		private Gdk.Pixbuf? _pixbuf_for_enabled = null;
		private Gdk.Pixbuf? _pixbuf_for_disabled = null;

		private bool _state = false;
		/**
		 * Specifies which pixbuf must be shown
		 * 
		 * @since 0.1
		 */
		public bool state {
			get { return (_state); }
			set {
				if (_state == value)
					return;
				_state = value;
				pixbuf = (_state == true) ? _pixbuf_for_enabled : _pixbuf_for_disabled;
			}
		}
		

		/**
		 * Creates new StateImage with symbolic icons specifying error states
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.fail(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("dialog-error-symbolic.symbolic", "computer-fail-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying ok/warning 
		 * states
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.ok_warning(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("emblem-ok-symbolic.symbolic", "dialog-warning-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying
		 * warning/question states
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.notification(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("dialog-warning-symbolic.symbolic", "dialog-question-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying
		 * items/events states
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.items_events(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("open-menu-symbolic.symbolic", "view-dual-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying alarm
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.alarm(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("alarm-symbolic.symbolic", "appointment-missed-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying tracking
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.tracking(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("network-receive-symbolic.symbolic", "user-not-tracked-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying content amount
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.content_amount(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("media-view-subtitles-symbolic.symbolic", "view-continuous-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying run/pause
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.run_pause(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("system-run-symbolic.symbolic", "media-playback-pause-symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying search or
		 * search and replace
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.search_and_replace(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("edit-find-replace-symbolic.symbolic", "edit-find-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying grid/list mode
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.grid_mode(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("view-grid-symbolic.symbolic", "view-list-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying close content
		 * When enabled Close icon is inside circle, when not close is bare
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.close(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("edit-delete-symbolic.symbolic", "list-remove-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying add/remove
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.add_remove(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("list-add-symbolic.symbolic", "list-remove-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying content
		 * availability
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.content(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("edit-select-all-symbolic.symbolic", "action-unavailable-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons specifying edit mode
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.edit_mode(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("changes-allow-symbolic.symbolic", "changes-prevent-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons representing radio button
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.radiobutton(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("radio-checked-symbolic.symbolic", "radio-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage with symbolic icons representing check box
		 * 
		 * @since 0.1
		 * 
		 * @param size Specifies icon size
		 */
		public StateImage.checkbox(Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
			this.symbolic ("checkbox-checked-symbolic.symbolic", "checkbox-symbolic.symbolic", size);
		}

		/**
		 * Creates new StateImage by loading symbolic icons
		 * 
		 * @since 0.1
		 * 
		 * @param pixbuf_for_enabled Pixbuf used for enabled state
		 * @param pixbuf_for_disabled Pixbuf used for disabled state
		 * @param size Specifies icon size
		 */
		public StateImage.symbolic (string pixbuf_for_enabled, string pixbuf_for_disabled, Gtk.IconSize size = Gtk.IconSize.SMALL_TOOLBAR)
		{
/*
			if (_hash == null)
				_hash = new HashTable<string, Gdk.Pixbuf>(str_hash, str_equal);
			string eh = "%i".printf((int) size) + "____" + pixbuf_for_enabled;
			string dh = "%i".printf((int) size) + "____" + pixbuf_for_enabled;
			if (_hash.contains(eh) == true)
				_pixbuf_for_enabled = _hash.get(eh);
			if (_hash.contains(dh) == true)
				_pixbuf_for_disabled = _hash.get(dh);
			if (_pixbuf_for_enabled == null) {*/
				_pixbuf_for_enabled = load_pixbuf (pixbuf_for_enabled, get_style_context(), true, size);
/*				_hash.insert (eh, _pixbuf_for_enabled);
			}
			if (_pixbuf_for_disabled == null) {*/
				_pixbuf_for_disabled = load_pixbuf (pixbuf_for_disabled, get_style_context(), true, size);
				pixbuf = _pixbuf_for_disabled;
/*				_hash.insert (dh, _pixbuf_for_enabled);
			}*/
			
		}

		/**
		 * Creates new StateImage
		 * 
		 * @since 0.1
		 * 
		 * @param pixbuf_for_enabled Pixbuf used for enabled state
		 * @param pixbuf_for_disabled Pixbuf used for disabled state
		 */
		public StateImage (Gdk.Pixbuf pixbuf_for_enabled, Gdk.Pixbuf pixbuf_for_disabled)
		{
			_pixbuf_for_enabled = pixbuf_for_enabled;
			_pixbuf_for_disabled = pixbuf_for_disabled;
			pixbuf = _pixbuf_for_disabled;
		}
	}
}

