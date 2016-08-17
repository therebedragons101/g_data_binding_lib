using GData;

namespace GDataGtk
{
	public const int ACTION_DELETE = 1;
	public const int ACTION_ADD = 2;
	public const int ACTION_REMOVE = 3;
	public const int ACTION_ACTIVATE = 4;
	public const int ACTION_RUN = 5;
	public const int ACTION_PAUSE = 6;

	/**
	 * ListBoxRow extended to support smooth hide/unhide by controlling 
	 * "revealed" property, which in turn correctly handles "visible" by using
	 * timeouts as specified
	 * 
	 * @since 0.1
	 */
	public class SmoothListBoxRow : Gtk.ListBoxRow
	{
		private bool ignore = false;
		private StrictWeakRef object_ref = new StrictWeakRef(null);
		public Object? object {
			get { return (object_ref.target); }
		}

		private Gtk.Box _int_container;
		private Gtk.Box _container;
		private Gtk.Revealer _revealer;

		/**
		 * Intended to control visibility. Unlike "visible" this correctly
		 * triggers internal Gtk.Revealer and sets "visible" after animation
		 * 
		 * @since 0.1
		 */
		public bool revealed {
			get { return (_revealer.reveal_child); }
			set {
				if (revealed == value)
					return;
				if (value == false)
					_revealer.reveal_child = value;
				else {
					ignore = true;
					visible = true;
					_revealer.reveal_child = value;
					ignore = false;
				}
				GLib.Timeout.add (transition_duration, set_visibility, GLib.Priority.DEFAULT);
			}
		}

		/**
		 * Animation transition type
		 * 
		 * @since 0.1
		 */
		public Gtk.RevealerTransitionType transition_type {
			get { return (_revealer.transition_type); }
			set { _revealer.transition_type = value; }
		}

		/**
		 * Animation transition duration
		 * 
		 * @since 0.1
		 */
		public uint transition_duration {
			get { return (_revealer.transition_duration); }
			set { _revealer.transition_duration = value; }
		}

		private bool set_visibility()
		{
			ignore = true;
			visible = revealed;
			ignore = false;
			return (GLib.Source.REMOVE);
		}

		/**
		 * Returns internal container which should contain all widgets
		 * 
		 * @since 0.1
		 * 
		 * @return Internal container
		 */
		public virtual Gtk.Box get_container()
		{
			return (_container);
		}

		/**
		 * Packs widget after internal container so that widget is at absolute
		 * right side
		 * 
		 * @since 0.1
		 * 
		 * @param widget New widget
		 */
		public virtual void pack_end_widget (Gtk.Widget widget)
		{
			_int_container.pack_start (widget, false, true);
		}

		/**
		 * Signal can be used by need to specify additional row actions.
		 * 
		 * Example:
		 * if row is created with .with_delete() it gets added close icon on
		 * the right side and whenever that icon is clicked it emits
		 * action_taken (ACTION_REMOVE, obj)
		 * 
		 * @since 0.1
		 * 
		 * @param action_id Integer representation of action
		 * @param obj Object being handled by row
		 */
		public signal void action_taken (int action_id, Object? obj);

		/**
		 * Creates SmoothListBoxRow with already present close icon that emits
		 * signal when pressed
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object represented by row
		 */
		public SmoothListBoxRow.with_delete (Object? obj, int? side_margin = null, int? height_margin = null, bool? visibility = null)
		{
			this (obj, side_margin, height_margin, visibility);
			PreflightEventBox ev = new PreflightEventBox();
			ev.visible = true;
			ev.clicked.connect (() => {
				action_taken (ACTION_DELETE, obj);
			});
			StateImage img = new StateImage.close();
			img.state = true;
			img.visible = true;
			ev.add (img);
			pack_end_widget (ev);
		}

		/**
		 * Creates SmoothListBoxRow
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object represented by row
		 */
		public SmoothListBoxRow (Object? obj, int? side_margin = null, int? height_margin = null, bool? visibility = null)
		{
			visible = (visibility != null) ? visibility : true;
			object_ref.set_new_target (obj);
			_revealer = new Gtk.Revealer();
			_revealer.visible = true;
			_revealer.reveal_child = true;
			notify["visible"].connect (() => { 
				if (ignore == false)
					revealed = visible;
			});
			revealed = true;
			transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
			transition_duration = 250;
			add (_revealer);
			_int_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 4);
			_int_container.visible = true;
			_revealer.add (_int_container);
			_container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
			_container.visible = true;
			_int_container.pack_start (_container, true, true);
			if (side_margin != null)
				set_side_margins (_int_container, side_margin);
			if (height_margin != null)
				set_height_margins (_int_container, height_margin);
		}
	}
}

