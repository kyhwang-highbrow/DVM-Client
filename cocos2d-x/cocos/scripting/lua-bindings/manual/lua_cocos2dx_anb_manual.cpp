#include "lua_cocos2dx_anb_manual.hpp"
#include "CCAzVisual.h"
#include "CCAzVRP.h"
#include "cocos2d.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "LuaScriptHandlerMgr.h"
#include "CCLuaValue.h"

int tolua_cocos2dx_anb_AzVisual_registerScriptLoopHander(lua_State* tolua_S)
{
	if (NULL == tolua_S)
		return 0;

	int argc = 0;
	cocos2d::AzVisual* self = nullptr;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S, 1, "cc.AzVisual", 0, &tolua_err)) goto tolua_lerror;
#endif

	self = static_cast<cocos2d::AzVisual*>(tolua_tousertype(tolua_S, 1, 0));

#if COCOS2D_DEBUG >= 1
	if (nullptr == self) {
		tolua_error(tolua_S, "invalid 'self' in function 'lua_cocos2dx_anb_AzVisual_registerScriptLoopHander'\n", NULL);
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
		self->registerScriptLoopHandler(handler);
		return 0;
	}

	CCLOG("'registerScriptLoopHandler' function of AzVisual  has wrong number of arguments: %d, was expecting %d\n", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'registerScriptLoopHandler'.", &tolua_err);
	return 0;
#endif
}

static int tolua_cocos2d_AzVisual_unregisterScriptLoopHandler(lua_State* tolua_S)
{

	if (NULL == tolua_S)
		return 0;

	int argc = 0;
	cocos2d::AzVisual* self = nullptr;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S, 1, "cc.AzVisual", 0, &tolua_err)) goto tolua_lerror;
#endif

	self = static_cast<cocos2d::AzVisual*>(tolua_tousertype(tolua_S, 1, 0));

#if COCOS2D_DEBUG >= 1
	if (nullptr == self) {
		tolua_error(tolua_S, "invalid 'self' in function 'tolua_cocos2d_AzVisual_unregisterScriptLoopHandler'\n", NULL);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (0 == argc)
	{
		self->unregisterScriptLoopHandler();
		return 0;
	}

	CCLOG("'unregisterScriptLoopHandler' function of AzVisual  has wrong number of arguments: %d, was expecting %d\n", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'unregisterScriptLoopHandler'.", &tolua_err);
	return 0;
#endif
}

static void extendCCAzVisual(lua_State* L)
{
    lua_pushstring(L, "cc.AzVisual");
    lua_rawget(L, LUA_REGISTRYINDEX);
    if (lua_istable(L,-1))
    {
		tolua_function(L, "registerScriptLoopHandler", tolua_cocos2dx_anb_AzVisual_registerScriptLoopHander);
		tolua_function(L, "unregisterScriptLoopHandler", tolua_cocos2d_AzVisual_unregisterScriptLoopHandler);
    }
    lua_pop(L, 1);
}


int tolua_cocos2dx_anb_AzVRP_registerScriptLoopHander(lua_State* tolua_S)
{
	if (NULL == tolua_S)
		return 0;

	int argc = 0;
	cocos2d::AzVRP* self = nullptr;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S, 1, "cc.AzVRP", 0, &tolua_err)) goto tolua_lerror;
#endif

	self = static_cast<cocos2d::AzVRP*>(tolua_tousertype(tolua_S, 1, 0));

#if COCOS2D_DEBUG >= 1
	if (nullptr == self) {
		tolua_error(tolua_S, "invalid 'self' in function 'lua_cocos2dx_anb_AzVRP_registerScriptLoopHander'\n", NULL);
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
		self->registerScriptLoopHandler(handler);
		return 0;
	}

	CCLOG("'registerScriptLoopHandler' function of AzVRP  has wrong number of arguments: %d, was expecting %d\n", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'registerScriptLoopHandler'.", &tolua_err);
	return 0;
#endif
}

static int tolua_cocos2d_AzVRP_unregisterScriptLoopHandler(lua_State* tolua_S)
{

	if (NULL == tolua_S)
		return 0;

	int argc = 0;
	cocos2d::AzVRP* self = nullptr;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
	if (!tolua_isusertype(tolua_S, 1, "cc.AzVRP", 0, &tolua_err)) goto tolua_lerror;
#endif

	self = static_cast<cocos2d::AzVRP*>(tolua_tousertype(tolua_S, 1, 0));

#if COCOS2D_DEBUG >= 1
	if (nullptr == self) {
		tolua_error(tolua_S, "invalid 'self' in function 'tolua_cocos2d_AzVRP_unregisterScriptLoopHandler'\n", NULL);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;

	if (0 == argc)
	{
		self->unregisterScriptLoopHandler();
		return 0;
	}

	CCLOG("'unregisterScriptLoopHandler' function of AzVRP  has wrong number of arguments: %d, was expecting %d\n", argc, 0);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'unregisterScriptLoopHandler'.", &tolua_err);
	return 0;
#endif
}

static void extendCCAzVRP(lua_State* L)
{
	lua_pushstring(L, "cc.AzVRP");
	lua_rawget(L, LUA_REGISTRYINDEX);
	if (lua_istable(L, -1))
	{
		tolua_function(L, "registerScriptLoopHandler", tolua_cocos2dx_anb_AzVRP_registerScriptLoopHander);
		tolua_function(L, "unregisterScriptLoopHandler", tolua_cocos2d_AzVRP_unregisterScriptLoopHandler);
	}
	lua_pop(L, 1);
}

int register_all_cocos2dx_anb_manual(lua_State* L)
{
    if (nullptr == L)
        return 0;

    extendCCAzVisual(L);
	extendCCAzVRP(L);

    return 0;
}
