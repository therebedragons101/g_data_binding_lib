# this makefile is based on work from https://github.com/antono/vala-object/blob/master/Makefile

export LD_LIBRARY_PATH := $(shell pwd)
export GI_TYPELIB_PATH := $(shell pwd)
LIB_MAJOR := 0
LIB_MINOR := 1
LIB_VERSION := ${LIB_MAJOR}.${LIB_MINOR}

all: g_data_binding_lib.so \
	g_data_binding_gtk_lib.so \
	g_data_binding_generics_lib.so \
	demo-and-tutorial \
	g_data_binding_lib-${LIB_VERSION}.typelib
#	csource \

run: run-g_data_binding_lib 

run-g_data_binding_lib: 

#valac --library=test_shared -H test_shared.h test_shared.vala -X -fPIC -X -shared -o test_shared.so
#	common/object_model_array.vala \

SOURCES := g_data_binding_lib.vala \
	common/compare_data_by.vala \
	common/delegates.vala \
	common/strict_weak_reference_t.vala \
	common/unique_by_properties.vala \
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
	contracts/contract_storage.vala \
	contracts/custom_binding_source_state.vala \
	contracts/custom_binding_source_value.vala \
	contracts/custom_property_notification_binding_source.vala \
	contracts/delegates.vala \
	contracts/methods.vala \
	contracts/pointer_storage.vala \
	contracts/signal_controlled_binding_pointer.vala \
	contracts/timer_controlled_binding_pointer.vala \
	property/bind_flags.vala \
	property/binder.vala \
	property/binding_interface.vala \
	property/data_flood_detection.vala \
	property/delegates.vala \
	property/property_alias.vala \
	property/property_binding.vala

GENERICS_SOURCES := g_data_binding_generics_lib.vala \
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

GTK_SOURCES := g_data_binding_gtk_lib.vala

PACKAGES := --pkg gio-2.0
DEMO_PACKAGES := --pkg gtk+-3.0
GTK_PACKAGES := --pkg gtk+-3.0
INCLUDES := ../includes/
BIN := ../bin/

# Vala

csource:
	valac \
	-H ${INCLUDES}g_data_binding_lib.h \
	-C \
	--vapi=${INCLUDES}g_data_binding_lib${LIB_MAJOR}.vapi \
	--library=${BIN}g_data_binding_lib${LIB_MAJOR} \
	${PACKAGES} \
	${SOURCES}

g_data_binding_lib.so:
	valac \
		-H ${INCLUDES}g_data_binding_lib.h \
		--vapi=${INCLUDES}g_data_binding_lib${LIB_MAJOR}.vapi \
		-X \
		-fPIC \
		-X \
		-shared \
		--library=${BIN}g_data_binding_lib${LIB_MAJOR} \
		--gir=${INCLUDES}g_data_binding_lib-${LIB_VERSION}.gir \
		-o ${BIN}g_data_binding_lib${LIB_MAJOR}.so \
	${PACKAGES} \
	${SOURCES}

g_data_binding_generics_lib.so:
	valac \
		-H ${INCLUDES}g_data_binding_generics_lib.h \
		--vapi=${INCLUDES}g_data_binding_generics_lib${LIB_MAJOR}.vapi \
		-X \
		-fPIC \
		-X \
		-shared \
		--library=${BIN}g_data_binding_generics_lib${LIB_MAJOR} \
		--gir=${INCLUDES}g_data_binding_generics_lib-${LIB_VERSION}.gir \
		-o ${BIN}g_data_binding_generics_lib${LIB_MAJOR}.so \
		-X -I${INCLUDES} \
		-X ${BIN}g_data_binding_lib0.so \
		${INCLUDES}g_data_binding_lib${LIB_MAJOR}.vapi \
	${PACKAGES} \
	${GENERICS_SOURCES}

g_data_binding_gtk_lib.so:
	valac \
		-H ${INCLUDES}g_data_binding_gtk_lib.h \
		--vapi=${INCLUDES}g_data_binding_gtk_lib${LIB_MAJOR}.vapi \
		-X \
		-fPIC \
		-X \
		-shared \
		--library=${BIN}g_data_binding_gtk_lib${LIB_MAJOR} \
		--gir=${INCLUDES}g_data_binding_gtk_lib-${LIB_VERSION}.gir \
		-o ${BIN}g_data_binding_gtk_lib${LIB_MAJOR}.so \
		-X -I${INCLUDES} \
		-X ${BIN}g_data_binding_lib0.so \
		${INCLUDES}g_data_binding_lib${LIB_MAJOR}.vapi \
	${PACKAGES} \
	${GTK_PACKAGES} \
	${GTK_SOURCES}

g_data_binding_lib-${LIB_VERSION}.typelib:
	g-ir-compiler \
		--shared-library=${BIN}g_data_binding_lib${LIB_MAJOR}.so \
		--output=${INCLUDES}g_data_binding_lib-${LIB_VERSION}.typelib \
		${INCLUDES}g_data_binding_lib-${LIB_VERSION}.gir

demo-and-tutorial:
	valac \
		${PACKAGES} \
		${DEMO_PACKAGES} \
		demos/demo_and_tutorial/main.vala \
		${INCLUDES}g_data_binding_lib${LIB_MAJOR}.vapi \
		${INCLUDES}g_data_binding_generics_lib${LIB_MAJOR}.vapi \
		-X -I${INCLUDES} \
		-X ${BIN}g_data_binding_lib0.so \
		-X ${BIN}g_data_binding_generics_lib0.so \
		-o ${BIN}demo_and_tutorial

# other

clean:
	rm -fr $(shell cat .gitignore)
