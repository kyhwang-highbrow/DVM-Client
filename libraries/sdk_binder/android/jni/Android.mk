LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

# sdk_binder
LOCAL_MODULE := perplesdk_shared

LOCAL_MODULE_FILENAME := libperplesdk

LOCAL_SRC_FILES := main/main.cpp \
                   main/runtime_android.cpp \
				   ../../src/lua_perplesdk.cpp \
				   ../../src/PerpleCore.cpp

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../src

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../src

LOCAL_WHOLE_STATIC_LIBRARIES := cocos_lua_static

LOCAL_LDLIBS := -llog

include $(BUILD_SHARED_LIBRARY)

$(call import-module,scripting/lua-bindings)
