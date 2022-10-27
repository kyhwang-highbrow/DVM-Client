LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

# sdk_binder
LOCAL_MODULE := sdk_binder_static

LOCAL_SRC_FILES := main/main.cpp \
                   main/runtime_android.cpp

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../src

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../src

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static

LOCAL_CFLAGS += -Wno-psabi
LOCAL_EXPORT_CFLAGS += -Wno-psabi

include $(BUILD_STATIC_LIBRARY)