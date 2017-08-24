#ifndef __PERP_CONSTANT_H__
#define __PERP_CONSTANT_H__


#define APP_NAME "DragonVillageM"
#define ENTRY_LUA "entry_patch.lua"

// SERVER LIST
#define SERVER_LIVE "LIVE"
#define SERVER_QA "QA"
#define SERVER_DEV "DEV"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#define TARGET_SERVER SERVER_LIVE
#define USE_OBB false
#endif

// TARGET SERVER는 NDK에서 넘겨준다. 없으면 'DEV'로 설정
#ifndef TARGET_SERVER
#define TARGET_SERVER SERVER_DEV
#endif

// 윈도우인 경우
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#define USE_PATCH false
#define USE_OBB false
#define USE_LUA_EXT true
#define IS_TEST_MODE true
#endif

// USE_PATCH : 패치 사용 여부
#ifndef USE_PATCH
#define USE_PATCH true
#endif

// USE_OBB : apk_expansion 사용 여부
#ifndef USE_OBB
#define USE_OBB true
#endif

// USE_LUA_EXT : ps 대신 lua 사용 여부
#ifndef USE_LUA_EXT
#define USE_LUA_EXT false
#endif

// IS_TEST_MODE : test 기능 사용 여부
#ifndef IS_TEST_MODE
#define IS_TEST_MODE false
#endif


#endif
