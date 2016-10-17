set(LPEG_SRC
  lpcap.c
  lpcode.c
  lpprint.c
  lpvm.c
  tolua_to.c
)

include_directories(
  ../lpeg
)


add_library(lpeg STATIC
  ${LPEG_SRC}
)

set_target_properties(lpeg
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)
