//
//  PerpleAdMob.h
//  PerpleSDK
//
//  Created by PerpleLab on 2018. 4. 20..
//  Copyright © 2018년 PerpleLab. All rights reserved.
//

#ifndef PerpleAdMob_h
#define PerpleAdMob_h

@import GoogleMobileAds;
#import "PerpleSDK.h"
#import "PerpleAdMobRewardedVideoAd.h"
#import "PerpleAdMobInterstitialAd.h"

@interface PerpleAdMob : NSObject

@property (nonatomic, copy) NSString *mAppId;
@property PerpleAdMobRewardedVideoAd* mRewardedVideoAd;
@property PerpleAdMobInterstitialAd* mInterstitialAd;

- (id) initWithAppId:(NSString *)appId;

- (void) initRewardedVideoAd;
- (void) initInterstitialAd;

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end

#endif /* PerpleAdMob_h */
