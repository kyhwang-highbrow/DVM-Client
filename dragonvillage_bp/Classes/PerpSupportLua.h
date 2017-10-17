#ifndef __PERP_SUPPORT_LUA__
#define __PERP_SUPPORT_LUA__

USING_NS_CC;

using namespace std;
#include <string>
#include "PerpConstant.h"

class SupportLua
{
public:
	static int luaLoader(lua_State *L);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
    static std::string SupportLua::wstrtostr(const std::wstring &wstr);
    static std::string SupportLua::AnsiToUtf8(std::string strAnsi);
    static std::string SupportLua::Utf8ToAnsi(std::string strUTF8);
#endif

    static std::string openFileDialog();
};

#endif