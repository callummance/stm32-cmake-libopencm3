set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

#Choose which command to find binaries
if(MINGW OR CYGWIN OR WIN32)
    set(UTIL_SEARCH_CMD where)
elseif(UNIX OR APPLE)
    set(UTIL_SEARCH_CMD which)
endif()

#Find directory containing arm-none-eabi binaries
set(TOOLCHAIN_PREFIX arm-none-eabi)
execute_process(
    COMMAND ${UTIL_SEARCH_CMD} ${TOOLCHAIN_PREFIX}-gcc
    OUTPUT_VARIABLE BINUTILS_PATH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
get_filename_component(ARM_TOOLCHAIN_DIR ${BINUTILS_PATH} DIRECTORY)

#Setup tools paths
set(CMAKE_AR            ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-ar)
set(CMAKE_ASM_COMPILER  ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_C_COMPILER    ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CPP_COMPILER  ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER  ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_LINKER        ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-ld)
set(CMAKE_OBJCOPY       ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-objcopy)
set(CMAKE_RANLIB        ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-ranlib)
set(CMAKE_SIZE          ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-size)
set(CMAKE_STRIP         ${ARM_TOOLCHAIN_DIR}/${TOOLCHAIN_PREFIX}-gcc)

#Setup find
set(CMAKE_FIND_ROOT_PATH ${BINUTILS_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

#Setup executable suffixes
set(CMAKE_EXECUTABLE_SUFFIX_C   .elf)
set(CMAKE_EXECUTABLE_SUFFIX_ASM .elf)