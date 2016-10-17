LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := spine_static

LOCAL_MODULE_FILENAME := libspine

LOCAL_SRC_FILES := Animation.cpp \
AnimationState.cpp \
AnimationStateData.cpp \
Atlas.cpp \
AtlasAttachmentLoader.cpp \
Attachment.cpp \
AttachmentLoader.cpp \
Bone.cpp \
BoneData.cpp \
BoundingBoxAttachment.cpp \
Event.cpp \
EventData.cpp \
extension.cpp \
IkConstraint.cpp \
IkConstraintData.cpp \
Json.cpp \
MeshAttachment.cpp \
PolygonBatch.cpp \
RegionAttachment.cpp \
Skeleton.cpp \
SkeletonAnimation.cpp \
SkeletonBounds.cpp \
SkeletonData.cpp \
SkeletonJson.cpp \
SkeletonRenderer.cpp \
Skin.cpp \
SkinnedMeshAttachment.cpp \
Slot.cpp \
SlotData.cpp \
spine-cocos2dx.cpp

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/..

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../.. \
$(LOCAL_PATH)/..

LOCAL_CFLAGS += -Wno-psabi
LOCAL_EXPORT_CFLAGS += -Wno-psabi

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static

include $(BUILD_STATIC_LIBRARY)

$(call import-module,.)
