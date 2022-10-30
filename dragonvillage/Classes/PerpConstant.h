#ifndef __PERP_CONSTANT_H__
#define __PERP_CONSTANT_H__


#define APP_NAME "DragonVillageM"
#define ENTRY_LUA "entry_patch.lua"

// DEFINE FOR GRADLE

//SERVER LIST
#define SERVER_LIVE "LIVE"
#define SERVER_QA "QA"
#define SERVER_DEV "DEV"

//NUMBER
#define NUM_0 "0"
#define NUM_1 "1"
#define NUM_2 "2"
#define NUM_3 "3"
#define NUM_4 "4"
#define NUM_5 "5"
#define NUM_6 "6"
#define NUM_7 "7"
#define NUM_8 "8"
#define NUM_9 "9"

// START
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#define APP_VER 138
#define TARGET_SERVER SERVER_LIVE
#define USE_PATCH true
#define USE_OBB false
#define USE_LUA_EXT false
#define IS_TEST_MODE false
#define IS_CAFE_BAZAAR_BUILD false // cafe baazar 빌드 여부

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#define TARGET_SERVER SERVER_DEV
#define USE_PATCH false
#define USE_OBB false
#define USE_LUA_EXT true
#define IS_TEST_MODE true
#define IS_CAFE_BAZAAR_BUILD false // cafe baazar 빌드 여부

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
#define APP_VER 999
#define TARGET_SERVER SERVER_DEV
#define USE_PATCH false
#define USE_OBB false
#define USE_LUA_EXT true
#define IS_TEST_MODE true
#define IS_CAFE_BAZAAR_BUILD false // cafe baazar 빌드 여부

#endif

// TARGET SERVER는 NDK에서 넘겨준다. 없으면 'DEV'로 설정
#ifndef TARGET_SERVER
#define TARGET_SERVER SERVER_DEV
#endif

// APP_VER : app version, 0이면 config.json의 값을 사용하도록 함.
#ifndef APP_VER
#define APP_VER 0
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

// IS_CAFE_BAZAAR_BUILD : cafe baazar 빌드 여부
// 기본값은 false이고 build.gradle에서 true로 설정
#ifndef IS_CAFE_BAZAAR_BUILD
#define IS_CAFE_BAZAAR_BUILD false
#endif

// LUA_DEBUG
#ifndef LUA_DEBUG
#endif

#endif
