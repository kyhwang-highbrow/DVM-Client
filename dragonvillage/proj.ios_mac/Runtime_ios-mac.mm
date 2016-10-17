
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

void send_event_to_app(const char *param1, const char *param2)
{
    if (strcmp(param1, "app_terminate") == 0) {
        //do nothing in ios
    }
    else if (strcmp(param1, "goto_web") == 0) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:param2]];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if (strcmp(param1, "alert") == 0) {
        NSArray *params = [[NSString stringWithUTF8String:param2] componentsSeparatedByString:@";"];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[params objectAtIndex:0]
                                                            message:[params objectAtIndex:1]
                                                           delegate:nil
                                                  cancelButtonTitle:@"확인"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    else if (strcmp(param1, "send_email") == 0) {
        //do nothing in ios
    }
    else if (strcmp(param1, "goto_store") == 0) {
        NSString *marketUrl;
        if (param2 && strlen(param2) > 1) {
            marketUrl = [NSString stringWithUTF8String:param2];
        }
        else {
            marketUrl = @"http://itunes.apple.com/kr/app/id721512161?mt=8&uo=4";
        }
        NSURL *url = [NSURL URLWithString:marketUrl];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if (strcmp(param1, "local_noti_add") == 0) {
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        NSArray *params = [[NSString stringWithUTF8String:param2] componentsSeparatedByString:@";"];
        NSString *type = [params objectAtIndex:0];
        int sec = [[params objectAtIndex:1] intValue];
        NSString *msg = [params objectAtIndex:2];
        [appController sendLocalNotification:type withTime:sec withMsg:msg];
    }
    else if (strcmp(param1, "local_noti_cancel") == 0) {
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController cancelNotification];
    }

}

// @google+, @adbrix, @tapjoy, @patisdk, @ppsdk
void sdkEvent(const char *id, const char *arg0, const char *arg1)
{
    if (strcmp(id, "clipboard_setText") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController clipboardSetText:_arg0];
    }
    else if (strcmp(id, "clipboard_getText") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController clipboardGetText:_arg0];
    }
#ifdef USE_BILLING
    // @billing
    else if (strcmp(id, "billing_prepare") == 0)
    {
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController billingPrepare];
    }
    // @billing
    else if (strcmp(id, "billing_request") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController billingRequest:_arg0 param:_arg1];
    }
    // @billing
    else if (strcmp(id, "billing_confirm") == 0)
    {
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController billingConfirm];
    }
#endif
#ifdef USE_GOOGLEPLAY
#ifndef GOOGLEPLAY_LOGIN_PATI
    else if (strcmp(id, "googleplay_setClientID") == 0)
    {
        NSString *cid = [NSString stringWithUTF8String:arg0];
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController gpgSetClientID:cid];
    }
    else if (strcmp(id, "googleplay_login") == 0)
    {
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController gpgSignIn];
    }
    else if (strcmp(id, "googleplay_logout") == 0)
    {
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController gpgSignOut];
    }
    else if (strcmp(id, "googleplay_isSignedIn") == 0)
    {
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController gpgIsSignedIn];
    }
#endif
    else if (strcmp(id, "googleplay_checkLogin") == 0)
    {
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController gpgCheckLogin];
    }
    else if (strcmp(id, "googleplay_showAchievements") == 0)
    {
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController gpgShowAchievements];
    }
    else if (strcmp(id, "googleplay_showLeaderboards") == 0)
    {
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController gpgShowLeaderboards];
    }
    else if (strcmp(id, "googleplay_showQuests") == 0)
    {
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController gpgShowQuests];
    }
    else if (strcmp(id, "googleplay_setAchievements") == 0)
    {
        NSString *aid = [NSString stringWithUTF8String:arg0];
        int count = atoi(arg1);
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController gpgSetAchievements:aid count:count];
    }
    else if (strcmp(id, "googleplay_setLeaderboards") == 0)
    {
        NSString *lid = [NSString stringWithUTF8String:arg0];
        int score = atoi(arg1);
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController gpgSetLeaderboards:lid score:score];
    }
    else if (strcmp(id, "googleplay_setEvents") == 0)
    {
        NSString *eid = [NSString stringWithUTF8String:arg0];
        int count = atoi(arg1);
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController gpgSetEvents:eid count:count];
    }
#endif
    else if (strcmp(id, "adbrix_userInfo") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController adbrixUserInfo:_arg0];
    }
    else if (strcmp(id, "adbrix_firstTimeExperience") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController adbrixFirstTimeExperience:_arg0 param:_arg1];
    }
    else if (strcmp(id, "adbrix_retention") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController adbrixRetention:_arg0 param:_arg1];
    }
    else if (strcmp(id, "adbrix_buy") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController adbrixBuy:_arg0 param:_arg1];
    }
    else if (strcmp(id, "adbrix_customCohort") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController adbrixCustomCohort:_arg0 param:_arg1];
    }
    else if (strcmp(id, "5rocks_userInfo") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController fiverocksUserInfo:_arg0];
    }
    else if (strcmp(id, "5rocks_trackEvent") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController fiverocksTrackEvent:_arg0];
    }
    else if (strcmp(id, "5rocks_trackPurchase") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController fiverocksTrackPurchase:_arg0];
    }
    else if (strcmp(id, "5rocks_customCohort") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController fiverocksCustomCohort:_arg0 param:_arg1];
    }
    else if (strcmp(id, "5rocks_appDataVersion") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController fiverocksAppDataVersion:_arg0];
    }
    else if (strcmp(id, "tnk_action") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController tnkAction:_arg0];
    }
    else if (strcmp(id, "tnk_setUserName") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController tnkSetUserName:_arg0];
    }
    else if (strcmp(id, "tnk_prepareInterstitialAd") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController tnkPrepareInterstitialAd:_arg0];
    }
    else if (strcmp(id, "tnk_showInterstitialAd") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        [(RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController tnkShowInterstitialAd:_arg0 param:_arg1];
    }
#ifdef USE_PARTYTRACK
    else if (strcmp(id, "partytrack_payment") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController partytrackPayment:_arg0];
    }
    else if (strcmp(id, "partytrack_event") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController partytrackEvent:_arg0];
    }
#endif
#ifdef USE_MOLOCO
    else if (strcmp(id, "moloco_event") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController molocoEvent:_arg0 param:_arg1];
    }
    else if (strcmp(id, "moloco_spatialEvent") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *appController = (AppController*)[[UIApplication sharedApplication] delegate];
        [appController molocoEventSpatial:_arg0 param:_arg1];
    }
#endif
#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
    // @ppsdk
    else if (strcmp(id, "ppsdk_login") == 0)
    {
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        //RootViewController *controller = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [controller ppsdkLogin];
    }
    // @ppsdk
    else if (strcmp(id, "ppsdk_logout") == 0)
    {
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        //RootViewController *controller = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [controller ppsdkLogout];
    }
    // @ppsdk
    else if (strcmp(id, "ppsdk_loginAuth") == 0)
    {
        NSString *authResult = [NSString stringWithUTF8String:arg0];
        NSString *uid = [NSString stringWithUTF8String:arg1];

        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        //RootViewController *controller = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [controller ppsdkLoginAuth:[authResult intValue] param:uid];
    }
    // @ppsdk
    else if (strcmp(id, "ppsdk_exchangeGoods") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];

        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        //RootViewController *controller = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [controller ppsdkExchangeGoods:_arg0];
    }
    // @ppsdk
    else if (strcmp(id, "ppsdk_showSDKCenter") == 0)
    {
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        //RootViewController *controller = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [controller ppsdkShowSDKCenter];
    }
#endif
#if (LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER)
    // @ppsdk
    else if (strcmp(id, "gcsdk_login") == 0)
    {
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        //RootViewController *controller = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [controller gcsdkLogin];
    }
#endif
#ifdef USE_UMENG
    // @umeng
    else if (strcmp(id, "umeng_beginLogPageView") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengBeginLogPageView:_arg0];
    }
    // @umeng
    else if (strcmp(id, "umeng_endLogPageView") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengEndLogPageView:_arg0];
    }
    // @umeng
    else if (strcmp(id, "umeng_beginEvent") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengBeginEvent:_arg0 param:_arg1];
    }
    // @umeng
    else if (strcmp(id, "umeng_endEvent") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengEndEvent:_arg0 param:_arg1];
    }
    // @umeng
    else if (strcmp(id, "umeng_event") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengEvent:_arg0 param:_arg1];
    }
    // @umeng
    else if (strcmp(id, "umeng_pay") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengPay:_arg0 param:_arg1];
    }
    // @umeng
    else if (strcmp(id, "umeng_buy") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengBuy:_arg0 param:_arg1];
    }
    // @umeng
    else if (strcmp(id, "umeng_use") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengUse:_arg0 param:_arg1];
    }
    // @umeng
    else if (strcmp(id, "umeng_level") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengLevel:_arg0 param:_arg1];
    }
    // @umeng
    else if (strcmp(id, "umeng_bonus") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengBonus:_arg0 param:_arg1];
    }
    // @umeng
    else if (strcmp(id, "umeng_profileSignInWithPUID") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengProfileSignInWithPUID:_arg0 param:_arg1];
    }
    // @umeng
    else if (strcmp(id, "umeng_profileSignOff") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengProfileSignOff:_arg0 param:_arg1];
    }
    // @umeng
    else if (strcmp(id, "umeng_setUserLevelId") == 0)
    {
        NSString *_arg0 = [NSString stringWithUTF8String:arg0];
        NSString *_arg1 = [NSString stringWithUTF8String:arg1];
        AppController *controller = (AppController*)[[UIApplication sharedApplication] delegate];
        [controller umengSetUserLevelId:_arg0 param:_arg1];
    }
#endif
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