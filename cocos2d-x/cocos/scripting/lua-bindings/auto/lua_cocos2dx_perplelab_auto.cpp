#include "lua_cocos2dx_perplelab_auto.hpp"
#include "CCPerpSpriter.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"



int lua_cocos2dx_perplelab_PerpSpriter_setSpriteSubstitution(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_setSpriteSubstitution'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        const char* arg0;
        const char* arg1;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();

        std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp); arg1 = arg1_tmp.c_str();
        if(!ok)
            return 0;
        cobj->setSpriteSubstitution(arg0, arg1);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setSpriteSubstitution",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_setSpriteSubstitution'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_play(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_play'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        bool ret = cobj->play(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "play",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_play'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_getOriginalAnimationLength(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_getOriginalAnimationLength'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        double ret = cobj->getOriginalAnimationLength();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getOriginalAnimationLength",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_getOriginalAnimationLength'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_initWithFile(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_initWithFile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        bool ret = cobj->initWithFile(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "initWithFile",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_initWithFile'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_setLooping(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_setLooping'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->setLooping(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setLooping",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_setLooping'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_getAlpha(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_getAlpha'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        double ret = cobj->getAlpha();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getAlpha",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_getAlpha'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_playByIndex(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_playByIndex'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        int arg0;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0);
        if(!ok)
            return 0;
        bool ret = cobj->playByIndex(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "playByIndex",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_playByIndex'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_setAlpha(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_setAlpha'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        double arg0;

        ok &= luaval_to_number(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->setAlpha(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setAlpha",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_setAlpha'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_buildSprite(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_buildSprite'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        const char* arg0;

        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
        if(!ok)
            return 0;
        cobj->buildSprite(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "buildSprite",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_buildSprite'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_getCurrentAnimationName(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_getCurrentAnimationName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        const char* ret = cobj->getCurrentAnimationName();
        tolua_pushstring(tolua_S,(const char*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCurrentAnimationName",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_getCurrentAnimationName'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_getCurrentAnimationLength(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_getCurrentAnimationLength'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        double ret = cobj->getCurrentAnimationLength();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCurrentAnimationLength",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_getCurrentAnimationLength'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_setAnimationLength(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_setAnimationLength'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        double arg0;

        ok &= luaval_to_number(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->setAnimationLength(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setAnimationLength",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_setAnimationLength'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_restart(lua_State* tolua_S)
{
    int argc = 0;
    PerpSpriter* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (PerpSpriter*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_perplelab_PerpSpriter_restart'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->restart();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "restart",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_restart'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 2)
        {
            const char* arg0;
            std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
            if (!ok) { break; }
            const char* arg1;
            std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp); arg1 = arg1_tmp.c_str();
            if (!ok) { break; }
            PerpSpriter* ret = PerpSpriter::create(arg0, arg1);
            object_to_luaval<PerpSpriter>(tolua_S, "PerpSpriter",(PerpSpriter*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 1)
        {
            const char* arg0;
            std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp); arg0 = arg0_tmp.c_str();
            if (!ok) { break; }
            PerpSpriter* ret = PerpSpriter::create(arg0);
            object_to_luaval<PerpSpriter>(tolua_S, "PerpSpriter",(PerpSpriter*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    CCLOG("%s has wrong number of arguments: %d, was expecting %d", "create",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_create'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_perplelab_PerpSpriter_setFPS(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"PerpSpriter",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        int arg0;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0);
        if(!ok)
            return 0;
        PerpSpriter::setFPS(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "setFPS",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_perplelab_PerpSpriter_setFPS'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_perplelab_PerpSpriter_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (PerpSpriter)");
    return 0;
}

int lua_register_cocos2dx_perplelab_PerpSpriter(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"PerpSpriter");
    tolua_cclass(tolua_S,"PerpSpriter","PerpSpriter","cc.Node",nullptr);

    tolua_beginmodule(tolua_S,"PerpSpriter");
        tolua_function(tolua_S,"setSpriteSubstitution",lua_cocos2dx_perplelab_PerpSpriter_setSpriteSubstitution);
        tolua_function(tolua_S,"play",lua_cocos2dx_perplelab_PerpSpriter_play);
        tolua_function(tolua_S,"getOriginalAnimationLength",lua_cocos2dx_perplelab_PerpSpriter_getOriginalAnimationLength);
        tolua_function(tolua_S,"initWithFile",lua_cocos2dx_perplelab_PerpSpriter_initWithFile);
        tolua_function(tolua_S,"setLooping",lua_cocos2dx_perplelab_PerpSpriter_setLooping);
        tolua_function(tolua_S,"getAlpha",lua_cocos2dx_perplelab_PerpSpriter_getAlpha);
        tolua_function(tolua_S,"playByIndex",lua_cocos2dx_perplelab_PerpSpriter_playByIndex);
        tolua_function(tolua_S,"setAlpha",lua_cocos2dx_perplelab_PerpSpriter_setAlpha);
        tolua_function(tolua_S,"buildSprite",lua_cocos2dx_perplelab_PerpSpriter_buildSprite);
        tolua_function(tolua_S,"getCurrentAnimationName",lua_cocos2dx_perplelab_PerpSpriter_getCurrentAnimationName);
        tolua_function(tolua_S,"getCurrentAnimationLength",lua_cocos2dx_perplelab_PerpSpriter_getCurrentAnimationLength);
        tolua_function(tolua_S,"setAnimationLength",lua_cocos2dx_perplelab_PerpSpriter_setAnimationLength);
        tolua_function(tolua_S,"restart",lua_cocos2dx_perplelab_PerpSpriter_restart);
        tolua_function(tolua_S,"create", lua_cocos2dx_perplelab_PerpSpriter_create);
        tolua_function(tolua_S,"setFPS", lua_cocos2dx_perplelab_PerpSpriter_setFPS);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(PerpSpriter).name();
    g_luaType[typeName] = "PerpSpriter";
    g_typeCast["PerpSpriter"] = "PerpSpriter";
    return 1;
}
TOLUA_API int register_all_cocos2dx_perplelab(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"cc",0);
	tolua_beginmodule(tolua_S,"cc");

	lua_register_cocos2dx_perplelab_PerpSpriter(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

