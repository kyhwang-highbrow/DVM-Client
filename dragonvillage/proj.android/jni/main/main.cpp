#include "AppDelegate.h"
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#include "ConfigParser.h"
#include "LoginPlatform.h"

#define LOG_TAG     "main"
#define LOGD(...)   __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

using namespace cocos2d;

void cocos_android_app_init (JNIEnv* env) {
    LOGD("cocos_android_app_init");
    AppDelegate *pAppDelegate = new AppDelegate();
}

extern "C"
{

JNIEXPORT bool JNICALL Java_org_cocos2dx_lua_AppActivity_nativeIsLandScape(JNIEnv *env, jobject thisz)
{
    if (!ConfigParser::getInstance()->isInit())
    {
        ConfigParser::getInstance()->readConfig();
    }
    return ConfigParser::getInstance()->isLandscape();
}

JNIEXPORT bool JNICALL Java_org_cocos2dx_lua_AppActivity_nativeIsDebug(JNIEnv *env, jobject thisz)
{
    #ifdef NDEBUG
        return false;
    #else
        return true;
    #endif
}

JNIEXPORT bool JNICALL Java_org_cocos2dx_lua_AppActivity_nativeIsTestMode(JNIEnv *env, jobject thisz)
{
    if (!ConfigParser::getInstance()->isInit())
    {
        ConfigParser::getInstance()->readConfig();
    }
    return ConfigParser::getInstance()->isTestMode();
}

JNIEXPORT int JNICALL Java_org_cocos2dx_lua_AppActivity_nativeLoginPlatform(JNIEnv *env, jobject thisz)
{
    #if (LOGIN_PLATFORM == LOGIN_PLATFORM_PATISDK)
        return 1;
    #elif (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
        return 2;
    #else
        return 0;
    #endif
}

JNIEXPORT void JNICALL Java_org_cocos2dx_lua_AppActivity_nativeSDKEventResult(JNIEnv *env, jobject thisz, jstring id, jstring result, jstring info)
{
    jboolean isCopy1;
    jboolean isCopy2;
    jboolean isCopy3;

    const char *szId = env->GetStringUTFChars(id, &isCopy1);
    const char *szResult = env->GetStringUTFChars(result, &isCopy2);
    const char *szInfo = env->GetStringUTFChars(info, &isCopy3);

    if (szId != NULL && szResult != NULL)
    {
        CCLog("%s => %s, %s", szId, szResult, szInfo);

        AppDelegate *pDelegate = (AppDelegate *)CCApplication::sharedApplication();
        pDelegate->sdkEventHandler(szId, szResult, szInfo);

        if (isCopy1 == JNI_TRUE)
        {
            env->ReleaseStringUTFChars(id, szId);
        }

        if (isCopy2 == JNI_TRUE)
        {
            env->ReleaseStringUTFChars(result, szResult);
        }

        if (isCopy3 == JNI_TRUE)
        {
            env->ReleaseStringUTFChars(info, szInfo);
        }
    }
}

}

