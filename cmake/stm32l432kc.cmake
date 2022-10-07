include(CMakePrintHelpers)

get_filename_component(libopencm3_SOURCE_DIR "libopencm3" ABSOLUTE)

#Build libopencm3
add_custom_target(libopencm3 make TARGETS=stm32/l4 WORKING_DIRECTORY ${libopencm3_SOURCE_DIR})

#Load variables from opencm3 link script
include(cmake/opencm3-genlink.cmake)
load_cm3_link_vars(${libopencm3_SOURCE_DIR} stm32l432kc)

#Setup target for linker script
add_custom_target(linker 
    DEPENDS ${CM3_GENLINK_LDSCRIPT} 
    COMMENT "Generating link script" 
    VERBATIM
)

#Create target for this uC and setup opencm3
add_library(stm32l432 STATIC IMPORTED)
set_property(TARGET stm32l432 PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${CM3_GENLINK_INCLUDEDIR})
set_property(TARGET stm32l432 PROPERTY IMPORTED_LOCATION ${CM3_GENLINK_LIBDEP})
add_dependencies(stm32l432 libopencm3)
add_dependencies(stm32l432 linker)
target_link_directories(stm32l432 INTERFACE ${CM3_GENLINK_LINKDIR})
target_link_options(stm32l432 INTERFACE -T${CM3_GENLINK_LDSCRIPT})

#Compile options
set(COMPILE_OPTS
    --static
    -nostartfiles
    -fno-common
    -Wl,--gc-sections
    -Os
    -Wall
)
list(APPEND COMPILE_OPTS ${CM3_GENLINK_ARCHFLAGS})
target_compile_options(stm32l432 INTERFACE ${COMPILE_OPTS})

#Compile options for debug build
#target_link_libraries(stm32l432 INTERFACE debug rdimon)
target_compile_definitions(
    stm32l432 INTERFACE
    $<$<CONFIG:DEBUG>:DEBUG>
    $<$<CONFIG:DEBUG>:SEMIHOSTING>
)
target_compile_options(
    stm32l432 INTERFACE
    $<$<CONFIG:DEBUG>:-ggdb3>
)
target_link_options(
    stm32l432 INTERFACE
    $<$<CONFIG:DEBUG>:--specs=rdimon.specs>
    $<$<CONFIG:RELEASE>:--specs=nosys.specs>
)

target_compile_definitions(stm32l432 INTERFACE ${CM3_GENLINK_DEFFLAGS})
target_link_options(stm32l432 INTERFACE ${COMPILE_OPTS})

# Add flash target
function(add_flash_target TARGET)
    set(DEVICE_FILE "${CMAKE_SOURCE_DIR}/device/st_nucleo_l4.cfg")
    set(EXECUTABLE_PATH "${CMAKE_BINARY_DIR}/${TARGET}.elf")
    add_custom_target(flash-l4-nucleo
        bash -c "openocd -f ${DEVICE_FILE}                                                                      \
                -c init                                                                    						\
                -c 'reset halt'                                                            						\
                -c 'flash write_image erase ${EXECUTABLE_PATH}'                                  			    \
                -c 'verify_image ${EXECUTABLE_PATH}'                                             			    \
                -c reset                                                                   						\
                -c shutdown"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        DEPENDS ${TARGET} 
        VERBATIM
    )
endfunction(add_flash_target)