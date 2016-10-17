#ifndef _PerpSocail_H_
#define _PerpSocail_H_

#include "cocos2d.h"
#include "LoginPlatform.h"
#include <map>

class PerpSocial
{
private:
    static PerpSocial *instance;

public:
    static std::map<std::string, int> m_onSDKEventFuncID;

    static PerpSocial *getInstance();

    PerpSocial();
    ~PerpSocial();

    /*
    // @kakao
    void OnKakaoInit();
    void OnKakaoInitError(char const* status, char const* error);

    void OnKakaoToken();
    void OnKakaoTokenError(char const* status, char const* error);

    void OnKakaoAuthInit(bool result);
    void OnKakaoAuthLogin(bool result);
    void OnKakaoAuthLogout(bool result);
    void OnKakaoAuthUnregister(bool result);
    void OnKakaoAuthErrorInit(char const* status, char const* error);
    void OnKakaoAuthErrorLogin(char const* status, char const* error);
    void OnKakaoAuthErrorLogout(char const* status, char const* error);
    void OnKakaoAuthErrorUnregister(char const* status, char const* error);

    void OnKakaoLogin();
    void OnKakaoLoginError(char const* status, char const* error);

    void OnKakaoLogout();
    void OnKakaoLogoutError(char const* status, char const* error);

    void OnKakaoLocalUser();
    void OnKakaoLocalUserError(char const* status, char const* error);

    void OnKakaoUnregister();
    void OnKakaoUnregisterError(char const* status, char const* error);

    static void KakaoEvent(const char *id, const char *arg0, const char *arg1);
    */

    static void SDKEvent(const char *id, const char *arg0, const char *arg1, int funcID);
    static void OnSDKEventResult(const char *id, const char *result, const char *info);

    static void RegisterToLuaFunc(lua_State* tolua_S);
};

#endif
