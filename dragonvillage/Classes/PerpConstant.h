#ifndef __LOGIN_PLATFORM_H__
#define __LOGIN_PLATFORM_H__


#define APP_NAME "DragonVillageM"
#define APP_VERSION "9.9.9"
#define ENTRY_LUA "entry_patch.lua"

// 빌드 타입
#define BUILD_TYPE_LIVE 1
#define BUILD_TYPE_QA 2
#define BUILD_TYPE_DEV 3

#define BUILD_TARGET_TYPE BUILD_TYPE_DEV

// 서버 및 채팅 서버 url
#if (BUILD_TARGET_TYPE == BUILD_TYPE_LIVE)
#define SERVER_URL "http://dv-test.perplelab.com:9003"

#elif (BUILD_TARGET_TYPE == BUILD_TYPE_QA)
#define SERVER_URL "http://dv-qa.perplelab.com:9003"

#elif (BUILD_TARGET_TYPE == BUILD_TYPE_DEV)
#define SERVER_URL "http://dv-test.perplelab.com:9003"
#define CHAT_SERVER_URL

#endif

// 채팅 서버

// 플랫폼별 처리
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#define USE_IDE_DEBUG false
#define USE_PATCH false
#define USE_OBB false
#define USE_LUA_EXT true
#define IS_TEST_MODE true

#else
#define USE_IDE_DEBUG false
#define USE_PATCH true
#define USE_OBB true
#define USE_LUA_EXT false
#define IS_TEST_MODE false

#endif


#endif