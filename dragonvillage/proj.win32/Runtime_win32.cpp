#include <io.h>
#include <direct.h>
#include <stdio.h>
#include <vector>
#include <string>

#include "cocos2d.h"
#include "../Classes/AppDelegate.h"
#include "../Classes/PerpConstant.h"

using namespace std;
using namespace cocos2d;

string getIPAddress()
{
    WSADATA wsaData;
    char name[155] = { 0 };
    char *ip = nullptr;
    PHOSTENT hostinfo;

    if (WSAStartup(MAKEWORD(2,0), &wsaData) == 0)
    {
        if (gethostname(name, sizeof(name)) == 0)
        {
            if ((hostinfo = gethostbyname(name)) != NULL)
            {
                ip = inet_ntoa(*(struct in_addr *)*hostinfo->h_addr_list);
            }
        }
        WSACleanup();
    }
    return ip;
}

int isInstalled(const char *packagename)
{
	return 0;
}

string getRunningApps()
{
    return "";
}

string getDeviceLanguage()
{
	return "ko";
}

string getLocale()
{
	return "ko_KR";
}

int isWifiConnected()
{
	return 0;
}

string getFreeMemory()
{
    return "";
}

void sdkEvent(const char *id, const char *arg0, const char *arg1)
{
    static int googleplayIsSignedIn = 0;

    AppDelegate *pDelegate = (AppDelegate *)CCApplication::sharedApplication();

	if (strcmp(id, "clipboard_setText") == 0)
	{
        std::string msg(arg0);
        HWND hwnd = GetDesktopWindow();
        OpenClipboard(hwnd);
        EmptyClipboard();
        HGLOBAL hg = GlobalAlloc(GMEM_MOVEABLE, msg.size() + 1);
        if (!hg)
        {
            CloseClipboard();
            return;
        }
        memcpy(GlobalLock(hg), msg.c_str(), msg.size() + 1);
        GlobalUnlock(hg);
        SetClipboardData(CF_TEXT, hg);
        CloseClipboard();
        GlobalFree(hg);
	}
	else if (strcmp(id, "clipboard_getText") == 0)
	{
        std::string ret = "fail";
        std::string info = "";
        HWND hwnd = GetDesktopWindow();
        OpenClipboard(hwnd);
        HANDLE hData = GetClipboardData(CF_TEXT);
        if (hData)
        {
            char* pszText = static_cast<char*>(GlobalLock(hData));
            if (pszText != nullptr)
            {
                ret = "success";
                info = pszText;
                GlobalUnlock(hData);
                CloseClipboard();
            }
        }
        pDelegate->sdkEventHandler(id, ret.c_str(), info.c_str());
	}
    else if (strcmp(id, "app_gotoWeb") == 0)
    {
        ShellExecuteA(NULL, "open", arg0, NULL, NULL, SW_SHOWNORMAL);
    }
    else
    {
        pDelegate->sdkEventHandler(id, "", "");
    }
}
