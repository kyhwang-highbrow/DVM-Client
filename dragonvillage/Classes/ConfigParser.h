#ifndef __CONFIG_PARSER_H__
#define __CONFIG_PARSER_H__

#include <string>
#include <vector>
#include "cocos2d.h"
#include "json/document.h"
using namespace std;
USING_NS_CC;

// ConfigParser

typedef struct _SimulatorScreenSize
{
    string title;
    int width;
    int height;

    _SimulatorScreenSize(const string title_, int width_, int height_)
    {
        title  = title_;
        width  = width_;
        height = height_;
    }
} SimulatorScreenSize;

typedef struct _PPSDKLoginInfo {
	string creator;
	string accountId;
	string nickName;
} PPSDKLoginInfo;

typedef struct _GCSDKLoginInfo {
    string localPlayerID;
    string idfa;
} GCSDKLoginInfo;

typedef vector<SimulatorScreenSize> ScreenSizeArray;

class ConfigParser
{
public:
    static ConfigParser *getInstance(void);
    void readConfig();

    // Predefined screen size.
    int getScreenSizeCount(void);
    cocos2d::Size getInitViewSize();
    string getInitViewName();
    string getEntryFile();
    void setEntryFile(string entiryFile) { _entryfile = entiryFile; }
    rapidjson::Document& getConfigJsonRoot();
    const SimulatorScreenSize getScreenSize(int index);
    const SimulatorScreenSize getNextScreenSize();
    bool isLandscape();
    bool isInit();
    bool isTestMode();
    double getScale();
    bool useIdeDebug();
    bool useDebugConsole();
    bool useLuaExtension();
    bool usePatch();
    const PPSDKLoginInfo getPPSDKLoginInfo();
    const GCSDKLoginInfo getGCSDKLoginInfo();

private:
    ConfigParser(void);
    static ConfigParser *s_sharedInstance;
    ScreenSizeArray _screenSizeArray;
    cocos2d::Size _initViewSize;
    string _viewName;
    string _entryfile;
    bool _isLandscape;
    bool _isInit;
    bool _isTestMode;
    double _scale;
    int _currScreenSizeIdx;
    bool _useIdeDebug;
    bool _useDebugConsole;
    bool _useLuaExtension;
    bool _usePatch;
    PPSDKLoginInfo _ppsdkLoginInfo;
    GCSDKLoginInfo _gcsdkLoginInfo;

    rapidjson::Document _docRootjson;
};

#endif // __CONFIG_PARSER_H__
