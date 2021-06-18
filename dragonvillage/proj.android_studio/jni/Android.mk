LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

# DragonVillageM
# @sgkim 2021.03.16 cocos2dlua_shared -> cocos2dlua로 변경함
# Android Gradle Plugin Version 3.4.3 -> 4.1.1 업그레이드의 사이드 이펙트
LOCAL_MODULE := cocos2dlua

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := main/main.cpp \
                   main/Runtime_android.cpp \
                   ../../Classes/VisibleRect.cpp \
                   ../../Classes/PerpSupportPatch.cpp \
                   ../../Classes/PerpSupportLua.cpp \
                   ../../Classes/PerpSocial.cpp \
                   ../../Classes/PerpLua.cpp \
                   ../../Classes/AppDelegate.cpp \
                   ../../Classes/AppDelegate_Custom.cpp \
                   ../../Classes/ConfigParser.cpp \
                   ../../Classes/Runtime.cpp \
                   ../../Classes/PerpExt/PerpUtils.cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes \
                    $(LOCAL_PATH)/../../../cocos2d-x/cocos/network \
                    $(LOCAL_PATH)/../../../cocos2d-x/cocos/editor-support/spine \
                    $(LOCAL_PATH)/../../../cocos2d-x/external/json \
					$(LOCAL_PATH)/../../../libraries/sdk_binder/src

LOCAL_SHARED_LIBRARIES := perplesdk_shared

LOCAL_WHOLE_STATIC_LIBRARIES := cocos_lua_static

LOCAL_SHORT_COMMANDS := true

include $(BUILD_SHARED_LIBRARY)

include $(LOCAL_PATH)/../../../libraries/sdk_binder/android/jni/Android.mk

$(call import-module,scripting/lua-bindings)