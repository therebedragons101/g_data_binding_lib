# this makefile is based on work from https://github.com/antono/vala-object/blob/master/Makefile

export LD_LIBRARY_PATH := $(shell pwd)
export GI_TYPELIB_PATH := $(shell pwd)

# edit library name and version here
COMMON_NAME := g_data_binding
NAME_SUFFIX := _lib
LIBRARY_NAME := ${COMMON_NAME}${NAME_SUFFIX}
GTK_LIBRARY_NAME := ${COMMON_NAME}_gtk${NAME_SUFFIX}
INCLUDES := ../includes/
BIN := ../bin/
RESOURCE := ../resources/

LIB_MAJOR := 0
LIB_MINOR := 1
LIB_VERSION := ${LIB_MAJOR}.${LIB_MINOR}

all: resources \
     ${LIBRARY_NAME}.so \
     ${COMMON_NAME}_generics${NAME_SUFFIX}.so \
     ${COMMON_NAME}_gtk${NAME_SUFFIX}.so \
     demo-and-tutorial \
     tests \
     hack-for-gir-bug \
     ${LIBRARY_NAME}-${LIB_VERSION}.typelib \
     move-binaries-to-bin

#     ${GTK_LIBRARY_NAME}-${LIB_VERSION}.typelib \

run: run-${COMMON_NAME}_lib

run-g_${COMMON_NAME}_lib:

COMMON_INTERNAL := common/consts.vala \
	common/markup.vala \
	common/methods.vala

SOURCES := ${LIBRARY_NAME}.vala \
	${COMMON_INTERNAL} \
	common/compare_data_by.vala \
	common/delegates.vala \
	common/gobject_array.vala \
	common/has_description.vala \
	common/object_information.vala \
	common/ref_timeout.vala \
	common/reference_monitor.vala \
	common/reference_monitor_group.vala \
	common/strict_weak_ref.vala \
	common/strict_weak_reference_t.vala \
	common/unique_by_properties.vala \
	common/weak_ref.vala \
	common/weak_ref_wrapper.vala \
	common/weak_reference_t.vala \
	contracts/binding_pointer.vala \
	contracts/binding_contract.vala \
	contracts/binding_group.vala \
	contracts/binding_information.vala \
	contracts/binding_information_interface.vala \
	contracts/binding_information_reference.vala \
	contracts/binding_pointer_from_property_value.vala \
	contracts/binding_pointer_update_type.vala \
	contracts/binding_reference_type.vala \
	contracts/binding_suspension_group.vala \
	contracts/binding_state_objects.vala \
	contracts/binding_value_objects.vala \
	contracts/consts.vala \
	contracts/contract_change_type.vala \
	contracts/contract_mapper_interface.vala \
	contracts/contract_storage.vala \
	contracts/custom_binding_source_state.vala \
	contracts/custom_binding_source_value.vala \
	contracts/custom_property_notification_binding_source.vala \
	contracts/delegates.vala \
	contracts/enum_state.vala \
	contracts/enum_state_group.vala \
	contracts/flag_state.vala \
	contracts/flag_state_group.vala \
	contracts/methods.vala \
	contracts/pointer_namespace.vala \
	contracts/pointer_storage.vala \
	contracts/proxy_property.vala \
	contracts/proxy_property_group.vala \
	contracts/signal_controlled_binding_pointer.vala \
	contracts/timer_controlled_binding_pointer.vala \
	property/bind_flags.vala \
	property/binder.vala \
	property/binding_side.vala \
	property/binding_interface.vala \
	property/binding_namespace.vala \
	property/data_flood_detection.vala \
	property/delegates.vala \
	property/property_alias.vala \
	property/property_binding.vala \
	property/type_information.vala \
	row_models/enum_flags_model.vala \
	row_models/enum_flags_value_object.vala \
	row_models/inverted_list_model.vala \
	row_models/row_model.vala

GENERICS_SOURCES := ${COMMON_NAME}_generics${NAME_SUFFIX}.vala \
	${COMMON_INTERNAL} \
	generics/common/delegates.vala \
	generics/common/key_value_array_k_v.vala \
	generics/common/key_value_pair_k_v.vala \
	generics/common/master_slave_array_mk_k_v.vala \
	generics/common/object_array_t.vala \
	generics/common/strict_weak_reference_t.vala \
	generics/common/weak_reference_t.vala \
	generics/contracts/contract_array.vala \
	generics/contracts/contract_storage.vala \
	generics/contracts/custom_binding_source_data_t.vala \
	generics/contracts/delegates.vala \
	generics/contracts/pointer_array.vala \
	generics/contracts/pointer_storage.vala \
	generics/property/alias_array.vala \
	generics/property/property_alias.vala

#	${RESOURCE}${COMMON_NAME}_gtk${NAME_SUFFIX}.*
GTK_SOURCES := ${COMMON_NAME}_gtk${NAME_SUFFIX}.vala \
	${RESOURCE}${COMMON_NAME}_gtk${NAME_SUFFIX}.* \
	${COMMON_INTERNAL} \
	gtk/inspector/binding_inspector.vala \
	gtk/inspector/binding_namespace_view_mode.vala \
	gtk/inspector/contract_event_description.vala \
	gtk/inspector/default_widgets.vala \
	gtk/inspector/event_array.vala \
	gtk/inspector/event_description.vala \
	gtk/inspector/event_filter_mode.vala \
	gtk/inspector/methods.vala \
	gtk/inspector/object_inspector_window.vala \
	gtk/widgets/edit_mode.vala \
	gtk/widgets/enum_flags_menu_button.vala \
	gtk/widgets/enum_flags_popover.vala \
	gtk/widgets/enum_flags_values.vala \
	gtk/widgets/enum_flags_value_interface.vala \
	gtk/widgets/methods.vala \
	gtk/widgets/object_events_row.vala \
	gtk/widgets/object_inspector.vala \
	gtk/widgets/object_inspector_listbox_row.vala \
	gtk/widgets/object_inspector_row.vala \
	gtk/widgets/object_inspector_view.vala \
	gtk/widgets/placeholder.vala \
	gtk/widgets/preflight_event_box.vala \
	gtk/widgets/pointer_info.vala \
	gtk/widgets/reference_monitor_row.vala \
	gtk/widgets/reference_monitor_show_view.vala \
	gtk/widgets/simple_entry_box.vala \
	gtk/widgets/smooth_list_box_row.vala \
	gtk/widgets/state_image.vala \
	gtk/widgets/title_description_row.vala \
	gtk/widgets/track_element.vala \
	gtk/widgets/track_log_element.vala \
	gtk/widgets/widget_defaults.vala

DEMO_INCLUDES := ${COMMON_INTERNAL} \
	demos/common/css.vala \
	demos/common/persons.vala

DEMO_SOURCES := demos/demo_and_tutorial/main.vala \
	demos/demo_and_tutorial/simple_binding/*.vala \
	demos/demo_and_tutorial/main_demo.vala \
	${RESOURCE}demo_and_tutorial.* \
	gtk/inspector/event_array.vala \
	gtk/inspector/methods.vala

PACKAGES := --pkg gio-2.0
DEMO_PACKAGES := --pkg gtk+-3.0
GTK_PACKAGES := --pkg gtk+-3.0

# Vala

resources:
	sh ../scripts/build_resources.sh

${LIBRARY_NAME}.so:
	valac \
		-H ${INCLUDES}${LIBRARY_NAME}.h \
		--vapi=${INCLUDES}${LIBRARY_NAME}${LIB_MAJOR}.vapi \
		-X \
		-fPIC \
		-X \
		-shared \
		--library=${LIBRARY_NAME}${LIB_MAJOR} \
		--gir=${INCLUDES}${LIBRARY_NAME}-${LIB_VERSION}.gir \
		-o ${LIBRARY_NAME}${LIB_MAJOR}.so \
	${PACKAGES} \
	${SOURCES}

${COMMON_NAME}_generics${NAME_SUFFIX}.so:
	valac \
		-H ${INCLUDES}${COMMON_NAME}_generics${NAME_SUFFIX}.h \
		--vapi=${INCLUDES}${COMMON_NAME}_generics${NAME_SUFFIX}${LIB_MAJOR}.vapi \
		-X \
		-fPIC \
		-X \
		-shared \
		--library=${COMMON_NAME}_generics${NAME_SUFFIX}${LIB_MAJOR} \
		--gir=${INCLUDES}${COMMON_NAME}_generics${NAME_SUFFIX}-${LIB_VERSION}.gir \
		-o ${COMMON_NAME}_generics${NAME_SUFFIX}${LIB_MAJOR}.so \
		-X -I${INCLUDES} \
		-X ${LIBRARY_NAME}${LIB_MAJOR}.so \
		${INCLUDES}${LIBRARY_NAME}${LIB_MAJOR}.vapi \
	${PACKAGES} \
	${GENERICS_SOURCES}

${COMMON_NAME}_gtk${NAME_SUFFIX}.so:
	valac \
		-H ${INCLUDES}${COMMON_NAME}_gtk${NAME_SUFFIX}.h \
		--vapi=${INCLUDES}${COMMON_NAME}_gtk${NAME_SUFFIX}${LIB_MAJOR}.vapi \
		-X \
		-fPIC \
		-X \
		-shared \
		--target-glib=2.38 \
		--gresources=gtk/g_data_binding_gtk_lib.resource \
		--library=${COMMON_NAME}_gtk${NAME_SUFFIX}${LIB_MAJOR} \
		--gir=${INCLUDES}${COMMON_NAME}_gtk${NAME_SUFFIX}-${LIB_VERSION}.gir \
		-o ${COMMON_NAME}_gtk${NAME_SUFFIX}${LIB_MAJOR}.so \
		-X -I${INCLUDES} \
		-X ${LIBRARY_NAME}${LIB_MAJOR}.so \
		-X ${COMMON_NAME}_generics${NAME_SUFFIX}${LIB_MAJOR}.so \
		${INCLUDES}${LIBRARY_NAME}${LIB_MAJOR}.vapi \
		${INCLUDES}${COMMON_NAME}_generics${NAME_SUFFIX}${LIB_MAJOR}.vapi \
	${PACKAGES} \
	${GTK_PACKAGES} \
	${GTK_SOURCES}

hack-for-gir-bug:
	sh gir_temporary_fix.sh

${LIBRARY_NAME}-${LIB_VERSION}.typelib:
	g-ir-compiler \
		--shared-library=${LIBRARY_NAME}${LIB_MAJOR}.so \
		--output=${INCLUDES}${LIBRARY_NAME}-${LIB_VERSION}.typelib \
		${INCLUDES}${LIBRARY_NAME}-${LIB_VERSION}.gir

${GTK_LIBRARY_NAME}-${LIB_VERSION}.typelib:
	g-ir-compiler \
		--shared-library=${GTK_LIBRARY_NAME}${LIB_MAJOR}.so \
		--output=${INCLUDES}${GTK_LIBRARY_NAME}-${LIB_VERSION}.typelib \
		${INCLUDES}${GTK_LIBRARY_NAME}-${LIB_VERSION}.gir

demo-and-tutorial:
	valac \
		${PACKAGES} \
		${DEMO_PACKAGES} \
		${INCLUDES}${LIBRARY_NAME}${LIB_MAJOR}.vapi \
		${INCLUDES}${COMMON_NAME}_generics${NAME_SUFFIX}${LIB_MAJOR}.vapi \
		${INCLUDES}${COMMON_NAME}_gtk${NAME_SUFFIX}${LIB_MAJOR}.vapi \
		-X -I${INCLUDES} \
		-X ${LIBRARY_NAME}${LIB_MAJOR}.so \
		-X ${COMMON_NAME}_generics${NAME_SUFFIX}${LIB_MAJOR}.so \
		-X ${COMMON_NAME}_gtk${NAME_SUFFIX}${LIB_MAJOR}.so \
		-o ${BIN}demo_and_tutorial \
	${DEMO_INCLUDES} \
	${DEMO_SOURCES}

tests:
	valac \
		${PACKAGES} \
		${DEMO_PACKAGES} \
		${INCLUDES}${LIBRARY_NAME}${LIB_MAJOR}.vapi \
		${INCLUDES}${COMMON_NAME}_generics${NAME_SUFFIX}${LIB_MAJOR}.vapi \
		${INCLUDES}${COMMON_NAME}_gtk${NAME_SUFFIX}${LIB_MAJOR}.vapi \
		-X -I${INCLUDES} \
		-X ${LIBRARY_NAME}${LIB_MAJOR}.so \
		-X ${COMMON_NAME}_generics${NAME_SUFFIX}${LIB_MAJOR}.so \
		-X ${COMMON_NAME}_gtk${NAME_SUFFIX}${LIB_MAJOR}.so \
		-o ${BIN}tests \
	${DEMO_INCLUDES} \
	demos/tests/main.vala

move-binaries-to-bin:
	mv *.so ${BIN}

# other

clean:
	rm -fr $(shell cat .gitignore)
