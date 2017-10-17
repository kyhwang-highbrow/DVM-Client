#include "AppDelegateTool.h"
#include "CCLuaEngine.h"
#include "ConfigParser.h"

AppDelegateTool::AppDelegateTool()
{
}

AppDelegateTool::~AppDelegateTool()
{
}

void AppDelegateTool::configChange()
{
    ConfigParser::getInstance()->setEntryFile("src_tool/entry_preload_generator.lua");
}