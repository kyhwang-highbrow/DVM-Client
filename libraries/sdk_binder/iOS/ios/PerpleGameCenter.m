//
//  PerpleGameCenter.m
//  PerpleSDK
//
//  Created by Yonghak on 2016. 9. 4..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import "PerpleGameCenter.h"

@implementation PerpleGameCenter

#pragma mark - Properties

@synthesize mParentView;

#pragma mark - Initialization

- (id) initWithParentView:(UIViewController *)parentView {
    NSLog(@"PerpleGameCenter, GameCenter initializing.");

    if (self = [super init]) {
        self.mParentView = parentView;
    } else {
        NSLog(@"PerpleGameCenter, GameCenter initializing fail.");
    }

    return self;
}

- (void) dealloc {
    self.mParentView = nil;
    
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs

- (void) loginWithParam:(NSString *)param1 completion:(PerpleSDKCallback)callback {

    NSString *createCustomTokenServerUrl = param1;
    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

    if (localPlayer.authenticateHandler != nil) {
        if (localPlayer.isAuthenticated) {
            if ([createCustomTokenServerUrl isEqualToString:@""]) {
                callback(@"success", localPlayer.playerID);
            } else {
                [self getCustomTokenWithPlayerID:localPlayer.playerID
                                       serverUrl:createCustomTokenServerUrl
                                      completion:callback];
            }
        } else {
            callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GAMECENTER_LOGIN
                                                  msg:@"게임센터 로그인이 비활성화되었습니다.\n기기의 설정 > Game Center 메뉴에서\n로그인하신 후\n앱을 다시 실행해 주세요."]);
        }
    } else {
        localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
            if (viewController != nil) {
                [self.mParentView presentViewController:viewController
                                               animated:YES
                                             completion:nil];
            } else if (localPlayer.isAuthenticated) {
                if ([createCustomTokenServerUrl isEqualToString:@""]) {
                    callback(@"success", localPlayer.playerID);
                } else {
                    [self getCustomTokenWithPlayerID:localPlayer.playerID
                                           serverUrl:createCustomTokenServerUrl
                                          completion:callback];
                }
            } else {
                NSString *subcode = @"0";
                NSString *msg = @"게임센터 로그인에 실패하였습니다.";
                if (error != nil) {
                    subcode = [@(error.code) stringValue];
                    msg = error.localizedDescription;
                }
                callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GAMECENTER_LOGIN
                                                  subcode:subcode
                                                      msg:msg]);
            }
        };
    }
}

#pragma mark - Public methods

- (NSDictionary *) getProfileData {
    GKLocalPlayer *player = [GKLocalPlayer localPlayer];
    if (player.isAuthenticated) {
        return @{@"id":(player.playerID ? player.playerID : @""),
                 @"name":(player.alias ? player.alias : @"")};
    } else {
        return @{};
    }
}

#pragma mark - Private methods

- (void) getCustomTokenWithPlayerID:(NSString *)playerID
                          serverUrl:(NSString *)serverUrl
                         completion:(PerpleSDKCallback)callback {
    NSString *customToken;
    NSError *error;
    [self getCustomTokenFromPlatformServerWithPlayerID:playerID
                                             serverUrl:serverUrl
                                           customToken:&customToken error:&error];
    if (error == nil) {
        callback(@"success", customToken);
    } else {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GAMECENTER_GETCUSTOMTOKEN
                                          subcode:[@(error.code) stringValue]
                                              msg:error.localizedDescription]);
    }
}

- (void) getCustomTokenFromPlatformServerWithPlayerID:(NSString *)playerID
                                            serverUrl:(NSString *)serverUrl
                                          customToken:(NSString **)customToken
                                                error:(NSError **)error {
    NSString *result;

    [PerpleSDK requestHttpPostWithUrl:serverUrl contentBody:@{@"player_id":playerID} result:&result error:error];

    if (*error != nil) {
        *customToken = nil;
        return;
    }

    if (PerpleSDK.isDebug) {
        NSLog(@"PerpleSDK, GetCustomToken - PlayerID: %@, Result: %@", playerID, result);
    }

    NSDictionary *dict = [PerpleSDK getNSDictionaryFromJSONString:result];
    NSDictionary *status = dict[@"status"];

    if (status == nil) {
        *error = [NSError errorWithDomain:@"PerpleSDK" code:0 userInfo:@{NSLocalizedDescriptionKey:@"No status key in response data."}];
        *customToken = nil;
        return;
    }

    NSNumber *retcode = status[@"retcode"];
    NSString *message = status[@"message"];

    if (![retcode isEqualToNumber:@0]) {
        *error = [NSError errorWithDomain:@"PerpleSDK" code:[retcode integerValue] userInfo:@{NSLocalizedDescriptionKey:message}];
        *customToken = nil;
        return;
    }

    *customToken = dict[@"customToken"];
}

@end
