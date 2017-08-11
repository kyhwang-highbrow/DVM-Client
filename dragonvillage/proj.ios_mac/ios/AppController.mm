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

// @perplesdk
static NSString *SENDER_ID = @"983890984134";
static NSString *CLIENT_ID = @"983890984134-krrfuti1qgk3k09j87gobkq96322v48v.apps.googleusercontent.com";
static NSString *ADBRIX_APP_KEY = @"696293230";
static NSString *ADBRIX_HASH_KEY = @"5c67709eb5c349c6";

// @idfa
#import <AdSupport/ASIdentifierManager.h>

extern void sdkEventResult(const char *id, const char *result, const char *info);

@implementation AppController

#ifdef USE_BILLING
// @billing
@synthesize skuDict;
@synthesize canBilling;
#endif

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;

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

    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) {
        viewController.wantsFullScreenLayout = YES;
    } else {
        viewController.extendedLayoutIncludesOpaqueBars = YES;
    }
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

    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLView::createWithEAGLView(eaglView);
    cocos2d::Director::getInstance()->setOpenGLView(glview);

    // local notification
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }

    // @perplesdk
    if ([[PerpleSDK sharedInstance] initSDKWithGcmSenderId:SENDER_ID debug:YES sandbox:YES]) {
        [[PerpleSDK sharedInstance] initGoogleWithClientId:CLIENT_ID];
        [[PerpleSDK sharedInstance] initFacebookWithParentView:viewController];
    }
    [[PerpleSDK sharedInstance] initAdbrixWithAppKey:ADBRIX_APP_KEY hashKey:ADBRIX_HASH_KEY logLevel:0];
    [[PerpleSDK sharedInstance] initBilling];
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

// @clipboard
- (void)clipboardSetText:(NSString *)arg0 {
    [[UIPasteboard generalPasteboard] setString:arg0];
}

// @clipboard
- (void)clipboardGetText:(NSString *)arg0 {
    NSString *text = [[UIPasteboard generalPasteboard] string];
    sdkEventResult("clipboard_getText", "success", [text UTF8String]);
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

    // @perplesdk
    [[PerpleSDK sharedInstance] dealloc];

    [super dealloc];
}

@end

