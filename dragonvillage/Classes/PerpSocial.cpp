#include "cocos2d.h"
#include "tolua_fix.h"
#include "CCLuaEngine.h"
#include "PerpSocial.h"

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PATISDK)
// @patisdk
#include "PatiPublishSDK.h"
#endif

/*
// @kakao
#include "document.h"
#include "prettywriter.h"
#include "stringbuffer.h"
#include "Kakao/Plugins/KakaoNativeExtension.h"
#include "Kakao/Common/KakaoLocalUser.h"
#include "Kakao/Common/KakaoFriends.h"
*/

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

/*
// @kakao
void PerpSocial::OnKakaoInit()
{
    CCLog("OnKakaoInit");
    CCLog("refresh_token : %s", CCUserDefault::sharedUserDefault()->getStringForKey("refresh_token").c_str());

    KakaoNativeExtension::getInstance()->auth(
        std::bind(&PerpSocial::OnKakaoAuthInit, this, std::placeholders::_1),
        std::bind(&PerpSocial::OnKakaoAuthErrorInit, this, std::placeholders::_1, std::placeholders::_2));
}

// @kakao
void PerpSocial::OnKakaoInitError(char const* status, char const* error)
{
    CCLog("OnKakaoInitError : %s, %s", status, error);

    rapidjson::Document doc;
    doc.Parse<0>("{}");
    doc.AddMember("status", status, doc.GetAllocator());
    doc.AddMember("error", error, doc.GetAllocator());

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    const char *info = strbuf.GetString();

    OnSDKEventResult("kakao_init", "error", info);
}

// @kakao
void PerpSocial::OnKakaoToken()
{
    CCLog("OnKakaoToken");
    CCLog("access_token : %s", CCUserDefault::sharedUserDefault()->getStringForKey("access_token").c_str());
}

// @kakao
void PerpSocial::OnKakaoTokenError(char const* status, char const* error)
{
    CCLog("OnKakaoTokenError : %s, %s", status, error);
}

// @kakao
void PerpSocial::OnKakaoAuthInit(bool result)
{
    CCLog("OnKakaoAuthInit");

    OnSDKEventResult("kakao_init", (result ? "true" : "false"), "");
}

// @kakao
void PerpSocial::OnKakaoAuthLogin(bool result)
{
    CCLog("OnKakaoAuthLogin");

    OnSDKEventResult("kakao_login", (result ? "true" : "false"), "");
}

// @kakao
void PerpSocial::OnKakaoAuthLogout(bool result)
{
    CCLog("OnKakaoAuthLogout");

    OnSDKEventResult("kakao_logout", (result ? "true" : "false"), "");
}

// @kakao
void PerpSocial::OnKakaoAuthUnregister(bool result)
{
    CCLog("OnKakaoAuthUnregister");

    OnSDKEventResult("kakao_unregister", (result ? "true" : "false"), "");
}

// @kakao
void PerpSocial::OnKakaoAuthErrorInit(char const* status, char const* error)
{
    CCLog("OnKakaoAuthErrorInit : %s, %s", status, error);

    rapidjson::Document doc;
    doc.Parse<0>("{}");
    doc.AddMember("status", status, doc.GetAllocator());
    doc.AddMember("error", error, doc.GetAllocator());

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    const char *info = strbuf.GetString();

    OnSDKEventResult("kakao_init", "auth_error", info);
}

// @kakao
void PerpSocial::OnKakaoAuthErrorLogin(char const* status, char const* error)
{
    CCLog("OnKakaoAuthErrorLogin : %s, %s", status, error);

    rapidjson::Document doc;
    doc.Parse<0>("{}");
    doc.AddMember("status", status, doc.GetAllocator());
    doc.AddMember("error", error, doc.GetAllocator());

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    const char *info = strbuf.GetString();

    OnSDKEventResult("kakao_login", "auth_error", info);
}

// @kakao
void PerpSocial::OnKakaoAuthErrorLogout(char const* status, char const* error)
{
    CCLog("OnKakaoAuthErrorLogout : %s, %s", status, error);

    rapidjson::Document doc;
    doc.Parse<0>("{}");
    doc.AddMember("status", status, doc.GetAllocator());
    doc.AddMember("error", error, doc.GetAllocator());

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    const char *info = strbuf.GetString();

    OnSDKEventResult("kakao_logout", "auth_error", info);
}

// @kakao
void PerpSocial::OnKakaoAuthErrorUnregister(char const* status, char const* error)
{
    CCLog("OnKakaoAuthErrorUnregister : %s, %s", status, error);

    rapidjson::Document doc;
    doc.Parse<0>("{}");
    doc.AddMember("status", status, doc.GetAllocator());
    doc.AddMember("error", error, doc.GetAllocator());

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    const char *info = strbuf.GetString();

    OnSDKEventResult("kakao_unregister", "auth_error", info);
}

// @kakao
void PerpSocial::OnKakaoLogin()
{
    CCLog("OnKakaoLogin");

    KakaoNativeExtension::getInstance()->auth(
        std::bind(&PerpSocial::OnKakaoAuthLogin, this, std::placeholders::_1),
        std::bind(&PerpSocial::OnKakaoAuthErrorLogin, this, std::placeholders::_1, std::placeholders::_2));
}

// @kakao
void PerpSocial::OnKakaoLoginError(char const* status, char const* error)
{
    CCLog("OnKakaoLoginError : %s, %s", status, error);

    rapidjson::Document doc;
    doc.Parse<0>("{}");
    doc.AddMember("status", status, doc.GetAllocator());
    doc.AddMember("error", error, doc.GetAllocator());

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    const char *info = strbuf.GetString();

    OnSDKEventResult("kakao_login", "error", info);
}

// @kakao
void PerpSocial::OnKakaoLogout()
{
    CCLog("OnKakaoLogout");

    KakaoNativeExtension::getInstance()->auth(
        std::bind(&PerpSocial::OnKakaoAuthLogout, this, std::placeholders::_1),
        std::bind(&PerpSocial::OnKakaoAuthErrorLogout, this, std::placeholders::_1, std::placeholders::_2));
}

// @kakao
void PerpSocial::OnKakaoLogoutError(char const* status, char const* error)
{
    CCLog("OnKakaoLogoutError : %s, %s", status, error);

    rapidjson::Document doc;
    doc.Parse<0>("{}");
    doc.AddMember("status", status, doc.GetAllocator());
    doc.AddMember("error", error, doc.GetAllocator());

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    const char *info = strbuf.GetString();

    OnSDKEventResult("kakao_logout", "error", info);
}

// @kakao
void PerpSocial::OnKakaoLocalUser()
{
    CCLog("OnKakaoLocalUser");

    rapidjson::Document doc;
    doc.Parse<0>("{}");
    doc.AddMember("uid", KakaoLocalUser::getInstance()->userId.c_str(), doc.GetAllocator());
    doc.AddMember("nickname", KakaoLocalUser::getInstance()->nickName.c_str(), doc.GetAllocator());
    doc.AddMember("hashed_talk_user_id", KakaoLocalUser::getInstance()->hashedTalkUserId.c_str(), doc.GetAllocator());
    doc.AddMember("profile_image_url", KakaoLocalUser::getInstance()->profileImageUrl.c_str(), doc.GetAllocator());
    doc.AddMember("countryIso", KakaoLocalUser::getInstance()->countryIso.c_str(), doc.GetAllocator());
    doc.AddMember("messageBlocked", KakaoLocalUser::getInstance()->messageBlocked ? "true" : "false", doc.GetAllocator());
    doc.AddMember("verified", KakaoLocalUser::getInstance()->verified ? "true" : "false", doc.GetAllocator());

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    const char *info = strbuf.GetString();

    OnSDKEventResult("kakao_localUser", "success", info);
}

// @kakao
void PerpSocial::OnKakaoLocalUserError(char const* status, char const* error)
{
    CCLog("OnKakaoLocalUserError : %s, %s", status, error);

    rapidjson::Document doc;
    doc.Parse<0>("{}");
    doc.AddMember("status", status, doc.GetAllocator());
    doc.AddMember("error", error, doc.GetAllocator());

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    const char *info = strbuf.GetString();

    OnSDKEventResult("kakao_localUser", "error", info);
}

// @kakao
void PerpSocial::OnKakaoUnregister()
{
    CCLog("OnKakaoUnregister");

    KakaoNativeExtension::getInstance()->auth(
        std::bind(&PerpSocial::OnKakaoAuthUnregister, this, std::placeholders::_1),
        std::bind(&PerpSocial::OnKakaoAuthErrorUnregister, this, std::placeholders::_1, std::placeholders::_2));
}

// @kakao
void PerpSocial::OnKakaoUnregisterError(char const* status, char const* error)
{
    CCLog("OnKakaoUnregisterError : %s, %s", status, error);

    rapidjson::Document doc;
    doc.Parse<0>("{}");
    doc.AddMember("status", status, doc.GetAllocator());
    doc.AddMember("error", error, doc.GetAllocator());

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    doc.Accept(writer);

    const char *info = strbuf.GetString();

    OnSDKEventResult("kakao_unregister", "error", info);
}

// @kakao
void PerpSocial::KakaoEvent(const char *id, const char *arg0, const char *arg1)
{
    PerpSocial *instance = PerpSocial::getInstance();

    if (strcmp(id, "kakao_init") == 0)
    {
#if 1
        OnSDKEventResult("kakao_init", "pass", "");
#else
        KakaoResponseHandler::getInstance()->onLocalUserComplete = std::bind(&PerpSocial::OnKakaoLocalUser, instance);
        KakaoResponseHandler::getInstance()->onLocalUserErrorComplete = std::bind(&PerpSocial::OnKakaoLocalUserError, instance, std::placeholders::_1, std::placeholders::_2);
        KakaoResponseHandler::getInstance()->onLoginComplete = std::bind(&PerpSocial::OnKakaoLogin, instance);
        KakaoResponseHandler::getInstance()->onLoginErrorComplete = std::bind(&PerpSocial::OnKakaoLoginError, instance, std::placeholders::_1, std::placeholders::_2);

        KakaoNativeExtension::getInstance()->init(
            std::bind(&PerpSocial::OnKakaoInit, instance),
            std::bind(&PerpSocial::OnKakaoInitError, instance, std::placeholders::_1, std::placeholders::_2));
        KakaoNativeExtension::getInstance()->tokenListener(
            std::bind(&PerpSocial::OnKakaoToken, instance),
            std::bind(&PerpSocial::OnKakaoTokenError, instance, std::placeholders::_1, std::placeholders::_2));
#endif
    }
    else if (strcmp(id, "kakao_login") == 0)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
        instance->OnKakaoAuthLogin(true);
#else
        KakaoNativeExtension::getInstance()->login(
            std::bind(&PerpSocial::OnKakaoLogin, instance),
            std::bind(&PerpSocial::OnKakaoLoginError, instance, std::placeholders::_1, std::placeholders::_2));
#endif
    }
    else if (strcmp(id, "kakao_logout") == 0)
    {
        KakaoNativeExtension::getInstance()->logout(
            std::bind(&PerpSocial::OnKakaoLogout, instance),
            std::bind(&PerpSocial::OnKakaoLogoutError, instance, std::placeholders::_1, std::placeholders::_2));
    }
    else if (strcmp(id, "kakao_localUser") == 0)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
        instance->OnKakaoLocalUser();
#else
        KakaoNativeExtension::getInstance()->localUser(
            std::bind(&PerpSocial::OnKakaoLocalUser, instance),
            std::bind(&PerpSocial::OnKakaoLocalUserError, instance, std::placeholders::_1, std::placeholders::_2));
#endif
    }
    else if (strcmp(id, "kakao_unregister") == 0)
    {
        KakaoNativeExtension::getInstance()->unregister(
            std::bind(&PerpSocial::OnKakaoUnregister, instance),
            std::bind(&PerpSocial::OnKakaoUnregisterError, instance, std::placeholders::_1, std::placeholders::_2));
    }
}
*/

void PerpSocial::SDKEvent(const char *id, const char *arg0, const char *arg1, int funcID)
{
    //log("PerpSocial::SDKEvent(%s, %s, %s)", id, arg0, arg1);

    m_onSDKEventFuncID[id] = funcID;

    std::string method = id;
    std::string prefix = method.substr(0, method.find("_"));

	/*
	// @kakao
    if (prefix == "kakao")
    {
        KakaoEvent(id, arg0, arg1);
    }
    else
    {
        sdkEvent(id, arg0, arg1);
    }
	*/

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
        !toluafix_isfunction(tolua_S, 5, "", 0, &tolua_err) ||
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
