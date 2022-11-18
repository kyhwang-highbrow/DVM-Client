#ifndef COCOS_SCRIPTING_LUA_BINDINGS_LUA_COCOS2DX_ANB_MANUAL_H
#define COCOS_SCRIPTING_LUA_BINDINGS_LUA_COCOS2DX_ANB_MANUAL_H

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

#include "base/CCRef.h"

TOLUA_API int register_all_cocos2dx_anb_manual(lua_State* L);


#endif // #ifndef COCOS_SCRIPTING_LUA_BINDINGS_LUA_COCOS2DX_ANB_MANUAL_H
