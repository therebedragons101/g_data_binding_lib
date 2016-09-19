namespace GData
{
	/**
	 * Interface that allows easier mapping of object. This is not to be
	 * confused with BinderMapper which is very similar. BindingContractMapper
	 * does exact same job on contract level which means that binding don't just
	 * fall apart when source or target is unvailable.
	 * 
	 * BinderMapper should be used where there is no need to track source
	 * changes while BindingContractMapper provides a bit heavier but more
	 * reliable bindings.
	 * 
	 * When to use one or another?
	 * - Read documentation about passive and active bindings. Whenever passive
	 * is more suitable BinderMapper should be used, for active using
	 * BindingContractMapper trough contract is better
	 * - For binding things that don't require changing persistence BinderMapper
	 * is correct choice. Under this fall things like main gui or list box
	 * rows
	 * - For binding things that track current selection like for example having
	 * listbox with items where your main gui needs to handle current
	 * selection BindingContractMapper is correct choice
	 * 
	 * @since 0.1
	 */
	public interface BindingContractMapper : Object
	{
		/**
		 * Contract owning this mapper
		 * 
		 * @since 0.1
		 */
		public abstract BindingContract contract_object { get; set; }

		/**
		 * Maps complete object structure from source to target. Map internally
		 * calls map_properties() by setting up layout from all enumerated
		 * properties available in source object
		 * 
		 * @since 0.1
		 * 
		 * @param source_type Source object type
		 * @param target Target object
		 * @param common_target_property_alias Common target property alias
		 * @param flags Binding flags
		 * @param prefix Prefix for widget names during discovery
		 * @param suffix Suffix for widget names during discovery
		 * @return Array of created bindings
		 */
		public BindingInformationInterface[] map_all (Type source_type, Object? target, string common_target_property_alias, 
		                                              BindFlags flags=BindFlags.SYNC_CREATE, string prefix = "", string suffix = "")
		{
			BindingInformationInterface[] res = new BindingInformationInterface[0];
			if ((target == null))
				return (res);
			GLib.Array<string> aprops = new GLib.Array<string>();
			TypeInformation.get_instance().iterate_type_properties(source_type, (p) => {
				aprops.append_val(p.name);
			});
			if (aprops.length == 0)
				return (res);
			string[] props = new string[aprops.length];
			for (int i=(int)aprops.length-1; i>=0; i--) {
				props[i] = aprops.data[(uint) i];
				aprops.remove_index (i);
			}
			res = map_properties (source_type, target, props, ALIAS_DEFAULT, flags, prefix, suffix);
			return (res);
		}

		/**
		 * Maps complete object structure from source to target. Map internally
		 * calls map_all() and specifies ALIAS_DEFAULT as targets common
		 * alias property which stands for default value property. This is not
		 * to be confused with map_to_single(). Later maps single source property
		 * to all elements in target which is useful to control sensitivity or
		 * visibility when specific layout is chosen
		 * 
		 * @since 0.1
		 * 
		 * @param source_type Source object type
		 * @param target Target object
		 * @param flags Binding flags
		 * @param prefix Prefix for widget names during discovery
		 * @param suffix Suffix for widget names during discovery
		 * @return Array of created bindings
		 */
		public BindingInformationInterface[] map (Type source_type, Object? target, BindFlags flags=BindFlags.SYNC_CREATE, string prefix = "", string suffix = "")
		{
			return (map_all (source_type, target, ALIAS_DEFAULT, flags, prefix, suffix));
		}

		/**
		 * Maps only specific properties or sublayouts from source to target
		 * 
		 * @since 0.1
		 * 
		 * @param source_type Source object type
		 * @param target Target object
		 * @param layout Names of properties or layouts that need to be binded
		 * @param common_target_property_alias Common target property alias
		 * @param flags Binding flags
		 * @param prefix Prefix for widget names during discovery
		 * @param suffix Suffix for widget names during discovery
		 * @return Array of created bindings
		 */
		public abstract BindingInformationInterface[] map_properties (Type source_type, Object? target, string[] layout, string common_target_property_alias,
		                                                              BindFlags flags=BindFlags.SYNC_CREATE, string prefix = "", string suffix = "");

		/**
		 * Resolving of objects being mapped is exactly the same as in map()
		 * with one difference instead of mapping them with their respective
		 * pair, it maps all to the same property and same value. This is useful
		 * to control things like visibility or sensitivity. And the other
		 * differnce is that unlike in map this also supports transform
		 * functions.
		 * 
		 * @since 0.1
		 * 
		 * @param source_type Source object type
		 * @param source_property Name of source property that is being used as
		 *                        mapping point
		 * @param target Target object
		 * @param layout Names of properties or layouts that need to be binded
		 * @param common_target_property_alias Common target property alias
		 * @param flags Binding flags
		 * @param prefix Prefix for widget names during discovery
		 * @param suffix Suffix for widget names during discovery
		 * @param transform_to Method used to transform data
		 * @param transform_from Method used to transform data
		 * @return Array of created bindings
		 */
		public abstract BindingInformationInterface[] map_single (Type source_type, string source_property, Object? target, string[] layout,
		                                                          string common_target_property_alias, BindFlags flags=BindFlags.SYNC_CREATE,
		                                                          string prefix = "", string suffix = "", owned PropertyBindingTransformFunc? transform_to = null, 
		                                                          owned PropertyBindingTransformFunc? transform_from = null);

		/**
		 * All binding mappers should for consistency reasons call this method
		 * to invoke binding as it guarantees consistency of it.
		 * 
		 * @since 0.1
		 * 
		 * @param source_type Source object type
		 * @param source_property Source property name
		 * @param target Target object
		 * @param target_property Target property name
		 * @param flags Binding flags determining binding rules
		 * @param transform_to Method used to transform data
		 * @param transform_from Method used to transform data
		 * @return Created binding or null if unsucessful
		 */
		protected BindingInformationInterface? bind (Type source_type, string source_property, Object? target, string target_property,
		                                             BindFlags flags, owned PropertyBindingTransformFunc? transform_to = null, 
		                                             owned PropertyBindingTransformFunc? transform_from = null)
		{
			if (target == null)
				return (null);
			BindingDataTransfer? trs = (BindingDataTransfer?) BindingDefaults.get_instance().get_introspection_object_for (source_type, source_property, false);
			BindingDataTransfer? trt = (BindingDataTransfer?) BindingDefaults.get_instance().get_transfer_object_for (target, target_property, false);
			return (bind_transfers (trs, trt, flags, transform_to, transform_from));
		}

		/**
		 * Invokes binding between two BindingDataTransfer objects
		 * 
		 * @since 0.1
		 * 
		 * @param source Source transfer object
		 * @param target Target transfer object
		 * @param flags Binding flags determining binding rules
		 * @param transform_to Method used to transform data
		 * @param transform_from Method used to transform data
		 * @return Created binding or null if unsucessful
		 */
		protected BindingInformationInterface? bind_transfers (BindingDataTransferInterface? source, BindingDataTransferInterface? target,
		                                                       BindFlags flags, owned PropertyBindingTransformFunc? transform_to = null, 
		                                                       owned PropertyBindingTransformFunc? transform_from = null)
		{
			if ((source == null) || (target == null))
				return (null);
			//TODO, handle safe object
			if ((source.get_value_type().is_a(typeof(Object)) == true) || (target.get_value_type().is_a(typeof(Object))))
				if (source.get_value_type().is_a(target.get_value_type()) == false)
					return (null);
			if (can_translate_value_type(source.get_value_type(), target.get_value_type()) == false)
				return (null);
			BindingInformationInterface res = contract().bind (source.get_name(), target.get_object(), target.get_name(), flags, transform_to, transform_from);
			return (res);
		}

		/**
		 * Returns binder object for chaining
		 * 
		 * @since 0.1
		 */
		public BindingContract contract()
		{
			return (contract_object);
		}
	}
}

