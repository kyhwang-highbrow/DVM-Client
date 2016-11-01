#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "Runtime.h"
#include "ConfigParser.h"
#include "HttpClient.h"
#include "LoginPlatform.h"

// @patisdk
#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PATISDK)
#include "PatiTypes.h"
#include "PatiPublishSDK.h"
#include "PatiPublishPlatform.h"
#endif

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

ReloadLuaHelper *ReloadLuaHelper::create(EEntryLua eEntryLua)
{
    ReloadLuaHelper *ret = new ReloadLuaHelper(eEntryLua);
    if (ret && ret->init())
    {
        ret->autorelease();
        return ret;
    }
    else
    {
        CC_SAFE_DELETE(ret);
        return nullptr;
    }
}

void ReloadLuaHelper::onEnter()
{
	if (m_eEntryLua == ENTRY_TITLE)
	{
		Size visibleSize = CCDirector::getInstance()->getVisibleSize();
		Vec2 origin = CCDirector::getInstance()->getVisibleOrigin();

        // 타이틀 화면이 PNG에서 A2D(vrp)로 변경되어 교체
        AzVRP* visual = AzVRP::create("res/ui/a2d/title/title.vrp");

        if (visual != NULL)
        {
            visual->loadPlistFiles("");
            visual->buildSprite("");
            visual->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2);
            visual->setVisual("group", "02_scene_replace");
            this->addChild(visual);
        }

        /*
        CCSprite* sprite = CCSprite::create("res/ui/logo/title.png");
        if (sprite != NULL)
        {
            sprite->setPosition(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2);
            this->addChild(sprite);
        }
        */
	}

    // 각종 Cache정리, 사운드 정지
    Director::getInstance()->getScheduler()->unscheduleAllWithMinPriority(Scheduler::PRIORITY_NON_SYSTEM_MIN);
    Director::getInstance()->getTextureCache()->removeAllTextures();
    SpriteFrameCache::getInstance()->removeSpriteFrames();
    SimpleAudioEngine::getInstance()->end();
    AzVRP::removeCacheAll();

    CCFileUtils::getInstance()->purgeCachedEntries();

    // Label Fallback폰트 정리
    cocos2d::Label::resetDefaultFallbackFontTTF();

    AppDelegate* pDelegate = (AppDelegate*)CCApplication::getInstance();
	pDelegate->initLuaEngine();

	switch (m_eEntryLua)
	{
	default:
	case ENTRY_PATCH: pDelegate->startLuaScript("entry_patch.lua"); break;
	case ENTRY_TITLE: pDelegate->startLuaScript("entry_main.lua"); break;
	}
}

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
	// HttpClient 사용시 앱 종료 때 crash나는 cocos2d 자체의 버그로 추가함(jjo)
	network::HttpClient::getInstance()->destroyInstance();
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    FileUtils::getInstance()->addSearchPath("ps");
    FileUtils::getInstance()->addSearchPath("src");
    FileUtils::getInstance()->addSearchPath("res");
    FileUtils::getInstance()->addSearchPath("..");

    if (!ConfigParser::getInstance()->isInit())
    {
        ConfigParser::getInstance()->readConfig();
    }

	setPathForPatch();

#if (COCOS2D_DEBUG>0)
	if (ConfigParser::getInstance()->useIdeDebug())
	{
		initRuntime();
	}
#endif

    // Initialize director.
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    if (!glview)
    {
        Size viewSize = ConfigParser::getInstance()->getInitViewSize();
        string title = ConfigParser::getInstance()->getInitViewName();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
        extern void createSimulator(const char *viewName, float width, float height, bool isLandscape = true, float frameZoomFactor = 1.0f);
        bool isLandscape = ConfigParser::getInstance()->isLandscape();
        createSimulator(title.c_str(), viewSize.width, viewSize.height, isLandscape);
#else
        glview = GLView::createWithRect(title.c_str(), Rect(0,0,viewSize.width,viewSize.height));
        director->setOpenGLView(glview);
#endif
    }

	// iOS와 Android에서는 화면 크기에 따라 640 또는 720으로 화면 넓이 지정함
	glview = director->getOpenGLView();
	Size frameSize = glview->getFrameSize();
	float height = (frameSize.height > frameSize.width) ? frameSize.height : frameSize.width;
	float width = (frameSize.height > frameSize.width) ? frameSize.width : frameSize.height;
	float ratio = height / width;

    float longLength = 0;
    float shortLength = 0;

    // 4:3 1.333
    if (ratio <= 1.41)
    {
        longLength = 1280;
        shortLength = 960;
    }
    // 3:2 1.5
    else if (ratio <= 1.55)
    {
        longLength = 1280;
        shortLength = 854;
    }
    // 16:10 1.6
    else if (ratio <= 1.63)
    {
        longLength = 1280;
        shortLength = 800;
    }
    // 5:3 1.666
    else if (ratio <= 1.7)
    {
        longLength = 1280;
        shortLength = 769;
    }
    // 16:9 1.777
    else
    {
        longLength = 1280;
        shortLength = 720;
    }

    if (ConfigParser::getInstance()->isLandscape() == true)
        Director::getInstance()->getOpenGLView()->setDesignResolutionSize(longLength, shortLength, ResolutionPolicy::EXACT_FIT);
    else
        Director::getInstance()->getOpenGLView()->setDesignResolutionSize(shortLength, longLength, ResolutionPolicy::EXACT_FIT);


#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	Director::getInstance()->getOpenGLView()->setFrameZoomFactor(ConfigParser::getInstance()->getScale());
#endif

    // Turn on display FPS.
    director->setDisplayStats(true);

    // Set FPS. The default value is 1.0/60 if you don't call this.
    director->setAnimationInterval(1.0 / 60);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	auto listener = EventListenerKeyboard::create();
	listener->onKeyPressed = CC_CALLBACK_2(AppDelegate::onKeyPressed, this);
	listener->onKeyReleased = CC_CALLBACK_2(AppDelegate::onKeyReleased, this);
	director->getEventDispatcher()->addEventListenerWithFixedPriority(listener, 1);
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
    /*
	this->receivedEventFromNative("userdefault", "phone_number;01049245635");
	this->receivedEventFromNative("userdefault", "device_type;win32");
	this->receivedEventFromNative("userdefault", getAppVer(true));
	this->receivedEventFromNative("userdefault", "market;GOOG");
	this->receivedEventFromNative("userdefault", "device_name;com");
	this->receivedEventFromNative("userdefault", "os_ver;win7");
    */

// @patisdk
#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PATISDK)
	PatiSDK::Win32::setPreferencesPath(PREFERENCES_PATH_EXECUTABLE_PATH, "");
    #ifdef USE_KAKAO
        PatiSDK::Win32::setEncryptedClientData("9dRs6IhLsf/NksBceLhHLgFy9JWXHvu76jllaQBo2rscyfl1m3Mh6wtoKM0ykYaU2U5QkdA/9wO8rIe1zbaRZw==");
        PatiSDK::Win32::setPackageName("com.perplelab.hod4kakao");
    #else
        PatiSDK::Win32::setEncryptedClientData("9dRs6IhLsf9G5c3V6pK+0gFy9JWXHvu7HMf+6EHL1brT93q3aCA+jBJ4bQZglENq8xKGjaOAkhTa2iqjW1roaQ==");
        PatiSDK::Win32::setPackageName("com.perplelab.hod");
    #endif
    PatiSDK::Win32::setMarketName("GOOG");
    //PatiSDK::Win32::setMarketName("APPL");
    PatiSDK::Win32::setAppRevision("1.0.0");

    if (PatiSDK::initSDK())
    {
#ifdef USE_FACEBOOK
#ifdef FACEBOOK_LOGIN_PATI
        // @facebook
        PatiSDK::initFacebook();
#endif
#endif

#ifdef USE_GOOGLEPLAY
#ifdef GOOGLEPLAY_LOGIN_PATI
		// @google+
		PatiSDK::initGooglePlus();
#endif
#endif

#ifdef USE_KAKAO
#ifdef KAKAO_LOGIN_PATI
		// @kakao, in patisdk
		const char *kakaoClientID = "94330009902599810";
		const char *kakaoClientSecret = "+GY145B5vGkjrTjO3500Mu+5yTzuQtqIj+Ecn3DlmDyCuoYgqhmsY4JXg/7KocEGuEi+2+EPwLWdcwxsnuARag==";
		PatiSDK::initKakao(kakaoClientID, kakaoClientSecret);
#endif
#endif

		bool isTestMode = ConfigParser::getInstance()->isTestMode();
		if (isTestMode)
		{
			PatiSDK::setTestMode();
		}

		PatiSDK::gameLaunched();
    }
#endif

#endif

	initLuaEngine();

    // Register custom function.
    //LuaStack *stack = engine->getLuaStack();
    //register_custom_function(stack->getLuaState());

#if (COCOS2D_DEBUG>0)
	/*
	if (ConfigParser::getInstance()->useIdeDebug())
	{
		if (startRuntime())
			return true;
	}
	*/
#endif

	FileUtils::getInstance()->addSearchPath("ps");
	FileUtils::getInstance()->addSearchPath("src");
	FileUtils::getInstance()->addSearchPath("res");

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	FileUtils::getInstance()->addSearchPath("..");
	FileUtils::getInstance()->addSearchPath("../ps");
	FileUtils::getInstance()->addSearchPath("../src");
	FileUtils::getInstance()->addSearchPath("../res");
#endif

    configChange();
	startLuaScript(ConfigParser::getInstance()->getEntryFile().c_str());

    // 필요한 entry 파일 넣고 빌드
    // startLuaScript("src_tool/entry_ingame_test.lua");

    return true;
}

// This function will be called when the app is inactive. When comes a phone call, it's be invoked too.
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();

    auto engine = ScriptEngineManager::getInstance()->getScriptEngine();
    engine->executeGlobalFunction("applicationDidEnterBackground");
}

// This function will be called when the app is active again.
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();

    auto engine = ScriptEngineManager::getInstance()->getScriptEngine();
    engine->executeGlobalFunction("applicationWillEnterForeground");
}

bool AppDelegate::startLuaScript(const char* filename)
{
	auto engine = ScriptEngineManager::getInstance()->getScriptEngine();
	return engine->executeScriptFile(filename);
}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "glfw3native.h"

// TAB 키를 누르면 resolution을 변경됨
static void updateRelativeNode(Node* node)
{
	if (!node) return;

    node->setRelativeSizeAndType(node->getRelativeSize(), node->getRelativeSizeType(), false);
    node->setUpdateTransform();

	auto& children = node->getChildren();
	for (auto child = children.begin(); child != children.end(); ++child)
	{
		updateRelativeNode(*child);
	}
}

void AppDelegate::onKeyPressed(EventKeyboard::KeyCode keyCode, Event* event)
{
	//log("Key with keycode %d pressed", keyCode);
	if (keyCode == EventKeyboard::KeyCode::KEY_TAB) {
		auto director = Director::getInstance();
		auto glview = director->getOpenGLView();

		const SimulatorScreenSize simulatorScrSize = ConfigParser::getInstance()->getNextScreenSize();
		int width = simulatorScrSize.width;
		int height = simulatorScrSize.height;

		glview->setViewName(simulatorScrSize.title);
		wstring wstr = L"";
		wstr.assign(simulatorScrSize.title.begin(), simulatorScrSize.title.end());

		HWND hWnd = glfwGetWin32Window(glview->getWindow());
		SetWindowText(hWnd, wstr.c_str());

		glview->setFrameSize((float)width, (float)height);
		glview->setDesignResolutionSize((float)width, (float)height, ResolutionPolicy::FIXED_WIDTH);
		log("change resolution to %d,%d", width, height);

		auto engine = ScriptEngineManager::getInstance()->getScriptEngine();
		engine->executeGlobalFunction("applicationDidChangeViewSize");

		updateRelativeNode(director->getRunningScene());
	}
}

void AppDelegate::onKeyReleased(EventKeyboard::KeyCode keyCode, Event* event)
{
	//log("Key with keycode %d released", keyCode);
}

#include <sstream>

std::vector<std::string> &split(const std::string &s, char delim, std::vector<std::string> &elems) {
	std::stringstream ss(s);
	std::string item;
	while (std::getline(ss, item, delim)) {
		elems.push_back(item);
	}
	return elems;
}

std::vector<std::string> split(const std::string &s, char delim) {
	std::vector<std::string> elems;
	return split(s, delim, elems);
}

int AppDelegate::receivedEventFromNative(const char *param1, const char *param2)
{
	if (strcmp(param1, "userdefault") == 0) {
		std::vector<std::string> vParams;
		if (param2) {
			vParams = split(param2, ';');
		}
		if (vParams.empty()) return 0;
		if (vParams.size() == 1) vParams.push_back("none");
        CCUserDefault::getInstance()->setStringForKey(vParams[0].c_str(), vParams[1].c_str());
        CCUserDefault::getInstance()->flush();
	}
	return -1;
}
#endif
