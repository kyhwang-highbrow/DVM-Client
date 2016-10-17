//
//  KakaoiOS+Leaderboard.h
//  kakao-cocos2dx-ios-plugin
//
//  Created by Cody on 13. 10. 4..
//  Copyright (c) 2013년 Game Dept. All rights reserved.
//

#import "KakaoiOS.h"
#import <UIKit/UIKit.h>

@interface KakaoiOS (Leaderboard)

- (void)loadGameInfo;

- (void)loadGameUserInfo;

- (void)updateUser:(int)additionalHeart withCurrentHeart:(int)currentHeart withPublicData:(NSString *)publicData withPrivateData:(NSString *)privateData;

- (void)useHeart:(int)useHeart;

- (void)updateResult:(NSString *)key withScore:(int)score withExp:(int)exp withPublicData:(NSString *)publicData withPrivateData:(NSString *)privateData;

- (void)updateMultipleResults:(NSDictionary *)scores withExp:(int)exp withPublicData:(NSString *)publicData withPrivateData:(NSString *)privateData;

- (void)loadLeaderboard:(NSString *)key;

- (void)loadGameFriends;

-(void)sendLinkGameMessage:(NSString*)receiverId
            withTemplateId:(NSString*)templateId
           withGameMessage:(NSString*)gameMessage
                 withHeart:(int)heart
                  withData:(NSData*)data
                 withImage:(UIImage*)image
            withExecuteUrl:(NSString*)executeUrl
              withMetainfo:(NSDictionary*)metaInfo;

-(void)sendInviteLinkGameMessage:(NSString*)receiverId
                  withTemplateId:(NSString*)templateId
                  withExecuteUrl:(NSString*)executeUrl
                    withMetaInfo:(NSDictionary*)metaInfo;

- (void)loadGameMessages;

- (void)acceptGameMessage:(NSString *)messageId;

- (void)acceptAllGameMessages;

- (void)deleteUser;

- (void)blockMessage:(BOOL)beBlock;

@end
