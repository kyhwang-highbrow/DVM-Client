LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := main.cpp \
                   Runtime_android.cpp \
                   ../../../../Classes/VisibleRect.cpp \
                   ../../../../Classes/PerpSupportPatch.cpp \
                   ../../../../Classes/PerpSupportLua.cpp \
                   ../../../../Classes/PerpSocial.cpp \
                   ../../../../Classes/PerpLua.cpp \
                   ../../../../Classes/AppDelegate.cpp \
                   ../../../../Classes/AppDelegate_Custom.cpp \
                   ../../../../Classes/ConfigParser.cpp \
                   ../../../../Classes/Runtime.cpp \
                   ../../../../Classes/PerpExt/PerpUtils.cpp \
                   ../../../../Classes/Kakao/Common/GameFriends.cpp \
                   ../../../../Classes/Kakao/Common/GameInfo.cpp \
                   ../../../../Classes/Kakao/Common/GameUserInfo.cpp \
                   ../../../../Classes/Kakao/Common/InvitationTracking.cpp \
                   ../../../../Classes/Kakao/Common/KakaoFriends.cpp \
                   ../../../../Classes/Kakao/Common/KakaoGameMessages.cpp \
                   ../../../../Classes/Kakao/Common/KakaoLeaderBoards.cpp \
                   ../../../../Classes/Kakao/Common/KakaoLocalUser.cpp \
                   ../../../../Classes/Kakao/Plugins/KakaoNativeExtension.cpp \
                   ../../../../Classes/Kakao/Plugins/KakaoResponseHandler.cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../../../Classes \
                    $(LOCAL_PATH)/../../../../../cocos2d-x/cocos/network \
                    $(LOCAL_PATH)/../../../../../cocos2d-x/external/json \
					$(LOCAL_PATH)/../../../../../libraries/perplesdk/include

LOCAL_STATIC_LIBRARIES := curl_static_prebuilt
LOCAL_STATIC_LIBRARIES += perplesdklua_static

LOCAL_SHARED_LIBRARIES := perplesdk_shared

LOCAL_WHOLE_STATIC_LIBRARIES := cocos_lua_static

include $(BUILD_SHARED_LIBRARY)

include $(LOCAL_PATH)/../../../../../libraries/perplesdk/prebuilt/android/Android.mk

$(call import-module,scripting/lua-bindings)
