//
//  KakaoiOS+Process.m
//  kakao-cocos2dx-ios-plugin
//
//  Created by Cody on 13. 9. 15..
//  Copyright (c) 2013년 Game Dept. All rights reserved.
//

#import "KakaoiOS+Process.h"
#import "KakaoMessageBlockViewController.h"
#import <Kakao.h>
#import <KakaoSDKViewController.h>

#define CLIENT_ID           @"91408462712127840"
#define CLIENT_SECRET_KEY   @"A2jBin4gNc0EJ1DVQQs1Dnxw5WtaZgmJgX1Clm6FnGugU2v+bYb+8mu2MMtSmb/3AJ/mxwMW1kjHqcSIfcSrkg=="

@implementation KakaoiOS (Process)

- (void)initWithAccessToken:(NSString *)accessToken withRefreshToken:(NSString *)refreshToken {

    KAAuth *kakao = [[KAAuth alloc] initWithClientID:CLIENT_ID
                                        clientSecret:CLIENT_SECRET_KEY
                                         redirectURL:[NSString stringWithFormat:@"kakao%@://exec", CLIENT_ID]
                                         accessToken:accessToken
                                        refreshToken:refreshToken];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kakaoAuthenticationDidChangeWithNotification:)
                                                 name:KAAuthenticationDidChangeNotification
                                               object:kakao];

    [KAAuth setSharedAuth:kakao];
    [self sendSuccess:[KakaoAction sharedInstance].Init withParam:nil];

    if (self.launchURL != nil) {
        [[KAAuth sharedAuth] handleOpenURL:self.launchURL];
        self.launchURL = nil;
    }
}

- (void)kakaoAuthenticationDidChangeWithNotification:(NSNotification *)notification {
    NSString *accessToken = [KAAuth sharedAuth].accessToken;
    NSString *refreshToken = [KAAuth sharedAuth].refreshToken;

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (accessToken != nil)
        [param setObject:accessToken forKey:[KakaoString sharedInstance].access_token];
    else
        [param setObject:@"" forKey:[KakaoString sharedInstance].access_token];

    if (refreshToken != nil)
        [param setObject:refreshToken forKey:[KakaoString sharedInstance].refresh_token];
    else
        [param setObject:@"" forKey:[KakaoString sharedInstance].refresh_token];

    [self sendSuccess:[KakaoAction sharedInstance].Token withParam:param];
}


- (void)authorized {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:[KAAuth sharedAuth].authenticated == YES ? @"true" : @"false" forKey:[KakaoString sharedInstance].authorized];
    [self sendSuccess:[KakaoAction sharedInstance].Authorized withParam:param];
}

- (void)login {
    if (self.isProccessLogin == YES)
        [[KAAuth sharedAuth] cancelRegistration];

    self.isProccessLogin = YES;
    [[KAAuth sharedAuth] registerWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                // success
                self.isProccessLogin = NO;
                [self sendSuccess:[KakaoAction sharedInstance].Login withParam:nil];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].Login withError:error];
            }
        });
    }];
}

- (void)localUser {
    [[KALocalUser localUser] loadLocalUserWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                // success
                [self sendSuccess:[KakaoAction sharedInstance].LocalUser withParam:response];
            }
            else {
                // error
                [self sendError:[KakaoAction sharedInstance].LocalUser withError:error];
            }
        });
    }];
}

- (void)friends {
    [[KALocalUser localUser] loadFriendsWithCompletionHandler:^(NSDictionary *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                // success
                [self sendSuccess:[KakaoAction sharedInstance].Friends withParam:response];
            }
            else {
                // error
                [self sendError:[KakaoAction sharedInstance].Friends withError:error];
            }
        });
    }];
}

- (void)sendLinkMessage:(UIImage *)image
         withTemplateId:(NSString *)templateId
         withReceiverId:(NSString *)receiverId
               withTags:(NSDictionary *)tags
         withExecuteUrl:(NSString *)executeUrl {
    NSMutableDictionary *metaInfo = [NSMutableDictionary dictionary];
    if (executeUrl != nil)
        [metaInfo setValue:executeUrl forKeyPath:@"executeurl"];

    if (image != nil)
        [metaInfo setValue:image forKeyPath:@"image"];

    if (tags != nil) {
        NSArray *keys = [tags allKeys];
        for (NSString *key in keys) {
            [metaInfo setObject:tags[key] forKey:key];
        }
    }

    [[KALocalUser localUser] sendLinkMessageWithReceiver:receiverId templateId:templateId metaInfo:metaInfo completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success == YES) {
                [self sendSuccess:[KakaoAction sharedInstance].SendLinkMessage withParam:nil];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].SendLinkMessage withError:error];
            }
        });
    }];
}

- (void)postStoryWithImage:(UIImage *)image withMessage:(NSString *)message withExecuteUrl:(NSString *)executeUrl {
    NSDictionary *androidMetaInfo = [NSDictionary dictionaryWithObjectsAndKeys:
            @"android", @"os",
            executeUrl, @"executeurl", nil];
    NSDictionary *iOSMetaInfo = [NSDictionary dictionaryWithObjectsAndKeys:
            @"ios", @"os",
            executeUrl, @"executeurl", nil];

    [[KakaoSDKViewController controller] showStoryViewWithImage:image
                                                     postString:message
                                                  metaInfoArray:[NSArray arrayWithObjects:androidMetaInfo, iOSMetaInfo, nil]
                                              completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self sendSuccess:[KakaoAction sharedInstance].PostToKakaoStory withParam:nil];
            }
            else {
                [self sendError:[KakaoAction sharedInstance].PostToKakaoStory withError:error];
            }
            [[KakaoSDKViewController controller] closeStoryView];
        });
    }];
}

- (void)logout {
    [[KALocalUser localUser] logoutWithCompletionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                // success
                [self sendSuccess:[KakaoAction sharedInstance].Logout withParam:nil];
            }
            else {
                // error
                [self sendError:[KakaoAction sharedInstance].Logout withError:error];
            }
        });
    }];
}

- (void)unregister {
    [[KALocalUser localUser] unregisterWithCompletionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                // success
                [self sendSuccess:[KakaoAction sharedInstance].Unregister withParam:nil];
            }
            else {
                // error
                [self sendError:[KakaoAction sharedInstance].Unregister withError:error];
            }
        });
    }];
}

- (void)showAlertMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"KAKAO" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        alert = nil;

    });
}

- (void)showMessageBlockDialog {
    dispatch_async(dispatch_get_main_queue(), ^{
        [KakaoMessageBlockViewController showMessageBlockDialog:^(BOOL success, NSError *error) {
            if(success) {
                [self sendSuccess:[KakaoAction sharedInstance].ShowMessageBlockDialog withParam:nil];
            } else {
                [self sendError:[KakaoAction sharedInstance].ShowMessageBlockDialog withError:error];
            }
        } withDelegate:self];
    });
}

- (void)onKakaoMessageBlockViewDidClickClose {
//    [self sendSuccess:[KakaoAction sharedInstance].ShowMessageBlockDialog withParam:<#(NSDictionary*)param#>];
}

@end
