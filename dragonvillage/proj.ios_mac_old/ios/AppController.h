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

#ifdef USE_MOLOCO
// @moloco
#import <Moloco/Moloco.h>
#endif

#ifdef USE_BILLING
// @billing
#import <StoreKit/StoreKit.h>
#endif

@class RootViewController;

#ifdef USE_BILLING
// @billing
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>
#else
@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate>
#endif
{
    UIWindow *window;
    RootViewController *viewController;
}

#ifdef USE_BILLING
// @billing
@property (nonatomic, retain) NSMutableDictionary *skuDict;
@property (assign) bool canBilling;
#endif

#ifdef USE_MOLOCO
// @moloco
@property (strong, readonly) MolocoTracker *tracer;
#endif

- (void)sendLocalNotification:(NSString *)type withTime:(int)sec withMsg:(NSString *)msg;
- (void)cancelNotification;

// @tapjoy
- (void)tjcConnectSuccess:(NSNotification *)notifyObj;
- (void)tjcConnectFail:(NSNotification *)notifyObj;

// @adbrix
- (void)adbrixUserInfo:(NSString *)arg0;
- (void)adbrixFirstTimeExperience:(NSString *)arg0 param:(NSString *)arg1;
- (void)adbrixRetention:(NSString *)arg0 param:(NSString *)arg1;
- (void)adbrixBuy:(NSString *)arg0 param:(NSString *)arg1;
- (void)adbrixCustomCohort:(NSString *)arg0 param:(NSString *)arg1;

// @tapjoy
- (void)fiverocksUserInfo:(NSString *)arg0;
- (void)fiverocksTrackEvent:(NSString *)arg0;
- (void)fiverocksTrackPurchase:(NSString *)arg0;
- (void)fiverocksCustomCohort:(NSString *)arg0 param:(NSString *)arg1;
- (void)fiverocksAppDataVersion:(NSString *)arg0;

#ifdef USE_PARTYTRACK
// @partytrack
- (void)partytrackPayment:(NSString *)arg0;
- (void)partytrackEvent:(NSString *)arg0;
#endif

#ifdef USE_MOLOCO
// @moloco
- (void)molocoEvent:(NSString *)arg0 param:(NSString *)arg1;
- (void)molocoEventSpatial:(NSString *)arg0 param:(NSString *)arg1;
#endif

// @clipboard
- (void)clipboardSetText:(NSString *)arg0;
- (void)clipboardGetText:(NSString *)arg0;

// @wifi
- (int)isWifiConnected;

// @memory info
- (NSString *)getFreeMemory;

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
// @ppsdk
- (void)ppsdkLogin;
- (void)ppsdkLogout;
- (void)ppsdkLoginAuth:(int)result param:(NSString *)info;
- (void)ppsdkExchangeGoods:(NSString *)arg0;
- (void)ppsdkShowSDKCenter;
#endif

#if LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER
// @gameCenter
- (void)gcsdkLogin;
#endif

#ifdef USE_UMENG
// @umeng
- (void)umengBeginLogPageView:(NSString *)arg0;
- (void)umengEndLogPageView:(NSString *)arg0;
- (void)umengBeginEvent:(NSString *)arg0 param:(NSString *)arg1;
- (void)umengEndEvent:(NSString *)arg0 param:(NSString *)arg1;
- (void)umengEvent:(NSString *)arg0 param:(NSString *)arg1;
- (void)umengPay:(NSString *)arg0 param:(NSString *)arg1;
- (void)umengBuy:(NSString *)arg0 param:(NSString *)arg1;
- (void)umengUse:(NSString *)arg0 param:(NSString *)arg1;
- (void)umengLevel:(NSString *)arg0 param:(NSString *)arg1;
- (void)umengBonus:(NSString *)arg0 param:(NSString *)arg1;
- (void)umengProfileSignInWithPUID:(NSString *)arg0 param:(NSString *)arg1;
- (void)umengProfileSignOff:(NSString *)arg0 param:(NSString *)arg1;
- (void)umengSetUserLevelId:(NSString *)arg0 param:(NSString *)arg1;

// @umeng - option1
//- (void)updateMethod:(NSDictionary *)appInfo;
#endif

#ifdef USE_BILLING
// @billing
- (void)billingPrepare;
- (void)billingRequest:(NSString *)arg0 param:(NSString *)arg1;
- (void)billingConfirm;
#endif

@end
