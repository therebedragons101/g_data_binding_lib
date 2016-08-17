using GData;
using GData.Generics;

namespace GDataGtk
{
	internal class EventArray : ObjectArray<EventDescription>
	{
		private StrictWeakReference<BindingPointer?> _resource = null;
		public BindingPointer? resource {
			get { return (_resource.target); }
			set {
				if (resource == value)
					return;
				disconnect_events();
				clear();
				_resource.set_new_target (value);
				connect_events();
			}
		}

		private void handle_data_changed (BindingPointer binding, string cookie)
		{
			add (
				new ContractEventDescription.as_signal (
					EventFilterMode.POINTER_SOURCE,
					"data_changed", 
					"(binding=%s, data_change_cookie=%s)".printf (get_self_ref_equality(binding, resource), cookie),
					INFORMATION_COLOR("\tSource object change notification. Note that this is event triggered from outside when BindingPointer is MANUAL\n") +
					"\t\tbinding (BindingPointer emiting the notification)\n" +
					"\t\tdata_change_cookie (description of data change as passed on by triggering event)" +
					get_current_source (binding.get_source())
				)
			);
		}

		private void handle_pointer_before_source_change (BindingPointer binding, bool is_same, Object? next)
		{
			add (
				new ContractEventDescription.as_signal (
					EventFilterMode.POINTER_SOURCE,
					"before_source_change", 
					"(binding=%s, is_same=%i, next=%s)".printf (get_self_ref_equality(binding, resource), (int) is_same, (next != null) ? get_object_str(next) : _null()),
					INFORMATION_COLOR("\tObject being pointed is about to change. In case if reference was not dropped it can still be accessed trough binding\n") +
					"\t\tbinding (BindingPointer emiting the notification)\n" +
					"\t\tis_same (specifies if type of next source being pointed to is the same)\n" +
					"\t\tnext (reference to next object being pointed to)" +
					get_current_source (binding.get_source())
				)
			);
		}

		private void handle_pointer_source_changed (BindingPointer binding)
		{
			add (
				new ContractEventDescription.as_signal (
					EventFilterMode.POINTER_SOURCE,
					"source_changed", 
					"(binding=%s)".printf(get_self_ref_equality(binding, resource)),
					INFORMATION_COLOR("\tObject being pointed has changed.\n") +
					"\t\tbinding (BindingPointer emiting the notification)" +
					get_current_source (binding.get_source())
				)
			);
		}

		private void handle_pointer_connect_notifications (Object? obj)
		{
			add (
				new ContractEventDescription.as_signal (
					EventFilterMode.POINTER_CONNECTION,
					"connect_notifications", 
					"(obj = %s)".printf (__get_current_source (obj)),
					INFORMATION_COLOR("\tSignal to connect anything application needs connected beside basic requirements when data source changes.")
				)
			);
		}

		private void handle_pointer_disconnect_notifications (Object? obj)
		{
			add (
				new ContractEventDescription.as_signal (
					EventFilterMode.POINTER_CONNECTION,
					"disconnect_notifications", 
					"(obj = %s)".printf (__get_current_source (obj)),
					INFORMATION_COLOR("\tSignal to disconnect anything application needs connected beside basic requirements when data source changes.")
				)
			);
		}

		private void handle_pointer_notify_data (Object obj, ParamSpec param)
		{
			add (
				new ContractEventDescription.as_property (
					EventFilterMode.PROPERTY_NOTIFICATIONS,
					"data", 
					" = %s => %s".printf (__get_current_source (resource.data), _get_current_source (resource.get_source()))
				)
			);
		}

		private void handle_contract_contract_changed (BindingContract ccontract)
		{
			add (
				new ContractEventDescription.as_signal (
					EventFilterMode.CONTRACT_CHANGE,
					"contract_changed", 
					"(contract=%s)".printf(get_self_ref_equality(ccontract, resource)),
					INFORMATION_COLOR("\tEmited when contract is disolved or renewed after source change.\n") +
					"\t\tcontract (BindingContract emiting the notification)" +
					get_current_source (resource.get_source())
				)
			);
		}

		private void handle_contract_bindings_changed (BindingContract ccontract, ContractChangeType change_type, BindingInformationInterface binding)
		{
			add (
				new ContractEventDescription.as_signal (
					EventFilterMode.CONTRACT_BINDINGS,
					"bindings_changed", 
					"(contract=%s, change_type=%s, binding=[%s])".printf(get_self_ref_equality(ccontract, resource), change_type.get_state_str(), binding.as_str(true)),
					INFORMATION_COLOR("\tEmited when bindings are changed by adding or removing.\n") +
					"\t\tcontract (BindingContract emiting the notification)\n" +
					"\t\tchange_type (binding ADDED or REMOVED)\n" +
					"\t\tbinding (BindingContract emiting the notification)" +
					get_current_source (resource.get_source())
				)
			);
		}

		private void handle_contract_notify_is_valid (Object obj, ParamSpec param)
		{
			add (
				new ContractEventDescription.as_property (
					EventFilterMode.PROPERTY_NOTIFICATIONS,
					"is_valid", 
					" = %s".printf (bool_str(as_contract(resource).is_valid == true))
				)
			);
		}

		private void handle_contract_notify_length (Object obj, ParamSpec param)
		{
			add (
				new ContractEventDescription.as_property (
					EventFilterMode.PROPERTY_NOTIFICATIONS,
					"length", 
					" = %i".printf ((int) (as_contract(resource).length))
				)
			);
		}

		private void handle_contract_notify_suspended (Object obj, ParamSpec param)
		{
			add (
				new ContractEventDescription.as_property (
					EventFilterMode.PROPERTY_NOTIFICATIONS,
					"is_suspended", 
					" = %s".printf (bool_str((as_contract(resource).suspended == true)))
				)
			);
		}

		internal void connect_binding_pointer_events()
		{
			resource.data_changed.connect (handle_data_changed);
			resource.before_source_change.connect (handle_pointer_before_source_change);
			resource.source_changed.connect (handle_pointer_source_changed);
			resource.connect_notifications.connect (handle_pointer_connect_notifications);
			resource.disconnect_notifications.connect (handle_pointer_disconnect_notifications);
			resource.notify["data"].connect (handle_pointer_notify_data);
		}

		internal void connect_binding_contract_events()
		{
			connect_binding_pointer_events();
			as_contract(resource).contract_changed.connect (handle_contract_contract_changed);
			as_contract(resource).bindings_changed.connect (handle_contract_bindings_changed);
			as_contract(resource).notify["is-valid"].connect (handle_contract_notify_is_valid);
			as_contract(resource).notify["length"].connect (handle_contract_notify_length);
			as_contract(resource).notify["suspended"].connect (handle_contract_notify_suspended);
		}

		internal void disconnect_binding_pointer_events()
		{
			resource.data_changed.disconnect (handle_data_changed);
			resource.before_source_change.disconnect (handle_pointer_before_source_change);
			resource.source_changed.disconnect (handle_pointer_source_changed);
			resource.connect_notifications.disconnect (handle_pointer_connect_notifications);
			resource.disconnect_notifications.disconnect (handle_pointer_disconnect_notifications);
			resource.notify["data"].disconnect (handle_pointer_notify_data);
		}

		internal void disconnect_binding_contract_events()
		{
			disconnect_binding_pointer_events();
			as_contract(resource).contract_changed.disconnect (handle_contract_contract_changed);
			as_contract(resource).bindings_changed.disconnect (handle_contract_bindings_changed);
			as_contract(resource).notify["is-valid"].disconnect (handle_contract_notify_is_valid);
			as_contract(resource).notify["length"].disconnect (handle_contract_notify_length);
			as_contract(resource).notify["suspended"].disconnect (handle_contract_notify_suspended);
		}

		internal void connect_events()
		{
			if (resource == null)
				return;
			if (is_binding_contract(resource) == true)
				connect_binding_contract_events();
			else
				connect_binding_pointer_events();
		}

		internal void disconnect_events()
		{
			if (resource == null)
				return;
			if (is_binding_contract(resource) == true)
				disconnect_binding_contract_events();
			else
				disconnect_binding_pointer_events();
		}

		~EventArray()
		{
			disconnect_events();
		}

		public EventArray (BindingPointer? ptr = null)
		{
			_resource = new StrictWeakReference<BindingPointer?>(null);
			resource = ptr;
		}
	}
}

