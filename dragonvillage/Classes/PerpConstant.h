#ifndef __LOGIN_PLATFORM_H__
#define __LOGIN_PLATFORM_H__


#define APP_NAME "DragonVillageM"
#define ENTRY_LUA "entry_patch.lua"

// TARGET SERVER�� NDK���� �Ѱ��ش�. ������ 'DEV'�� ����
#ifndef TARGET_SERVER
#define TARGET_SERVER "DEV"
#endif

// �������� ���
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#define USE_PATCH false
#define USE_OBB false
#define USE_LUA_EXT true
#define IS_TEST_MODE true
#endif

// USE_PATCH : ��ġ ��� ����
#ifndef USE_PATCH
#define USE_PATCH true
#endif

// USE_OBB : apk_expansion ��� ����
#ifndef USE_OBB
#define USE_OBB true
#endif

// USE_LUA_EXT : ps ��� lua ��� ����
#ifndef USE_LUA_EXT
#define USE_LUA_EXT false
#endif

// IS_TEST_MODE : test ��� ��� ����
#ifndef IS_TEST_MODE
#define IS_TEST_MODE false
#endif


#endif