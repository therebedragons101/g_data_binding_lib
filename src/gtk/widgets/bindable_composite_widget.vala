namespace GDataGtk
{
	/**
	 * Specifies interface to access information in composite bindable widgets
	 * 
	 * @since 0.1
	 */
	public interface BindableCompositeWidget : Gtk.Widget
	{
		/**
		 * Returns widget which should be used for binding
		 * 
		 * @since 0.1
		 * 
		 * @return Widget which should be used for binding
		 */
		public abstract Gtk.Widget? get_bindable_widget();
		/**
		 * Returns property which should be used for binding
		 * 
		 * @since 0.1
		 * 
		 * @return Property which should be used for binding
		 */
		public abstract string? get_value_binding_property();
	}
}
