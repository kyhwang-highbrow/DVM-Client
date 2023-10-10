#ifndef __APP_DELEGATE_H__
#define __APP_DELEGATE_H__

#include "cocos2d.h"
#include "CCApplication.h"
#include "PerpConstant.h"

class ReloadLuaHelper : public cocos2d::Scene
{
public:
	enum EEntryLua
	{
		ENTRY_PATCH = 0,
		ENTRY_TITLE,
	};

    static ReloadLuaHelper *create(EEntryLua eEntryLua);
    void purgeEngine();

	ReloadLuaHelper(EEntryLua eEntryLua) : m_eEntryLua(eEntryLua) {}
	virtual ~ReloadLuaHelper() {}

    virtual void onEnter();
    void run();
    
	EEntryLua m_eEntryLua;
};

/**
@brief  The cocos2d Application

The reason for implement as private inheritance is to hide some interface call by Director.
*/
class AppDelegate : private cocos2d::Application
{
public:
    AppDelegate();
    virtual ~AppDelegate();

    /**
    @brief  Implement Director and Scene init code here.
    @return true    Initialize success, app continue.
    @return false   Initialize failed, app terminate.
    */
    virtual bool applicationDidFinishLaunching();

    /**
    @brief  The function be called when the application enter background.
    @param  The pointer of the application
    */
    virtual void applicationDidEnterBackground();

    /**
    @brief  The function be called when the application enter foreground.
    @param  The pointer of the application
    */
    virtual void applicationWillEnterForeground();

    virtual void configChange() {}

	void initLuaEngine();
	bool startLuaScript(const char* filename);
	void setPathForPatch();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
	void onKeyPressed(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event);
	void onKeyReleased(cocos2d::EventKeyboard::KeyCode keyCode, cocos2d::Event* event);
#endif

    void sdkEventHandler(const char *id, const char *result, const char *info);

    void reloadLuaModule();
};

#endif // __APP_DELEGATE_H__
