LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := patisdk_lua_static
LOCAL_MODULE_FILENAME := libpatisdk
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libpatisdklua.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../include
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := patisdk_shared
LOCAL_MODULE_FILENAME := libpatisdk
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libpatisdk.so
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../include
include $(PREBUILT_SHARED_LIBRARY)
