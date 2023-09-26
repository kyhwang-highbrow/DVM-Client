//
//  PerpleTapjoy.m
//  PerpleSDK
//
//  Created by Yonghak on 2016. 8. 4..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import "PerpleTapjoy.h"

/*
@implementation PerpleTapjoy

#pragma mark - Properties

@synthesize mPlacements;
@synthesize mSetPlacementCallbacks;
@synthesize mShowPlacementCallbacks;
@synthesize mEarnedCurrencyCallack;
@synthesize mIsUsePush;
@synthesize mIsTrackPurchase;

#pragma mark - Initialization

- (id) initWithAppKey:(NSString *)appKey
              usePush:(BOOL)isUsePush
                debug:(BOOL)isDebug {
    NSLog(@"PerpleTapjoy, Initializing Tapjoy.");

    if (self = [super init]) {
        // Tapjoy connect success failure notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tjcConnectSuccess:)
                                                     name:TJC_CONNECT_SUCCESS
                                                   object:nil];
        // Tapjoy connect failure failure notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tjcConnectFail:)
                                                     name:TJC_CONNECT_FAILED
                                                   object:nil];
        // Push notifications
        self.mIsUsePush = isUsePush;

        // Placement
        self.mPlacements = [NSMutableDictionary dictionary];
        self.mSetPlacementCallbacks = [NSMutableDictionary dictionary];
        self.mShowPlacementCallbacks = [NSMutableDictionary dictionary];

        // Turn on/off Tapjoy debug mode
        // Do not set this YES for any version of the game released to an app store!
        [Tapjoy setDebugEnabled:isDebug];

        // The Tapjoy connect call
        [Tapjoy connect:appKey];
    } else {
        NSLog(@"PerpleTapjoy, Initializing Tapjoy fail.");
    }

    return self;
}

- (void) dealloc {
    self.mPlacements = nil;
    self.mSetPlacementCallbacks = nil;
    self.mShowPlacementCallbacks = nil;

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs

- (void) setPlacementWithName:(NSString *)name
                   completion:(PerpleSDKCallback)callback {
    TJPlacement *p = [self.mPlacements objectForKey:name];

    if (p == nil) {
        p = [TJPlacement placementWithName:name
                                  delegate:self];
        [self.mPlacements setObject:p
                             forKey:name];
    }
    [self.mSetPlacementCallbacks setObject:callback
                                    forKey:name];

    [p requestContent];
}

- (void) showPlacementWithName:(NSString *)name
                    completion:(PerpleSDKCallback)callback {
    TJPlacement *p = [self.mPlacements objectForKey:name];

    if (p != nil) {
        if (p.isContentReady) {
            [self.mShowPlacementCallbacks setObject:callback
                                             forKey:name];
            [p showContentWithViewController:nil];
        } else {
            // Handle situation where there is no content to show, or it has not yet downloaded.
            callback(@"wait", @"");
        }
    } else {
        NSLog(@"PerpleTapjoy, Tapjoy placement is not set - name:%@", name);
        callback(@"error", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TAPJOY_NOTSETPLACEMENT
                                               msg:@"Tapjoy placement is not set."]);
    }

}

- (void) getCurrencyWithCompletion:(PerpleSDKCallback)callback {
    [Tapjoy getCurrencyBalanceWithCompletion:^(NSDictionary *parameters, NSError *error) {
        if (error != nil) {
            callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TAPJOY_GETCURRENCY
                                              subcode:[@(error.code) stringValue]
                                                  msg:error.localizedDescription]);
        } else {
            callback(@"success", [PerpleSDK getJSONStringFromNSDictionary:@{@"currencyName":parameters[@"currencyName"],
                                                                            @"balance":parameters[@"amount"]}]);
        }
    }];

}

- (void) setEarnedCurrencyCallback:(PerpleSDKCallback)callback {
    self.mEarnedCurrencyCallack = callback;

    // Tapjoy currency earned notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showEarnedCurrencyAlert:)
                                                 name:TJC_CURRENCY_EARNED_NOTIFICATION
                                               object:nil];
}

- (void) spendCurrencyWithAmount:(int)amount
                      completion:(PerpleSDKCallback)callback {
    [Tapjoy spendCurrency:amount
               completion:^(NSDictionary *parameters, NSError *error) {
                   if (error != nil) {
                       callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TAPJOY_SPENDCURRENCY
                                                         subcode:[@(error.code) stringValue]
                                                             msg:error.localizedDescription]);
                   } else {
                       callback(@"success", [PerpleSDK getJSONStringFromNSDictionary:@{@"currencyName":parameters[@"currencyName"],
                                                                                       @"balance":parameters[@"amount"]}]);
                   }
               }];
}

- (void) awardCurrencyWithAmount:(int)amount
                      completion:(PerpleSDKCallback)callback {
    [Tapjoy awardCurrency:amount
               completion:^(NSDictionary *parameters, NSError *error) {
                   if (error != nil) {
                       callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TAPJOY_AWARDCURRENCY
                                                         subcode:[@(error.code) stringValue]
                                                             msg:error.localizedDescription]);
                   } else {
                       callback(@"success", [PerpleSDK getJSONStringFromNSDictionary:@{@"currencyName":parameters[@"currencyName"],
                                                                                       @"balance":parameters[@"amount"]}]);
                   }
               }];
}

- (void) trackEvent:(NSString *)cmd
             param1:(NSString *)param1
             param2:(NSString *)param2 {
    if ([cmd isEqualToString:@"userID"]) {
        [Tapjoy setUserID:param1];
    } else if ([cmd isEqualToString:@"userLevel"]) {
        [Tapjoy setUserLevel:[param1 intValue]];
    } else if ([cmd isEqualToString:@"userFriendCount"]) {
        [Tapjoy setUserFriendCount:[param1 intValue]];
    } else if ([cmd isEqualToString:@"appDataVersion"]) {
        [Tapjoy setAppDataVersion:param1];
    } else if ([cmd isEqualToString:@"userCohortVariable"]) {
        [Tapjoy setUserCohortVariable:[param1 intValue]
                                value:param2];
    } else if ([cmd isEqualToString:@"trackEvent"]) {
        NSArray *params = [param1 componentsSeparatedByString:@";"];
        NSUInteger paramCount = [params count];
        if (paramCount == 4) {
            [Tapjoy trackEvent:[params objectAtIndex:1]
                      category:[params objectAtIndex:0]
                    parameter1:[params objectAtIndex:2]
                    parameter2:[params objectAtIndex:3]];
        } else if (paramCount == 5) {
            [Tapjoy trackEvent:[params objectAtIndex:1]
                      category:[params objectAtIndex:0]
                    parameter1:[params objectAtIndex:2]
                    parameter2:[params objectAtIndex:3]
                         value:[[params objectAtIndex:4] longLongValue]];
        } else if (paramCount == 6) {
            [Tapjoy trackEvent:[params objectAtIndex:1]
                      category:[params objectAtIndex:0]
                    parameter1:[params objectAtIndex:2]
                    parameter2:[params objectAtIndex:3]
                    value1name:[params objectAtIndex:4]
                        value1:[[params objectAtIndex:5] longLongValue]];
        } else if (paramCount == 8) {
            [Tapjoy trackEvent:[params objectAtIndex:1]
                      category:[params objectAtIndex:0]
                    parameter1:[params objectAtIndex:2]
                    parameter2:[params objectAtIndex:3]
                    value1name:[params objectAtIndex:4]
                        value1:[[params objectAtIndex:5] longLongValue]
                    value2name:[params objectAtIndex:6]
                        value2:[[params objectAtIndex:7] longLongValue]];
        } else if (paramCount == 10) {
            [Tapjoy trackEvent:[params objectAtIndex:1]
                      category:[params objectAtIndex:0]
                    parameter1:[params objectAtIndex:2]
                    parameter2:[params objectAtIndex:3]
                    value1name:[params objectAtIndex:4]
                        value1:[[params objectAtIndex:5] longLongValue]
                    value2name:[params objectAtIndex:6]
                        value2:[[params objectAtIndex:7] longLongValue]
                    value3name:[params objectAtIndex:8]
                        value3:[[params objectAtIndex:9] longLongValue]];
        }
    } else if ([cmd isEqualToString:@"trackPurchase"]) {
        NSArray *params = [param1 componentsSeparatedByString:@";"];
        NSUInteger paramCount = [params count];
        if (paramCount == 3) {
            [Tapjoy trackPurchase:[params objectAtIndex:0]
                     currencyCode:[params objectAtIndex:1]
                            price:[[params objectAtIndex:2] doubleValue]
                       campaignId:nil
                    transactionId:nil];
        } else if (paramCount == 4) {
            [Tapjoy trackPurchase:[params objectAtIndex:0]
                     currencyCode:[params objectAtIndex:1]
                            price:[[params objectAtIndex:2] doubleValue]
                       campaignId:[params objectAtIndex:3]
                    transactionId:nil];
        }
    }
}

- (void) trackPurchase:(BOOL)flag {
    self.mIsTrackPurchase = flag;
}

#pragma mark - Tapjoy connect notifications

// Tapjoy connect success notification
- (void) tjcConnectSuccess:(NSNotification *)notifyObj {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleTapjoy, Tapjoy connect succeeded.");
    }
}

// Tapjoy connect failure notification
- (void) tjcConnectFail:(NSNotification *)notifyObj {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleTapjoy, Tapjoy connect failed.");
    }
}

#pragma mark - Tapoy currency earned notification

// Tapjoy currency earned notification
- (void) showEarnedCurrencyAlert:(NSNotification *)notifyObj {
    // Pops up a UIAlert notifying the user that they have successfully earned some currency.
    // this is the default alert, so you may place a custom alert here if you choose to do so.
    //[Tapjoy showDefaultEarnedCurrencyAlert];

    NSString *currencyName = notifyObj.name;
    NSNumber *amount = notifyObj.object;

    if (self.mEarnedCurrencyCallack != nil) {
        self.mEarnedCurrencyCallack(@"earn", [PerpleSDK getJSONStringFromNSDictionary:@{@"currencyName":currencyName,
                                                                                        @"amount":amount}]);
    }

    // This is a good place to remove this notification since it is undesirable to have a pop-up alert more than once per app run.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TJC_CURRENCY_EARNED_NOTIFICATION
                                                  object:nil];
}

#pragma mark - TJPlacementDelegate

// TJPlacementDelegate
// Called when the content request returns from Tapjoy's servers. Does not necessarily mean that content is available.
- (void) requestDidSucceed:(TJPlacement *)placement {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleTapjoy, requestDidSucceed - placement:%@", [placement placementName]);
    }

    PerpleSDKCallback callback = self.mSetPlacementCallbacks[[placement placementName]];
    if (callback) {
        callback(@"success", @"");
    }
}

// TJPlacementDelegate
- (void) requestDidFail:(TJPlacement *)placement
                  error:(NSError *)error {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleTapjoy, requestDidFail - placement:%@, error:%@", [placement placementName], error);
    }

    PerpleSDKCallback callback = self.mSetPlacementCallbacks[[placement placementName]];
    if (callback) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TAPJOY_SETPLACEMENT
                                          subcode:[@(error.code) stringValue]
                                              msg:error.localizedDescription]);
    }
}

// TJPlacementDelegate
// Called when the content is actually available to display.
- (void) contentIsReady:(TJPlacement *)placement {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleTapjoy, contentIsReady - placement:%@", [placement placementName]);
    }

    PerpleSDKCallback callback = self.mSetPlacementCallbacks[[placement placementName]];
    if (callback) {
        callback(@"ready", @"");
    }
}

// TJPlacementDelegate
// Called when user clicks the product link in IAP promotion content
- (void) placement:(TJPlacement *)placement
didRequestPurchase:(TJActionRequest *)request
           productId:(NSString *)productId {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleTapjoy, didRequestPurchase - placement:%@, request:%@, productId:%@", [placement placementName], request, productId);
    }

    // Implement code here to trigger IAP purchase flow for item  here
    PerpleSDKCallback callback = self.mSetPlacementCallbacks[[placement placementName]];
    if (callback) {
        callback(@"purchase", [PerpleSDK getJSONStringFromNSDictionary:@{@"request":request,
                                                                         @"productId":productId}]);
    }
}

// TJPlacementDelegate
// Called when the reward content is closed by the user
- (void) placement:(TJPlacement *)placement
  didRequestReward:(TJActionRequest *)request
            itemId:(NSString *)itemId
          quantity:(int)quantity {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleTapjoy, didRequestReqard - placement:%@, request:%@, itemId:%@, quantity:%@", [placement placementName], request, itemId, @(quantity));
    }

    // Implement code here to give the player copies of item
    PerpleSDKCallback callback = self.mSetPlacementCallbacks[[placement placementName]];
    if (callback) {
        callback(@"reward", [PerpleSDK getJSONStringFromNSDictionary:@{@"request":request,
                                                                       @"itemId":itemId,
                                                                       @"quantity":@(quantity)}]);
    }
}

// TJPlacementDelegate
- (void) contentDidAppear:(TJPlacement *)placement {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleTapjoy, contentDidAppear - placement:%@", [placement placementName]);
    }

    PerpleSDKCallback callback = self.mShowPlacementCallbacks[[placement placementName]];
    if (callback) {
        callback(@"show", @"");
    }
}

// TJPlacementDelegate
- (void) contentDidDisappear:(TJPlacement *)placement {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleTapjoy, contentDidDisappear - placement:%@", [placement placementName]);
    }

    PerpleSDKCallback callback = self.mShowPlacementCallbacks[[placement placementName]];
    if (callback) {
        callback(@"dismiss", @"");
    }
}

#pragma mark - AppDelegate

// AppDelegate
- (void) applicationWillEnterForeground:(UIApplication *)application {
    [Tapjoy startSession];
}

// AppDelegate
- (void) applicationDidEnterBackground:(UIApplication *)application {
    [Tapjoy endSession];
}

// AppDelegate, for Push notifications
// Called when the remote notification is registered
- (void) application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (self.mIsUsePush) {
        [Tapjoy setDeviceToken:deviceToken];
    }
}

// AppDelegate, for Push notifications
// Called when the user get push message while playing the app
- (void) application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (self.mIsUsePush) {
        [Tapjoy setReceiveRemoteNotification:userInfo];
    }
}

- (void) payment:(SKPaymentTransaction *)transaction
         product:(SKProduct *)product {
    if (self.mIsTrackPurchase) {
        if (transaction != nil && product != nil) {
            [Tapjoy trackPurchase:product.productIdentifier
                     currencyCode:@"USD"
                            price:[product.price doubleValue]
                       campaignId:nil
                    transactionId:transaction.transactionIdentifier];
        }
    }
}

 
@end
 */
