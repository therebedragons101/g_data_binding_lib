namespace GData
{
	/**
	 * Interface for needed functionality in BindingInformation. This is only
	 * intended when there is a need to supply custom binding information and
	 * it is also used in BindingGroup
	 * 
	 * since 0.1
	 */
	public interface BindingInformationInterface : Object
	{
		/**
		 * Contract BindingInformation belongs to
		 * 
		 * @since 0.1
		 */
		public abstract BindingContract? contract { get; }

		/**
		 * Returns true if binding is currently active for data transfer
		 * 
		 * @since 0.1
		 */
		public abstract bool activated { get; }

		/**
		 * Specifies source property name
		 * 
		 * @since 0.1
		 */
		public abstract string source_property { get; }

		/**
		 * Specifies target property name
		 * 
		 * @since 0.1
		 */
		public abstract string target_property { get; }

		/**
		 * Specifies binding rules for data transfer
		 * 
		 * @since 0.1
		 */
		public abstract BindFlags flags { get; }

		/**
		 * Returns if source data is valid or not.
		 * 
		 * Validity is checked first against valid source and then updated on
		 * each property value transfer where bind() specified specific way to
		 * check if data is valid or not. This way source validity always checks
		 * for correct conditions even when property bindings are added or 
		 * removed. When property binding is added, so is its condition and same
		 * for removal where property binding condition is removed as well
		 * 
		 * Note that contract value of "is-valid" will be cumulative of all
		 * conditions on all properties
		 * 
		 * @since 0.1
		 */
		public abstract bool is_valid { get; }
		/**
		 * Activates binding if possible. This executes contract.binder.bind()
		 * method in order to generate BindingInterface
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object being connected and can be used to check sanity.
		 *            This is obtained as part of notifications during "data"
		 *            changes
		 */
		public abstract void bind_connection (Object? obj);
		/**
		 * Unbinds active connection between properties
		 * 
		 * @since 0.1
		 * 
		 * @param obj Object being connected and can be used to check sanity.
		 *            This is obtained as part of notifications during "data"
		 *            changes
		 */
		public abstract void unbind_connection (Object? obj);

		/**
		 * Invokes creation of BindingInformation for specified parameters.
		 * If contract is active and everything is in order this also creates
		 * BindingInterface and activates data transfer 
		 * 
		 * Main reasoning for this method is to allow chain API in objective 
		 * languages which makes code much simpler to follow 
		 * 
		 * NOTE!
		 * transform_from and transform_to can work in two ways. If value return
		 * is true, then newly converted value is assigned to property, if
		 * return is false, then that doesn't happen which can be used to assign
		 * property values directly and avoiding value conversion
		 *   
		 * @since 0.1
		 * @param source_property Source property name
		 * @param target Target object
		 * @param target_property Target property name
		 * @param flags Flags describing property binding creation
		 * @param transform_to Custom method to transform data from source value
		 *                     to target value
		 * @param transform_from Custom method to transform data from source 
		 *                       value to target value
		 * @param source_validation Specifies custom method to validate this
		 *                          particular property in source object. When
		 *                          this is not specified, validity is true
		 * @return Newly create BindingInformationInterface
		 */
		public BindingInformationInterface bind (
				string source_property, Object target, string target_property, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			return (contract.bind (source_property, target, target_property, flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
		}

		/**
		 * Invokes creation of another BindingInformation for specified 
		 * parameters. If contract is active and everything is in order this 
		 * also creates BindingInterface and activates data transfer 
		 * 
		 * Main reasoning for this method is to allow chain API in objective 
		 * languages which makes code much simpler to follow 
		 * 
		 * NOTE!
		 * transform_from and transform_to can work in two ways. If value return
		 * is true, then newly converted value is assigned to property, if
		 * return is false, then that doesn't happen which can be used to assign
		 * property values directly and avoiding value conversion
		 *   
		 * @since 0.1
		 * @param source_property Source property name
		 * @param target Target object
		 * @param target_property Target property name
		 * @param flags Flags describing property binding creation
		 * @param transform_to Custom method to transform data from source value
		 *                     to target value
		 * @param transform_from Custom method to transform data from source 
		 *                       value to target value
		 * @param source_validation Specifies custom method to validate this
		 *                          particular property in source object. When
		 *                          this is not specified, validity is true
		 * @return Newly create BindingInformationInterface
		 */
		public BindingInformationInterface bind_default (
				string source_property, string target_property, BindFlags flags = BindFlags.DEFAULT,
				owned PropertyBindingTransformFunc? transform_to = null, owned PropertyBindingTransformFunc? transform_from = null,
				owned SourceValidationFunc? source_validation = null
		) {
			return (contract.bind (source_property, contract.default_target, target_property, flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
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
	}
}
