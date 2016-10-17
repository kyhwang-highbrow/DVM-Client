set(SPINE_SRC
  Animation.cpp
  AnimationState.cpp
  AnimationStateData.cpp
  Atlas.cpp
  AtlasAttachmentLoader.cpp
  Attachment.cpp
  AttachmentLoader.cpp
  Bone.cpp
  BoneData.cpp
  BoundingBoxAttachment.cpp
  Event.cpp
  EventData.cpp
  extension.cpp
  IkConstraint.cpp
  IkConstraintData.cpp
  Json.cpp
  MeshAttachment.cpp
  PolygonBatch.cpp
  RegionAttachment.cpp
  Skeleton.cpp
  SkeletonAnimation.cpp
  SkeletonBounds.cpp
  SkeletonData.cpp
  SkeletonJson.cpp
  SkeletonRenderer.cpp
  Skin.cpp
  SkinnedMeshAttachment.cpp
  Slot.cpp
  SlotData.cpp
  spine-cocos2dx.cpp
)

include_directories(
  ..
)

add_library(spine STATIC
  ${SPINE_SRC}
)

set_target_properties(spine
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)

