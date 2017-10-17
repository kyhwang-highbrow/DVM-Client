/*
** Lua binding: PerpLua
*/


#include "cocos2d.h"
#include "tolua++.h"
#include "PerpConstant.h"

using namespace cocos2d;
using namespace CocosDenshion;
/* Exported function */
TOLUA_API int  tolua_PerpLua_open (lua_State* tolua_S);

#include "PerpExt/PerpUtils.h"

/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
#ifndef Mtolua_typeid
#define Mtolua_typeid(L,TI,T)
#endif
 tolua_usertype(tolua_S,"PerpUtils");
 Mtolua_typeid(tolua_S,typeid(PerpUtils), "PerpUtils");
 tolua_usertype(tolua_S,"LUA_FUNCTION");
 Mtolua_typeid(tolua_S,typeid(LUA_FUNCTION), "LUA_FUNCTION");
}

/* method: GetEncrypedFileData of class  PerpUtils */
#ifndef TOLUA_DISABLE_tolua_PerpLua_PerpUtils_GetEncrypedFileData00
static int tolua_PerpLua_PerpUtils_GetEncrypedFileData00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isusertable(tolua_S, 1, "PerpUtils", 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isnoobj(tolua_S, 3, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        const char* path = ((const char*)tolua_tostring(tolua_S, 2, 0));
        {
            char* tolua_ret = (char*)PerpUtils::GetEncrypedFileData(path);
            tolua_pushstring(tolua_S, (const char*)tolua_ret);
            free(tolua_ret);
        }
    }
    return 1;
#ifndef TOLUA_RELEASE
tolua_lerror :
    tolua_error(tolua_S, "#ferror in function 'GetEncrypedFileData'.", &tolua_err);
    return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: XorEncrypt of class  PerpUtils */
#ifndef TOLUA_DISABLE_tolua_PerpLua_PerpUtils_XorEncrypt00
static int tolua_PerpLua_PerpUtils_XorEncrypt00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (
        !tolua_isusertable(tolua_S, 1, "PerpUtils", 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 3, 0, &tolua_err) ||
        !tolua_isnoobj(tolua_S, 4, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        const char* path = ((const char*)tolua_tostring(tolua_S, 2, 0));
        const char* tar = ((const char*)tolua_tostring(tolua_S, 3, 0));
        {
            PerpUtils::XorEncrypt(path, tar);
        }
    }
    return 1;
#ifndef TOLUA_RELEASE
tolua_lerror :
    tolua_error(tolua_S, "#ferror in function 'XorEncrypt'.", &tolua_err);
    return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


/* Open function */
TOLUA_API int tolua_PerpLua_open (lua_State* tolua_S)
{
    tolua_open(tolua_S);
    tolua_reg_types(tolua_S);
    tolua_module(tolua_S, NULL, 0);
    tolua_beginmodule(tolua_S, NULL);
        tolua_cclass(tolua_S,"PerpUtils","PerpUtils","",NULL);
        tolua_beginmodule(tolua_S,"PerpUtils");
            tolua_function(tolua_S,"GetEncrypedFileData",tolua_PerpLua_PerpUtils_GetEncrypedFileData00);
            tolua_function(tolua_S,"XorEncrypt", tolua_PerpLua_PerpUtils_XorEncrypt00);
        tolua_endmodule(tolua_S);
    tolua_endmodule(tolua_S);
    return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
    TOLUA_API int luaopen_PerpLua (lua_State* tolua_S) {
    return tolua_PerpLua_open(tolua_S);
};
#endif

