namespace GData
{
	/**
	 * Convenience binding interface whose main purpose is to enable specific
	 * binding conveniences which are defined by class that implements it. This
	 * is done in a way where it accepts target name instead if target refernce
	 * 
	 * Example class is GDataGtk.GladeMapper which allows simply passing name
	 * of widget in glade file instead of its reference
	 * 
	 * @since 0.1
	 */
	public interface ContractMapperInterface : Object
	{
		/**
		 * Target name prefix string, this is added on every bind
		 * 
		 * @since 0.1
		 */
		public abstract string prefix { get; set; }

		/**
		 * Target name suffix string, this is added on every bind
		 * 
		 * @since 0.1
		 */
		public abstract string suffix { get; set; }

		/**
		 * Contract BindingInformation belongs to
		 * 
		 * @since 0.1
		 */
		public abstract BindingContract contract { get; }

		public ContractMapperInterface automap (string[] properties, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, 
				owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			return (_automap (properties, "=", flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
		}

		public ContractMapperInterface automaps (string[] properties, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, 
				owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			return (_automap (properties, "^", flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
		}

		public ContractMapperInterface automape (string[] properties, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, 
				owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			return (_automap (properties, "=", flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
		}

		public ContractMapperInterface automapv (string[] properties, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, 
				owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			return (_automap (properties, "!", flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
		}

		private ContractMapperInterface _automap (string[] properties, string target_property,
				BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, 
				owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			if ((properties.length == 1) && (properties[0] == ""))
				return (this);
			GLib.Array<string> props = new GLib.Array<string>();
			if (properties.length == 0) {
				Type type = typeof(Object);
				if (contract.only_accept_type != null)
					type = contract.only_accept_type;
				else if (contract.get_source() == null) {
					GLib.error ("When automapping all properties, contract must have valid source or there has to be specified type in only_accept_type");
					return (this);
				}
				else
					type = contract.get_source().get_type();

				ObjectClass ocl = (ObjectClass) type.class_ref ();
				foreach (ParamSpec spec in ocl.list_properties ())
					props.append_val (spec.get_name ());
			}
			else
				for (int i=0; i<properties.length; i++)
					props.append_val (properties[i]);
			for (int i=0; i<props.length; i++)
				map (props.data[i], target_property, flags, (owned) transform_to, (owned) transform_from, (owned) source_validation);
			return (this);
		}

		/**
		 * Convenience method that tries to map following
		 * - source object is taken from contract
		 * - source property name
		 * - target is resolved by name using (prefix+source_property+suffix)
		 * - target property name
		 * 
		 * NOTE! 
		 * _map(), _mapv() and _maps() methods are almost the same with 
		 * exception of fixed target property names where
		 * 
		 * - _map() defaults to "&" (aka. default)
		 * - _mape() defaults to "=" (aka. equal as source property name)
		 * - _mapv() defaults to "^" (aka. sensitive)
		 * - _maps() defaults to "!" (aka. visible)
		 * 
		 * These 3 can be freely taken advantage of by defining custom property
		 * aliases
		 * 
		 * @since 0.1
		 * @param source_property Source property name
		 * @param flags Flags describing property binding creation
		 * @param transform_to Custom method to transform data from source value
		 *                     to target value
		 * @param transform_from Custom method to transform data from source 
		 *                       value to target value
		 * @param source_validation Specifies custom method to validate this
		 *                          particular property in source object. When
		 *                          this is not specified, validity is true
		 * @return Returns instance of it self in order to allow further 
		 *         chaining
		 */
		public ContractMapperInterface _map (
				string source_property, string target_property, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, 
				owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			return (map (source_property, "&", flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
		}

		/**
		 * Convenience method that tries to map following
		 * - source object is taken from contract
		 * - source property name
		 * - target is resolved by name using (prefix+source_property+suffix)
		 * - target property name is fixed to "^" (aka. sensitive)
		 * 
		 * NOTE! 
		 * _map(), _mapv() and _maps() methods are almost the same with 
		 * exception of fixed target property names where
		 * 
		 * - _map() defaults to "&" (aka. default)
		 * - _mape() defaults to "=" (aka. equal as source property name)
		 * - _mapv() defaults to "^" (aka. sensitive)
		 * - _maps() defaults to "!" (aka. visible)
		 * 
		 * These 3 can be freely taken advantage of by defining custom property
		 * aliases
		 * 
		 * @since 0.1
		 * @param source_property Source property name
		 * @param flags Flags describing property binding creation
		 * @param transform_to Custom method to transform data from source value
		 *                     to target value
		 * @param transform_from Custom method to transform data from source 
		 *                       value to target value
		 * @param source_validation Specifies custom method to validate this
		 *                          particular property in source object. When
		 *                          this is not specified, validity is true
		 * @return Returns instance of it self in order to allow further 
		 *         chaining
		 */
		public ContractMapperInterface _maps (
				string source_property, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, 
				owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			return (map (source_property, "^", flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
		}

		/**
		 * Convenience method that tries to map following
		 * - source object is taken from contract
		 * - source property name
		 * - target is resolved by name using (prefix+source_property+suffix)
		 * - target property name is fixed to "=" (aka. equal as source)
		 * 
		 * NOTE! 
		 * _map(), _mapv() and _maps() methods are almost the same with 
		 * exception of fixed target property names where
		 * 
		 * - _map() defaults to "&" (aka. default)
		 * - _mape() defaults to "=" (aka. equal as source property name)
		 * - _mapv() defaults to "^" (aka. sensitive)
		 * - _maps() defaults to "!" (aka. visible)
		 * 
		 * These 3 can be freely taken advantage of by defining custom property
		 * aliases
		 * 
		 * @since 0.1
		 * @param source_property Source property name
		 * @param flags Flags describing property binding creation
		 * @param transform_to Custom method to transform data from source value
		 *                     to target value
		 * @param transform_from Custom method to transform data from source 
		 *                       value to target value
		 * @param source_validation Specifies custom method to validate this
		 *                          particular property in source object. When
		 *                          this is not specified, validity is true
		 * @return Returns instance of it self in order to allow further 
		 *         chaining
		 */
		public ContractMapperInterface _mape (
				string source_property, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, 
				owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			return (map (source_property, "=", flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
		}

		/**
		 * Convenience method that tries to map following
		 * - source object is taken from contract
		 * - source property name
		 * - target is resolved by name using (prefix+source_property+suffix)
		 * - target property name defaults to "!" (aka. visible)
		 * 
		 * NOTE! 
		 * _map(), _mape(), _mapv() and _maps() methods are almost the same with
		 * exception of fixed target property names where
		 * 
		 * - _map() defaults to "&" (aka. default)
		 * - _mape() defaults to "=" (aka. equal as source property name)
		 * - _mapv() defaults to "^" (aka. sensitive)
		 * - _maps() defaults to "!" (aka. visible)
		 * 
		 * These 3 can be freely taken advantage of by defining custom property
		 * aliases
		 * 
		 * @since 0.1
		 * @param source_property Source property name
		 * @param flags Flags describing property binding creation
		 * @param transform_to Custom method to transform data from source value
		 *                     to target value
		 * @param transform_from Custom method to transform data from source 
		 *                       value to target value
		 * @param source_validation Specifies custom method to validate this
		 *                          particular property in source object. When
		 *                          this is not specified, validity is true
		 * @return Returns instance of it self in order to allow further 
		 *         chaining
		 */
		public ContractMapperInterface _mapv (
				string source_property, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, 
				owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			return (map (source_property, "!", flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
		}

		/**
		 * Convenience method that tries to map following
		 * - source object is taken from contract
		 * - source property name
		 * - target is resolved by name using (prefix+source_property+suffix)
		 * - target property name
		 * 
		 * NOTE! 
		 * _map(), _mape(), _mapv() and _maps() methods are almost the same with
		 * of fixed target property names where
		 * - _map() defaults to "&" (aka. default)
		 * - _mape() defaults to "=" (aka. equal as source property name)
		 * - _mapv() defaults to "^" (aka. sensitive)
		 * - _maps() defaults to "!" (aka. visible)
		 * 
		 * These 3 can be freely taken advantage of by defining custom property
		 * aliases
		 * 
		 * @since 0.1
		 * @param source_property Source property name
		 * @param target Target object name
		 * @param target_property Target property name
		 * @param flags Flags describing property binding creation
		 * @param transform_to Custom method to transform data from source value
		 *                     to target value
		 * @param transform_from Custom method to transform data from source 
		 *                       value to target value
		 * @param source_validation Specifies custom method to validate this
		 *                          particular property in source object. When
		 *                          this is not specified, validity is true
		 * @return Returns instance of it self in order to allow further 
		 *         chaining
		 */
		public ContractMapperInterface map (
				string source_property, string target_property, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, 
				owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			return (bind (source_property, source_property, target_property, flags, (owned) transform_to, (owned) transform_from, (owned) source_validation));
		}

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
		 * This method is already preset so it can be used in derived classes by
		 * just redirecting correct data to it
		 * 
		 * Implementation in classes must have their own handling of "prefix" 
		 * and "suffix"
		 * 
		 * @since 0.1
		 * @param source_property Source property name
		 * @param target Target object name
		 * @param target_property Target property name
		 * @param flags Flags describing property binding creation
		 * @param transform_to Custom method to transform data from source value
		 *                     to target value
		 * @param transform_from Custom method to transform data from source 
		 *                       value to target value
		 * @param source_validation Specifies custom method to validate this
		 *                          particular property in source object. When
		 *                          this is not specified, validity is true
		 * @return Returns instance of it self in order to allow further 
		 *         chaining
		 */
		public abstract ContractMapperInterface bind (
				string source_property, string target, string target_property, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null);

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
		 * This method is already preset so it can be used in derived classes by
		 * just redirecting correct data to it
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
		 * @return Returns instance of it self in order to allow further 
		 *         chaining
		 */
		public ContractMapperInterface _bind (
				string source_property, Object target, string target_property, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			BindingInformationInterface i = 
				contract.bind (source_property, target, target_property, flags, (owned) transform_to, (owned) transform_from, (owned) source_validation);
			if (i == null)
				GLib.warning ("Problem binding '%s' to '%s'", source_property, target_property);
			return (this);
		}
	}
}
