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
#import "mach/mach.h"
#import "cocos2d.h"

#import "AppController.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "CCEAGLView.h"
#import "ConfigParser.h"

// @idfa
#import <AdSupport/ASIdentifierManager.h>

#ifdef USE_UMENG
// @umeng
#import "MobClick.h"
#import "MobClickGameAnalytics.h"
#endif

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PATISDK)
// @patisdk
#import "PatiPublishLua.h"
#import "PatiPublishPlatform.h"
#import "PatiPublishSDK.h"
#import "PatiTypes.h"
#elif (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
// @ppsdk
#import <PPAppPlatformKit/PPAppPlatformKit.h>
#elif (LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER)
// @gamecenter
#import <GameKit/GameKit.h>
// @umeng push notification
#import "UMessage.h"
#endif

#ifdef USE_FACEBOOK
// @facebook
#import <FacebookSDK/FacebookSDK.h>
#endif

#ifdef USE_GOOGLEPLAY
// @google+
#import <GooglePlus/GooglePlus.h>
#endif

// @adbrix
//#import <IgaworksCore_v2.2.7in/IgaworksCore.h>
#import <IgaworksCore/IgaworksCore.h>
#import <Adbrix/AdBrix.h>

// @tapjoy
#import <Tapjoy/Tapjoy.h>

// @tnk
#import "tnksdk.h"

#ifdef USE_PARTYTRACK
// @partytrack
#import <Partytrack/Partytrack.h>
#endif

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER)
// @umeng push notification
#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define _IPHONE80_ 80000
#endif

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER)
// @adbrix
#define ADBRIX_APP_ID @"322506897"
#define ADBRIX_APP_KEY @"cd0216102de846bc"
#else
// @adbrix
#define ADBRIX_APP_ID @"55164356"
#define ADBRIX_APP_KEY @"5d28b37c5fd44df6"
#endif

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER)
// @tapjoy
#define TAPJOY_SDK_KEY @"Agcl4BHYQT-sWRyO-RcVbQEBkv4BJLWSdu9toqhhvJxJPfitfPas4EbZCl7G"
#else
// @tapjoy
#define TAPJOY_SDK_KEY @"VPAYGZU4gACgADM6OAAAYwEBdTaS3RbSSgEZbmAl2NIfiLJlGOK7ZyRmhqUl"
#endif

#ifdef USE_PARTYTRACK
// @partytrack
#define PARTYTRACK_APP_ID 4859
#define PARTYTRACK_APP_KEY @"4f960016b7920710f27182a31e370e5d"
#endif

// @tnk
#define TNK_APP_ID @"9070b060-70e1-f4fd-df4f-1e0704070905"

#ifdef USE_KAKAO
// @kakao
#define KAKAO_CLIENT_ID "90632481807591536"
#define KAKAO_CLIENT_SECRET "hh30eul0DagtAqBIiySftf9l6GpMdJcMr611JCqa8fIqunOjW6XdUilKl5yrMRNiYiEuq1rcgbWe8hcqbvTm1Q=="
#endif

#ifdef USE_UMENG
// @umeng
#define UMENG_APPKEY @"559a30f867e58e54cc002738"
#endif

extern void sdkEventResult(const char *id, const char *result, const char *info);

@implementation AppController

#ifdef USE_BILLING
// @billing
@synthesize skuDict;
@synthesize canBilling;
#endif

#ifdef USE_MOLOCO
// @moloco
@synthesize tracer = _tracer;
#endif

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;

#ifdef USE_UMENG
// @umeng
- (void)umengTrack {
    //[MobClick setCrashReportEnabled:NO];                    // 如果不需要捕捉异常，注释掉此行(If you do not catch the exception, comment out this line)
    //[MobClick setLogEnabled:YES];                           // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗(Open the Umeng sdk Pay special attention to the need to comment out this line when Release release, reducing consumption io)
    [MobClick setAppVersion:XcodeAppVersion];               // 参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取(NSString * parameter types, custom app version, if not set, the default CFBundleVersion taken from inside)

    // reportPolicy为枚举类型,可以为 REALTIME,BATCH,SENDDAILY,SENDWIFIONLY几种(reportPolicy as an enumerated type can REALTIME, BATCH, SENDDAILY, SENDWIFIONLY several)
    // channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道(channelId as NSString * type, channelId is nil or @ "", the default will be treated as @ "App Store" channel)
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];

    //[MobClick checkUpdate];                               // 自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数(Automatic update check, if you need to customize the update, please use the following method, you need to receive a (NSDictionary *) appInfo parameters)
    //[MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];

    [MobClick updateOnlineConfig];                          // 在线参数配置(Online parameter configuration)

    // 1.6.8之前的初始化方法(1.6.8 Prior to the initialization method)
    //[MobClick setDelegate:self reportPolicy:REALTIME];    // 建议使用新方法(The new method is recommended)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
}

// @umeng
- (void)onlineConfigCallBack:(NSNotification *)note {
    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}
#endif

- (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.

    [application setApplicationIconBadgeNumber:0];

#ifdef USE_BILLING
    // @billing
    if ([SKPaymentQueue canMakePayments] == NO) {
        self.canBilling = false;
    }
    else {
        self.canBilling = true;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    self.skuDict = [[NSMutableDictionary alloc] init];
#endif

#ifdef USE_UMENG
    // @umeng
    // 友盟的方法本身是异步执行，所以不需要再异步调用(Umeng method itself is executed asynchronously, so no need to asynchronous calls)
    [self umengTrack];
#endif

#ifdef USE_MOLOCO
    // @moloco
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"Moloco", kMLCParamPartnerName,
                            //@"eur", kMLCParamCurrency,
                            //@"1", kMLCParamEnableLogging,
                            nil];
    _tracer = [[MolocoTracker alloc] initWithParams:params];
#endif

    // @adbrix
    [IgaworksCore igaworksCoreWithAppKey:ADBRIX_APP_ID
                              andHashKey:ADBRIX_APP_KEY
            andIsUseIgaworksRewardServer:NO];

    if (NSClassFromString(@"ASIdentifierManager")){
        NSUUID *ifa =[[ASIdentifierManager sharedManager]advertisingIdentifier];
        BOOL isAppleAdvertisingTrackingEnalbed = [[ASIdentifierManager sharedManager]isAdvertisingTrackingEnabled];
        [IgaworksCore setAppleAdvertisingIdentifier:[ifa UUIDString] isAppleAdvertisingTrackingEnabled:isAppleAdvertisingTrackingEnalbed];

        NSLog(@"[ifa UUIDString] %@", [ifa UUIDString]);
    }

    // @tapjoy
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectSuccess:)
                                                 name:TJC_CONNECT_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectFail:)
                                                 name:TJC_CONNECT_FAILED
                                               object:nil];
    //Turn on Tapjoy debug mode
    //Do not set this for any version of the game released to an app store!
    //[Tapjoy setDebugEnabled:YES];
    //The Tapjoy connect call
    [Tapjoy connect:TAPJOY_SDK_KEY];

    // @tapjoy push notification
    [Tapjoy setApplicationLaunchingOptions:launchOptions];

    // @tnk init
    [TnkSession initInstance:TNK_APP_ID];

    // @tnk tracking on/off
    [[TnkSession sharedInstance] setTrackingEnabled:YES];

#ifdef USE_PARTYTRACK
    // @partytrack
    [[Partytrack sharedInstance] startWithAppID:PARTYTRACK_APP_ID AndKey:PARTYTRACK_APP_KEY];
    //[[Partytrack sharedInstance] disableApplicationTracking];
    //[Partytrack openDebugInfo];
#endif

    ConfigParser::getInstance()->readConfig();

    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    CCEAGLView *eaglView = [CCEAGLView viewWithFrame:[window bounds]
                                         pixelFormat:kEAGLColorFormatRGBA8
                                         depthFormat:GL_DEPTH24_STENCIL8_OES
                                  preserveBackbuffer:NO
                                          sharegroup:nil
                                       multiSampling:NO
                                     numberOfSamples:0];

    [eaglView setMultipleTouchEnabled:YES];

    // Use RootViewController manage CCEAGLView
    viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    viewController.wantsFullScreenLayout = YES;
    viewController.view = eaglView;

    // Set RootViewController to window
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0) {
        // Warning: addSubView doesn't work on iOS6.
        [window addSubview:viewController.view];
    } else {
        // Use this method on iOS6.
        [window setRootViewController:viewController];
    }

    [window makeKeyAndVisible];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    // local notification
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }

    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLView::createWithEAGLView(eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PATISDK)
    // @patisdk
    if (PatiSDK::initSDK())
    {
#ifdef USE_FACEBOOK
#ifdef FACEBOOK_LOGIN_PATI
        // @facebook
        PatiSDK::initFacebook();
#endif
#endif

#ifdef USE_GOOGLEPLAY
#ifdef GOOGLEPLAY_LOGIN_PATI
        // @google+
        PatiSDK::initGooglePlus();
#endif
#endif

#ifdef USE_KAKAO
#ifdef KAKAO_LOGIN_PATI
        // @kakao
        PatiSDK::initKakao(KAKAO_CLIENT_ID, KAKAO_CLIENT_SECRET);
#endif
#endif

        BOOL isTestMode = ConfigParser::getInstance()->isTestMode();
#ifdef SHIPPING_BUILD
        isTestMode = FALSE;
#endif
        if (isTestMode) {
            PatiSDK::setTestMode();
        }

        PatiSDK::gameLaunched();
    }
#elif (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
    // @ppsdk
    PPAppPlatformKit *ppKit = [PPAppPlatformKit share];
    [ppKit setupWithDelegate:viewController.manager
                       appId:6353
                      appKey:@"b0fda7997eda8268473b6949ff18f048"];
    // for v1.5.2
    //ppKit.orientationMaskType = PPSDKInterfaceOrientationMaskTypePortrait;
    [ppKit startPPSDK];

#elif LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER
    // @gameCenter
    // @umeng push notification
    //set AppKey and LaunchOptions
    [UMessage startWithAppkey:UMENG_APPKEY launchOptions:launchOptions];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if(UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        // remote notification
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
    } else{
        //register remote notification types
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }
#else
    //register remote notification types
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];

#endif
    //for log
    [UMessage setLogEnabled:YES];
#endif

    cocos2d::Application::getInstance()->run();

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    cocos2d::Director::getInstance()->pause();

    // @tapjoy
    [Tapjoy endSession];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */

#ifdef USE_FACEBOOK
    // @facebook
    [FBAppCall handleDidBecomeActive];
#endif

    cocos2d::Director::getInstance()->resume();

    // @tapjoy
    [Tapjoy startSession];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::Application::getInstance()->applicationDidEnterBackground();

    // @tapjoy
    [Tapjoy endSession];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];

    /*
     Called as part of transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::Application::getInstance()->applicationWillEnterForeground();

    // @tapjoy
    [Tapjoy startSession];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */

    // @tapjoy
    [Tapjoy endSession];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PATISDK)
    // @patisdk
    PatiSDK::iOS::registerPushToken(deviceToken);
#elif (LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER)
    // @umeng push notification
    NSLog(@"umeng push notification to get deviceToken %@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
        stringByReplacingOccurrencesOfString: @">" withString: @""]
        stringByReplacingOccurrencesOfString: @" " withString: @""]);

    [UMessage registerDeviceToken:deviceToken];

#endif

    // @tapjoy push notification
    [Tapjoy setDeviceToken:deviceToken];
}

// @umeng push notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
#if (LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER)
    [UMessage didReceiveRemoteNotification:userInfo];
#endif

    // @tapjoy push notification
    [Tapjoy setReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // @patisdk
    // @todo, 푸시 관련 에러 처리

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER)
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"umeng push notification failed to get deviceToken, error:%@", error_str);
#endif
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)noti
{
    application.applicationIconBadgeNumber = 0;
}

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // @ppsdk
    [[PPAppPlatformKit share] alixPayResult:url];
    return YES;
}
#endif

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PATISDK)
    // @patisdk
    return PatiSDK::iOS::handleOpenURL(url, sourceApplication, annotation);
#elif (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
    // @ppsdk
    [[PPAppPlatformKit share] alixPayResult:url];
    return YES;
#endif
}

- (void)sendLocalNotification:(NSString *)type withTime:(int)sec withMsg:(NSString *)msg
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

- (void)cancelNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#ifdef USE_BILLING
// @billing
- (void)requestProductData:(NSString*)sku withPayload:(NSString*)payload
{
    NSString *ios_sku = [NSString stringWithFormat:@"%@", sku];
    NSSet *productIdentifiers = [NSSet setWithObject:ios_sku];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;

    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObjectsAndKeys:payload, @"payload", sku, @"sku", nil];
    [self.skuDict setObject:info forKey:ios_sku];

    [request start];
}

// @billing
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"InAppPurchase didReceiveResponse");
    for (SKProduct *product in response.products) {
        if (product != nil) {
            NSLog(@"InAppPurchase Product id: %@", product.productIdentifier);
            NSLog(@"InAppPurchase Product title: %@", product.localizedTitle);
            NSLog(@"InAppPurchase Product desc: %@", product.localizedDescription);
            NSLog(@"InAppPurchase Product price: %@", product.price);

            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            break;
        }
    }

    [request release];

    for (NSString *invalidProductId in response.invalidProductIdentifiers) {
        NSLog(@"InAppPurchase Invalid product id: %@", invalidProductId);

        sdkEventResult("billing_request", "fail", "");
    }
}

// @billing
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"InAppPurchase completeTransaction");
    //NSLog(@"InAppPurchase Transaction Identifier: %@", transaction.transactionIdentifier);
    //NSLog(@"InAppPurchase Transaction Date: %@", transaction.transactionDate);

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    //NSLog(@"base64 : %@", [transaction.transactionReceipt base64Encoding]);
    NSDictionary *info = [self.skuDict objectForKey:[transaction.payment productIdentifier]];
    if (info) {
        NSString *payload = [info objectForKey:@"payload"];
        NSString *sku = [info objectForKey:@"sku"];
        if (payload && sku) {
            NSString *result = [NSString stringWithFormat:@"%@;%@;%@;%@"
                                , sku
                                , transaction.transactionIdentifier
                                , payload
                                , [transaction.transactionReceipt base64Encoding]];

            sdkEventResult("billing_request", "success", [result UTF8String]);
        }
    }
}

// @billing
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"InAppPurchase failedTransaction");
    //NSLog(@"InAppPurchase Transaction Identifier: %@", transaction.transactionIdentifier);
    //NSLog(@"InAppPurchase Transaction Date: %@", transaction.transactionDate);

    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"InAppPurchase failedTransaction SKErrorDomain - %d", (int)transaction.error.code);
        sdkEventResult("billing_request", "fail", "");
    }
    else {
        sdkEventResult("billing_request", "cancel", "");
    }

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

// @billing
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"InAppPurchase restoreTransaction");
    //NSLog(@"InAppPurchase Transaction Identifier: %@", transaction.transactionIdentifier);
    //NSLog(@"InAppPurchase Transaction Date: %@", transaction.transactionDate);

    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

// @billing
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"InAppPurchase SKPaymentTransactionStatePurchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStateDeferred:
                NSLog(@"InAppPurchase SKPaymentTransactionStateDeferred");
                break;
        }
    }
}
#endif

// @tapjoy
- (void)tjcConnectSuccess:(NSNotification *)notifyObj
{
    NSLog(@"Tapjoy connect Succeeded");
}

// @tapjoy
- (void)tjcConnectFail:(NSNotification *)notifyObj
{
    NSLog(@"Tapjoy connect Failed");
}

// @adbrix
- (void)adbrixUserInfo:(NSString *)arg0 {
    if (![arg0 isEqualToString:@""]) {
        NSArray *params = [arg0 componentsSeparatedByString:@";"];
        if ([params count] > 0) {
            [IgaworksCore setUserId:[params objectAtIndex:0]];
        }
        if ([params count] > 1) {
            [IgaworksCore setAge:[[params objectAtIndex:1] intValue]];
        }
        if ([params count] > 2) {
            if ([[params objectAtIndex:2] isEqualToString:@"male"]) {
                [IgaworksCore setGender:IgaworksCoreGenderMale];
            } else if ([[params objectAtIndex:2] isEqualToString:@"female"]) {
                [IgaworksCore setGender:IgaworksCoreGenderFemale];
            }
        }
    }
}

// @adbrix
- (void)adbrixFirstTimeExperience:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg1 isEqualToString:@""]) {
      [AdBrix firstTimeExperience:arg0];
    } else {
      [AdBrix firstTimeExperience:arg0 param:arg1];
    }
}

// @adbrix
- (void)adbrixRetention:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg1 isEqualToString:@""]) {
      [AdBrix retention:arg0];
    } else {
      [AdBrix retention:arg0 param:arg1];
    }
}

// @adbrix
- (void)adbrixBuy:(NSString *)arg0 param:(NSString *)arg1; {
    if ([arg1 isEqualToString:@""]) {
      [AdBrix buy:arg0];
    } else {
      [AdBrix buy:arg0 param:arg1];
    }
}

// @adbrix
- (void)adbrixCustomCohort:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg0 isEqualToString:@"COHORT_1"]) {
        [AdBrix setCustomCohort:AdBrixCustomCohort_1 filterName:arg1];
    } else if ([arg0 isEqualToString:@"COHORT_2"]) {
        [AdBrix setCustomCohort:AdBrixCustomCohort_2 filterName:arg1];
    } else if ([arg0 isEqualToString:@"COHORT_3"]) {
        [AdBrix setCustomCohort:AdBrixCustomCohort_3 filterName:arg1];
    }
}

// @tapjoy
- (void)fiverocksUserInfo:(NSString *)arg0 {
    if (![arg0 isEqualToString:@""]) {
        NSArray *params = [arg0 componentsSeparatedByString:@";"];
        if ([params count] > 0) {
            [Tapjoy setUserID:[params objectAtIndex:0]];
        }
        if ([params count] > 1) {
            [Tapjoy setUserLevel:[[params objectAtIndex:1] intValue]];
        }
        if ([params count] > 2) {
            [Tapjoy setUserFriendCount:[[params objectAtIndex:2] intValue]];
        }
    }
}

// @tapjoy
- (void)fiverocksTrackEvent:(NSString *)arg0 {
    if (![arg0 isEqualToString:@""]) {
        NSArray *params = [arg0 componentsSeparatedByString:@";"];
        int paramsCount = (int)[params count];
        if (paramsCount == 4) {
            [Tapjoy trackEvent:[params objectAtIndex:1] category:[params objectAtIndex:0] parameter1:[params objectAtIndex:2] parameter2:[params objectAtIndex:3]];
        } else if (paramsCount == 5) {
            [Tapjoy trackEvent:[params objectAtIndex:1] category:[params objectAtIndex:0] parameter1:[params objectAtIndex:2] parameter2:[params objectAtIndex:3] value:[[params objectAtIndex:4] longLongValue]];
        } else if (paramsCount == 6) {
            NSString *value1name = [params objectAtIndex:4];
            int64_t value1 = [[params objectAtIndex:5] longLongValue];
            [Tapjoy trackEvent:[params objectAtIndex:1] category:[params objectAtIndex:0] parameter1:[params objectAtIndex:2] parameter2:[params objectAtIndex:3] value1name:value1name value1:value1];
        } else if (paramsCount == 8) {
            NSString *value1name = [params objectAtIndex:4];
            int64_t value1 = [[params objectAtIndex:5] longLongValue];
            NSString *value2name = [params objectAtIndex:6];
            int64_t value2 = [[params objectAtIndex:7] longLongValue];
            [Tapjoy trackEvent:[params objectAtIndex:1] category:[params objectAtIndex:0] parameter1:[params objectAtIndex:2] parameter2:[params objectAtIndex:3] value1name:value1name value1:value1 value2name:value2name value2:value2];
        } else if (paramsCount == 10) {
            NSString *value1name = [params objectAtIndex:4];
            int64_t value1 = [[params objectAtIndex:5] longLongValue];
            NSString *value2name = [params objectAtIndex:6];
            int64_t value2 = [[params objectAtIndex:7] longLongValue];
            NSString *value3name = [params objectAtIndex:8];
            int64_t value3 = [[params objectAtIndex:9] longLongValue];
            [Tapjoy trackEvent:[params objectAtIndex:1] category:[params objectAtIndex:0] parameter1:[params objectAtIndex:2] parameter2:[params objectAtIndex:3] value1name:value1name value1:value1 value2name:value2name value2:value2 value3name:value3name value3:value3];
        }
    }
}

// @tapjoy
- (void)fiverocksTrackPurchase:(NSString *)arg0 {
    if (![arg0 isEqualToString:@""]) {
        NSArray *params = [arg0 componentsSeparatedByString:@";"];
        int paramsCount = (int)[params count];
        if (paramsCount == 3) {
            [Tapjoy trackPurchase:[params objectAtIndex:0] currencyCode:[params objectAtIndex:1] price:[[params objectAtIndex:2] doubleValue] campaignId:nil transactionId:nil];
        } else if (paramsCount == 4) {
            [Tapjoy trackPurchase:[params objectAtIndex:0] currencyCode:[params objectAtIndex:1] price:[[params objectAtIndex:2] doubleValue] campaignId:[params objectAtIndex:3] transactionId:nil];
        }
    }
}

// @tapjoy
- (void)fiverocksCustomCohort:(NSString *)arg0 param:(NSString *)arg1 {
    [Tapjoy setUserCohortVariable:[arg0 intValue] value:arg1];
}

// @tapjoy
- (void)fiverocksAppDataVersion:(NSString *)arg0 {
    [Tapjoy setAppDataVersion:arg0];
}

// @tnk
- (void)tnkAction:(NSString *)arg0 {
    [[TnkSession sharedInstance] actionCompleted:arg0];
}

// @tnk
- (void)tnkSetUserName:(NSString *)arg0 {
    [[TnkSession sharedInstance] setUserName:arg0];
}

#ifdef USE_PARTYTRACK
// @partytrack
- (void)partytrackPayment:(NSString *)arg0 {
    if (![arg0 isEqualToString:@""]) {
        NSArray *params = [arg0 componentsSeparatedByString:@";"];
        int paramsCount = (int)[params count];
        if (paramsCount == 3) {
            double price = [[params objectAtIndex:1] doubleValue];
            NSString *currency = [params objectAtIndex:2];
            NSString *name = [params objectAtIndex:0];
            [[Partytrack sharedInstance] sendPaymentWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"item_num",[NSNumber numberWithDouble:price],@"item_price",currency,@"item_price_currency",name,@"item_name", nil]];
        } else if (paramsCount == 4) {
            double price = [[params objectAtIndex:1] doubleValue];
            NSString *currency = [params objectAtIndex:2];
            NSString *name = [params objectAtIndex:0];
            [[Partytrack sharedInstance] sendPaymentWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[params objectAtIndex:3] intValue]],@"item_num",[NSNumber numberWithDouble:price],@"item_price",currency,@"item_price_currency",name,@"item_name", nil]];
        }
    }
}

// @partytrack
- (void)partytrackEvent:(NSString *)arg0 {
    [[Partytrack sharedInstance] sendEventWithID:[arg0 intValue]];
}
#endif

#ifdef USE_MOLOCO
// @moloco
- (void)molocoEvent:(NSString *)arg0 param:(NSString *)arg1 {
    [_tracer trackEvent:arg0 :arg1];
}

// @moloco
- (void)molocoEventSpatial:(NSString *)arg0 param:(NSString *)arg1 {

    NSArray *params0 = [arg0 componentsSeparatedByString:@";"];
    NSString *eventName = [params0 objectAtIndex:0];

    NSArray *params1 = [arg1 componentsSeparatedByString:@";"];
    float x = [[params1 objectAtIndex:0] floatValue];
    float y = [[params1 objectAtIndex:1] floatValue];
    float z = [[params1 objectAtIndex:2] floatValue];

    [_tracer spatialEvent:eventName :x :y :z];
}
#endif

// @clipboard
- (void)clipboardSetText:(NSString *)arg0 {
    [[UIPasteboard generalPasteboard] setString:arg0];
    sdkEventResult("clipboard_setText", "true", "");
}

// @clipboard
- (void)clipboardGetText:(NSString *)arg0 {
    NSString *text = [[UIPasteboard generalPasteboard] string];
    sdkEventResult("clipboard_getText", "true", [text UTF8String]);
}

// @wifi
- (int)isWifiConnected {
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
- (NSString *)getFreeMemory {
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

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
// @ppsdk
- (void)ppsdkLogin {
    NSLog(@"PERP : ppsdkDylibLoaded = %d", viewController.ppsdkDylibLoaded);
    viewController.ppsdkLoginReady = 1;

    if (viewController.ppsdkDylibLoaded == 1) {
        [viewController ppsdkLoginStart];
    }
}

// @ppsdk
- (void)ppsdkLogout {
    [[PPAppPlatformKit share] logout];
}

// @ppsdk
- (void)ppsdkLoginAuth:(int)result param:(NSString *)info {
    // cp必须回调(cp must Callback)
    tokenVerifyingSuccessCallBack block = viewController.blockVerifyingAuthToken;
    if (block) {
        if (result == 1) {
            block(YES);
            viewController.ppsdkUid = info;
            [viewController SDKLoginSuccess];
        } else {
            block(NO);
            viewController.ppsdkUid = info;
            [viewController SDKLoginFail];
        }
    }
    viewController.blockVerifyingAuthToken = nil;
}

// @ppsdk
- (void)ppsdkExchangeGoods:(NSString *)arg0 {
    NSLog(@"PERP : ppsdk_exchangeGoods - param:%@", arg0);

    if (![arg0 isEqualToString:@""]) {
        NSArray *params = [arg0 componentsSeparatedByString:@";"];
        int paramsCount = (int)[params count];
        if (paramsCount == 3) {
            int price = [[params objectAtIndex:0] intValue];
            NSString *billNo = [params objectAtIndex:1];
            NSString *billTitle = [params objectAtIndex:2];

            NSLog(@"PERP : ppsdk try exchangeGoods - price:%d, billNo:%@, billTitle:%@ ...", price, billNo, billTitle);
            [[PPAppPlatformKit share] exchangeGoods:price BillNo:billNo BillTitle:billTitle RoleId:@"0" ZoneId:0];
        } else {
            sdkEventResult("ppsdk_exchangeGoods", "fail", "param count");
        }
    } else {
        sdkEventResult("ppsdk_exchangeGoods", "fail", "empty param");
    }
}

// @ppsdk
- (void)ppsdkShowSDKCenter {
    [[PPAppPlatformKit share] showSDKCenter];
}
#endif

#if LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER
// @gamecenter
- (void)gcsdkLogin {
    // @idfa
    NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];

    // @localPlayer
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    if (localPlayer.isAuthenticated)
    {
        NSString *info = [NSString stringWithFormat:@"%@;%@", localPlayer.playerID, idfaString];
        sdkEventResult("gcsdk_login", "success", [info UTF8String]);
    } else {
        localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
            if (viewController != nil)
            {
                // open game center login window
                UIViewController* pRootViewController = (UIViewController*)[[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
                [pRootViewController presentViewController:viewController animated:YES completion:nil];
            } else if (localPlayer.isAuthenticated) {
                NSString *info = [NSString stringWithFormat:@"%@;%@", localPlayer.playerID, idfaString];
                sdkEventResult("gcsdk_login", "success", [info UTF8String]);
            } else {
                NSString *info = [NSString stringWithFormat:@"%@;%@", localPlayer.playerID, idfaString];
                sdkEventResult("gcsdk_login", "fail", [info UTF8String]);
                NSLog(@"GameCenter error: %@", error);
            }
        };
    }
}
#endif

#ifdef USE_UMENG
// @umeng
- (void)umengBeginLogPageView:(NSString *)arg0 {
    [MobClick beginLogPageView:arg0];
}

// @umeng
- (void)umengEndLogPageView:(NSString *)arg0 {
    [MobClick endLogPageView:arg0];
}

// @umeng
- (void)umengBeginEvent:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg1 isEqualToString:@""]) {
        NSArray *params = [arg0 componentsSeparatedByString:@";"];
        int paramsCount = (int)[params count];
        if (paramsCount == 1) {
            [MobClick beginEvent:[params objectAtIndex:0]];
        } else if (paramsCount == 2) {
            [MobClick beginEvent:[params objectAtIndex:0] label:[params objectAtIndex:1]];
        }
    } else {
        NSArray *params = [arg1 componentsSeparatedByString:@";"];
        NSString *key = [params objectAtIndex:0];
        NSDictionary *attribs = nil;
        [MobClick beginEvent:arg0 primarykey:key attributes:attribs];
    }
}

// @umeng
- (void)umengEndEvent:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg1 isEqualToString:@""]) {
        NSArray *params = [arg0 componentsSeparatedByString:@";"];
        int paramsCount = (int)[params count];
        if (paramsCount == 1) {
            [MobClick endEvent:[params objectAtIndex:0]];
        } else if (paramsCount == 2) {
            [MobClick endEvent:[params objectAtIndex:0] label:[params objectAtIndex:1]];
        }
    } else {
        [MobClick endEvent:arg0 primarykey:arg1];
    }
}

// @umeng
- (void)umengEvent:(NSString *)arg0 param:(NSString *)arg1 {
    NSArray *params = [arg0 componentsSeparatedByString:@";"];
    int paramsCount = (int)[params count];
    if (paramsCount == 1) {
        [MobClick event:[params objectAtIndex:0]];
    } else if (paramsCount == 2) {
        if ([arg1 isEqualToString:@"label"]) {
            [MobClick event:[params objectAtIndex:0] label:[params objectAtIndex:1]];
        } else if ([arg1 isEqualToString:@"acc"]) {
            [MobClick event:[params objectAtIndex:0] acc:[[params objectAtIndex:1] integerValue]];
        } else if ([arg1 isEqualToString:@"attributes"]) {
            NSString *jsonString = [params objectAtIndex:1];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *attribs = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            [MobClick event:[params objectAtIndex:0] attributes:attribs];
        } else if ([arg1 isEqualToString:@"durations"]) {
            [MobClick event:[params objectAtIndex:0] durations:[[params objectAtIndex:1] intValue]];
        }
    } else if (paramsCount == 3) {
        if ([arg1 isEqualToString:@"label_acc"]) {
            [MobClick event:[params objectAtIndex:0] label:[params objectAtIndex:1] acc:[[params objectAtIndex:2] integerValue]];
        } else if ([arg1 isEqualToString:@"label_durations"]) {
            [MobClick event:[params objectAtIndex:0] label:[params objectAtIndex:1] durations:[[params objectAtIndex:2] intValue]];
        } else if ([arg1 isEqualToString:@"attributes_counter"]) {
            NSString *jsonString = [params objectAtIndex:1];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *attribs = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            [MobClick event:[params objectAtIndex:0] attributes:attribs counter:[[params objectAtIndex:2] intValue]];
        } else if ([arg1 isEqualToString:@"attributes_durations"]) {
            NSString *jsonString = [params objectAtIndex:1];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *attribs = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            [MobClick event:[params objectAtIndex:0] attributes:attribs durations:[[params objectAtIndex:2] intValue]];
        }
    }
}

// @umeng
- (void)umengPay:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg0 isEqualToString:@""]) {
        return;
    }

    NSArray *params = [arg0 componentsSeparatedByString:@";"];
    int paramsCount = (int)[params count];

    if (paramsCount == 3) {

        double cash = [[params objectAtIndex:0] doubleValue];
        int source = [[params objectAtIndex:1] intValue];
        double coin = [[params objectAtIndex:2] doubleValue];

        // 充值.
        [MobClickGameAnalytics pay:cash source:source coin:coin];
    } else if (paramsCount == 5) {

        double cash = [[params objectAtIndex:0] doubleValue];
        int source = [[params objectAtIndex:1] intValue];
        NSString *item = [params objectAtIndex:2];
        int amount = [[params objectAtIndex:3] intValue];
        double price = [[params objectAtIndex:4] doubleValue];

        // 充值并购买道具.
        [MobClickGameAnalytics pay:cash source:source item:item amount:amount price:price];
    }
}

// @umeng
- (void)umengBuy:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg0 isEqualToString:@""]) {
        return;
    }

    NSArray *params = [arg0 componentsSeparatedByString:@";"];

    NSString *item = [params objectAtIndex:0];
    int amount = [[params objectAtIndex:1] intValue];
    double price = [[params objectAtIndex:2] doubleValue];

    // 购买道具.
    [MobClickGameAnalytics buy:item amount:amount price:price];
}

// @umeng
- (void)umengUse:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg0 isEqualToString:@""]) {
        return;
    }

    NSArray *params = [arg0 componentsSeparatedByString:@";"];

    NSString *item = [params objectAtIndex:0];
    int amount = [[params objectAtIndex:1] intValue];
    double price = [[params objectAtIndex:2] doubleValue];

    // 使用道具.
    [MobClickGameAnalytics use:item amount:amount price:price];
}

// @umeng
- (void)umengLevel:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg0 isEqualToString:@""]) {
        return;
    }

    if ([arg1 isEqualToString:@"start"]) {
        // 进入关卡.
        [MobClickGameAnalytics startLevel:arg0];
    } else if ([arg1 isEqualToString:@"finish"]) {
        // 通过关卡.
        [MobClickGameAnalytics finishLevel:arg0];
    } else if ([arg1 isEqualToString:@"fail"]) {
        // 未通过关卡.
        [MobClickGameAnalytics failLevel:arg0];
    }
}

// @umeng
- (void)umengBonus:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg0 isEqualToString:@""]) {
        return;
    }

    NSArray *params = [arg0 componentsSeparatedByString:@";"];
    int paramsCount = (int)[params count];

    if (paramsCount == 2) {

        double coin = [[params objectAtIndex:0] doubleValue];
        int source = [[params objectAtIndex:1] intValue];

        // 赠送金币.
        [MobClickGameAnalytics bonus:coin source:source];
    } else if (paramsCount == 4) {

        NSString *item = [params objectAtIndex:0];
        int amount = [[params objectAtIndex:1] intValue];
        double price = [[params objectAtIndex:2] doubleValue];
        int source = [[params objectAtIndex:3] intValue];

        // 赠送道具.
        [MobClickGameAnalytics bonus:item amount:amount price:price source:source];
    }
}

// @umeng
- (void)umengProfileSignInWithPUID:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg0 isEqualToString:@""]) {
        return;
    }

    NSArray *params = [arg0 componentsSeparatedByString:@";"];
    int paramsCount = (int)[params count];

    if (paramsCount == 1) {
        NSString *puid = [params objectAtIndex:0];

        [MobClickGameAnalytics profileSignInWithPUID:puid];
    } else if (paramsCount == 2) {
        NSString *puid = [params objectAtIndex:0];
        NSString *provider = [params objectAtIndex:1];

        [MobClickGameAnalytics profileSignInWithPUID:puid provider:provider];
    }
}

// @umeng
- (void)umengProfileSignOff:(NSString *)arg0 param:(NSString *)arg1 {
    [MobClickGameAnalytics profileSignOff];
}

// @umeng
- (void)umengSetUserLevelId:(NSString *)arg0 param:(NSString *)arg1 {
    if ([arg0 isEqualToString:@""]) {
        return;
    }

    int level = [arg0 intValue];

    [MobClickGameAnalytics setUserLevelId:level];
}
#endif

#ifdef USE_BILLING
// @billing
- (void)billingPrepare {
    if (self.canBilling) {
        sdkEventResult("billing_prepare", "true", "");
    }
    else {
        sdkEventResult("billing_prepare", "false", "");
    }
}

// @billing
- (void)billingRequest:(NSString *)arg0 param:(NSString *)arg1 {
    [self requestProductData:arg0 withPayload:arg1];
}

// @billing
- (void)billingConfirm {

}
#endif

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
     cocos2d::Director::getInstance()->purgeCachedData();
}

- (void)dealloc {
#ifdef USE_BILLING
    // @billing
    self.skuDict = nil;
#endif

#ifdef USE_MOLOCO
    // @moloco
    [_tracer release];
#endif

    [super dealloc];
}

#ifdef USE_UMENG
/*
#pragma mark -
#pragma mark UINavigationControllerDelegate (More screen)

// @umeng
- (void)updateMethod:(NSDictionary *)appInfo {
    NSLog(@"update info %@",appInfo);
}
*/
#endif

@end

