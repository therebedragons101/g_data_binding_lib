namespace GData
{
	/**
	 * Most basic property binding requirement
	 * 
	 * Main use is to define custom property binding objects when controlling
	 * events with Binder
	 * 
	 * @since 0.1
	 */ 
	public interface BindingInterface : Object
	{
		/**
		 * Returns true if binding is currently active, false if not
		 * 
		 * @since 0.1
		 */
		public bool activated {
			get { return (flags.IS_ACTIVE() == true); }
		}

		/**
		 * Source object
		 * 
		 * @since 0.1
		 */
		public abstract Object? source { get; }
		/**
		 * Source property name
		 * 
		 * @since 0.1
		 */
		public abstract string source_property { get; }
		/**
		 * Target object
		 * 
		 * @since 0.1
		 */
		public abstract Object? target { get; }
		/**
		 * Target property name
		 * 
		 * @since 0.1
		 */
		public abstract string target_property { get; }
		/**
		 * Flags that describe property binding creation and status
		 * 
		 * @since 0.1
		 */
		public abstract BindFlags flags { get; }

		/**
		 * Unbind drops property binding and stops data transfer. It also
		 * drops its own permanent holding reference which means that if there
		 * is no other live reference, object will be disposed
		 * 
		 * @since 0.1
		 */
		public abstract void unbind();

		/**
		 * Adds property to binding as notification its data has changed
		 * 
		 * @since 0.1
		 * 
		 * @param side Specifies side which property will be connected to
		 * @param property_names Specifies array of properties that need to be
		 *                       connected
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public BindingInterface add_property_notification (BindingSide side, string property_name)
		{
			return (add_custom_property_notification ((side == BindingSide.SOURCE) ? source : target, property_name, side));
		}

		/**
		 * Adds signal to binding as notification its data has changed
		 * 
		 * @since 0.1
		 * 
		 * @param side Specifies side which signal will be connected to
		 * @param detailed_signal_name Specifies signal that need to be 
		 *                             connected. Signal supports signal::quark
		 *                             structure where quark is not necessary
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public BindingInterface add_signal (BindingSide side, string detailed_signal_name)
		{
			return (add_custom_signal ((side == BindingSide.SOURCE) ? source : target, detailed_signal_name, side));
		}

		/**
		 * Adds property to binding as notification its data has changed
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object containing the property
		 * @param property_name Specifies array of properties that need to be
		 *                       connected
		 * @param trigger_update_from Specifies side which property will be 
		 *                            connected to
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public abstract BindingInterface add_custom_property_notification (Object? obj, string property_name, BindingSide trigger_update_from);

		/**
		 * Adds signal to binding as notification its data has changed
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object containing the property
		 * @param detailed_signal_name Specifies signal that need to be 
		 *                             connected. Signal supports signal::quark
		 *                             structure where quark is not necessary
		 * @param trigger_update_from Specifies side which property will be 
		 *                            connected to
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public abstract BindingInterface add_custom_signal (Object? obj, string detailed_signal_name, BindingSide trigger_update_from);

		/**
		 * Adds properties to binding as notification its data has changed
		 * 
		 * This just calls add_property_notification() for every specified 
		 * property name
		 * 
		 * @since 0.1
		 * 
		 * @param side Specifies side which property will be connected to
		 * @param property_names Specifies array of properties that need to be
		 *                       connected
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public BindingInterface add_property_notifications (BindingSide side, string[]? property_names)
		{
			if (property_names == null)
				return (this);
			for (int i=0; i<property_names.length; i++)
				add_property_notification (side, property_names[i]);
			return (this);
		}

		/**
		 * Adds signals to binding as notification its data has changed
		 * 
		 * This just calls add_signal() for every specified signal name
		 * 
		 * @since 0.1
		 * 
		 * @param side Specifies side which signal will be connected to
		 * @param signal_names Specifies array of signals that need to be
		 *                     connected
		 * @return BindingInterface reference to it self to allow chain API in
		 *         objective oriented languages
		 */
		public BindingInterface add_signals (BindingSide side, string[] signal_names)
		{
			if (signal_names == null)
				return (this);
			for (int i=0; i<signal_names.length; i++)
				add_signal (side, signal_names[i]);
			return (this);
		}

		/**
		 * Returns string representation for binding description
		 * 
		 * @since 0.1
		 * 
		 * @param markup Enable markup
		 * @return String representation for binding description
		 */
		public string as_short_str (bool markup = false)
		{
			string dir = flags.get_direction_arrow();
			if (markup == true)
				return ("%s%s%s".printf (bold(fix_markup(source_property)), dir, bold(fix_markup(target_property))));
			else
				return ("%s%s%s".printf (source_property, dir, target_property));
		}

		/**
		 * Returns string representation for binding description
		 * 
		 * @since 0.1
		 * 
		 * @param markup Enable markup
		 * @return String representation for binding description
		 */
		public string as_str (bool markup = false)
		{
			return ("%s/%s".printf (as_short_str(markup), bool_activity(activated, markup)));
		}

		public string sources_as_str(bool markup = false, GetObjectDescriptionStringDelegate? method = null)
		{
			ParamSpec? psource = TypeInformation.get_instance().find_property_from_type (get_type(), "source");
			ParamSpec? ptarget = TypeInformation.get_instance().find_property_from_type (get_type(), "target");
			if ((psource == null) && (ptarget == null))
				return ("");
			string src;
			string tgt;
			GLib.Value sval = GLib.Value(typeof(Object));
			GLib.Value tval = GLib.Value(typeof(Object));
			if (psource != null)
				get_property (psource.name, ref sval);
			if (ptarget != null)
				get_property (ptarget.name, ref tval);
			Object? osrc = sval.get_object();
			Object? otgt = tval.get_object();
			if (method != null) {
				src = (psource == null) ? "" : "%s %s".printf (small(italic("Source:", markup), markup), method(osrc, markup).replace("\n", " "));
				tgt = (ptarget == null) ? "" : "%s %s".printf (small(italic("Target:", markup), markup), method(otgt, markup).replace("\n", " "));
			}
			else {
				src = (psource == null) ? "" : "%s %s".printf (small(italic("Source:", markup), markup), TYPE_COLOR(bold(psource.value_type.name())));
				tgt = (ptarget == null) ? "" : "%s %s".printf (small(italic("Target:", markup), markup), TYPE_COLOR(bold(ptarget.value_type.name())));
			}
			string delim = ((src != "") && (tgt != "")) ? "\n" : "";
			return ("%s%s%s".printf (src, delim, tgt));
		}
		/**
		 * Signal emited upon unbind of binding interface
		 * 
		 * @since 0.1
		 */
		public signal void dropping (BindingInterface binding);
	}
}
