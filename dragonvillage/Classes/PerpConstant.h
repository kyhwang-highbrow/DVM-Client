#ifndef __LOGIN_PLATFORM_H__
#define __LOGIN_PLATFORM_H__


#define APP_NAME "DragonVillageM"
#define ENTRY_LUA "entry_patch.lua"

// ���� Ÿ��
#define BUILD_TYPE_TEST 0
#define BUILD_TYPE_QA 1
#define BUILD_TYPE_LIVE 101

#define BUILD_TARGET_TYPE BUILD_TYPE_TEST

// ���� �� ä�� ���� url
#if (BUILD_TARGET_TYPE == BUILD_TYPE_LIVE)
#define TARGET_SERVER "LIVE"

#elif (BUILD_TARGET_TYPE == BUILD_TYPE_QA)
#define TARGET_SERVER "QA"

#elif (BUILD_TARGET_TYPE == BUILD_TYPE_TEST)
#define TARGET_SERVER "TEST"

#endif

// �÷����� ó��
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#define USE_PATCH false
#define USE_LUA_EXT true

#else
#define USE_PATCH true
#define USE_LUA_EXT false

#endif

#ifndef USE_OBB
    #define USE_OBB false
#endif

#ifndef IS_TEST_MODE
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
        #define IS_TEST_MODE true
    #else
        #define IS_TEST_MODE false
    #endif
#endif


#endif