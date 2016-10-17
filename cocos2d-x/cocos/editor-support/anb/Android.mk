LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := anb_static

LOCAL_MODULE_FILENAME := libanb

LOCAL_SRC_FILES := a2dLoader4x.cpp \
a2dToken4x.cpp \
AzBlend.cpp \
AzDataDictionary.cpp \
AzDataTrip.cpp \
AzID.cpp \
azmodel.pb.cc \
AzTM.cpp \
azvisual.pb.cc \
CCazVisual.cpp	\
CCActionInterval3D.cpp	\
CCAzVRP.cpp	\




LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/..

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../.. \
$(LOCAL_PATH)/..

LOCAL_CFLAGS += -Wno-psabi
LOCAL_EXPORT_CFLAGS += -Wno-psabi

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static

include $(BUILD_STATIC_LIBRARY)

$(call import-module,.)
