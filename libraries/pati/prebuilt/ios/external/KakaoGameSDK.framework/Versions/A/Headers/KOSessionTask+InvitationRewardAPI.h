//
// Created by house.dr on 2016. 3. 15..
// Copyright (c) 2016 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@class KGInvitationEvent;
@class KGInvitationSender;

typedef void(^KOSessionInvitationEventsTaskCompletionHandler)(NSArray *invitationEvents, NSError *error);
typedef void(^KOSessionInvitationEventInfoTaskCompletionHandler)(KGInvitationEvent *event, NSError *error);
typedef void(^KOSessionInvitationStatesTaskCompletionHandler)(NSArray *invitationStates, NSError *error);
typedef void(^KOSessionInvitationSenderTaskCompletionHandler)(KGInvitationSender *invitationSender, NSError *error);

@interface KOSessionTask (InvitationRewardAPI)

+(instancetype)invitationEventsWithCompletionHandler:(KOSessionInvitationEventsTaskCompletionHandler)completionHandler;

+(instancetype)invitationEventInfoWithId:(NSNumber *)eventId CompletionHandler:(KOSessionInvitationEventInfoTaskCompletionHandler)completionHandler;

+(instancetype)invitationStatesWithId:(NSNumber *)eventId CompletionHandler:(KOSessionInvitationStatesTaskCompletionHandler)completionHandler;

+(instancetype)invitationSenderWithId:(NSNumber *)eventId CompletionHandler:(KOSessionInvitationSenderTaskCompletionHandler)completionHandler;

@end