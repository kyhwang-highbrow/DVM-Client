#include "json/document.h"
#include "json/filestream.h"
#include "json/stringbuffer.h"
#include "json/writer.h"
#include "ConfigParser.h"

#include <iostream>
#include <fstream>

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
    string fileContent, line;
	int width, height;

	ifstream readFile(filecfg);

	if (readFile.is_open())
	{
		while (getline(readFile, line))
		{
			fileContent += line + "\n";
		}
		readFile.close();
	}

    if (!fileContent.empty())
    {
        _docRootjson.Parse<0>(fileContent.c_str());
       
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

ConfigParser::ConfigParser(void) : _isInit(false), _scale(1), _currScreenSizeIdx(-1)
{
    _viewName = "EngineSample";
}

rapidjson::Document& ConfigParser::getConfigJsonRoot()
{
    return _docRootjson;
}

int ConfigParser::getScreenSizeCount(void)
{
    return (int)_screenSizeArray.size();
}

const SimulatorScreenSize ConfigParser::getScreenSize(int index)
{
    return _screenSizeArray.at(index);
}

const SimulatorScreenSize ConfigParser::getCurrScreenSize()
{
	return getScreenSize(_currScreenSizeIdx);
}

const SimulatorScreenSize ConfigParser::getNextScreenSize()
{
	int cnt = (int)_screenSizeArray.size();

	++_currScreenSizeIdx;
	_currScreenSizeIdx %= cnt;

	return getScreenSize(_currScreenSizeIdx);
}
