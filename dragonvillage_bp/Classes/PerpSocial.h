#ifndef _PerpSocail_H_
#define _PerpSocail_H_

#include "cocos2d.h"
#include "PerpConstant.h"
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

    static void SDKEvent(const char *id, const char *arg0, const char *arg1, int funcID);
    static void OnSDKEventResult(const char *id, const char *result, const char *info);

    static void RegisterToLuaFunc(lua_State* tolua_S);
};

#endif
