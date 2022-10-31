//
//  PerpleAdMobRewardedVideoAd.m
//  PerpleSDK
//
//  Created by PerpleLab on 15/01/2019.
//  Copyright © 2019 PerpleLab. All rights reserved.
//

/*
#import "PerpleAdMobRewardedVideoAd.h"

@implementation PerpleAdMobRewardedVideoAd

#define MAX_TRY_COUNT 10

#pragma mark - Properties
@synthesize mCallback;
@synthesize mRewardVideoAd;
@synthesize mHasReward;
@synthesize mCurrAdUnitId;
@synthesize mTryLoadingCount;

#pragma mark - Initialization
- (id) init {
    NSLog(@"# PerpleAdMobRewardedVideoAd, Initializing AdMob Rewarded Video Ad.");
    self.mHasReward = NO;
    self.mRewardVideoAd = [GADRewardBasedVideoAd sharedInstance];
    self.mTryLoadingCount = 0;

    self.mRewardVideoAd.delegate = self;

    return self;
}

- (void) dealloc {
    self.mCallback = nil;
    self.mRewardVideoAd = nil;
    self.mCurrAdUnitId = nil;

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs

- (void) loadRequest{
    NSLog(@"# PerpleAdMobRewardedVideoAd, loadRequest");

    // 더 세련되게 하고 싶지만.. 잘못된 ad unit id 등의 이유로 통신이 계속 실패할 경우 최대 10회만 시도
    self.mTryLoadingCount++;
    if (self.mTryLoadingCount >= MAX_TRY_COUNT) {
        NSLog(@"# PerpleAdMobRewardedVideoAd, loadRequest is Failed. Check ad unit ids");
        return;
    }

    // ad unit id 가 설정이 안된 경우
    if (self.mCurrAdUnitId == NULL) {
        NSLog(@"# PerpleAdMobRewardedVideoAd, loadRequest is Failed. Ad unit id is null");
        return;
    }

    // 현재의 ad unit id 로 광고 load 시도
    if (![self.mRewardVideoAd isReady]) {
        NSLog(@"# PerpleAdMobRewardedVideoAd, loadRequest ad id : %@", self.mCurrAdUnitId);
        [self loadRequestWithId:self.mCurrAdUnitId];
    }

}

- (void) loadRequestWithId:(NSString *)adUnitId {
    [self.mRewardVideoAd loadRequest:[GADRequest request] withAdUnitID:adUnitId];
}

- (void) setResultCallback:(PerpleSDKCallback)callback {
    self.mCallback = callback;
}

- (void) show:(NSString *) adUnitId {
    self.mTryLoadingCount = 0;

    // 잘못된 ad unit id
    if (adUnitId == nil) {
        if (self.mCallback) {
            self.mCallback(@"error", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_ADMOB_INVALIDADUNITID
                                                         msg:@"There is no ad unit id to show."]);
        }
        return;
    }
    if (self.mRewardVideoAd == nil) {
        if (self.mCallback) {
            self.mCallback(@"error", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_ADMOB_NOTINITIALIZED
                                                         msg:@"AdMob Interstitial Ad is not initialized."]);
        }
        return;
    }

    NSLog(@"# PerpleAdMobRewardedVideoAd, show : %@", adUnitId);
    self.mCurrAdUnitId = adUnitId;

    // 광고 있으면 재생
    if ([self.mRewardVideoAd isReady]) {
        [self.mRewardVideoAd presentFromRootViewController:[[PerpleSDK sharedInstance] mViewController]];
    }
    // 광고 없으면 load
    else {
        if (self.mRewardVideoAd != nil) {
            [self loadRequestWithId:adUnitId];
        }

        if (self.mCallback) {
            self.mCallback(@"error", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_ADMOB_NOTLOADEDAD
                                                         msg:@"Ad is not loaded."]);
        }
    }
}

- (void) adMobLoadError:(GADRequestError *) error {
    NSInteger error_code = [error code];
    NSString* error_code_str = [NSString stringWithFormat:@"%ld", (long)error_code];

    NSLog(@"# PerpleAdMobRewardedVideoAd, adMobLoadError - code : %@", error_code_str);

    switch (error_code) {
        case kGADErrorInvalidRequest:
            // 잘못된 요청이므로 굳이 더 시도 하지 않는다.
            self.mTryLoadingCount = MAX_TRY_COUNT;
            break;
        case kGADErrorNoFill:
            break;
        case kGADErrorNetworkError:
            break;
        case kGADErrorServerError:
            break;
        case kGADErrorOSVersionTooLow:
            break;
        case kGADErrorTimeout:
            break;
        case kGADErrorInterstitialAlreadyUsed:
            break;
        case kGADErrorMediationDataError:
            break;
        case kGADErrorMediationAdapterError:
            break;
        case kGADErrorMediationNoFill:
            break;
        case kGADErrorMediationInvalidAdSize:
            break;
        case kGADErrorInternalError:
            break;
        case kGADErrorInvalidArgument:
            break;
        case kGADErrorReceivedInvalidResponse:
            break;
        default:
            break;
    }

    if (self.mCallback) {
        self.mCallback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_ADMOB_FAILLOAD
                                                subcode:error_code_str
                                                    msg:[error localizedDescription]]);
    }

}

#pragma mark GADRewardBasedVideoAdDelegate implementation
// 광고 보상 설정
// 광고 플레이가 종료되었을 시 발생한다
// 광고 종료하면서 보상 처리할 플래그 설정
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
    NSString *rewardMessage = [NSString stringWithFormat:@"# PerpleAdMob, Reward received with currency %@ , amount %lf", reward.type, [reward.amount doubleValue]];
    NSLog(@"%@", rewardMessage);

    self.mHasReward = YES;
}

// 광고 로드 완료
// 광고 로드 플래그
- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"# PerpleAdMobRewardedVideoAd, Reward based video ad is received.");
    NSLog(@"# PerpleAdMobRewardedVideoAd, Rewarded video adapter class name: %@", rewardBasedVideoAd.adNetworkClassName);

    // load 완료한 ad unit id 삭제
    self.mCurrAdUnitId = nil;

    // 광고 load 완료 콜백
    if (self.mCallback) {
        self.mCallback(@"receive", @"Reward based video ad is received.");
    }
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"# PerpleAdMobRewardedVideoAd, Opened reward based video ad.");
    if (self.mCallback) {
        self.mCallback(@"open", @"Reward based video ad is open.");
    }
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"# PerpleAdMobRewardedVideoAd, Reward based video ad started playing.");
    if (self.mCallback) {
        self.mCallback(@"start", @"Reward based video ad start.");
    }
}

- (void)rewardBasedVideoAdDidCompletePlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"# PerpleAdMobRewardedVideoAd, Reward based video ad has completed.");
    if (self.mCallback) {
        self.mCallback(@"complete", @"Reward based video ad is complete.");
    }
}

// 광고 종료
// 광고 종료하며 다시 광고를 load한다
// 동시에 보상 처리를 위한 콜백을 날림
- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"# PerpleAdMobRewardedVideoAd, Reward based video ad is closed.");

    // 보상 처리
    if (self.mCallback) {
        if (self.mHasReward) {
            self.mCallback(@"finish", @"reward based video ad is successfully finished.");
        }
        else {
            self.mCallback(@"cancel", @"reward based video ad is canceled.");
        }
    }
    self.mHasReward = NO;
    [self loadRequest];
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"# PerpleAdMobRewardedVideoAd, Reward based video ad will leave application.");
}

// 광고 load 실패
- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(GADRequestError *)error {

    // 에러 처리
    NSLog(@"# PerpleAdMobRewardedVideoAd, Reward based video ad failed to load.");
    [self adMobLoadError:error];

    // 광고 다시 load
    NSLog(@"# PerpleAdMobRewardedVideoAd, Reward based video ad retry to request.");
    [self loadRequest];
}

@end
*/
