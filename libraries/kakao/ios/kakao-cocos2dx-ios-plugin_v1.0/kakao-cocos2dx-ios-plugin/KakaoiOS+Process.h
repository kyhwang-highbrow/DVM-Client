//
//  KakaoiOS+Process.h
//  kakao-cocos2dx-ios-plugin
//
//  Created by Cody on 13. 9. 15..
//  Copyright (c) 2013년 Game Dept. All rights reserved.
//

#import "KakaoiOS.h"
#import "KakaoMessageBlockViewController.h"
#import <UIKit/UIKit.h>

@interface KakaoiOS (Process) <KakaoMessageBlockViewDelegate>

- (void)initWithAccessToken:(NSString *)accessToken withRefreshToken:(NSString *)refreshToken;

- (void)authorized;

- (void)login;

- (void)loginWithWebview;

- (void)localUser;

- (void)friends;

- (void)sendLinkMessage:(UIImage *)image
         withTemplateId:(NSString *)templateId
         withReceiverId:(NSString *)receiverId
               withTags:(NSDictionary *)tags
         withExecuteUrl:(NSString *)executeUrl;

- (void)postStoryWithImage:(UIImage *)image withMessage:(NSString *)message withExecuteUrl:(NSString *)executeUrl;

- (void)logout;

- (void)unregister;

- (void)showAlertMessage:(NSString *)message;

- (void)showMessageBlockDialog;

@end
