# this makefile is based on work from https://github.com/antono/vala-object/blob/master/Makefile

export LD_LIBRARY_PATH := $(shell pwd)
export GI_TYPELIB_PATH := $(shell pwd)

# edit library name and version here
COMMON_NAME := g_data_binding
NAME_SUFFIX := _lib
LIBRARY_NAME := ${COMMON_NAME}${NAME_SUFFIX}

LIB_MAJOR := 0
LIB_MINOR := 1
LIB_VERSION := ${LIB_MAJOR}.${LIB_MINOR}

all: ${LIBRARY_NAME}.so \
     ${COMMON_NAME}gtk${NAME_SUFFIX}.so \
     ${COMMON_NAME}generics${NAME_SUFFIX}.so \
     demo-and-tutorial \
     hack-for-gir-bug \
     ${COMMON_NAME}${NAME_SUFFIX}-${LIB_VERSION}.typelib \
     move-binaries-to-bin

run: run-${COMMON_NAME}_lib

run-g_${COMMON_NAME}_lib:

SOURCES := ${LIBRARY_NAME}.vala \
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
	property/property_binding.vala \
	row_models/row_model.vala

GENERICS_SOURCES := ${COMMON_NAME}_generics${NAME_SUFFIX}.vala \
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

GTK_SOURCES := ${COMMON_NAME}_gtk${NAME_SUFFIX}.vala

PACKAGES := --pkg gio-2.0
DEMO_PACKAGES := --pkg gtk+-3.0
GTK_PACKAGES := --pkg gtk+-3.0
INCLUDES := ../includes/
BIN := ../bin/

# Vala

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

${COMMON_NAME}generics${NAME_SUFFIX}.so:
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

${COMMON_NAME}gtk${NAME_SUFFIX}.so:
	valac \
		-H ${INCLUDES}${COMMON_NAME}_gtk${NAME_SUFFIX}.h \
		--vapi=${INCLUDES}${COMMON_NAME}_gtk${NAME_SUFFIX}${LIB_MAJOR}.vapi \
		-X \
		-fPIC \
		-X \
		-shared \
		--library=${COMMON_NAME}_gtk${NAME_SUFFIX}${LIB_MAJOR} \
		--gir=${INCLUDES}${COMMON_NAME}_gtk${NAME_SUFFIX}-${LIB_VERSION}.gir \
		-o ${COMMON_NAME}_gtk${NAME_SUFFIX}${LIB_MAJOR}.so \
		-X -I${INCLUDES} \
		-X ${LIBRARY_NAME}${LIB_MAJOR}.so \
		${INCLUDES}${LIBRARY_NAME}${LIB_MAJOR}.vapi \
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

demo-and-tutorial:
	valac \
		${PACKAGES} \
		${DEMO_PACKAGES} \
		demos/demo_and_tutorial/main.vala \
		${INCLUDES}${LIBRARY_NAME}${LIB_MAJOR}.vapi \
		${INCLUDES}${COMMON_NAME}_generics${NAME_SUFFIX}${LIB_MAJOR}.vapi \
		-X -I${INCLUDES} \
		-X ${LIBRARY_NAME}${LIB_MAJOR}.so \
		-X ${COMMON_NAME}_generics${NAME_SUFFIX}${LIB_MAJOR}.so \
		-o ${BIN}demo_and_tutorial

move-binaries-to-bin:
	mv *.so ${BIN}

# other

clean:
	rm -fr $(shell cat .gitignore)
