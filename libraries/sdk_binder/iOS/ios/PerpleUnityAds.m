//
//  PerpleUnityAds.m
//  PerpleSDK
//
//  Created by PerpleLab on 2017. 8. 16..
//  Copyright © 2017년 PerpleLab. All rights reserved.
//
/*
#import "PerpleUnityAds.h"

@implementation PerpleUnityAds

@synthesize mParentView;
@synthesize mGameId;
@synthesize mIsDebug;
@synthesize mCallback;

- (id) initWithGameId:(NSString *)gameId
           parentView:(UIViewController *)view
                debug:(BOOL)isDebug {

    if (self = [super init]) {
        self.mGameId = gameId;
        self.mIsDebug = isDebug;
        self.mParentView = view;
    } else {
        NSLog(@"PerpleUnityAds, UnityAds initializing fail.");
    }

    return self;
}

- (void) dealloc {
    self.mParentView = nil;
    self.mGameId = nil;

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)start:(BOOL)isTestMode
     metaData:(NSString *)metaData
   completion:(PerpleSDKCallback)callback {
    self.mCallback = callback;

    if ([UnityAds isInitialized]) {
        if (self.mCallback) {
            self.mCallback(@"error", @"ALREADY_INITIALIZED");
        }
        return;
    }

    if (![metaData isEqualToString:@""]) {
        NSDictionary *dic = [PerpleSDK getNSDictionaryFromJSONString:metaData];
        NSString *name = [dic objectForKey:@"name"];
        NSString *version = [dic objectForKey:@"version"];

        id mediationMetaData = [[UADSMediationMetaData alloc] init];
        [mediationMetaData setName:name];
        [mediationMetaData setVersion:version];
        [mediationMetaData commit];
    }

    [UnityAds initialize:self.mGameId testMode:isTestMode];
    [UnityAds addDelegate:self];
    [UnityAds setDebugMode:self.mIsDebug];
}

- (void)show:(NSString *)placementId
    metaData:(NSString *)metaData {

    if (![UnityAds isInitialized]) {
        if (self.mCallback) {
            self.mCallback(@"error", @"NOT_INITIALIZED");
        }
        return;
    }

    NSString *serverId = @"";
    NSString *ordinalId = @"";

    if (![metaData isEqualToString:@""]) {
        NSDictionary *dic = [PerpleSDK getNSDictionaryFromJSONString:metaData];
        serverId = [dic objectForKey:@"serverId"];
        ordinalId = [dic objectForKey:@"ordinalId"];
    }

    if ([placementId isEqualToString:@""]) {
        if ([UnityAds isReady]) {

            if (serverId != nil && ![serverId isEqualToString:@""]) {
                id playerMetaData = [[UADSPlayerMetaData alloc] init];
                [playerMetaData setServerId:serverId];
                [playerMetaData commit];
            }

            if (ordinalId != nil && ![ordinalId isEqualToString:@""]) {
                id mediationMetaData = [[UADSMediationMetaData alloc] init];
                [mediationMetaData setOrdinal:[ordinalId intValue]];
                [mediationMetaData commit];
            }

            [UnityAds show:self.mParentView];
        } else {
            if (self.mCallback) {
                self.mCallback(@"error", @"NOT_READY");
            }
        }

    } else {
        if ([UnityAds isReady:placementId]) {

            if (serverId != nil && ![serverId isEqualToString:@""]) {
                id playerMetaData = [[UADSPlayerMetaData alloc] init];
                [playerMetaData setServerId:serverId];
                [playerMetaData commit];
            }

            if (ordinalId != nil && ![ordinalId isEqualToString:@""]) {
                id mediationMetaData = [[UADSMediationMetaData alloc] init];
                [mediationMetaData setOrdinal:[ordinalId intValue]];
                [mediationMetaData commit];
            }

            [UnityAds show:self.mParentView placementId:placementId];
        } else {
            if (self.mCallback) {
                self.mCallback(@"error", @"NOT_READY");
            }
        }
    }
}

- (void)unityAdsReady:(NSString *)placementId {
    if (self.mCallback) {
        self.mCallback(@"ready", placementId);
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    if (self.mCallback) {
        NSString *errorCode = @"ERROR";
        switch (error) {
            case kUnityAdsErrorInitializedFailed:
                errorCode = @"INITIALIZE_FAILED";
                break;
            case kUnityAdsErrorVideoPlayerError:
                errorCode = @"VIDEO_PLAYER_ERROR";
                break;
            case kUnityAdsErrorNotInitialized:
                errorCode = @"NOT_INITIALIZED";
                break;
            case kUnityAdsErrorDeviceIdError:
                errorCode = @"DEVICE_ID_ERROR";
                break;
            case kUnityAdsErrorShowError:
                errorCode = @"SHOW_ERROR";
                break;
            case kUnityAdsErrorFileIoError:
                errorCode = @"FILE_IO_ERROR";
                break;
            case kUnityAdsErrorInternalError:
                errorCode = @"INTERNAL_ERROR";
                break;
            case kUnityAdsErrorInvalidArgument:
                errorCode = @"INVALID_ARGUMENT";
                break;
            case kUnityAdsErrorAdBlockerDetected:
                errorCode = @"AD_BLOCKER_DETECTED";
                break;
            case kUnityAdsErrorInitSanityCheckFail:
                errorCode = @"INIT_SANITY_CHECK_FAIL";
                break;
        }
        self.mCallback(@"error", errorCode);
    }
}

- (void)unityAdsDidStart:(NSString *)placementId {
    if (self.mCallback) {
        self.mCallback(@"start", placementId);
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    if (self.mCallback) {
        NSString *result = @"ERROR";
        switch (state) {
            case kUnityAdsFinishStateError:
                result = @"ERROR";
                break;
            case kUnityAdsFinishStateSkipped:
                result = @"SKIPPED";
                break;
            case kUnityAdsFinishStateCompleted:
                result = @"COMPLETED";
                break;
        }
        NSString *info = [PerpleSDK getJSONStringFromNSDictionary:@{@"placementId":placementId, @"result":result}];
        self.mCallback(@"finish", info);
    }
}

@end
*/
