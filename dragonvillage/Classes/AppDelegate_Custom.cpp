#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "cocos2d.h"
#include "PerpSupportPatch.h"
#include "PerpSupportLua.h"
#include "PerpSocial.h"
#include "PerpExt/PerpUtils.h"
#include "PerpConstant.h"
#include "ConfigParser.h"
#include "tolua_fix.h"

// @perplesdk
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "PerpleCore.h"
#endif

/*
정리하기가 애매한 부분이 있어 AppDelegate.cpp의 라인을 줄이고,
수정 가능성이 있는 부분만 이 곳에 옮겨서 정의
*/

USING_NS_CC;
using namespace std;

TOLUA_API int  tolua_PerpLua_open(lua_State* tolua_S);

/**
@brief : 문자열을 잘라주는 함수입니다.
@strOrigin : 자를 데이터
@strTok : 분기줄 데이터
@string : 반환형 , 배열로 인자전달
*/
string* StringSplit(string strTarget, string strTok)
{
    int nCutPos;
    int nIndex = 0;
    string* strResult = new string[3];

    while ((nCutPos = (int)strTarget.find_first_of(strTok)) != strTarget.npos)
    {
        if (nCutPos > 0)
        {
            strResult[nIndex++] = strTarget.substr(0, nCutPos);
        }
        strTarget = strTarget.substr(nCutPos + 1);
    }

    if (strTarget.length() > 0)
    {
        strResult[nIndex++] = strTarget.substr(0, nCutPos);
    }

    return strResult;
}

/**
 @brief : 앱버전 문자열을 반환한다.
 */
string GetAppVer()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    string major_ver = MAJOR_VER;
    string minor_ver = MINOR_VER;
    string build_ver = BUILD_VER;
    return major_ver + "." + minor_ver + "." + build_ver;
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    int major_ver = floor(APP_VER/100);
    int minor_ver = floor((APP_VER - (major_ver * 100))/10);
    int build_ver = APP_VER - (major_ver * 100) - (minor_ver * 10);
    return to_string(major_ver) + "." + to_string(minor_ver) + "." + to_string(build_ver);
#else
    return ConfigParser::getInstance()->getAppVer();
#endif
}

void AppDelegate::setPathForPatch()
{
	// 리소스 다운로드 경로
    string app_ver = GetAppVer();
	string res_path = SupportPatch::getExtensionPath();
    string patch_path = SupportPatch::getPatchPath(app_ver.c_str());

	FileUtils* fileUtils = FileUtils::getInstance();

	// 기본 search path 백업
	vector<string> baseSearchPathArray = fileUtils->getSearchPaths();

	// 패치 search path 추가
	vector<string> finalSearchPathArray = vector<string>();
	string writable_path = fileUtils->getWritablePath();

    bool use_patch = USE_PATCH;
    if (use_patch)
    {
		finalSearchPathArray.push_back(writable_path + patch_path);
		finalSearchPathArray.push_back(writable_path + patch_path + "src/");
		finalSearchPathArray.push_back(writable_path + patch_path + "ps/");
		finalSearchPathArray.push_back(writable_path + patch_path + "res/");
        finalSearchPathArray.push_back(writable_path + res_path);
        finalSearchPathArray.push_back(writable_path + res_path + "src/");
        finalSearchPathArray.push_back(writable_path + res_path + "ps/");
        finalSearchPathArray.push_back(writable_path + res_path + "res/");
    }

	// 패치 search path 뒤에 기본 search path 추가
	for (auto searchIt = baseSearchPathArray.cbegin(); searchIt != baseSearchPathArray.cend(); ++searchIt)
	{
		finalSearchPathArray.push_back(*searchIt);
	}

	// 새로운 search path 백터 설정
	fileUtils->setSearchPaths(finalSearchPathArray);

	// 패치 폴더 생성
    SupportPatch::makePath(writable_path + patch_path);
    SupportPatch::makePath(writable_path + res_path);

	// dump 폴더 생성
    SupportPatch::makePath(writable_path + "dump/");
    SupportPatch::makePath(writable_path + "network_dump/");

    { // 이전 버전 폴더 삭제
        //string app_ver = GetAppVer();
        string* tok = StringSplit(app_ver, ".");
        int ver_major = (int)strtol(tok[0].c_str(), NULL, 10);
        int ver_minor = (int)strtol(tok[1].c_str(), NULL, 10);
        int ver_build = (int)strtol(tok[2].c_str(), NULL, 10);

        int ver = (ver_major * 100) + (ver_minor * 10) + ver_build;
        for (int idx = ver; 0 < idx; --idx)
        {
            int major = (idx / 100);
            int minor = ((idx % 100) / 10);
            int build = (idx % 10);

            // 현재 버전은 skip
            if ((ver_major == major) && (ver_minor == minor) && (ver_build == build)) continue;

            // 0.0.0버전은 skip
            if ((0 == major) && (0 == minor) && (0 == build)) continue;

            String patch_path = StringUtils::format("patch_%d_%d_%d", major, minor, build);
            SupportPatch::removeDir(writable_path + patch_path.getCString());
        }
    }
}

static int l_isWin32(lua_State* L)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
	lua_pushboolean(L, (int)1);
#else
	lua_pushboolean(L, (int)0);
#endif
	return 1;
}

static int l_isAndroid(lua_State* L)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    lua_pushboolean(L, (int)1);
#else
    lua_pushboolean(L, (int)0);
#endif
    return 1;
}

static int l_isIos(lua_State* L)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    lua_pushboolean(L, (int)1);
#else
    lua_pushboolean(L, (int)0);
#endif
    return 1;
}

static int l_isMac(lua_State* L)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    lua_pushboolean(L, (int)1);
#else
    lua_pushboolean(L, (int)0);
#endif
    return 1;
}

static int l_isTestMode(lua_State* L)
{
    bool isTestMode = IS_TEST_MODE;
    if (isTestMode)
    {
        lua_pushboolean(L, (int)1);
    }
    else
    {
        lua_pushboolean(L, (int)0);
    }
    return 1;
}

static int l_isCafeBazaarBuild(lua_State* L)
{
    bool isCafeBazaarBuild = IS_CAFE_BAZAAR_BUILD;
    if (isCafeBazaarBuild)
    {
        lua_pushboolean(L, (int)1);
    }
    else
    {
        lua_pushboolean(L, (int)0);
    }
    return 1;
}

static int l_usePatch(lua_State* L)
{
    bool usePatch = USE_PATCH;
    if (usePatch)
    {
        lua_pushboolean(L, (int)1);
    }
    else
    {
        lua_pushboolean(L, (int)0);
    }
    return 1;
}

static int l_useObb(lua_State* L)
{
    bool usePatch = USE_OBB;
    if (usePatch)
    {
        lua_pushboolean(L, (int)1);
    }
    else
    {
        lua_pushboolean(L, (int)0);
    }
    return 1;
}

static int l_getTargetServer(lua_State* L)
{
    string tar_server = TARGET_SERVER;
    lua_pushlstring(L, tar_server.c_str(), strlen(tar_server.c_str()));

    return 1;
}

static int l_getAppVer(lua_State* L)
{
    string app_ver = GetAppVer();
    lua_pushlstring(L, app_ver.c_str(), strlen(app_ver.c_str()));
	return 1;
}

static int l_restart(lua_State* L)
{
    auto scene = ReloadLuaHelper::create(ReloadLuaHelper::ENTRY_PATCH);
	Director::getInstance()->replaceScene(scene);

	return 0;
}

static int l_finishPatch(lua_State* L)
{
    //Director::getInstance()->replaceScene(scene);
    auto* scene = ReloadLuaHelper::create(ReloadLuaHelper::ENTRY_TITLE);
    CallFunc* runCallback = CallFunc::create(CC_CALLBACK_0(ReloadLuaHelper::purgeEngine, scene));
    //scene->run();
    //this->runAction(Sequence::create(DelayTime::create(0.001), runCallback, nullptr));
    Director::getInstance()->getRunningScene()->runAction(Sequence::create(DelayTime::create(0.01f), runCallback, nullptr));

	return 0;
}

static int l_unzip(lua_State* L)
{
	const char *zip = lua_tostring(L, 1);
	const char *target = lua_tostring(L, 2);
	const char *md5 = lua_tostring(L, 3);

	int ret = SupportPatch::unzipFiles(zip, md5, target, "__");
	lua_pushnumber(L, ret);

	return 1;
}

static int l_unzipAsync(lua_State* L)
{
    const char *zip = tolua_tostring(L, 1, 0);
    const char *target = tolua_tostring(L, 2, 0);
    const char *md5 = tolua_tostring(L, 3, 0);
    const int funcId = toluafix_ref_function(L, 4, 0);

    SupportPatch::startUnzipThread(zip, md5, target, "__", [=](int ret){
        if (funcId > 0)
        {
            lua_pushnumber(L, (lua_Number)ret);
            LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
            stack->executeFunctionByHandler(funcId, 1);
            stack->clean();
        }
    });

    return 0;
}

static int l_getMd5(lua_State* L)
{
	const char *target = lua_tostring(L, 1);
	char checkSum[33];
	SupportPatch::getMd5(target, checkSum);
	lua_pushlstring(L, checkSum, strlen(checkSum));

	return 1;
}

static int l_isSameMd5(lua_State* L)
{
    const char *md5 = lua_tostring(L, 1);
    const char *fileName = lua_tostring(L, 2);

    if (SupportPatch::isSameMd5(fileName, md5))
    {
        lua_pushboolean(L, (int)1);
    }
    else
    {
        lua_pushboolean(L, (int)0);
    }
    return 1;
}

extern int isInstalled(const char *packagename);
static int l_isInstalled(lua_State* L)
{
    const char *pPackage = lua_tostring(L, 1);

    int ret = isInstalled(pPackage);
    lua_pushboolean(L, (int)ret);
    return 1;
}

extern string getRunningApps();
static int l_getRunningApps(lua_State* L)
{
    string ret = getRunningApps();
    const char *apps = ret.c_str();
    lua_pushstring(L, apps);
    return 1;
}

extern string getDeviceLanguage();
static int l_getDeviceLanguage(lua_State* L)
{
	string ret = getDeviceLanguage();
	const char *language = ret.c_str();
	lua_pushstring(L, language);
	return 1;
}

extern string getLocale();
static int l_getLocale(lua_State* L)
{
	string ret = getLocale();
	const char *locale = ret.c_str();
	lua_pushstring(L, locale);
	return 1;
}

extern int isWifiConnected();
static int l_isWifiConnected(lua_State* L)
{
	int ret = isWifiConnected();
	lua_pushboolean(L, (int)ret);
	return 1;
}

extern string getFreeMemory();
static int l_getFreeMemory(lua_State* L)
{
    string ret = getFreeMemory();
    const char *memoryInfo = ret.c_str();
    lua_pushstring(L, memoryInfo);
    return 1;
}

static int l_openFileDialog(lua_State *L)
{
    /*
    const char *event_name = lua_tostring(L, 1);
    const char *param1 = lua_tostring(L, 2);
    const char *param2 = lua_tostring(L, 3);
    const char *param3 = lua_tostring(L, 4);
    */
    lua_pushstring(L, SupportLua::openFileDialog().c_str());

    return 1;
}

extern string getIPAddress();
static int l_getIPAddress(lua_State *L)
{
	string ret = getIPAddress();
	const char *ip = ret.c_str();
	lua_pushstring(L, ip);
	return 1;
}

void AppDelegate::initLuaEngine()
{
	// 기존의 ScriptEngineManager를 제거
    ScriptEngineManager::destroyInstance();

	// LuaEngine 생성 후 설정
	auto engine = LuaEngine::getInstance();
	ScriptEngineManager::getInstance()->setScriptEngine(engine);

	// LuaState
	lua_State* L = engine->getLuaStack()->getLuaState();

	// Lua Load : decrypt
	engine->getLuaStack()->addLuaLoader(SupportLua::luaLoader);

	// lua에서 사용할 전역 cpp함수 등록
	const luaL_reg global_functions[] = {
			{ "restart", l_restart },
			{ "finishPatch", l_finishPatch },
			{ "isWin32", l_isWin32 },
            { "isMac", l_isMac },
            { "isAndroid", l_isAndroid },
            { "isIos", l_isIos },
			{ "isTestMode", l_isTestMode },
            { "isCafeBazaarBuild", l_isCafeBazaarBuild },
            { "usePatch", l_usePatch }, 
            { "useObb", l_useObb },
            { "getTargetServer", l_getTargetServer },
			{ "getAppVer", l_getAppVer },
			{ "getMd5", l_getMd5 },
            { "isSameMd5", l_isSameMd5 },
            { "isInstalled", l_isInstalled },
            { "getRunningApps", l_getRunningApps },
			{ "getDeviceLanguage", l_getDeviceLanguage },
			{ "getLocale", l_getLocale },
			{ "isWifiConnected", l_isWifiConnected },
            { "getFreeMemory", l_getFreeMemory },
			{ "unzip", l_unzip },
            { "unzipAsync", l_unzipAsync },
            { "openFileDialog", l_openFileDialog },
			{ "getIPAddress", l_getIPAddress },
			{ NULL, NULL }
	};
    luaL_register(L, "_G", global_functions);

	// PerpLua : Register
    tolua_PerpLua_open(L);

	// PerpSocial : Register
	PerpSocial::getInstance()->RegisterToLuaFunc(L);

	// PerpleSDK : Register
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    PerpleCore::LuaOpenPerpleSDK(L);
#endif
}

void AppDelegate::sdkEventHandler(const char *id, const char *result, const char *info)
{
    PerpSocial::OnSDKEventResult(id, result, info);
}

void AppDelegate::reloadLuaModule()
{
    auto engine = LuaEngine::getInstance();

    if (engine != NULL)
    {
        engine->executeGlobalFunction("reloadModule");
    }
}
