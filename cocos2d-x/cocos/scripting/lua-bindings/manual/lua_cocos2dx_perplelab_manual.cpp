#include "lua_cocos2dx_perplelab_manual.hpp"
#include "CCPerpSpriter.h"
#include "cocos2d.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "LuaScriptHandlerMgr.h"
#include "CCLuaValue.h"

int tolua_cocos2dx_perplelab_PerpSpriter_registerLoopHandler(lua_State* tolua_S)
{
	if (NULL == tolua_S)
		return 0;

	int argc = 0;
	PerpSpriter* self = nullptr;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S, 1, "PerpSpriter", 0, &tolua_err)) goto tolua_lerror;
#endif

	self = static_cast<PerpSpriter*>(tolua_tousertype(tolua_S, 1, 0));

#if COCOS2D_DEBUG >= 1
	if (nullptr == self) {
		tolua_error(tolua_S, "invalid 'self' in function 'tolua_cocos2dx_perplelab_PerpSpriter_registerLoopHandler'\n", NULL);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (1 == argc)
	{
#if COCOS2D_DEBUG >= 1
		if (!toluafix_isfunction(tolua_S, 2, "LUA_FUNCTION", 0, &tolua_err))
		{
			goto tolua_lerror;
		}
#endif
		LUA_FUNCTION handler = (toluafix_ref_function(tolua_S, 2, 0));
		self->registerLoopHandler(handler);
		return 0;
	}

	CCLOG("'registerLoopHandler' function of PerpSpriter  has wrong number of arguments: %d, was expecting %d\n", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'registerLoopHandler'.", &tolua_err);
	return 0;
#endif
}

static int tolua_cocos2d_perplelab_PerpSpriter_unregisterLoopHandler(lua_State* tolua_S)
{

	if (NULL == tolua_S)
		return 0;

	int argc = 0;
	PerpSpriter* self = nullptr;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S, 1, "PerpSpriter", 0, &tolua_err)) goto tolua_lerror;
#endif

	self = static_cast<PerpSpriter*>(tolua_tousertype(tolua_S, 1, 0));

#if COCOS2D_DEBUG >= 1
	if (nullptr == self) {
		tolua_error(tolua_S, "invalid 'self' in function 'tolua_cocos2d_perplelab_PerpSpriter_unregisterLoopHandler'\n", NULL);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (0 == argc)
	{
		self->unregisterLoopHandler();
		return 0;
	}

	CCLOG("'unregisterLoopHandler' function of PerpSpriter  has wrong number of arguments: %d, was expecting %d\n", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'unregisterLoopHandler'.", &tolua_err);
	return 0;
#endif
}

int tolua_cocos2dx_perplelab_PerpSpriter_registerTriggerHandler(lua_State* tolua_S)
{
	if (NULL == tolua_S)
		return 0;

	int argc = 0;
	PerpSpriter* self = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S, 1, "PerpSpriter", 0, &tolua_err)) goto tolua_lerror;
#endif

	self = static_cast<PerpSpriter*>(tolua_tousertype(tolua_S, 1, 0));

#if COCOS2D_DEBUG >= 1
	if (nullptr == self) {
		tolua_error(tolua_S, "invalid 'self' in function 'tolua_cocos2dx_perplelab_PerpSpriter_registerTriggerHandler'\n", NULL);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 2)
	{
		double arg0;
		LUA_FUNCTION arg1;

		ok &= luaval_to_number(tolua_S, 2, &arg0);
		if (!ok)
			return 0;

#if COCOS2D_DEBUG >= 1
		if (!toluafix_isfunction(tolua_S, 3, "LUA_FUNCTION", 0, &tolua_err))
		{
			goto tolua_lerror;
		}
#endif
		arg1 = (toluafix_ref_function(tolua_S, 3, 0));
		self->registerTriggerHandler(arg0, arg1);
		return 0;
	}

	CCLOG("'registerTriggerHandler' function of PerpSpriter  has wrong number of arguments: %d, was expecting %d\n", argc, 2);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'registerTriggerHandler'.", &tolua_err);
	return 0;
#endif
}

static int tolua_cocos2d_perplelab_PerpSpriter_unregisterTriggerHandler(lua_State* tolua_S)
{

	if (NULL == tolua_S)
		return 0;

	int argc = 0;
	PerpSpriter* self = nullptr;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S, 1, "PerpSpriter", 0, &tolua_err)) goto tolua_lerror;
#endif

	self = static_cast<PerpSpriter*>(tolua_tousertype(tolua_S, 1, 0));

#if COCOS2D_DEBUG >= 1
	if (nullptr == self) {
		tolua_error(tolua_S, "invalid 'self' in function 'tolua_cocos2d_perplelab_PerpSpriter_unregisterTriggerHandler'\n", NULL);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (0 == argc)
	{
		self->unregisterTriggerHandler();
		return 0;
	}

	CCLOG("'unregisterTriggerHandler' function of PerpSpriter  has wrong number of arguments: %d, was expecting %d\n", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'unregisterTriggerHandler'.", &tolua_err);
	return 0;
#endif
}

static void extendCCPerpSpriter(lua_State* L)
{
    lua_pushstring(L, "PerpSpriter");
    lua_rawget(L, LUA_REGISTRYINDEX);
    if (lua_istable(L,-1))
    {
		tolua_function(L, "registerLoopHandler", tolua_cocos2dx_perplelab_PerpSpriter_registerLoopHandler);
		tolua_function(L, "unregisterLoopHandler", tolua_cocos2d_perplelab_PerpSpriter_unregisterLoopHandler);
		tolua_function(L, "registerTriggerHandler", tolua_cocos2dx_perplelab_PerpSpriter_registerTriggerHandler);
		tolua_function(L, "unregisterTriggerHandler", tolua_cocos2d_perplelab_PerpSpriter_unregisterTriggerHandler);
    }
    lua_pop(L, 1);
}

int register_all_cocos2dx_perplelab_manual(lua_State* L)
{
    if (nullptr == L)
        return 0;

	extendCCPerpSpriter(L);
    
    return 0;
}
