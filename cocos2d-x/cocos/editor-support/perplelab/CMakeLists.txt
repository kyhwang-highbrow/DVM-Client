set(PERPLELAB_SRC
  CCPerpSpriter.cpp
)

include_directories(
  ..
)

add_library(perplelab STATIC
  ${PERPLELAB_SRC}
)

set_target_properties(perplelab
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)
