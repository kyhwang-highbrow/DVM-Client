#ifndef __CONFIG_PARSER_H__
#define __CONFIG_PARSER_H__

# pragma once 

#include <string>
#include <vector>
#include "json/document.h"
using namespace std;

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
	bool isInit();

    // Predefined screen size.
    int getScreenSizeCount(void);
    rapidjson::Document& getConfigJsonRoot();
    const SimulatorScreenSize getScreenSize(int index);
    const SimulatorScreenSize getCurrScreenSize();
	const SimulatorScreenSize getNextScreenSize();

private:
    ConfigParser(void);
    static ConfigParser *s_sharedInstance;
    ScreenSizeArray _screenSizeArray;
    //cocos2d::Size _initViewSize;
    string _viewName;
    double _scale;
	bool _isInit;
    int _currScreenSizeIdx;

    rapidjson::Document _docRootjson;
};

#endif // __CONFIG_PARSER_H__
