
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#include <string>
#include <vector>

#include "cocos2d.h"
#include "AppDelegate.h"

#import "AppController.h"
#import "RootViewController.h"

using namespace std;
using namespace cocos2d;

string getIPAddress()
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;

    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)]UTF8String];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return "";
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
    //NSString *lan = [NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    NSString *lan = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLog(@"language(setted value) : %@", lan);

    NSString *language = [lan lowercaseString];
    if ([language isEqualToString:@"zh-hant"] || [language isEqualToString:@"zh-hk"]) {
        language = @"zh-tw";
    } else if ([language isEqualToString:@"zh-hans"]) {
        language = @"zh-cn";
    }

    NSLog(@"language(returned value) : %@", language);
    return [language UTF8String];
}

string getLocale()
{
    NSString *loc = [[NSLocale currentLocale] localeIdentifier];
    NSLog(@"locale : %@", loc);

    return [loc UTF8String];
}

int isWifiConnected()
{
    AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
    return [appController isWifiConnected];
}

string getFreeMemory()
{
    AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
    return [[appController getFreeMemory] UTF8String];
}

string getAndroidID()
{
    return "";
}

void sdkEvent(const char *id, const char *arg0, const char *arg1)
{
    if (strcmp(id, "app_terminate") == 0) {
        //do nothing in ios
    }
    else if (strcmp(id, "app_gotoWeb") == 0) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:arg0]];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if (strcmp(id, "app_alert") == 0) {
        NSArray *params = [[NSString stringWithUTF8String:arg0] componentsSeparatedByString:@";"];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[params objectAtIndex:0]
                                                            message:[params objectAtIndex:1]
                                                           delegate:nil
                                                  cancelButtonTitle:@"확인"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    else if (strcmp(id, "app_sendMail") == 0) {
        //do nothing in ios
    }
    else if (strcmp(id, "app_gotoStore") == 0) {
        NSString *marketUrl;
        if (arg0 && strlen(arg0) > 1) {
            marketUrl = [NSString stringWithUTF8String:arg0];
        }
        else {
            marketUrl = @"http://itunes.apple.com/kr/app/id721512161?mt=8&uo=4";
        }
        NSURL *url = [NSURL URLWithString:marketUrl];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if (strcmp(id, "localpush_add") == 0) {
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        NSArray *params = [[NSString stringWithUTF8String:arg0] componentsSeparatedByString:@";"];
        NSString *type = [params objectAtIndex:0];
        int sec = [[params objectAtIndex:1] intValue];
        NSString *msg = [params objectAtIndex:2];
        [appController sendLocalNotification:type withTime:sec withMsg:msg];
    }
    else if (strcmp(id, "localpush_cancel") == 0) {
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController cancelNotification];
    }
    else if (strcmp(id, "clipboard_setText") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController clipboardSetText:_arg0];
    }
    else if (strcmp(id, "clipboard_getText") == 0)
    {
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        NSString *text = [appController clipboardGetText];
        sdkEvent(id, "success", [text UTF8String]);
    }
    else if (strcmp(id, "app_deviceInfo") == 0)
    {
        NSDictionary *dict = @{ @"name":[UIDevice currentDevice].name,
                                @"model":[UIDevice currentDevice].model,
                                @"localizedModel":[UIDevice currentDevice].localizedModel,
                                @"systemName":[UIDevice currentDevice].systemName,
                                @"systemVersion":[UIDevice currentDevice].systemVersion };
        NSString *info = [AppController getJSONStringFromNSDictionary:dict];
        sdkEvent(id, "success", [info UTF8String]);
    }
}

void sdkEventResult(const char *id, const char *result, const char *info)
{
    AppDelegate *pDelegate = (AppDelegate *)CCApplication::getInstance();
    pDelegate->sdkEventHandler(id, result, info);
}

// Fix iOS simulator link error
extern "C"
{
    size_t fwrite$UNIX2003(const void *a, size_t b, size_t c, FILE *d)
    {
        return fwrite(a, b, c, d);
    }

    char *strerror$UNIX2003(int errnum)
    {
        return strerror(errnum);
    }
}
