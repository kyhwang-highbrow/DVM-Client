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

#ifdef USE_BILLING
// @billing
#import <StoreKit/StoreKit.h>
#endif

// @perplesdk
#import "PerpleSDK.h"

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

- (void)sendLocalNotification:(NSString *)type withTime:(int)sec withMsg:(NSString *)msg;
- (void)cancelNotification;

// @clipboard
- (void)clipboardSetText:(NSString *)arg0;
- (NSString *)clipboardGetText;

// @wifi
- (int)isWifiConnected;

// @memory info
- (NSString *)getFreeMemory;

#ifdef USE_BILLING
// @billing
- (void)billingPrepare;
- (void)billingRequest:(NSString *)arg0 param:(NSString *)arg1;
- (void)billingConfirm;
#endif

+ (NSString *) getJSONStringFromNSDictionary:(NSDictionary *)obj;

@end
