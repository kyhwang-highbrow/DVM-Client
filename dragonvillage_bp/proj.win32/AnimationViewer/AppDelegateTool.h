#ifndef __APP_DELEGATE_TOOL_H__
#define __APP_DELEGATE_TOOL_H__

#include "AppDelegate.h"

class AppDelegateTool : public AppDelegate
{
public:
    AppDelegateTool();
    virtual ~AppDelegateTool();

    virtual void configChange();
};

#endif // __APP_DELEGATE_TOOL_H__
