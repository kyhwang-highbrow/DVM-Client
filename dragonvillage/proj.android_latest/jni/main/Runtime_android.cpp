#include <jni.h>
#include <android/log.h>
#include "jni/JniHelper.h"
#include <string>
#include <vector>
#include "LoginPlatform.h"

#define PACKAGE_NAME    "com/perplelab/dragonvillagem/kr/AppActivity"

using namespace std;
using namespace cocos2d;

string getSDCardPath()
{
    JniMethodInfo t;
    string sdcardPath("");

    if (JniHelper::getStaticMethodInfo(t, PACKAGE_NAME, "getSDCardPath", "()Ljava/lang/String;"))
    {
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        sdcardPath = JniHelper::jstring2string(str);
        t.env->DeleteLocalRef(str);
    }
    return sdcardPath;

}

string getIPAddress()
{
    JniMethodInfo t;
    string IPAddress("");

    if (JniHelper::getStaticMethodInfo(t, PACKAGE_NAME, "getLocalIpAddress", "()Ljava/lang/String;"))
    {
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        IPAddress = JniHelper::jstring2string(str);
        t.env->DeleteLocalRef(str);
    }
    return IPAddress;
}

int isInstalled(const char *packagename)
{
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, PACKAGE_NAME, "isInstalled", "(Ljava/lang/String;)I"))
    {
        jstring stringPackageName = t.env->NewStringUTF(packagename);
        int ret = t.env->CallStaticIntMethod(t.classID, t.methodID, stringPackageName);
        t.env->DeleteLocalRef(stringPackageName);
        t.env->DeleteLocalRef(t.classID);
        return ret;
    }
    else
    {
        return 0;
    }
}

string getRunningApps()
{
    JniMethodInfo t;
    string apps;
    if (JniHelper::getStaticMethodInfo(t, PACKAGE_NAME, "getRunningApps", "()Ljava/lang/String;"))
    {
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        apps = JniHelper::jstring2string(str);
        t.env->DeleteLocalRef(str);
        return apps;
    }
    else
    {
        return "";
    }
}

string getDeviceLanguage()
{
    JniMethodInfo t;
    string language;
    if (JniHelper::getStaticMethodInfo(t, PACKAGE_NAME, "getDeviceLanguage", "()Ljava/lang/String;"))
    {
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        language = JniHelper::jstring2string(str);
        t.env->DeleteLocalRef(str);
        return language;
    }
    else
    {
        return "";
    }

}

string getLocale()
{
    JniMethodInfo t;
    string locale;
    if (JniHelper::getStaticMethodInfo(t, PACKAGE_NAME, "getLocale", "()Ljava/lang/String;"))
    {
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        locale = JniHelper::jstring2string(str);
        t.env->DeleteLocalRef(str);
        return locale;
    }
    else
    {
        return "";
    }

}

int isWifiConnected()
{
    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, PACKAGE_NAME, "isWifiConnected", "()I"))
    {
        int ret = t.env->CallStaticIntMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        return ret;
    }
    else
    {
        return 0;
    }
}

string getFreeMemory()
{
    JniMethodInfo t;
    string MemoryInfo;
    if (JniHelper::getStaticMethodInfo(t, PACKAGE_NAME, "getFreeMemory", "()Ljava/lang/String;"))
    {
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        MemoryInfo = JniHelper::jstring2string(str);
        t.env->DeleteLocalRef(str);
        return MemoryInfo;
    }
    else
    {
        return "";
    }
}

void send_event_to_app(const char *param1, const char *param2)
{
    JniMethodInfo t;

    if (JniHelper::getStaticMethodInfo(t, PACKAGE_NAME, "receiveEventFromNative", "(Ljava/lang/String;Ljava/lang/String;)V")) {
        jstring strParam1 = t.env->NewStringUTF(param1);
        jstring strParam2 = t.env->NewStringUTF(param2);
        t.env->CallStaticVoidMethod(t.classID, t.methodID, strParam1, strParam2);
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(strParam1);
        t.env->DeleteLocalRef(strParam2);
    }
}

void sdkEvent(const char *id, const char *arg0, const char *arg1)
{
#ifndef USE_GOOGLEPLAY
    if (strcmp(id, "googleplay_login") == 0)
    {
        return;
    }
    else if (strcmp(id, "googleplay_logout") == 0)
    {
        return;
    }
    else if (strcmp(id, "googleplay_isSignedIn") == 0)
    {
        return;
    }
    else if (strcmp(id, "googleplay_checkLogin") == 0)
    {
        return;
    }
    else if (strcmp(id, "googleplay_showAchievements") == 0)
    {
        return;
    }
    else if (strcmp(id, "googleplay_showLeaderboards") == 0)
    {
        return;
    }
    else if (strcmp(id, "googleplay_showQuests") == 0)
    {
        return;
    }
    else if (strcmp(id, "googleplay_setAchievements") == 0)
    {
        return;
    }
    else if (strcmp(id, "googleplay_setLeaderboards") == 0)
    {
        return;
    }
    else if (strcmp(id, "googleplay_setEvents") == 0)
    {
        return;
    }
#else
#ifdef GOOGLEPLAY_LOGIN_PATI
    if (strcmp(id, "googleplay_login") == 0)
    {
        return;
    }
    else if (strcmp(id, "googleplay_logout") == 0)
    {
        return;
    }
    else if (strcmp(id, "googleplay_isSignedIn") == 0)
    {
        return;
    }
#endif
#endif

    JniMethodInfo t;

    if (JniHelper::getStaticMethodInfo(t, PACKAGE_NAME, "sdkEvent", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"))
    {
        jstring jid = t.env->NewStringUTF(id);
        jstring jarg0 = t.env->NewStringUTF(arg0);
        jstring jarg1 = t.env->NewStringUTF(arg1);
        t.env->CallStaticVoidMethod(t.classID, t.methodID, jid, jarg0, jarg1);
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(jid);
        t.env->DeleteLocalRef(jarg0);
        t.env->DeleteLocalRef(jarg1);
    }
}
