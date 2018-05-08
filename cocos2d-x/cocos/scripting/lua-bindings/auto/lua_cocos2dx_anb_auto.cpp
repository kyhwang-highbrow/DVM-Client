#include "lua_cocos2dx_anb_auto.hpp"
#include "CCazVisual.h"
#include "CCazVRP.h"
#include "CCActionInterval3D.h"
#include "CCAzPerspective.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"



int lua_cocos2dx_anb_AzVisual_isRepeat(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_isRepeat'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        bool ret = cobj->isRepeat();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "isRepeat",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_isRepeat'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_enableDrawShapeInfo(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_enableDrawShapeInfo'", nullptr);
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
        cobj->enableDrawShapeInfo(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "enableDrawShapeInfo",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_enableDrawShapeInfo'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_enableDrawSocketInfo(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_enableDrawSocketInfo'", nullptr);
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
        cobj->enableDrawSocketInfo(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "enableDrawSocketInfo",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_enableDrawSocketInfo'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_isEndAnimation(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_isEndAnimation'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        bool ret = cobj->isEndAnimation();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "isEndAnimation",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_isEndAnimation'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_getSocketNode(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_getSocketNode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cocos2d::Node* ret = cobj->getSocketNode(arg0);
        object_to_luaval<cocos2d::Node>(tolua_S, "cc.Node",(cocos2d::Node*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getSocketNode",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_getSocketNode'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_getVisualName(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_getVisualName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        std::string ret = cobj->getVisualName();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getVisualName",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_getVisualName'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_bindSocket(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_bindSocket'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 3) 
    {
        std::string arg0;
        std::string arg1;
        std::string arg2;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);

        ok &= luaval_to_std_string(tolua_S, 3,&arg1);

        ok &= luaval_to_std_string(tolua_S, 4,&arg2);
        if(!ok)
            return 0;
        bool ret = cobj->bindSocket(arg0, arg1, arg2);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "bindSocket",argc, 3);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_bindSocket'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_setRepeat(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_setRepeat'", nullptr);
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
        cobj->setRepeat(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setRepeat",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_setRepeat'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_initEventShapeList(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_initEventShapeList'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->initEventShapeList();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "initEventShapeList",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_initEventShapeList'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_buildEventShapeID(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_buildEventShapeID'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        bool ret = cobj->buildEventShapeID(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "buildEventShapeID",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_buildEventShapeID'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_setAdditiveColor(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_setAdditiveColor'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Color3B arg0;

        ok &= luaval_to_color3b(tolua_S, 2, &arg0);
        if(!ok)
            return 0;
        cobj->setAdditiveColor(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setAdditiveColor",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_setAdditiveColor'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_getVisualGroupName(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_getVisualGroupName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        std::string ret = cobj->getVisualGroupName();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getVisualGroupName",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_getVisualGroupName'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_setVisual(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif
    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);
#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_setVisual'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S)-1;
    do{
        if (argc == 2) {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0);

            if (!ok) { break; }
            std::string arg1;
            ok &= luaval_to_std_string(tolua_S, 3,&arg1);

            if (!ok) { break; }
            bool ret = cobj->setVisual(arg0, arg1);
            tolua_pushboolean(tolua_S,(bool)ret);
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 2) {
            int arg0;
            ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0);

            if (!ok) { break; }
            int arg1;
            ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1);

            if (!ok) { break; }
            bool ret = cobj->setVisual(arg0, arg1);
            tolua_pushboolean(tolua_S,(bool)ret);
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 1) {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0);

            if (!ok) { break; }
            bool ret = cobj->setVisual(arg0);
            tolua_pushboolean(tolua_S,(bool)ret);
            return 1;
        }
    }while(0);
    ok  = true;
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setVisual",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_setVisual'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_setSpriteSubstitution(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_setSpriteSubstitution'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        std::string arg0;
        std::string arg1;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);

        ok &= luaval_to_std_string(tolua_S, 3,&arg1);
        if(!ok)
            return 0;
        cobj->setSpriteSubstitution(arg0, arg1);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setSpriteSubstitution",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_setSpriteSubstitution'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_getValidRect(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_getValidRect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cocos2d::Rect ret = cobj->getValidRect();
        rect_to_luaval(tolua_S, ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getValidRect",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_getValidRect'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_bindVisual(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_bindVisual'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 3) 
    {
        std::string arg0;
        std::string arg1;
        std::string arg2;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);

        ok &= luaval_to_std_string(tolua_S, 3,&arg1);

        ok &= luaval_to_std_string(tolua_S, 4,&arg2);
        if(!ok)
            return 0;
        bool ret = cobj->bindVisual(arg0, arg1, arg2);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "bindVisual",argc, 3);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_bindVisual'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_getDuration(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_getDuration'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        double ret = cobj->getDuration();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getDuration",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_getDuration'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_buildSprite(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_buildSprite'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->buildSprite(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "buildSprite",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_buildSprite'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_releaseSprite(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_releaseSprite'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->releaseSprite();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "releaseSprite",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_releaseSprite'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_buildPhysicBody(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_buildPhysicBody'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->buildPhysicBody();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "buildPhysicBody",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_buildPhysicBody'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_getShapeCount(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_getShapeCount'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->getShapeCount();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getShapeCount",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_getShapeCount'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_loadPlistFiles(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_loadPlistFiles'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->loadPlistFiles(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "loadPlistFiles",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_loadPlistFiles'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_setFrame(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_setFrame'", nullptr);
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
        cobj->setFrame(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setFrame",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_setFrame'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_queryEventShape(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_queryEventShape'", nullptr);
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
        cobj->queryEventShape(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "queryEventShape",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_queryEventShape'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_setFile(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_setFile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        bool ret = cobj->setFile(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setFile",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_setFile'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_enableDrawVisibleRect(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVisual* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVisual*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVisual_enableDrawVisibleRect'", nullptr);
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
        cobj->enableDrawVisibleRect(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "enableDrawVisibleRect",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_enableDrawVisibleRect'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVisual_removeUnusedCache(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        cocos2d::AzVisual::removeUnusedCache();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "removeUnusedCache",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_removeUnusedCache'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_anb_AzVisual_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 1)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0);
            if (!ok) { break; }
            cocos2d::AzVisual* ret = cocos2d::AzVisual::create(arg0);
            object_to_luaval<cocos2d::AzVisual>(tolua_S, "cc.AzVisual",(cocos2d::AzVisual*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 0)
        {
            cocos2d::AzVisual* ret = cocos2d::AzVisual::create();
            object_to_luaval<cocos2d::AzVisual>(tolua_S, "cc.AzVisual",(cocos2d::AzVisual*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    CCLOG("%s has wrong number of arguments: %d, was expecting %d", "create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_create'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_anb_AzVisual_removeCache(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cocos2d::AzVisual::removeCache(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "removeCache",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_removeCache'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_anb_AzVisual_removeCacheAll(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.AzVisual",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        cocos2d::AzVisual::removeCacheAll();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "removeCacheAll",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVisual_removeCacheAll'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_anb_AzVisual_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (AzVisual)");
    return 0;
}

int lua_register_cocos2dx_anb_AzVisual(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"cc.AzVisual");
    tolua_cclass(tolua_S,"AzVisual","cc.AzVisual","cc.Node",nullptr);

    tolua_beginmodule(tolua_S,"AzVisual");
        tolua_function(tolua_S,"isRepeat",lua_cocos2dx_anb_AzVisual_isRepeat);
        tolua_function(tolua_S,"enableDrawShapeInfo",lua_cocos2dx_anb_AzVisual_enableDrawShapeInfo);
        tolua_function(tolua_S,"enableDrawSocketInfo",lua_cocos2dx_anb_AzVisual_enableDrawSocketInfo);
        tolua_function(tolua_S,"isEndAnimation",lua_cocos2dx_anb_AzVisual_isEndAnimation);
        tolua_function(tolua_S,"getSocketNode",lua_cocos2dx_anb_AzVisual_getSocketNode);
        tolua_function(tolua_S,"getVisualName",lua_cocos2dx_anb_AzVisual_getVisualName);
        tolua_function(tolua_S,"bindSocket",lua_cocos2dx_anb_AzVisual_bindSocket);
        tolua_function(tolua_S,"setRepeat",lua_cocos2dx_anb_AzVisual_setRepeat);
        tolua_function(tolua_S,"initEventShapeList",lua_cocos2dx_anb_AzVisual_initEventShapeList);
        tolua_function(tolua_S,"buildEventShapeID",lua_cocos2dx_anb_AzVisual_buildEventShapeID);
        tolua_function(tolua_S,"setAdditiveColor",lua_cocos2dx_anb_AzVisual_setAdditiveColor);
        tolua_function(tolua_S,"getVisualGroupName",lua_cocos2dx_anb_AzVisual_getVisualGroupName);
        tolua_function(tolua_S,"setVisual",lua_cocos2dx_anb_AzVisual_setVisual);
        tolua_function(tolua_S,"setSpriteSubstitution",lua_cocos2dx_anb_AzVisual_setSpriteSubstitution);
        tolua_function(tolua_S,"getValidRect",lua_cocos2dx_anb_AzVisual_getValidRect);
        tolua_function(tolua_S,"bindVisual",lua_cocos2dx_anb_AzVisual_bindVisual);
        tolua_function(tolua_S,"getDuration",lua_cocos2dx_anb_AzVisual_getDuration);
        tolua_function(tolua_S,"buildSprite",lua_cocos2dx_anb_AzVisual_buildSprite);
        tolua_function(tolua_S,"releaseSprite",lua_cocos2dx_anb_AzVisual_releaseSprite);
        tolua_function(tolua_S,"buildPhysicBody",lua_cocos2dx_anb_AzVisual_buildPhysicBody);
        tolua_function(tolua_S,"getShapeCount",lua_cocos2dx_anb_AzVisual_getShapeCount);
        tolua_function(tolua_S,"loadPlistFiles",lua_cocos2dx_anb_AzVisual_loadPlistFiles);
        tolua_function(tolua_S,"setFrame",lua_cocos2dx_anb_AzVisual_setFrame);
        tolua_function(tolua_S,"queryEventShape",lua_cocos2dx_anb_AzVisual_queryEventShape);
        tolua_function(tolua_S,"setFile",lua_cocos2dx_anb_AzVisual_setFile);
        tolua_function(tolua_S,"enableDrawVisibleRect",lua_cocos2dx_anb_AzVisual_enableDrawVisibleRect);
        tolua_function(tolua_S,"removeUnusedCache", lua_cocos2dx_anb_AzVisual_removeUnusedCache);
        tolua_function(tolua_S,"create", lua_cocos2dx_anb_AzVisual_create);
        tolua_function(tolua_S,"removeCache", lua_cocos2dx_anb_AzVisual_removeCache);
        tolua_function(tolua_S,"removeCacheAll", lua_cocos2dx_anb_AzVisual_removeCacheAll);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::AzVisual).name();
    g_luaType[typeName] = "cc.AzVisual";
    g_typeCast["AzVisual"] = "cc.AzVisual";
    return 1;
}
int lua_cocos2dx_anb_AzVRP_getTimeScale(lua_State* tolua_S)
{
	int argc = 0;
	cocos2d::AzVRP* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "cc.AzVRP", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getTimeScale'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 0)
	{
		if (!ok)
			return 0;
		float ret = cobj->getTimeScale();
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getTimeScale", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_anb_AzVRP_getTimeScale'.", &tolua_err);
#endif

	return 0;
}
int lua_cocos2dx_anb_AzVRP_setTimeScale(lua_State* tolua_S)
{
	int argc = 0;
	cocos2d::AzVRP* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "cc.AzVRP", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_setTimeScale'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1)
	{
		double arg0;

		ok &= luaval_to_number(tolua_S, 2, &arg0);
		if (!ok)
			return 0;
		cobj->setTimeScale(arg0);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setTimeScale", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_anb_AzVRP_setTimeScale'.", &tolua_err);
#endif

	return 0;
}
int lua_cocos2dx_anb_AzVRP_getSocketPosX(lua_State* tolua_S)
{
	int argc = 0;
	cocos2d::AzVRP* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "cc.AzVRP", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getSocketPosX'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1)
	{
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0);
		if (!ok)
			return 0;
		double ret = cobj->getSocketPosX(arg0);
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getSocketPosX", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_anb_AzVRP_getSocketPosX'.", &tolua_err);
#endif

	return 0;
}
int lua_cocos2dx_anb_AzVRP_getSocketPosY(lua_State* tolua_S)
{
	int argc = 0;
	cocos2d::AzVRP* cobj = nullptr;
	bool ok = true;

#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
	if (!tolua_isusertype(tolua_S, 1, "cc.AzVRP", 0, &tolua_err)) goto tolua_lerror;
#endif

	cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
	if (!cobj)
	{
		tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getSocketPosY'", nullptr);
		return 0;
	}
#endif

	argc = lua_gettop(tolua_S) - 1;
	if (argc == 1)
	{
		std::string arg0;

		ok &= luaval_to_std_string(tolua_S, 2, &arg0);
		if (!ok)
			return 0;
		double ret = cobj->getSocketPosY(arg0);
		tolua_pushnumber(tolua_S, (lua_Number)ret);
		return 1;
	}
	CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getSocketPosY", argc, 1);
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_anb_AzVRP_getSocketPosY'.", &tolua_err);
#endif

	return 0;
}
int lua_cocos2dx_anb_AzVRP_isRepeat(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_isRepeat'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        bool ret = cobj->isRepeat();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "isRepeat",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_isRepeat'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_setSpriteSubstitution(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_setSpriteSubstitution'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        std::string arg0;
        std::string arg1;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);

        ok &= luaval_to_std_string(tolua_S, 3,&arg1);
        if(!ok)
            return 0;
        cobj->setSpriteSubstitution(arg0, arg1);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setSpriteSubstitution",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_setSpriteSubstitution'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_enableDrawShapeInfo(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_enableDrawShapeInfo'", nullptr);
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
        cobj->enableDrawShapeInfo(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "enableDrawShapeInfo",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_enableDrawShapeInfo'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_enableDrawSocketInfo(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_enableDrawSocketInfo'", nullptr);
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
        cobj->enableDrawSocketInfo(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "enableDrawSocketInfo",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_enableDrawSocketInfo'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_unregisterScriptSocketHandler(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_unregisterScriptSocketHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->unregisterScriptSocketHandler();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "unregisterScriptSocketHandler",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_unregisterScriptSocketHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_SetCheckValidRect(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_SetCheckValidRect'", nullptr);
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
        cobj->SetCheckValidRect(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "SetCheckValidRect",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_SetCheckValidRect'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_isEndAnimation(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_isEndAnimation'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        bool ret = cobj->isEndAnimation();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "isEndAnimation",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_isEndAnimation'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getSocketNode(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getSocketNode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cocos2d::Node* ret = cobj->getSocketNode(arg0);
        object_to_luaval<cocos2d::Node>(tolua_S, "cc.Node",(cocos2d::Node*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getSocketNode",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getSocketNode'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getVisualName(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getVisualName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        std::string ret = cobj->getVisualName();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getVisualName",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getVisualName'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getVisualIndex(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getVisualIndex'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->getVisualIndex();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getVisualIndex",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getVisualIndex'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getEventShapeIndex(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getEventShapeIndex'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        int ret = cobj->getEventShapeIndex(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getEventShapeIndex",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getEventShapeIndex'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_setRepeat(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_setRepeat'", nullptr);
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
        cobj->setRepeat(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setRepeat",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_setRepeat'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_Frame(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_Frame'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        double ret = cobj->getCurrentSocketEvent_Frame();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCurrentSocketEvent_Frame",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_Frame'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_initEventShapeList(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_initEventShapeList'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->initEventShapeList();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "initEventShapeList",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_initEventShapeList'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_bindVRP(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_bindVRP'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        std::string arg0;
        cocos2d::AzVRP* arg1;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);

        ok &= luaval_to_object<cocos2d::AzVRP>(tolua_S, 3, "cc.AzVRP",&arg1);
        if(!ok)
            return 0;
        bool ret = cobj->bindVRP(arg0, arg1);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "bindVRP",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_bindVRP'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_buildEventShapeID(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_buildEventShapeID'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        bool ret = cobj->buildEventShapeID(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "buildEventShapeID",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_buildEventShapeID'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_Idx(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_Idx'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->getCurrentSocketEvent_Idx();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCurrentSocketEvent_Idx",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_Idx'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getVisualGroupName(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getVisualGroupName'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        std::string ret = cobj->getVisualGroupName();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getVisualGroupName",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getVisualGroupName'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_setVisual(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;
#if (COCOS2D_DEBUG >= 1 || LUA_DEBUG >= 1)
    tolua_Error tolua_err;
#endif

#if (COCOS2D_DEBUG >= 1 || LUA_DEBUG >= 1)
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif
    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);
#if (COCOS2D_DEBUG >= 1 || LUA_DEBUG >= 1)
    if (!cobj)
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_setVisual'", nullptr);
        return 0;
    }
#endif
    argc = lua_gettop(tolua_S)-1;
    do{
        if (argc == 1) {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0);

            if (!ok) { break; }
            bool ret = cobj->setVisual(arg0);
            tolua_pushboolean(tolua_S,(bool)ret);
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 2) {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0);

            if (!ok) { break; }
            std::string arg1;
            ok &= luaval_to_std_string(tolua_S, 3,&arg1);

            if (!ok) { break; }
            bool ret = cobj->setVisual(arg0, arg1);
            tolua_pushboolean(tolua_S,(bool)ret);
            return 1;
        }
    }while(0);
    ok  = true;
    do{
        if (argc == 1) {
            int arg0;
            ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0);

            if (!ok) { break; }
            bool ret = cobj->setVisual(arg0);
            tolua_pushboolean(tolua_S,(bool)ret);
            return 1;
        }
    }while(0);
    ok  = true;
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setVisual",argc, 1);
    return 0;

#if (COCOS2D_DEBUG >= 1 || LUA_DEBUG >= 1)
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_setVisual'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_registerScriptSocketHandler(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_registerScriptSocketHandler'", nullptr);
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
        cobj->registerScriptSocketHandler(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "registerScriptSocketHandler",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_registerScriptSocketHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_enableSocketHandler(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_enableSocketHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->enableSocketHandler(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "enableSocketHandler",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_enableSocketHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_refIdx(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_refIdx'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        int ret = cobj->getCurrentSocketEvent_refIdx();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCurrentSocketEvent_refIdx",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_refIdx'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getEventShapeName(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getEventShapeName'", nullptr);
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
        const char* ret = cobj->getEventShapeName(arg0);
        tolua_pushstring(tolua_S,(const char*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getEventShapeName",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getEventShapeName'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getValidRect(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getValidRect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cocos2d::Rect ret = cobj->getValidRect();
        rect_to_luaval(tolua_S, ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getValidRect",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getValidRect'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getSocketIndex(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getSocketIndex'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        int ret = cobj->getSocketIndex(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getSocketIndex",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getSocketIndex'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_buildPhysicBody(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_buildPhysicBody'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->buildPhysicBody();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "buildPhysicBody",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_buildPhysicBody'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getDuration(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getDuration'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        double ret = cobj->getDuration();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getDuration",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getDuration'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_buildSprite(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_buildSprite'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->buildSprite(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "buildSprite",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_buildSprite'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_clearSocketHandler(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_clearSocketHandler'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->clearSocketHandler();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "clearSocketHandler",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_clearSocketHandler'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_releaseSprite(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_releaseSprite'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        cobj->releaseSprite();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "releaseSprite",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_releaseSprite'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getVisualListLuaTable(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getVisualListLuaTable'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        std::string ret = cobj->getVisualListLuaTable();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getVisualListLuaTable",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getVisualListLuaTable'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_initWithFile(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_initWithFile'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
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
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_initWithFile'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_loadPlistFiles(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_loadPlistFiles'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        std::string arg0;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cobj->loadPlistFiles(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "loadPlistFiles",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_loadPlistFiles'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_setFrame(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_setFrame'", nullptr);
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
        cobj->setFrame(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setFrame",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_setFrame'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_ID(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_ID'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        const char* ret = cobj->getCurrentSocketEvent_ID();
        tolua_pushstring(tolua_S,(const char*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCurrentSocketEvent_ID",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_ID'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_queryEventShape(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_queryEventShape'", nullptr);
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
        cobj->queryEventShape(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "queryEventShape",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_queryEventShape'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getSocketName(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getSocketName'", nullptr);
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
        const char* ret = cobj->getSocketName(arg0);
        tolua_pushstring(tolua_S,(const char*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getSocketName",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getSocketName'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_TM(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_TM'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
            return 0;
        const cocos2d::Mat4& ret = cobj->getCurrentSocketEvent_TM();
        mat4_to_luaval(tolua_S, ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "getCurrentSocketEvent_TM",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_TM'.",&tolua_err);
#endif

    return 0;
}
int lua_cocos2dx_anb_AzVRP_removeUnusedCache(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        cocos2d::AzVRP::removeUnusedCache();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "removeUnusedCache",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_removeUnusedCache'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_anb_AzVRP_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S)-1;

    do 
    {
        if (argc == 1)
        {
            std::string arg0;
            ok &= luaval_to_std_string(tolua_S, 2,&arg0);
            if (!ok) { break; }
            cocos2d::AzVRP* ret = cocos2d::AzVRP::create(arg0);
            object_to_luaval<cocos2d::AzVRP>(tolua_S, "cc.AzVRP",(cocos2d::AzVRP*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    do 
    {
        if (argc == 0)
        {
            cocos2d::AzVRP* ret = cocos2d::AzVRP::create();
            object_to_luaval<cocos2d::AzVRP>(tolua_S, "cc.AzVRP",(cocos2d::AzVRP*)ret);
            return 1;
        }
    } while (0);
    ok  = true;
    CCLOG("%s has wrong number of arguments: %d, was expecting %d", "create",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_create'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_anb_AzVRP_removeCache(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0);
        if(!ok)
            return 0;
        cocos2d::AzVRP::removeCache(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "removeCache",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_removeCache'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_anb_AzVRP_removeCacheAll(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.AzVRP",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
            return 0;
        cocos2d::AzVRP::removeCacheAll();
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "removeCacheAll",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_AzVRP_removeCacheAll'.",&tolua_err);
#endif
    return 0;
}
int lua_cocos2dx_anb_AzVRP_setCustomShader(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S, 1, "cc.AzVRP", 0, &tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_setCustomShader'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S) - 1;
    if (argc == 2)
    {
        double arg0;

        ok &= luaval_to_number(tolua_S, 2, &arg0);
        if (!ok)
            return 0;

        double arg1;

        ok &= luaval_to_number(tolua_S, 3, &arg1);
        if (!ok)
            return 0;

        cobj->setCustomShader(arg0, arg1);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d \n", "setFrame", argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_anb_AzVRP_setCustomShader'.", &tolua_err);
#endif

    return 0;
}

int lua_cocos2dx_anb_AzVRP_isIgnoreLowEndMode(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S, 1, "cc.AzVRP", 0, &tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_isIgnoreLowEndMode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if (!ok)
            return 0;
        bool ret = cobj->isIgnoreLowEndMode();
        tolua_pushboolean(tolua_S, (bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "isIgnoreLowEndMode", argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_anb_AzVRP_isIgnoreLowEndMode'.", &tolua_err);
#endif
    return 0;
}

int lua_cocos2dx_anb_AzVRP_setIgnoreLowEndMode(lua_State* tolua_S)
{
    int argc = 0;
    cocos2d::AzVRP* cobj = nullptr;
    bool ok = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S, 1, "cc.AzVRP", 0, &tolua_err)) goto tolua_lerror;
#endif

    cobj = (cocos2d::AzVRP*)tolua_tousertype(tolua_S, 1, 0);

#if COCOS2D_DEBUG >= 1
    if (!cobj)
    {
        tolua_error(tolua_S, "invalid 'cobj' in function 'lua_cocos2dx_anb_AzVRP_setIgnoreLowEndMode'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        bool arg0;
        ok &= luaval_to_boolean(tolua_S, 2, &arg0);

        if (!ok)
            return 0;
        cobj->setIgnoreLowEndMode(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "setIgnoreLowEndMode", argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_anb_AzVRP_setIgnoreLowEndMode'.", &tolua_err);
#endif
    return 0;
}

int lua_cocos2dx_anb_AzVRP_isLowEndMode(lua_State* tolua_S)
{
    int argc = 0;
    bool ok = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S, 1, "cc.AzVRP", 0, &tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if (!ok)
            return 0;
        bool ret = cocos2d::AzVRP::isLowEndMode();
        tolua_pushboolean(tolua_S, (bool)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "isLowEndMode", argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_anb_AzVRP_isLowEndMode'.", &tolua_err);
#endif
    return 0;
}

int lua_cocos2dx_anb_AzVRP_setLowEndMode(lua_State* tolua_S)
{
    int argc = 0;
    bool ok = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S, 1, "cc.AzVRP", 0, &tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        bool arg0;
        ok &= luaval_to_boolean(tolua_S, 2, &arg0);

        if (!ok)
            return 0;
        cocos2d::AzVRP::setLowEndMode(arg0);
        return 0;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "setLowEndMode", argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(tolua_S, "#ferror in function 'lua_cocos2dx_anb_AzVRP_setLowEndMode'.", &tolua_err);
#endif
    return 0;
}

static int lua_cocos2dx_anb_AzVRP_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (AzVRP)");
    return 0;
}

int lua_register_cocos2dx_anb_AzVRP(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"cc.AzVRP");
    tolua_cclass(tolua_S,"AzVRP","cc.AzVRP","cc.Node",nullptr);

    tolua_beginmodule(tolua_S,"AzVRP");
		tolua_function(tolua_S,"getTimeScale",lua_cocos2dx_anb_AzVRP_getTimeScale);
		tolua_function(tolua_S,"setTimeScale",lua_cocos2dx_anb_AzVRP_setTimeScale);
		tolua_function(tolua_S,"getSocketPosX",lua_cocos2dx_anb_AzVRP_getSocketPosX);
		tolua_function(tolua_S,"getSocketPosY",lua_cocos2dx_anb_AzVRP_getSocketPosY);
        tolua_function(tolua_S,"isRepeat",lua_cocos2dx_anb_AzVRP_isRepeat);
        tolua_function(tolua_S,"setSpriteSubstitution",lua_cocos2dx_anb_AzVRP_setSpriteSubstitution);
        tolua_function(tolua_S,"enableDrawShapeInfo",lua_cocos2dx_anb_AzVRP_enableDrawShapeInfo);
        tolua_function(tolua_S,"enableDrawSocketInfo",lua_cocos2dx_anb_AzVRP_enableDrawSocketInfo);
        tolua_function(tolua_S,"unregisterScriptSocketHandler",lua_cocos2dx_anb_AzVRP_unregisterScriptSocketHandler);
        tolua_function(tolua_S,"SetCheckValidRect",lua_cocos2dx_anb_AzVRP_SetCheckValidRect);
        tolua_function(tolua_S,"isEndAnimation",lua_cocos2dx_anb_AzVRP_isEndAnimation);
        tolua_function(tolua_S,"getSocketNode",lua_cocos2dx_anb_AzVRP_getSocketNode);
        tolua_function(tolua_S,"getVisualName",lua_cocos2dx_anb_AzVRP_getVisualName);
        tolua_function(tolua_S,"getVisualIndex",lua_cocos2dx_anb_AzVRP_getVisualIndex);
        tolua_function(tolua_S,"getEventShapeIndex",lua_cocos2dx_anb_AzVRP_getEventShapeIndex);
        tolua_function(tolua_S,"setRepeat",lua_cocos2dx_anb_AzVRP_setRepeat);
        tolua_function(tolua_S,"getCurrentSocketEvent_Frame",lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_Frame);
        tolua_function(tolua_S,"initEventShapeList",lua_cocos2dx_anb_AzVRP_initEventShapeList);
        tolua_function(tolua_S,"bindVRP",lua_cocos2dx_anb_AzVRP_bindVRP);
        tolua_function(tolua_S,"buildEventShapeID",lua_cocos2dx_anb_AzVRP_buildEventShapeID);
        tolua_function(tolua_S,"getCurrentSocketEvent_Idx",lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_Idx);
        tolua_function(tolua_S,"getVisualGroupName",lua_cocos2dx_anb_AzVRP_getVisualGroupName);
        tolua_function(tolua_S,"setVisual",lua_cocos2dx_anb_AzVRP_setVisual);
        tolua_function(tolua_S,"registerScriptSocketHandler",lua_cocos2dx_anb_AzVRP_registerScriptSocketHandler);
        tolua_function(tolua_S,"enableSocketHandler",lua_cocos2dx_anb_AzVRP_enableSocketHandler);
        tolua_function(tolua_S,"getCurrentSocketEvent_refIdx",lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_refIdx);
        tolua_function(tolua_S,"getEventShapeName",lua_cocos2dx_anb_AzVRP_getEventShapeName);
        tolua_function(tolua_S,"getValidRect",lua_cocos2dx_anb_AzVRP_getValidRect);
        tolua_function(tolua_S,"getSocketIndex",lua_cocos2dx_anb_AzVRP_getSocketIndex);
        tolua_function(tolua_S,"buildPhysicBody",lua_cocos2dx_anb_AzVRP_buildPhysicBody);
        tolua_function(tolua_S,"getDuration",lua_cocos2dx_anb_AzVRP_getDuration);
        tolua_function(tolua_S,"buildSprite",lua_cocos2dx_anb_AzVRP_buildSprite);
        tolua_function(tolua_S,"clearSocketHandler",lua_cocos2dx_anb_AzVRP_clearSocketHandler);
        tolua_function(tolua_S,"releaseSprite",lua_cocos2dx_anb_AzVRP_releaseSprite);
        tolua_function(tolua_S,"getVisualListLuaTable",lua_cocos2dx_anb_AzVRP_getVisualListLuaTable);
        tolua_function(tolua_S,"initWithFile",lua_cocos2dx_anb_AzVRP_initWithFile);
        tolua_function(tolua_S,"loadPlistFiles",lua_cocos2dx_anb_AzVRP_loadPlistFiles);
        tolua_function(tolua_S,"setFrame",lua_cocos2dx_anb_AzVRP_setFrame);
        tolua_function(tolua_S,"getCurrentSocketEvent_ID",lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_ID);
        tolua_function(tolua_S,"queryEventShape",lua_cocos2dx_anb_AzVRP_queryEventShape);
        tolua_function(tolua_S,"getSocketName",lua_cocos2dx_anb_AzVRP_getSocketName);
        tolua_function(tolua_S,"getCurrentSocketEvent_TM",lua_cocos2dx_anb_AzVRP_getCurrentSocketEvent_TM);
        tolua_function(tolua_S,"removeUnusedCache", lua_cocos2dx_anb_AzVRP_removeUnusedCache);
        tolua_function(tolua_S,"create", lua_cocos2dx_anb_AzVRP_create);
        tolua_function(tolua_S,"removeCache", lua_cocos2dx_anb_AzVRP_removeCache);
        tolua_function(tolua_S,"removeCacheAll", lua_cocos2dx_anb_AzVRP_removeCacheAll);
        tolua_function(tolua_S,"setCustomShader", lua_cocos2dx_anb_AzVRP_setCustomShader);
        tolua_function(tolua_S,"isIgnoreLowEndMode", lua_cocos2dx_anb_AzVRP_isIgnoreLowEndMode);
        tolua_function(tolua_S,"setIgnoreLowEndMode", lua_cocos2dx_anb_AzVRP_setIgnoreLowEndMode);
        tolua_function(tolua_S,"isLowEndMode", lua_cocos2dx_anb_AzVRP_isLowEndMode);
        tolua_function(tolua_S,"setLowEndMode", lua_cocos2dx_anb_AzVRP_setLowEndMode);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::AzVRP).name();
    g_luaType[typeName] = "cc.AzVRP";
    g_typeCast["AzVRP"] = "cc.AzVRP";
    return 1;
}

int lua_cocos2dx_anb_MoveBy3D_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.MoveBy3D",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        double arg0;
        cocos2d::Vec3 arg1;
        ok &= luaval_to_number(tolua_S, 2,&arg0);
        ok &= luaval_to_vec3(tolua_S, 3, &arg1);
        if(!ok)
            return 0;
        cocos2d::MoveBy3D* ret = cocos2d::MoveBy3D::create(arg0, arg1);
        object_to_luaval<cocos2d::MoveBy3D>(tolua_S, "cc.MoveBy3D",(cocos2d::MoveBy3D*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_MoveBy3D_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_anb_MoveBy3D_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (MoveBy3D)");
    return 0;
}

int lua_register_cocos2dx_anb_MoveBy3D(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"cc.MoveBy3D");
    tolua_cclass(tolua_S,"MoveBy3D","cc.MoveBy3D","cc.ActionInterval",nullptr);

    tolua_beginmodule(tolua_S,"MoveBy3D");
        tolua_function(tolua_S,"create", lua_cocos2dx_anb_MoveBy3D_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::MoveBy3D).name();
    g_luaType[typeName] = "cc.MoveBy3D";
    g_typeCast["MoveBy3D"] = "cc.MoveBy3D";
    return 1;
}

int lua_cocos2dx_anb_MoveTo3D_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.MoveTo3D",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        double arg0;
        cocos2d::Vec3 arg1;
        ok &= luaval_to_number(tolua_S, 2,&arg0);
        ok &= luaval_to_vec3(tolua_S, 3, &arg1);
        if(!ok)
            return 0;
        cocos2d::MoveTo3D* ret = cocos2d::MoveTo3D::create(arg0, arg1);
        object_to_luaval<cocos2d::MoveTo3D>(tolua_S, "cc.MoveTo3D",(cocos2d::MoveTo3D*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_MoveTo3D_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_anb_MoveTo3D_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (MoveTo3D)");
    return 0;
}

int lua_register_cocos2dx_anb_MoveTo3D(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"cc.MoveTo3D");
    tolua_cclass(tolua_S,"MoveTo3D","cc.MoveTo3D","cc.MoveBy3D",nullptr);

    tolua_beginmodule(tolua_S,"MoveTo3D");
        tolua_function(tolua_S,"create", lua_cocos2dx_anb_MoveTo3D_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::MoveTo3D).name();
    g_luaType[typeName] = "cc.MoveTo3D";
    g_typeCast["MoveTo3D"] = "cc.MoveTo3D";
    return 1;
}

int lua_cocos2dx_anb_MoveToTarget_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.MoveToTarget",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        double arg0;
        const cocos2d::Node* arg1;
        ok &= luaval_to_number(tolua_S, 2,&arg0);
        ok &= luaval_to_object<const cocos2d::Node>(tolua_S, 3, "cc.Node",&arg1);
        if(!ok)
            return 0;
        cocos2d::MoveToTarget* ret = cocos2d::MoveToTarget::create(arg0, arg1);
        object_to_luaval<cocos2d::MoveToTarget>(tolua_S, "cc.MoveToTarget",(cocos2d::MoveToTarget*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_MoveToTarget_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_anb_MoveToTarget_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (MoveToTarget)");
    return 0;
}

int lua_register_cocos2dx_anb_MoveToTarget(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"cc.MoveToTarget");
    tolua_cclass(tolua_S,"MoveToTarget","cc.MoveToTarget","cc.ActionInterval",nullptr);

    tolua_beginmodule(tolua_S,"MoveToTarget");
        tolua_function(tolua_S,"create", lua_cocos2dx_anb_MoveToTarget_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::MoveToTarget).name();
    g_luaType[typeName] = "cc.MoveToTarget";
    g_typeCast["MoveToTarget"] = "cc.MoveToTarget";
    return 1;
}

int lua_cocos2dx_anb_JumpBy3D_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.JumpBy3D",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        double arg0;
        cocos2d::Vec3 arg1;
        double arg2;
        int arg3;
        ok &= luaval_to_number(tolua_S, 2,&arg0);
        ok &= luaval_to_vec3(tolua_S, 3, &arg1);
        ok &= luaval_to_number(tolua_S, 4,&arg2);
        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3);
        if(!ok)
            return 0;
        cocos2d::JumpBy3D* ret = cocos2d::JumpBy3D::create(arg0, arg1, arg2, arg3);
        object_to_luaval<cocos2d::JumpBy3D>(tolua_S, "cc.JumpBy3D",(cocos2d::JumpBy3D*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_JumpBy3D_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_anb_JumpBy3D_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (JumpBy3D)");
    return 0;
}

int lua_register_cocos2dx_anb_JumpBy3D(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"cc.JumpBy3D");
    tolua_cclass(tolua_S,"JumpBy3D","cc.JumpBy3D","cc.ActionInterval",nullptr);

    tolua_beginmodule(tolua_S,"JumpBy3D");
        tolua_function(tolua_S,"create", lua_cocos2dx_anb_JumpBy3D_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::JumpBy3D).name();
    g_luaType[typeName] = "cc.JumpBy3D";
    g_typeCast["JumpBy3D"] = "cc.JumpBy3D";
    return 1;
}

int lua_cocos2dx_anb_JumpTo3D_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.JumpTo3D",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        double arg0;
        cocos2d::Vec3 arg1;
        double arg2;
        int arg3;
        ok &= luaval_to_number(tolua_S, 2,&arg0);
        ok &= luaval_to_vec3(tolua_S, 3, &arg1);
        ok &= luaval_to_number(tolua_S, 4,&arg2);
        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3);
        if(!ok)
            return 0;
        cocos2d::JumpTo3D* ret = cocos2d::JumpTo3D::create(arg0, arg1, arg2, arg3);
        object_to_luaval<cocos2d::JumpTo3D>(tolua_S, "cc.JumpTo3D",(cocos2d::JumpTo3D*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_JumpTo3D_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_anb_JumpTo3D_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (JumpTo3D)");
    return 0;
}

int lua_register_cocos2dx_anb_JumpTo3D(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"cc.JumpTo3D");
    tolua_cclass(tolua_S,"JumpTo3D","cc.JumpTo3D","cc.JumpBy3D",nullptr);

    tolua_beginmodule(tolua_S,"JumpTo3D");
        tolua_function(tolua_S,"create", lua_cocos2dx_anb_JumpTo3D_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::JumpTo3D).name();
    g_luaType[typeName] = "cc.JumpTo3D";
    g_typeCast["JumpTo3D"] = "cc.JumpTo3D";
    return 1;
}

int lua_cocos2dx_anb_BezierBy3D_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.BezierBy3D",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        double arg0;
        cocos2d::_ccBezier3DConfig arg1;
        ok &= luaval_to_number(tolua_S, 2,&arg0);
        #pragma warning NO CONVERSION TO NATIVE FOR _ccBezier3DConfig;
        if(!ok)
            return 0;
        cocos2d::BezierBy3D* ret = cocos2d::BezierBy3D::create(arg0, arg1);
        object_to_luaval<cocos2d::BezierBy3D>(tolua_S, "cc.BezierBy3D",(cocos2d::BezierBy3D*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_BezierBy3D_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_anb_BezierBy3D_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (BezierBy3D)");
    return 0;
}

int lua_register_cocos2dx_anb_BezierBy3D(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"cc.BezierBy3D");
    tolua_cclass(tolua_S,"BezierBy3D","cc.BezierBy3D","cc.ActionInterval",nullptr);

    tolua_beginmodule(tolua_S,"BezierBy3D");
        tolua_function(tolua_S,"create", lua_cocos2dx_anb_BezierBy3D_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::BezierBy3D).name();
    g_luaType[typeName] = "cc.BezierBy3D";
    g_typeCast["BezierBy3D"] = "cc.BezierBy3D";
    return 1;
}

int lua_cocos2dx_anb_BezierTo3D_create(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"cc.BezierTo3D",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        double arg0;
        cocos2d::_ccBezier3DConfig arg1;
        ok &= luaval_to_number(tolua_S, 2,&arg0);
        #pragma warning NO CONVERSION TO NATIVE FOR _ccBezier3DConfig;
        if(!ok)
            return 0;
        cocos2d::BezierTo3D* ret = cocos2d::BezierTo3D::create(arg0, arg1);
        object_to_luaval<cocos2d::BezierTo3D>(tolua_S, "cc.BezierTo3D",(cocos2d::BezierTo3D*)ret);
        return 1;
    }
    CCLOG("%s has wrong number of arguments: %d, was expecting %d\n ", "create",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_cocos2dx_anb_BezierTo3D_create'.",&tolua_err);
#endif
    return 0;
}
static int lua_cocos2dx_anb_BezierTo3D_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (BezierTo3D)");
    return 0;
}

int lua_register_cocos2dx_anb_BezierTo3D(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"cc.BezierTo3D");
    tolua_cclass(tolua_S,"BezierTo3D","cc.BezierTo3D","cc.BezierBy3D",nullptr);

    tolua_beginmodule(tolua_S,"BezierTo3D");
        tolua_function(tolua_S,"create", lua_cocos2dx_anb_BezierTo3D_create);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(cocos2d::BezierTo3D).name();
    g_luaType[typeName] = "cc.BezierTo3D";
    g_typeCast["BezierTo3D"] = "cc.BezierTo3D";
    return 1;
}
TOLUA_API int register_all_cocos2dx_anb(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"cc",0);
	tolua_beginmodule(tolua_S,"cc");

	lua_register_cocos2dx_anb_MoveBy3D(tolua_S);
	lua_register_cocos2dx_anb_AzVisual(tolua_S);
	lua_register_cocos2dx_anb_MoveToTarget(tolua_S);
	lua_register_cocos2dx_anb_JumpBy3D(tolua_S);
	lua_register_cocos2dx_anb_JumpTo3D(tolua_S);
	lua_register_cocos2dx_anb_BezierBy3D(tolua_S);
	lua_register_cocos2dx_anb_BezierTo3D(tolua_S);
	lua_register_cocos2dx_anb_MoveTo3D(tolua_S);
	lua_register_cocos2dx_anb_AzVRP(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

