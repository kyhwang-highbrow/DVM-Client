set(ANB_SRC
  a2dLoader4x.cpp
  a2dToken4x.cpp
  AzBlend.cpp
  AzDataDictionary.cpp
  AzDataTrip.cpp
  AzID.cpp
  azmodel.pb.cc
  AzTM.cpp
  azvisual.pb.cc
  CCazVisual.cpp
)

include_directories(
  ..
)

add_library(anb STATIC
  ${ANB_SRC}
)

set_target_properties(anb
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)

