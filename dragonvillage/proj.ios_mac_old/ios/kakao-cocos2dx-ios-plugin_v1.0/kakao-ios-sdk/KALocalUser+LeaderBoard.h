//
//  KALocalUser+LeaderBoard.h
//  kakao-ios-sdk
//
//  Created by Lucas Ryu on 4/22/12.
//  Copyright (c) 2012 KAKAO Corp. All rights reserved.
//

#import "KALocalUser.h"
#import <Foundation/Foundation.h>

@class KAGameLinkMessageRequest;

@interface KALocalUser (LeaderBoard)

- (void)loadGameInfoWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)loadGameMeWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)loadGameFriendsWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)loadLeaderBoardWithParameters:(NSDictionary *)parameters withCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)loadGameMessagesWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)updateResult:(NSDictionary *)parameters withCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)updateResults:(NSDictionary *)parameters withCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)updateMeWithParameters:(NSDictionary *)parameters withCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)deleteMeWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)useHeartWithParameters:(NSDictionary *)parameters withCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)acceptMessageWithParameters:(NSDictionary *)parameters withCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)acceptAllMessagesWithCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)messageBlockWithParameters:(NSDictionary *)parameters withCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)sendLinkGameMessageWithReceiver:(NSString *)receiver_id withTemplate:(NSString *)template_id withHeart:(NSNumber *)heart withGameMessage:(NSString *)game_msg withData:(NSData *)data withMetaInfo:(NSDictionary *)metaInfo withCompletionHandler:(KACompletionResponseBlock)completionHandler;

- (void)sendInviteLinkGameMessageWithReceiver:(NSString *)receiver_id withTemplate:(NSString *)template_id withMetaInfo:(NSDictionary *)metaInfo withCompletionHandler:(KACompletionResponseBlock)completionHandler;

@end

@interface KALocalUser (Deprecated_Leaderboard)

- (void)sendInviteMessageWithParameters:(NSDictionary *)parameters withCompletionHandler:(KACompletionResponseBlock)completionHandler __attribute((deprecated("Deprecated - Use sendInviteLinkGameMessageWithReceiver:withTemplate:withMetaInfo:withCompletionHandler method instead of this.")));

- (void)sendGameMessageWithParameters:(NSDictionary *)parameters withCompletionHandler:(KACompletionResponseBlock)completionHandler __attribute((deprecated("Deprecated - Use sendLinkGameMessageWithReceiver:withTemplate:withHeart:withGameMessage:withData method instead of this.")));


@end