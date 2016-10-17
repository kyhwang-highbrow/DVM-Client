#include "json/document.h"
#include "json/filestream.h"
#include "json/stringbuffer.h"
#include "json/writer.h"
#include "ConfigParser.h"

// ConfigParser

ConfigParser *ConfigParser::s_sharedInstance = NULL;

ConfigParser *ConfigParser::getInstance(void)
{
    if (!s_sharedInstance)
    {
        s_sharedInstance = new ConfigParser();
    }
    return s_sharedInstance;
}

bool ConfigParser::isInit()
{
    return _isInit;
}

void ConfigParser::readConfig()
{
    _isInit = true;
    string filecfg = "config.json";

    string fileContent;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID && !defined(NDEBUG)) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS && defined(COCOS2D_DEBUG))
    string fullPathFile = FileUtils::getInstance()->getWritablePath();
    fullPathFile.append("debugruntime/");
    fullPathFile.append(filecfg.c_str());
    fileContent=FileUtils::getInstance()->getStringFromFile(fullPathFile.c_str());
#endif

    if (fileContent.empty())
    {
        filecfg=FileUtils::getInstance()->fullPathForFilename(filecfg.c_str());
        fileContent=FileUtils::getInstance()->getStringFromFile(filecfg.c_str());
    }

    if (!fileContent.empty())
    {
        _docRootjson.Parse<0>(fileContent.c_str());
        if (_docRootjson.HasMember("init_cfg"))
        {
            if (_docRootjson["init_cfg"].IsObject())
            {
                const rapidjson::Value &objectInitView = _docRootjson["init_cfg"];
                if (objectInitView.HasMember("width") && objectInitView.HasMember("height"))
                {
                    _initViewSize.width = objectInitView["width"].GetUint();
                    _initViewSize.height = objectInitView["height"].GetUint();
                    if (_initViewSize.height>_initViewSize.width)
                    {
                        float tmpvalue =_initViewSize.height;
                        _initViewSize.height = _initViewSize.width;
                         _initViewSize.width = tmpvalue;
                    }
                }
                if (objectInitView.HasMember("name") && objectInitView["name"].IsString())
                {
                    _viewName = objectInitView["name"].GetString();
                }
                if (objectInitView.HasMember("isLandscape") && objectInitView["isLandscape"].IsBool())
                {
                    _isLandscape = objectInitView["isLandscape"].GetBool();
                }
                if (objectInitView.HasMember("entry") && objectInitView["entry"].IsString())
                {
                    _entryfile = objectInitView["entry"].GetString();
                }
                if (objectInitView.HasMember("isTestMode") && objectInitView["isTestMode"].IsBool())
                {
                    _isTestMode = objectInitView["isTestMode"].GetBool();
                }
				if (objectInitView.HasMember("scale") && objectInitView["scale"].GetDouble())
                {
					_scale = objectInitView["scale"].GetDouble();
				}
				if (objectInitView.HasMember("useIdeDebug") && objectInitView["useIdeDebug"].IsBool())
                {
					_useIdeDebug = objectInitView["useIdeDebug"].GetBool();
				}
				if (objectInitView.HasMember("useDebugConsole") && objectInitView["useDebugConsole"].IsBool())
                {
					_useDebugConsole = objectInitView["useDebugConsole"].GetBool();
				}
                if (objectInitView.HasMember("useLuaExtension") && objectInitView["useLuaExtension"].GetBool())
                {
                    _useLuaExtension = objectInitView["useLuaExtension"].GetBool();
                }
                if (objectInitView.HasMember("usePatch") && objectInitView["usePatch"].GetBool())
                {
                    _usePatch = objectInitView["usePatch"].GetBool();
                }
                if (objectInitView.HasMember("appVer") && objectInitView["appVer"].IsString())
                {
                    _appVer = objectInitView["appVer"].GetString();
                }
            }
        }
		if (_docRootjson.HasMember("ppsdk_login"))
		{
			if (_docRootjson["ppsdk_login"].IsObject())
			{
				const rapidjson::Value& object = _docRootjson["ppsdk_login"];
				if (object.HasMember("creator"))
				{
					_ppsdkLoginInfo.creator = object["creator"].GetString();
				}
				if (object.HasMember("accountId"))
				{
					_ppsdkLoginInfo.accountId = object["accountId"].GetString();
				}
				if (object.HasMember("nickName"))
				{
					_ppsdkLoginInfo.nickName = object["nickName"].GetString();
				}
			}
		}
        if (_docRootjson.HasMember("gcsdk_login"))
        {
            if (_docRootjson["gcsdk_login"].IsObject())
            {
                const rapidjson::Value& object = _docRootjson["gcsdk_login"];
                if (object.HasMember("localPlayerID"))
                {
                    _gcsdkLoginInfo.localPlayerID = object["localPlayerID"].GetString();
                }
                if (object.HasMember("idfa"))
                {
                    _gcsdkLoginInfo.idfa = object["idfa"].GetString();
                }
            }
        }
        if (_docRootjson.HasMember("simulator_screen_size"))
        {
            const rapidjson::Value &ArrayScreenSize = _docRootjson["simulator_screen_size"];
            if (ArrayScreenSize.IsArray())
            {
                for (int i = 0; i < ArrayScreenSize.Size(); i++)
                {
                    const rapidjson::Value &objectScreenSize = ArrayScreenSize[i];
                    if (objectScreenSize.HasMember("title") && objectScreenSize.HasMember("width") && objectScreenSize.HasMember("height"))
                    {
                        _screenSizeArray.push_back(SimulatorScreenSize(objectScreenSize["title"].GetString(), objectScreenSize["width"].GetUint(), objectScreenSize["height"].GetUint()));
                    }
                }
            }
        }
    }
}

ConfigParser::ConfigParser(void) : _isInit(false), _isLandscape(true), _isTestMode(true), _scale(1), _currScreenSizeIdx(-1), _useIdeDebug(true), _useDebugConsole(true), _useLuaExtension(false), _usePatch(false)
{
    _initViewSize.setSize(960, 640);
    _viewName = "EngineSample";
    _entryfile = "src/main.lua";

	_ppsdkLoginInfo.creator = "";
	_ppsdkLoginInfo.accountId = "";
	_ppsdkLoginInfo.nickName = "";

    _gcsdkLoginInfo.localPlayerID = "";
    _gcsdkLoginInfo.idfa = "";
    _appVer = "0.0.0";
}

rapidjson::Document& ConfigParser::getConfigJsonRoot()
{
    return _docRootjson;
}

string ConfigParser::getInitViewName()
{
    return _viewName;
}

string ConfigParser::getEntryFile()
{
    return _entryfile;
}

Size ConfigParser::getInitViewSize()
{
    return _initViewSize;
}

bool ConfigParser::isLandscape()
{
    return _isLandscape;
}

bool ConfigParser::isTestMode()
{
    return _isTestMode;
}

double ConfigParser::getScale()
{
	return _scale;
}

bool ConfigParser::useIdeDebug()
{
	return _useIdeDebug;
}

bool ConfigParser::useDebugConsole()
{
	return _useDebugConsole;
}

bool ConfigParser::useLuaExtension()
{
    return _useLuaExtension;
}

bool ConfigParser::usePatch()
{
    return _usePatch;
}

int ConfigParser::getScreenSizeCount(void)
{
    return (int)_screenSizeArray.size();
}

const SimulatorScreenSize ConfigParser::getScreenSize(int index)
{
    return _screenSizeArray.at(index);
}

const SimulatorScreenSize ConfigParser::getNextScreenSize()
{
	int cnt = (int)_screenSizeArray.size();

	++_currScreenSizeIdx;
	_currScreenSizeIdx %= cnt;

	return getScreenSize(_currScreenSizeIdx);
}

const PPSDKLoginInfo ConfigParser::getPPSDKLoginInfo()
{
	return _ppsdkLoginInfo;
}

const GCSDKLoginInfo ConfigParser::getGCSDKLoginInfo()
{
    return _gcsdkLoginInfo;
}

string ConfigParser::getAppVer()
{
    return _appVer;
}
