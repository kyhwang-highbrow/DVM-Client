//
//  PerpleAdMob.m
//  PerpleSDK
//
//  Created by sgkim on 2021. 5. 27..
//  Copyright © 2021년 highbrow. All rights reserved.
//

#import "PerpleAdMob.h"

@implementation PerpleAdMob

#pragma mark - Properties
@synthesize mViewController;
@synthesize mAdMobRewardAdUnits;

#pragma mark - Initialization
- (id) initWithParentView:(UIViewController *)parentView {
    self.mViewController = parentView;
    self.mAdMobRewardAdUnits = [NSMutableDictionary dictionary];
    return self;
}

- (void) dealloc {
    self.mViewController = nil;
    self.mAdMobRewardAdUnits = nil;
    
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs
- (void) initialize:(PerpleSDKCallback)callback {
    
    NSLog(@"# PerpleAdMob - initialize");
    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {
        callback(@"success", @"");
    }];
}

- (void) loadRewardAd:(NSString *)adUnitId completion:(PerpleSDKCallback)callback {
    AdMobRewardAdUnit *adUnit = [self.mAdMobRewardAdUnits objectForKey:adUnitId];
    if (adUnit == nil) {
        adUnit = [[AdMobRewardAdUnit alloc] initWithAdUnitId:adUnitId parentView:self.mViewController];
        [self.mAdMobRewardAdUnits setObject:adUnit forKey:adUnitId];
    }
    
    [adUnit loadRewardAd:callback];
}

- (void) showRewardAd:(NSString *)adUnitId completion:(PerpleSDKCallback)callback {
    AdMobRewardAdUnit *adUnit = [self.mAdMobRewardAdUnits objectForKey:adUnitId];
    if (adUnit == nil) {
        adUnit = [[AdMobRewardAdUnit alloc] initWithAdUnitId:adUnitId parentView:self.mViewController];
        [self.mAdMobRewardAdUnits setObject:adUnit forKey:adUnitId];
    }
    
    [adUnit showRewardAd:callback];
}

#pragma mark - AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    //[GADMobileAds configureWithApplicationID:self.mAppId];
    return YES;
}

@end
