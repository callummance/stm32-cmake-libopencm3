include(CMakePrintHelpers)

function(load_cm3_link_vars LIBOPENCM3_DIR DEVICE)
    # Retrieve device details using libopencm3 provided script
    execute_process(
        COMMAND python3 ${LIBOPENCM3_DIR}/scripts/genlink.py ${LIBOPENCM3_DIR}/ld/devices.data ${DEVICE} FAMILY
        OUTPUT_VARIABLE genlink_family
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    execute_process(
        COMMAND python3 ${LIBOPENCM3_DIR}/scripts/genlink.py ${LIBOPENCM3_DIR}/ld/devices.data ${DEVICE} SUBFAMILY
        OUTPUT_VARIABLE genlink_subfamily
        OUTPUT_STRIP_TRAILING_WHITESPACE 
    )

    execute_process(
        COMMAND python3 ${LIBOPENCM3_DIR}/scripts/genlink.py ${LIBOPENCM3_DIR}/ld/devices.data ${DEVICE} CPU
        OUTPUT_VARIABLE genlink_cpu
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    execute_process(
        COMMAND python3 ${LIBOPENCM3_DIR}/scripts/genlink.py ${LIBOPENCM3_DIR}/ld/devices.data ${DEVICE} FPU
        OUTPUT_VARIABLE genlink_fpu
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    execute_process(
        COMMAND python3 ${LIBOPENCM3_DIR}/scripts/genlink.py ${LIBOPENCM3_DIR}/ld/devices.data ${DEVICE} CPPFLAGS
        OUTPUT_VARIABLE genlink_cppflags
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    execute_process(
        COMMAND python3 ${LIBOPENCM3_DIR}/scripts/genlink.py ${LIBOPENCM3_DIR}/ld/devices.data ${DEVICE} DEFS
        OUTPUT_VARIABLE genlink_defflags
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    execute_process(
        COMMAND make list-targets
        WORKING_DIRECTORY ${LIBOPENCM3_DIR}
        OUTPUT_VARIABLE opencm3_targets
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Get list of opencm3 targets
    string(REPLACE "/" "" opencm3_targets_str ${opencm3_targets})
    string(REPLACE " " ";" opencm3_libs ${opencm3_targets_str})

    # CPPFlags
    separate_arguments(genlink_cppflags)
    set(CM3_GENLINK_CPPFLAGS ${genlink_cppflags} PARENT_SCOPE)

    # CPU Flags
    list(APPEND arch_flags -mcpu=${genlink_cpu})
    if(${genlink_cpu} MATCHES "^\\s*cortex-(m0|m0plus|m3|m4|m7)\\s*$")
        list(APPEND arch_flags -mthumb)
    endif()

    # FPU Flags
    if(genlink_fpu STREQUAL "soft")
        list(APPEND arch_flags -msoft-float)
    elseif(genlink_fpu STREQUAL "hard-fpv4-sp-d16")
        list(APPEND arch_flags -mfloat-abi=hard -mfpu=fpv4-sp-d16)
    elseif(genlink_fpu STREQUAL "hard-fpv5-sp-d16")
        list(APPEND arch_flags -mfloat-abi=hard -mfpu=fpv5-sp-d16)
    else()
        message(WARNING "No match found for flags for FPU ${genlink_fpu}")
    endif()
    set(CM3_GENLINK_ARCHFLAGS ${arch_flags} PARENT_SCOPE)

    # Defs
    separate_arguments(genlink_defflags)
    set(CM3_GENLINK_DEFFLAGS ${genlink_defflags} PARENT_SCOPE)

    # LDScript generator
    set(ldscript "generated.${DEVICE}.ld")
    set(link_script_src ${LIBOPENCM3_DIR}/ld/linker.ld.S)
    add_custom_command(OUTPUT ${ldscript}
        COMMAND ${CMAKE_C_COMPILER} ${arch_flags} ${genlink_defflags} "-P" "-E" "${link_script_src}" "-o" "${ldscript}"
        MAIN_DEPENDENCY ${link_script_src}
        COMMENT "Preprocessing linker script ${ldscript}"
        VERBATIM
    )
    set(CM3_GENLINK_LDSCRIPT ${ldscript} PARENT_SCOPE)

    # Check that device is known to opencm3 script
    if(${genlink_family} STREQUAL "")
        message(WARNING "${DEVICE} not found in devices list")
    endif()

    # Export library filename and path if it exists
    if(${genlink_family} IN_LIST opencm3_libs)
        set(CM3_GENLINK_LDLIB libopencm3_${genlink_family} PARENT_SCOPE)
        set(CM3_GENLINK_LIBDEP ${LIBOPENCM3_DIR}/lib/libopencm3_${genlink_family}.a PARENT_SCOPE)
    elseif(${genlink_subfamily} IN_LIST opencm3_libs)
        set(CM3_GENLINK_LDLIB libname libopencm3_${genlink_subfamily} PARENT_SCOPE)
        set(CM3_GENLINK_LIBDEP ${LIBOPENCM3_DIR}/lib/libopencm3_${genlink_subfamily}.a PARENT_SCOPE)
    else()
        message(WARNING "${LIBOPENCM3_DIR}/lib/libopencm3_${genlink_family}.a library variant not found")
    endif()

    # Export link directory if it exists
    if ((EXISTS ${LIBOPENCM3_DIR}/lib) AND (IS_DIRECTORY ${LIBOPENCM3_DIR}/lib))
        set(CM3_GENLINK_LINKDIR ${LIBOPENCM3_DIR}/lib PARENT_SCOPE)
    else()
        message(WARNING "${LIBOPENCM3_DIR}/lib directory does not exist")
    endif()

    # Export include directory if it exists
    if ((EXISTS ${LIBOPENCM3_DIR}/include) AND (IS_DIRECTORY ${LIBOPENCM3_DIR}/include))
        set(CM3_GENLINK_INCLUDEDIR ${LIBOPENCM3_DIR}/include PARENT_SCOPE)
    else()
        message(WARNING "${LIBOPENCM3_DIR}/lib directory does not exist")
    endif()
endfunction()