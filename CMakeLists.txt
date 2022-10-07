cmake_minimum_required(VERSION 3.3 FATAL_ERROR)

set(CMAKE_TOOLCHAIN_FILE cmake/arm-none-eabi.cmake CACHE STRING "")
project(blink VERSION 0.0.1 LANGUAGES C ASM)

include(cmake/stm32l432kc.cmake)

add_executable(blink
    src/main.c
)

target_link_libraries(blink stm32l432 m c gcc nosys)
set_property(TARGET blink PROPERTY C_STANDARD 11)
add_flash_target(blink)
