/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MessageUI/MessageUI.h>
#import <AVFoundation/AVFoundation.h>

#import "mach/mach.h"
#import "cocos2d.h"

#import "AppController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "CCEAGLView.h"
#import "ConfigParser.h"

// @perplesdk
#define SENDER_ID                   @"983890984134"
#define CLIENT_ID                   @"983890984134-krrfuti1qgk3k09j87gobkq96322v48v.apps.googleusercontent.com"
#define ADBRIX_APP_KEY              @"696293230"
#define ADBRIX_HASH_KEY             @"5c67709eb5c349c6"
#define TAPJOY_SDK_KEY              @"Ws1LafcqRzuuBd763wqDOAEBFg9MYTtlr04omXYpDVNJIVl4ivGW9cK37TA2"
#define UNITY_ADS_GAME_ID           @"1515685"
#define ADCOLONY_APP_ID             @"appe9879f49a31a47448b"
#define ADJUST_TOKKEN_ID            @"esjmkti8vim8"
#define TWITTER_CUSTOMER_KEY        @"VCJ9gb6EjeIQO74rAbUl9B6aj"
#define TWITTER_CUSTOMER_SECRET     @"D0kt613Jye142Efej1DxtvJguItaK5PtgvYyJfY34Pvqs1HCBH"
#define ADMOB_APP_ID                @"ca-app-pub-4135263923809648~6871109304"

// iTunes Connect App ID : 1281873988

// @idfa
#import <AdSupport/ASIdentifierManager.h>
#import "DragonVillage-Swift.h"

extern void sdkEventResult(const char *id, const char *result, const char *info);

@implementation AppController

@class HBAppTrackingTransparency;

#pragma mark - Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;

- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.
    [application setApplicationIconBadgeNumber:0];

    // local notification
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }

    ConfigParser::getInstance()->readConfig();

    // 음악 재생 중 게임 실행 시 음악 중단되지 않도록 함
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

    // Add the view controller's view to the window and display.
    _window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame:[_window bounds]
                                         pixelFormat:kEAGLColorFormatRGBA8
                                         depthFormat:GL_DEPTH24_STENCIL8_OES
                                  preserveBackbuffer:NO
                                          sharegroup:nil
                                       multiSampling:NO
                                     numberOfSamples:0];

    [eaglView setMultipleTouchEnabled:YES];

    // Use RootViewController manage CCEAGLView
    viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    viewController.extendedLayoutIncludesOpaqueBars = YES;
    viewController.view = eaglView;

    // Set RootViewController to window
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0) {
        // Warning: addSubView doesn't work on iOS6.
        [_window addSubview:viewController.view];
    } else {
        // Use this method on iOS6.
        [_window setRootViewController:viewController];
    }

    [_window makeKeyAndVisible];

    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLView::createWithEAGLView(eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);

    // @perplesdk
    NSArray *adjustSecretKey = @[ @1, @562501988, @1877997235, @662395286, @1781468312 ];

    [[PerpleSDK sharedInstance] setMViewController:viewController];

    BOOL isDebug;
#ifdef COCOS2D_DEBUG
    isDebug = (COCOS2D_DEBUG >= 1);
#else
    isDebug = false;
#endif
    
    // Adjust의 Sandbox Mode설정 여부
    // iOS Live빌드일 경우 Sadnbox Mode를 off하기 위해 adjust의 debug를 false로 설정한다.
    // sgkim 20190821
    BOOL isDebugAdjust;
#ifdef TARGET_SERVER
    if (strcmp(TARGET_SERVER, SERVER_LIVE) == 0)
        isDebugAdjust = false;
    else
        isDebugAdjust = isDebug;
#else
    isDebugAdjust = isDebug;
#endif
    

    if ([[PerpleSDK sharedInstance] initSDKWithGcmSenderId:SENDER_ID debug:isDebug]) {
        [[PerpleSDK sharedInstance] initGoogleWithClientId:CLIENT_ID parentView:viewController];
        [[PerpleSDK sharedInstance] initFacebookWithParentView:viewController];
        [[PerpleSDK sharedInstance] initTwitterWithCustomerKey:TWITTER_CUSTOMER_KEY secret:TWITTER_CUSTOMER_SECRET];
        [[PerpleSDK sharedInstance] initGameCenterWithParentView:viewController];
    }
    //[[PerpleSDK sharedInstance] initAdbrixWithAppKey:ADBRIX_APP_KEY hashKey:ADBRIX_HASH_KEY logLevel:0];
    [[PerpleSDK sharedInstance] initTapjoyWithAppKey:TAPJOY_SDK_KEY usePush:NO debug:isDebug];
    [[PerpleSDK sharedInstance] initBilling];
    [[PerpleSDK sharedInstance] initAdjustWithAppKey:ADJUST_TOKKEN_ID secret:adjustSecretKey debug:isDebugAdjust];
    //[[PerpleSDK sharedInstance] initAdMobWithAppId:ADMOB_APP_ID];
    [[PerpleSDK sharedInstance] initAdMobWithParentView:viewController];
    [[PerpleSDK sharedInstance] initAppleWithWindow:_window];
    [[PerpleSDK sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    cocos2d::Application::getInstance()->run();

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    cocos2d::Director::getInstance()->pause();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    cocos2d::Director::getInstance()->resume();

    // @perplesdk
    [[PerpleSDK sharedInstance] applicationDidBecomeActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::Application::getInstance()->applicationDidEnterBackground();

    // @perplesdk
    [[PerpleSDK sharedInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::Application::getInstance()->applicationWillEnterForeground();

    [application setApplicationIconBadgeNumber:0];

    // @perplesdk
    [[PerpleSDK sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // @perplesdk
    [[PerpleSDK sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // @perplesdk
    [[PerpleSDK sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}
#else
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // @perplesdk
    [[PerpleSDK sharedInstance] application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}
#endif

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // @todo, 푸시 관련 에러 처리
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)noti
{
    application.applicationIconBadgeNumber = 0;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // @perplesdk
    return [[PerpleSDK sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}
#else
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    // @perplesdk
    return [[PerpleSDK sharedInstance] application:application openURL:url options:options];
}

#endif

// @send mail
- (void)sendMail:(NSString *)recipient
           title:(NSString *)title
            body:(NSString *)body {
    NSArray *recipients = [NSArray arrayWithObject:recipient];
    NSString *emailTitle = title;
    NSString *messageBody = body;

    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = viewController;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:recipients];

    // Present mail view controller on screen
    [viewController presentViewController:mc animated:YES completion:NULL];
}

// @localpush
+ (void)sendLocalNotification:(NSString *)type withTime:(int)sec withMsg:(NSString *)msg
{
    NSNumber *key = [NSNumber numberWithInt:1];
    UILocalNotification *localNoti = [[[UILocalNotification alloc] init] autorelease];
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:sec];

    localNoti.fireDate = fireDate;
    localNoti.alertBody = msg;
    localNoti.soundName = UILocalNotificationDefaultSoundName;
    localNoti.applicationIconBadgeNumber = 1;
    localNoti.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:key, type, nil];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
}

// @localpush
+ (void)cancelNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

// @wifi
+ (int)isWifiConnected {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "8.8.8.8");
    SCNetworkReachabilityFlags flags;
    BOOL success = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    if (!success) {
        return 0;
    }
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL isNetworkReachable = (isReachable && !needsConnection);

    if (!isNetworkReachable) {
        return 0;
    } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        return 0;
    } else {
        return 1;
    }
}

// @memory info
+ (NSString *)getFreeMemory {
    // @usedMemory
    // struct task_basic_info info;
    // mach_msg_type_number_t size = sizeof(info);
    // kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);

    //NSString *usedMemory = [@(info.resident_size) stringValue];

    // @freeMemory
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;

    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);

    NSString *freeMemory = [@(vm_stat.free_count * pagesize) stringValue];

    // @totalMemory
    NSString *totalMemory = [@([NSProcessInfo processInfo].physicalMemory) stringValue];

    return [NSString stringWithFormat:@"%@;%@", freeMemory, totalMemory];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
     cocos2d::Director::getInstance()->purgeCachedData();
}

- (void)dealloc {

    // @perplesdk
    [[PerpleSDK sharedInstance] dealloc];

    [super dealloc];
}

+ (NSString *)getJSONStringFromNSDictionary:(NSDictionary *)obj {
    if (obj != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:0
                                                         error:&error];
        if (data != nil) {
            NSString *result = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            if (result != nil) {
                return result;
            }
        } else {
            if ([PerpleSDK isDebug]) {
                NSLog(@"Error in getJSONStringFromNSDictionary - %@", error);
            }
        }
    }
    return @"";
}

@end
