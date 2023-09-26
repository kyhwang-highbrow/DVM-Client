//
//  PerpleTapjoy.h
//  PerpleSDK
//
//  Created by Yonghak on 2016. 8. 4..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

/*
#import <Foundation/Foundation.h>
#import <Tapjoy/Tapjoy.h>
#import <Tapjoy/TJPlacement.h>
#import "PerpleSDK.h"

@interface PerpleTapjoy : NSObject <TJPlacementDelegate>

#pragma mark - Properties

@property (nonatomic, retain) NSMutableDictionary *mPlacements;
@property (nonatomic, retain) NSMutableDictionary *mSetPlacementCallbacks;
@property (nonatomic, retain) NSMutableDictionary *mShowPlacementCallbacks;
@property PerpleSDKCallback mEarnedCurrencyCallack;
@property BOOL mIsUsePush;
@property BOOL mIsTrackPurchase;

#pragma mark - Initialization

- (id) initWithAppKey:(NSString *)appKey usePush:(BOOL)isUsePush debug:(BOOL)isDebug;

#pragma mark - APIs

- (void) setPlacementWithName:(NSString *)name completion:(PerpleSDKCallback)callback;
- (void) showPlacementWithName:(NSString *)name completion:(PerpleSDKCallback)callbak;
- (void) getCurrencyWithCompletion:(PerpleSDKCallback)callback;
- (void) setEarnedCurrencyCallback:(PerpleSDKCallback)callback;
- (void) spendCurrencyWithAmount:(int)amount completion:(PerpleSDKCallback)callback;
- (void) awardCurrencyWithAmount:(int)amount completion:(PerpleSDKCallback)callback;
- (void) trackEvent:(NSString *)cmd param1:(NSString *)param1 param2:(NSString *)param2;
- (void) trackPurchase:(BOOL)flag;

#pragma mark - Tapjoy connect notifications

// Tapjoy connect success/failure notifications
- (void) tjcConnectSuccess:(NSNotification *)notifyObj;
- (void) tjcConnectFail:(NSNotification *)notifyObj;

#pragma mark - Tapoy currency earned notification

// Tapjoy currency earned notification
- (void) showEarnedCurrencyAlert:(NSNotification *)notifyObj;

#pragma mark - TJPlacementDelegate

// TJPlacementDelegate
- (void) requestDidSucceed:(TJPlacement *)placement;
- (void) requestDidFail:(TJPlacement *)placement error:(NSError *)error;
- (void) contentIsReady:(TJPlacement *)placement;
- (void) contentDidAppear:(TJPlacement *)placement;
- (void) contentDidDisappear:(TJPlacement *)placement;
- (void) placement:(TJPlacement *)placement didRequestPurchase:(TJActionRequest *)request productId:(NSString *)productId;
- (void) placement:(TJPlacement *)placement didRequestReward:(TJActionRequest *)request itemId:(NSString *)itemId quantity:(int)quantity;

#pragma mark - AppDelegate

// AppDelegate
- (void) applicationWillEnterForeground:(UIApplication *)application;
- (void) applicationDidEnterBackground:(UIApplication *)application;

// AppDelegate, for Push notifications
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void) payment:(SKPaymentTransaction *)transaction product:(SKProduct *)product;

@end
*/
