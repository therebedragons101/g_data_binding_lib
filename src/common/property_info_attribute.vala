namespace GData
{
	/**
	 * PropertyInfoAttribute main purpose is to tackle deficiency of ParamSpec
	 * not being derived from GObject and as such not really useful for binding
	 * 
	 * At the same time it also takes care there is always only one attribute
	 * per property. add_property_info() returns already existing if that is the
	 * case
	 * 
	 * @since 0.1
	 */
	public class PropertyInfoAttribute : Attribute
	{
		private ParamSpec? pspec = null;

		/**
		 * Safe method to assign unique attribute to property. If pspec already
		 * has PropertyInfoAttribute then old reference is returned, if not
		 * new one is created
		 * 
		 * @since 0.1
		 * 
		 * @param pspec Property specification
		 */
		public static PropertyInfoAttribute? get_property_info (ParamSpec? pspec)
		{
			if (pspec == null)
				return (null);
			PropertyInfoAttribute[] attrs = (PropertyInfoAttribute[]) find_property_attributes (pspec, typeof(PropertyInfoAttribute));
			if (attrs.length > 0)
				return (attrs[0]);
			PropertyInfoAttribute attr = new PropertyInfoAttribute (pspec);
			add_property_attribute (pspec, attr);
			return (attr);
		}

		/**
		 * Returns property nick
		 * 
		 * @since 0.1
		 */
		public string nick {
			get { return (pspec.get_nick()); }
		}

		/**
		 * Returns property name
		 * 
		 * @since 0.1
		 */
		public string name {
			get { return (pspec.get_name()); }
		}

		/**
		 * Returns property blurb
		 * 
		 * @since 0.1
		 */
		public string blurb {
			get { return (pspec.get_blurb()); }
		}

		/**
		 * Returns property value type
		 * 
		 * @since 0.1
		 */
		public Type value_type {
			get { return (pspec.value_type); }
		}

		/**
		 * Returns property owner type
		 * 
		 * @since 0.1
		 */
		public Type owner_type {
			get { return (pspec.owner_type); }
		}

		private PropertyInfoAttribute (ParamSpec pspec)
		{
			this.pspec = pspec;
		}
	}
}
