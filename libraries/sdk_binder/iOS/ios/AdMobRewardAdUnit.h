//
//  AdMobRewardAdUnit.h
//  sdk_binder
//
//  Created by sgkim on 2021/05/27.
//  Copyright © 2021 highbrow. All rights reserved.
//

#ifndef AdMobRewardAdUnit_h
#define AdMobRewardAdUnit_h

@import GoogleMobileAds;
#import "PerpleSDK.h"

@interface AdMobRewardAdUnit : NSObject <GADFullScreenContentDelegate>

@property (nonatomic, retain) UIViewController *mViewController;
@property (nonatomic, copy) NSString *mAdUnitId;
@property (nonatomic, strong) GADRewardedAd *mRewardedAd;
@property (nonatomic, strong) GADAdReward *mRewardItem;

@property BOOL mIsLoading;
@property PerpleSDKCallback mShowCallback;

- (id) initWithAdUnitId:(NSString *)adUnitId parentView:(UIViewController *)parentView;
- (void) loadRewardAd:(PerpleSDKCallback)callback;
- (void) showRewardAd:(PerpleSDKCallback)callback;

@end

#endif /* AdMobRewardAdUnit_h */
