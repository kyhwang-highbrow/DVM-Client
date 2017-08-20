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

typedef vector<SimulatorScreenSize> ScreenSizeArray;

class ConfigParser
{
public:
    static ConfigParser *getInstance(void);
    void readConfig();

    // Predefined screen size.
    int getScreenSizeCount(void);
    cocos2d::Size getInitViewSize();
    rapidjson::Document& getConfigJsonRoot();
    const SimulatorScreenSize getScreenSize(int index);
    const SimulatorScreenSize getNextScreenSize();
    bool isLandscape();
    bool isInit();
    double getScale();
    string getAppVer();

private:
    ConfigParser(void);
    static ConfigParser *s_sharedInstance;
    ScreenSizeArray _screenSizeArray;
    cocos2d::Size _initViewSize;
    bool _isLandscape;
    bool _isInit;
    double _scale;
    int _currScreenSizeIdx;
    string _appVer;

    rapidjson::Document _docRootjson;
};

#endif // __CONFIG_PARSER_H__
