#include "cocos2d.h"
#include "tolua_fix.h"
#include "CCLuaEngine.h"
#include "PerpSocial.h"

USING_NS_CC;

std::map<std::string, int> PerpSocial::m_onSDKEventFuncID;

extern void sdkEvent(const char *id, const char *arg0, const char *arg1);

PerpSocial *PerpSocial::instance = 0;

PerpSocial *PerpSocial::getInstance() {
    if (instance == 0)
    {
        instance = new PerpSocial();
    }

    return instance;
}

PerpSocial::PerpSocial()
{
}

PerpSocial::~PerpSocial()
{
}

void PerpSocial::SDKEvent(const char *id, const char *arg0, const char *arg1, int funcID)
{
    //log("PerpSocial::SDKEvent(%s, %s, %s)", id, arg0, arg1);

    m_onSDKEventFuncID[id] = funcID;

    std::string method = id;
    std::string prefix = method.substr(0, method.find("_"));

	sdkEvent(id, arg0, arg1);
}

void PerpSocial::OnSDKEventResult(const char *id, const char *result, const char *info)
{
    ScriptEngineProtocol *protocol = ScriptEngineManager::getInstance()->getScriptEngine();

    if (protocol == 0) {
        log("[OnSDKEventResult error] no engine protocol");
        return;
    }

    //log("PerpSocial::OnSDKEventResult(%s, %s, %s)", id, result, info);

    auto engine = LuaEngine::getInstance();
    lua_State *L = engine->getLuaStack()->getLuaState();

    int funcID = m_onSDKEventFuncID[id];

    if (funcID > 0)
    {
        lua_pushstring(L, result);
        lua_pushstring(L, info);
        LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
        stack->executeFunctionByHandler(funcID, 2);
        stack->clean();
    }
}


//--------------------------------------------------------------------------------
// PerpSocial Lua Binding Functions
//--------------------------------------------------------------------------------

static int tolua_PerpLua_PerpSocial_SDKEvent00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isusertable(tolua_S, 1, "PerpSocial", 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 3, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 4, 0, &tolua_err) ||
        //!toluafix_isfunction(tolua_S, 5, "", 0, &tolua_err) ||
        !tolua_isnoobj(tolua_S, 6, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        const char *id = tolua_tostring(tolua_S, 2, 0);
        const char *arg0 = tolua_tostring(tolua_S, 3, 0);
        const char *arg1 = tolua_tostring(tolua_S, 4, 0);
        int funcID = toluafix_ref_function(tolua_S, 5, 0);
        {
            PerpSocial::SDKEvent(id, arg0, arg1, funcID);
        }
    }
    return 0;
#ifndef TOLUA_RELEASE
tolua_lerror :
    tolua_error(tolua_S, "#ferror in function 'SDKEvent'.", &tolua_err);
    return 0;
#endif
}

void PerpSocial::RegisterToLuaFunc(lua_State* tolua_S)
{
#ifndef Mtolua_typeid
#define Mtolua_typeid(L,TI,T)
#endif
    tolua_usertype(tolua_S, "PerpSocial");
    Mtolua_typeid(tolua_S, typeid(PerpSocial), "PerpSocial");

    tolua_cclass(tolua_S, "PerpSocial", "PerpSocial", "", NULL);
    tolua_beginmodule(tolua_S, "PerpSocial");

    tolua_function(tolua_S, "SDKEvent", tolua_PerpLua_PerpSocial_SDKEvent00);

    tolua_endmodule(tolua_S);
}
