# this makefile is based on work from https://github.com/antono/vala-object/blob/master/Makefile

export LD_LIBRARY_PATH := $(shell pwd)
export GI_TYPELIB_PATH := $(shell pwd)
LIB_MAJOR := 0
LIB_MINOR := 1
LIB_VERSION := ${LIB_MAJOR}.${LIB_MINOR}

all: g_data_binding_lib.so \
	g_data_binding_generics_lib.so \
	demo-and-tutorial \
	g_data_binding_lib-${LIB_VERSION}.typelib
#	csource \

run: run-g_data_binding_lib 

run-g_data_binding_lib: 

#valac --library=test_shared -H test_shared.h test_shared.vala -X -fPIC -X -shared -o test_shared.so
SOURCES := g_data_binding_lib.vala \
	common/compare_data_by.vala \
	common/delegates.vala \
	common/key_value_array_k_v.vala \
	common/key_value_pair_k_v.vala \
	common/master_slave_array_mk_k_v.vala \
	common/object_array_t.vala \
	common/strict_weak_reference_t.vala \
	common/unique_by_properties.vala \
	common/weak_reference_t.vala \
	contracts/binding_contract.vala \
	contracts/binding_group.vala \
	contracts/binding_information.vala \
	contracts/binding_information_interface.vala \
	contracts/binding_information_reference.vala \
	contracts/binding_pointer.vala \
	contracts/binding_pointer_from_property_value.vala \
	contracts/binding_pointer_update_type.vala \
	contracts/binding_reference_type.vala \
	contracts/binding_suspension_group.vala \
	contracts/binding_state_objects.vala \
	contracts/binding_value_objects.vala \
	contracts/consts.vala \
	contracts/contract_array.vala \
	contracts/contract_change_type.vala \
	contracts/contract_storage.vala \
	contracts/custom_binding_source_state.vala \
	contracts/custom_binding_source_value.vala \
	contracts/custom_property_notification_binding_source.vala \
	contracts/delegates.vala \
	contracts/methods.vala \
	contracts/pointer_array.vala \
	contracts/pointer_storage.vala \
	contracts/signal_controlled_binding_pointer.vala \
	contracts/timer_controlled_binding_pointer.vala \
	property/alias_array.vala \
	property/bind_flags.vala \
	property/binder.vala \
	property/binding_interface.vala \
	property/data_flood_detection.vala \
	property/delegates.vala \
	property/property_alias.vala \
	property/property_binding.vala

GENERICS_SOURCES := g_data_binding_generics_lib.vala \
	generics/common/key_value_array_k_v.vala \
	generics/common/key_value_pair_k_v.vala \
	generics/common/master_slave_array_mk_k_v.vala \
	generics/common/object_array_t.vala \
	generics/common/strict_weak_reference_t.vala \
	generics/common/weak_reference_t.vala \
	generics/contracts/custom_binding_source_data_t.vala

PACKAGES := --pkg gio-2.0
DEMO_PACKAGES := --pkg gtk+-3.0

# Vala

csource:
	valac \
	-H g_data_binding_lib.h \
	-C \
	--vapi=g_data_binding_lib${LIB_MAJOR}.vapi \
	--library=g_data_binding_lib${LIB_MAJOR} \
	${PACKAGES} \
	${SOURCES}

g_data_binding_lib.so:
	valac \
		-H g_data_binding_lib.h \
		--vapi=g_data_binding_lib${LIB_MAJOR}.vapi \
		-X \
		-fPIC \
		-X \
		-shared \
		--library=g_data_binding_lib${LIB_MAJOR} \
		--gir=g_data_binding_lib-${LIB_VERSION}.gir \
		-o g_data_binding_lib${LIB_MAJOR}.so \
	${PACKAGES} \
	${SOURCES}

g_data_binding_generics_lib.so:
	valac \
		-H g_data_binding_generics_lib.h \
		--vapi=g_data_binding_generics_lib${LIB_MAJOR}.vapi \
		-X \
		-fPIC \
		-X \
		-shared \
		--library=g_data_binding_generics_lib${LIB_MAJOR} \
		--gir=g_data_binding_generics_lib-${LIB_VERSION}.gir \
		-o g_data_binding_generics_lib${LIB_MAJOR}.so \
		-X -I. \
		-X g_data_binding_lib0.so \
		g_data_binding_lib${LIB_MAJOR}.vapi \
	${PACKAGES} \
	${GENERICS_SOURCES}

g_data_binding_lib-${LIB_VERSION}.typelib:
	g-ir-compiler \
		--shared-library=g_data_binding_lib${LIB_MAJOR}.so \
		--output=g_data_binding_lib-${LIB_VERSION}.typelib \
		g_data_binding_lib-${LIB_VERSION}.gir

demo-and-tutorial:
	valac \
		${PACKAGES} \
		${DEMO_PACKAGES} \
		demos/demo_and_tutorial/main.vala \
		g_data_binding_lib${LIB_MAJOR}.vapi \
		g_data_binding_generics_lib${LIB_MAJOR}.vapi \
		-X -I. \
		-X g_data_binding_lib0.so \
		-X g_data_binding_generics_lib0.so \
		-o demos/demo_and_tutorial/demo_and_tutorial

# other

clean:
	rm -fr $(shell cat .gitignore)
