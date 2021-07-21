
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#include <string>
#include <vector>

#include "cocos2d.h"
#include "AppDelegate.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#import "AppController.h"
#import "RootViewController.h"
#import "DeviceDetector.h"
#import <AdSupport/ASIdentifierManager.h>
#import "DragonVillage-Swift.h"
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
#import "SimulatorApp.h"
#endif

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
    NSLocale* locale = [NSLocale autoupdatingCurrentLocale];
    NSString* code = locale.languageCode;
    //NSString* language = [locale localizedStringForLanguageCode:code];

    //NSString *lan = [NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    /*
    NSString *lan = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLog(@"language(setted value) : %@", lan);

    NSString *language = [lan lowercaseString];
    if ([language isEqualToString:@"zh-hant"] || [language isEqualToString:@"zh-hk"]) {
        language = @"zh-tw";
    } else if ([language isEqualToString:@"zh-hans"]) {
        language = @"zh-cn";
    }
    NSLog(@"language(returned value) : %@", language);
     */
    NSLog(@"code) : %@", code);

    return [code UTF8String];
}

string getLocale()
{
    NSString *loc = [[NSLocale currentLocale] localeIdentifier];
    NSLog(@"locale : %@", loc);

    return [loc UTF8String];
}

int isWifiConnected()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    return 1;
#else
    return [AppController isWifiConnected];
#endif
}

string getFreeMemory()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    return "0";
#else
    return [[AppController getFreeMemory] UTF8String];
#endif
}

string getAndroidID()
{
    return "";
}

void sdkEventResult(const char *id, const char *result, const char *info)
{
    AppDelegate *pDelegate = (AppDelegate *)Application::getInstance();
    pDelegate->sdkEventHandler(id, result, info);
}

void sdkEvent(const char *id, const char *arg0, const char *arg1)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC)
    if (strcmp(id, "app_deviceInfo") == 0) {
        NSHost *host = [NSHost currentHost];
        NSString *version = [[NSProcessInfo processInfo] operatingSystemVersionString];

        NSDictionary *dict = @{ @"desc":@"MacOs",
                                @"device":@"MacBook",
                                @"name":[host localizedName],
                                @"model":@"",
                                @"localizedModel":@"",
                                @"systemName":@"",
                                @"systemVersion":version };
        NSString *info = [AppController getJSONStringFromNSDictionary:dict];
        sdkEventResult(id, "success", [info UTF8String]);
    } else if (strcmp(id, "clipboard_setText") == 0) {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        [[NSPasteboard generalPasteboard] clearContents];
        [[NSPasteboard generalPasteboard] setString:_arg0 forType:NSStringPboardType];
    } else if (strcmp(id, "app_gotoWeb") == 0) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:arg0]];
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
#else
    if (strcmp(id, "app_restart") == 0) {
        // @todo
    } else if (strcmp(id, "app_terminate") == 0) {
        // do nothing in iOS
    } else if (strcmp(id, "app_alert") == 0) {
        NSArray *params = [[NSString stringWithUTF8String:arg0] componentsSeparatedByString:@";"];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[params objectAtIndex:0]
                                                            message:[params objectAtIndex:1]
                                                           delegate:nil
                                                  cancelButtonTitle:@"확인"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    } else if (strcmp(id, "app_sendMail") == 0) {
        NSArray *params = [[NSString stringWithUTF8String:arg0] componentsSeparatedByString:@";"];
        NSString *recipient = [params objectAtIndex:0];
        NSString *title = [params objectAtIndex:1];
        NSString *body = [params objectAtIndex:2];
        AppController *appController = (AppController *)[[UIApplication sharedApplication] delegate];
        [appController sendMail:recipient title:title body:body];
    } else if (strcmp(id, "app_gotoWeb") == 0) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:arg0]];
        [[UIApplication sharedApplication] openURL:url];
    } else if (strcmp(id, "app_gotoStore") == 0) {
        NSString *appId = [NSString stringWithUTF8String:arg0];
        NSString *marketUrl = [NSString stringWithFormat:@"http://itunes.apple.com/kr/app/id%@?mt=8&uo=4", appId];
        NSURL *url = [NSURL URLWithString:marketUrl];
        [[UIApplication sharedApplication] openURL:url];
    } else if (strcmp(id, "localpush_register") == 0) {
        // no nothing in iOS
    } else if (strcmp(id, "localpush_add") == 0) {
        NSArray *params = [[NSString stringWithUTF8String:arg0] componentsSeparatedByString:@";"];
        NSString *type = [params objectAtIndex:0];
        int sec = [[params objectAtIndex:1] intValue];
        NSString *msg = [params objectAtIndex:2];
        [AppController sendLocalNotification:type withTime:sec withMsg:msg];
    } else if (strcmp(id, "localpush_cancel") == 0) {
        [AppController cancelNotification];
    } else if (strcmp(id, "clipboard_setText") == 0) {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        [[UIPasteboard generalPasteboard] setString:_arg0];
    } else if (strcmp(id, "clipboard_getText") == 0) {
        NSString *text = [[UIPasteboard generalPasteboard] string];
        sdkEventResult(id, "success", [text UTF8String]);
    } else if (strcmp(id, "app_deviceInfo") == 0) {
        NSString *systemName = [UIDevice currentDevice].systemName;
        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
        NSString *device = [DeviceDetector deviceName];
        NSString *desc = [NSString stringWithFormat:@"Apple %@(%@ %@)", device, systemName, systemVersion];
        NSDictionary *dict = @{ @"desc":desc,
                                @"device":device,
                                @"name":[UIDevice currentDevice].name,
                                @"model":[UIDevice currentDevice].model,
                                @"localizedModel":[UIDevice currentDevice].localizedModel,
                                @"systemName":systemName,
                                @"systemVersion":systemVersion };
        NSString *info = [AppController getJSONStringFromNSDictionary:dict];
        sdkEventResult(id, "success", [info UTF8String]);

    // 광고 식별자(IDFA)
    } else if (strcmp(id, "advertising_id") == 0) {
        NSString *advertising_id = @"";
        if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            NSUUID *IDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier];
            advertising_id = [IDFA UUIDString];
        }
        sdkEventResult(id, "success", [advertising_id UTF8String]);
        
    // iOS 14 개인 정보 보호
    } else if (strcmp(id, "request_tracking_authorization") == 0) {
        if (@available(iOS 14, *)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HBAppTrackingTransparency requestTrackingAuthorizationWithHandler:^(NSUInteger status) {
                    NSLog(@"[HB] Tracking Authorization Status : %lu", (unsigned long)status);
                    switch(status)
                    {
                        // notDetermined
                        case 0:
                            sdkEventResult(id, "fail", "notDetermined");
                            break;
                            
                        // restricted
                        case 1:
                            sdkEventResult(id, "fail", "restricted");
                            break;
                            
                        // denied
                        case 2:
                            sdkEventResult(id, "fail", "denied");
                            break;
                            
                        // authorized
                        case 3:
                            sdkEventResult(id, "success", "authorized");
                            break;
                    }
                }];
            });     
        } else {
            sdkEventResult(id, "success", "under iOS 14");
        }
    } else if (strcmp(id, "tracking_authorized") == 0) {
        bool b = [HBAppTrackingTransparency isAuthorized];
        sdkEventResult(id, b ? "success" : "fail", "");
        
    } else if (strcmp(id, "tracking_not_determined") == 0) {
        bool b = [HBAppTrackingTransparency isNotDetermined];
        sdkEventResult(id, b ? "success" : "fail", "");
        
    }
    
#endif
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
