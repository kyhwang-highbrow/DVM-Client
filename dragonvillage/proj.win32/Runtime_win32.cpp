#include <io.h>
#include <direct.h>
#include <stdio.h>
#include <vector>
#include <string>

#include "cocos2d.h"
#include "../Classes/AppDelegate.h"
#include "../Classes/LoginPlatform.h"

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

void send_event_to_app(const char *param1, const char *param2)
{
}

// @google+
void sdkEvent(const char *id, const char *arg0, const char *arg1)
{
    static int googleplayIsSignedIn = 0;

    AppDelegate *pDelegate = (AppDelegate *)CCApplication::sharedApplication();

	if (strcmp(id, "clipboard_setText") == 0)
	{
		pDelegate->sdkEventHandler(id, "true", "");
	}
	else if (strcmp(id, "clipboard_getText") == 0)
	{
		pDelegate->sdkEventHandler(id, "true", "");
	}
#ifdef USE_GOOGLEPLAY
#ifndef GOOGLEPLAY_LOGIN_PATI
    else if (strcmp(id, "googleplay_login") == 0)
    {
		googleplayIsSignedIn = 1;
        pDelegate->sdkEventHandler(id, "success", "{ \"playerId\" : \"1234567890\", \"displayName\" : \"guest\" }");
    }
    else if (strcmp(id, "googleplay_logout") == 0)
    {
		googleplayIsSignedIn = 0;
        pDelegate->sdkEventHandler(id, "true", "");
    }
    else if (strcmp(id, "googleplay_isSignedIn") == 0)
    {
		pDelegate->sdkEventHandler(id, (googleplayIsSignedIn == 1 ? "true" : "false"), "");
    }
#endif
	else if (strcmp(id, "googleplay_checkLogin") == 0)
	{
		pDelegate->sdkEventHandler(id, "true", "");
	}
	else if (strcmp(id, "googleplay_showAchievements") == 0)
	{
		if (googleplayIsSignedIn == 1)
			pDelegate->sdkEventHandler(id, "true", "");
		else
			pDelegate->sdkEventHandler(id, "false", "");
	}
	else if (strcmp(id, "googleplay_showLeaderboards") == 0)
	{
		if (googleplayIsSignedIn == 1)
			pDelegate->sdkEventHandler(id, "true", "");
		else
			pDelegate->sdkEventHandler(id, "false", "");
	}
	else if (strcmp(id, "googleplay_showQuests") == 0)
	{
		if (googleplayIsSignedIn == 1)
			pDelegate->sdkEventHandler(id, "true", "");
		else
			pDelegate->sdkEventHandler(id, "false", "");
	}
	else if (strcmp(id, "googleplay_setAchievements") == 0)
	{
		if (googleplayIsSignedIn == 1)
		{
			int count = atoi(arg1);
			if (count > 0)
			{
				pDelegate->sdkEventHandler(id, "true", "setSteps");
			}
			else if (count == 0)
			{
				pDelegate->sdkEventHandler(id, "true", "unlocked");
			}
		}
		else
			pDelegate->sdkEventHandler(id, "false", "not signedin");
	}
	else if (strcmp(id, "googleplay_setLeaderboards") == 0)
	{
		if (googleplayIsSignedIn == 1)
			pDelegate->sdkEventHandler(id, "true", "");
		else
			pDelegate->sdkEventHandler(id, "false", "not signedin");
	}
	else if (strcmp(id, "googleplay_setEvents") == 0)
	{
		if (googleplayIsSignedIn == 1)
			pDelegate->sdkEventHandler(id, "true", "");
		else
			pDelegate->sdkEventHandler(id, "false", "not signedin");
	}
#endif
#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
	// @ppsdk
	else if (strcmp(id, "ppsdk_login") == 0)
	{
		pDelegate->sdkEventHandler(id, "success", "");
	}
	// @ppsdk
	else if (strcmp(id, "ppsdk_loginAuth") == 0)
	{
		int result = atoi(arg0);
		if (result == 1)
			pDelegate->sdkEventHandler(id, "success", "");
		else
			pDelegate->sdkEventHandler(id, "fail", "");
	}
	// @ppsdk
	else if (strcmp(id, "ppsdk_exchangeGoods") == 0)
	{
	}
	// @ppsdk
	else if (strcmp(id, "ppsdk_showSDKCenter") == 0)
	{
	}
#endif
#if (LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER)
    // @gameCenter
    else if (strcmp(id, "gcsdk_login") == 0)
    {
        pDelegate->sdkEventHandler(id, "success", "");
    }
#endif
    else
    {
        pDelegate->sdkEventHandler(id, "", "");
    }
}
