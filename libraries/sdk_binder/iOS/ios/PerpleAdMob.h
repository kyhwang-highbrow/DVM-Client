//
//  PerpleAdMob.h
//  PerpleSDK
//
//  Created by sgkim on 2021. 5. 27..
//  Copyright © 2021년 highbrow. All rights reserved.
//

#ifndef PerpleAdMob_h
#define PerpleAdMob_h

@import GoogleMobileAds;
#import "PerpleSDK.h"
#import "AdMobRewardAdUnit.h"

@interface PerpleAdMob : NSObject

#pragma mark - Properties
@property (nonatomic, retain) UIViewController *mViewController;
@property (nonatomic, retain) NSMutableDictionary *mAdMobRewardAdUnits;

#pragma mark - Initialization
- (id) initWithParentView:(UIViewController *)parentView;

#pragma mark - APIs
- (void) initialize:(PerpleSDKCallback)callback;
- (void) loadRewardAd:(NSString *)adUnitId completion:(PerpleSDKCallback)callback;
- (void) showRewardAd:(NSString *)adUnitId completion:(PerpleSDKCallback)callback;

#pragma mark - AppDelegate
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end

#endif /* PerpleAdMob_h */
