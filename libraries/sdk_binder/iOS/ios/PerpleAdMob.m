//
//  PerpleAdMob.m
//  PerpleSDK
//
//  Created by PerpleLab on 2018. 4. 20..
//  Copyright © 2018년 PerpleLab. All rights reserved.
//

#import "PerpleAdMob.h"

@implementation PerpleAdMob

#define MAX_TRY_COUNT 10

#pragma mark - Properties
@synthesize mAppId;
@synthesize mRewardedVideoAd;
@synthesize mInterstitialAd;

#pragma mark - Initialization
- (id) initWithAppId:(NSString *)appId{
    NSLog(@"# PerpleAdMob, Initializing AdMob.");
    self.mAppId = appId;
    NSLog(@"# PerpleAdMob, app id : %@", self.mAppId);

    return self;
}

- (void) dealloc {
    self.mAppId = nil;

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs
- (void) initRewardedVideoAd {
    mRewardedVideoAd = [[PerpleAdMobRewardedVideoAd alloc] init];
}

- (void) initInterstitialAd {
    mInterstitialAd = [[PerpleAdMobInterstitialAd alloc] init];
}

#pragma mark - AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [GADMobileAds configureWithApplicationID:self.mAppId];
    return YES;
}

@end
