#pragma once

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#undef WIN32_LEAN_AND_MEAN
#else
#include <Windows.h>
#endif

class CSObject
{
private:
    CRITICAL_SECTION m_cs;

public:
    CSObject()
    {
        InitializeCriticalSection(&m_cs);
    }

    ~CSObject()
    {
        DeleteCriticalSection(&m_cs);
    }

    void Enter()
    {
        EnterCriticalSection(&m_cs);
    }

    void Leave()
    {
        LeaveCriticalSection(&m_cs);
    }
};

class CSLock
{
public:
    CSLock()
    {
        s_CSObject.Enter();
    }
    ~CSLock()
    {
        s_CSObject.Leave();
    }

private:
    static CSObject s_CSObject;
};
