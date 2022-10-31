//
//  PerpleAdMobInterstitialAd.m
//  PerpleSDK
//
//  Created by PerpleLab on 15/01/2019.
//  Copyright © 2019 PerpleLab. All rights reserved.
//
/*
#import "PerpleAdMobInterstitialAd.h"

@implementation PerpleAdMobInterstitialAd

#define MAX_TRY_COUNT 10

#pragma mark - Properties
@synthesize mInterstitialAd;
@synthesize mCallback;
@synthesize mAdUnitId;
@synthesize mTryLoadingCount;

#pragma mark - Initialization
- (id) init {
    NSLog(@"# PerpleAdMobInterstitialAd, Initializing AdMob Interstitial Ad.");
    self.mTryLoadingCount = 0;
    return self;
}

- (void) dealloc {
    self.mCallback = nil;
    self.mInterstitialAd = nil;

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs
- (void) setAdUnitId:(NSString *)adUnitId {
    self.mAdUnitId = adUnitId;
}

- (void) loadRequest {
    // 더 세련되게 하고 싶지만.. 잘못된 ad unit id 등의 이유로 통신이 계속 실패할 경우 최대 10회만 시도
    self.mTryLoadingCount++;
    if (self.mTryLoadingCount >= MAX_TRY_COUNT) {
        NSLog(@"# PerpleAdMobInterstitialAd, loadRequest is Failed.");
        return;
    }

    GADInterstitial *interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.mAdUnitId];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];

    self.mInterstitialAd = interstitial;
}

- (void) setResultCallback:(PerpleSDKCallback)callback {
    self.mCallback = callback;
}

- (void) show {
    self.mTryLoadingCount = 0;


    if (self.mInterstitialAd == nil) {
        if (self.mCallback) {
            self.mCallback(@"error", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_ADMOB_NOTINITIALIZED
                                                         msg:@"AdMob Interstitial Ad is not initialized."]);
        }
        return;
    }

    if (self.mInterstitialAd.isReady) {
        [self.mInterstitialAd presentFromRootViewController:[[PerpleSDK sharedInstance] mViewController]];
    } else {
        if (self.mInterstitialAd != nil) {
            [self loadRequest];
        }

        if (self.mCallback) {
            self.mCallback(@"error", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_ADMOB_NOTLOADEDAD
                                                         msg:@"Ad is not loaded."]);
        }
    }
}

#pragma mark GADInterstitialDelegate implementation
// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"PerpleAdMobInterstitialAd, interstitialDidReceiveAd");
    
    if (self.mCallback) {
        self.mCallback(@"receive", @"Interstitial ad is received.");
    }
}

/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"PerpleAdMobInterstitialAd, interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);

    // 광고 다시 load
    [self loadRequest];
}

/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"PerpleAdMobInterstitialAd, interstitialWillPresentScreen");
    if (self.mCallback) {
        self.mCallback(@"open", @"Interstitial ad is open.");
        self.mCallback(@"start", @"Interstitial ad is start.");
    }
}

/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"PerpleAdMobInterstitialAd, interstitialWillDismissScreen");
    if (self.mCallback) {
        self.mCallback(@"complete", @"Interstitial ad is complete.");
    }
}

/// Tells the delegate the interstitial had been animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"PerpleAdMobInterstitialAd, interstitialDidDismissScreen");

    if (self.mCallback) {
        self.mCallback(@"finish", @"Interstitial ad is successfully finished.");
    }

    // 광고 다시 load
    [self loadRequest];
}

/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"PerpleAdMobInterstitialAd, interstitialWillLeaveApplication");
}
@end
*/
