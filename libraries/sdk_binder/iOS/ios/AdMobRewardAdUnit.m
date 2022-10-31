
//
//  AdMobRewardAdUnit.m
//  sdk_binder
//
//  Created by sgkim on 2021/05/27.
//  Copyright © 2021 highbrow. All rights reserved.
//

#import "AdMobRewardAdUnit.h"

@implementation AdMobRewardAdUnit

#pragma mark - Properties

@synthesize mViewController;
@synthesize mAdUnitId;
@synthesize mRewardedAd;
@synthesize mRewardItem;
@synthesize mIsLoading;
@synthesize mShowCallback;

#pragma mark - Initialization

- (id) initWithAdUnitId:(NSString *)adUnitId parentView:(UIViewController *)parentView
{
    self.mViewController = parentView;
    self.mAdUnitId = adUnitId;
    NSLog(@"# AdMobRewardAdUnit, initWithAdUnitId. adUnitId : %@", self.mAdUnitId);
    
    self.mRewardedAd = nil;
    self.mIsLoading = false;
    
    return self;
}

- (void) dealloc {
    self.mViewController = nil;
    self.mAdUnitId = nil;
    self.mRewardedAd = nil;
    self.mShowCallback = nil;
    
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs

- (void) loadRewardAd:(PerpleSDKCallback)callback {
    // test adUnitUd : @"ca-app-pub-3940256099942544/4806952744"
    
    // 이미 로드되어 있는 경우
    if ((self.mIsLoading == false) && (self.mRewardedAd != nil)) {
        // @escape
        callback(@"success", @"");
        return;
    }
    
    // 이전 호출로 로딩 중인 경우
    if (self.mIsLoading == true) {
        // @escape
        callback(@"loading", @"Ad is loading.");
        return;
    }
    
    self.mIsLoading = true;
    GADRequest *request = [GADRequest request];
    [GADRewardedAd loadWithAdUnitID:self.mAdUnitId request:request completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
            
            self.mRewardedAd = nil;
            self.mIsLoading = false;
            
            NSInteger code = [error code];
            NSString *info = [PerpleSDK getErrorInfo:[@(code) stringValue]
                                                 msg:[error localizedDescription]];
            // @escape
            callback(@"fail", info);
            return;
        }
        NSLog(@"Rewarded ad loaded.");
        self.mRewardedAd = ad;
        self.mIsLoading = false;
        
        // @escape
        callback(@"success", @"");
    }];
}

- (void) showRewardAd:(PerpleSDKCallback)callback {
    if (self.mRewardedAd == nil) {
        // @escape
        callback(@"fail", @"Ads are not loading.");
        return;
    }
    
    self.mShowCallback = callback;
    self.mRewardedAd.fullScreenContentDelegate = self;
    self.mRewardItem = nil; // 보상 정보 (광고를 끝까지 보았는지 여부) 초기화
    
    [self.mRewardedAd presentFromRootViewController:self.mViewController userDidEarnRewardHandler:^{
        GADAdReward *reward = self.mRewardedAd.adReward;
        //[reward amount];
        //[reward type];
        self.mRewardItem = reward;
    }];
    
    // mShowCallackd은 아래 두 함수에서 호출된다.
    // (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error
    // (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
    if (self.mShowCallback != nil) {
        NSInteger code = [error code];
        NSString *info = [PerpleSDK getErrorInfo:[@(code) stringValue]
                                             msg:[error localizedDescription]];
        // @escape
        self.mShowCallback(@"fail", info);
    }
    self.mShowCallback = nil;
    self.mRewardedAd = nil;
    self.mIsLoading = false;
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad did present full screen content.");
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
   NSLog(@"Ad did dismiss full screen content.");
    if (self.mShowCallback == nil) {
        return;
    }
    
    if (self.mRewardItem != nil) {
        // 보상 정보가 있으면 시청 완료. 성공 처리
        self.mShowCallback(@"success", @"");
    } else {
        // 보상 정보가 없으면 시청 도중 취소
        self.mShowCallback(@"cancel", @"");
    }
    
    self.mShowCallback = nil;
    self.mRewardedAd = nil;
    self.mIsLoading = false;
}

@end
