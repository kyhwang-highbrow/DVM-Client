#ifndef __PATISDK_PUBLISHLUA_H__
#define __PATISDK_PUBLISHLUA_H__

struct lua_State;
extern void luaopen_patipublishsdk(lua_State* L);

typedef int (*lua_CFunction) (lua_State *L);
namespace PatiSDK {
	namespace LuaBinding {
		void SetErrorHandler(lua_CFunction new_error_handler);
	}
}

#endif


