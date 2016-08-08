using GData;

namespace GDataGtk
{
	/**
	 * Class intended to bind directly from glade file as coding convenience
	 * 
	 * @since 0.1
	 */
	public class GladeMapper
	{
		/**
		 * Target name prefix string, this is added on every bind
		 * 
		 * @since 0.1
		 */
		public string prefix { get; set; default = ""; }

		/**
		 * Target name suffix string, this is added on every bind
		 * 
		 * @since 0.1
		 */
		public string suffix { get; set; default = ""; }

		private StrictWeakReference<Gtk.Builder> _ui_builder = null;
		/**
		 * Reference to builder object
		 * 
		 * @since 0.1
		 */
		public Gtk.Builder ui_builder {
			get { return (_ui_builder.target); }
		}

		private StrictWeakReference<BindingContract> _contract = null;
		/**
		 * Contract BindingInformation belongs to
		 * 
		 * @since 0.1
		 */
		public abstract BindingContract contract { 
			get { return (_contract.target); } 
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
		public ContractBinderInterface bind (
				string source_property, string target, string target_property, BindFlags flags = BindFlags.DEFAULT, 
				owned PropertyBindingTransformFunc? transform_to = null, owned PropertyBindingTransformFunc? transform_from = null, 
				owned SourceValidationFunc? source_validation = null
		) {
			return (_bind (source_property, ui_builder.get_object(prefix + target + suffix), target_property, flags,
			               owned transform_to, owned transform_from, owned source_validation));
		}

		/**
		 * Creates new instance of glade binder convenience class
		 * 
		 * @since 0.1
		 * 
		 * @param contract Contract binding is done for
		 * @param ui_builder Builder object that contains specific file
		 */
		public GladeBinder (BindingContract? contract, Gtk.Builder? ui_builder, string prefix = "", string suffix = "")
			requires (contract != null)
			requires (ui_builder != null)
		{
			this._ui_builder = new StrictWeakReference<BindingContract> (ui_builder);
			_contract = new StrictWeakReference<BindingContract> (contract);
		}
	}
}

