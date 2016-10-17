//
//  KakaoGameAPI.h
//  kakao-ios-game-sdk
//
//  Created by Thomas on 2015. 9. 9..
//  Copyright (c) 2015년 Kakao. All rights reserved.
//

#import "RegisteredFriendContext.h"
#import "InvitableFriendContext.h"
#import "MultiChatContext.h"
#import "KageImageInfo.h"
#import "KOSessionTask+GuildAPI.h"
#import "KOSessionTask+KGStoryAPI.h"
#import "KGGuild.h"
#import "KGGuildMember.h"
#import "KOSessionTask+InvitationRewardAPI.h"

#import <Foundation/Foundation.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@class KGExtendedFriend;

typedef void(^KageImageTaskCompletionHandler)(KageImageInfo *imageInfo, NSError *error);

@interface KakaoGameAPI : NSObject

+ (KOSessionTask *)signUpTaskWithProperties:(NSDictionary *)properties completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

+ (void)logoutAndCloseWithCompletionHandler:(KOCompletionSuccessHandler)completionHandler;

+ (KOSessionTask *)unlinkTaskWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

+ (KOSessionTask *)meTaskWithCompletionHandler:(KOSessionTaskCompletionHandler)completionHandler;

+ (KOSessionTask *)profileUpdateTaskWithProperties:(NSDictionary *)properties
                              completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

+ (KOSessionTask *)registeredFriendsWithContext:(RegisteredFriendContext *)context completionHandler:(KOSessionFriendsTaskCompletionHandler)completionHandler;

+ (KOSessionTask *)invitableFriendsWithLimit:(InvitableFriendContext *)context completionHandler:(KOSessionFriendsTaskCompletionHandler)completionHandler;

+ (KOSessionTask *)recommendedInvitableFriendsWithLimit:(InvitableFriendContext *)context completionHandler:(KOSessionFriendsTaskCompletionHandler)completionHandler;

+ (KOSessionTask *)talkProfileTaskWithCompletionHandler:(KOSessionTaskCompletionHandler)completionHandler;

+ (KOSessionTask *)sendGameMessageTaskWithTemplateID:(NSString *)templateID
                                      receiverFriend:(KOFriend *)receiverFriend
                                    messageArguments:(NSDictionary *)messageArguments
                                   completionHandler:(void (^)(NSError *error))completionHandler;

+ (KOSessionTask *)sendInviteMessageTaskWithTemplateID:(NSString *)templateID
                                      receiverFriend:(KOFriend *)receiverFriend
                                    messageArguments:(NSDictionary *)messageArguments
                                   completionHandler:(void (^)(NSError *error))completionHandler;

+ (KOSessionTask *)sendRecommendedInviteMessageTaskWithTemplateID:(NSString *)templateID
                                                   receiverFriend:(KGExtendedFriend *)receiverFriend
                                                 messageArguments:(NSDictionary *)messageArguments
                                                completionHandler:(void (^)(NSError *error))completionHandler;

+ (KOSessionTask *)gameImageUploadTaskWithImage:(UIImage *)image completionHandler:(KageImageTaskCompletionHandler)completionHandler;

+ (KOSessionTask *)sendImageMessageTaskWithTemplateID:(NSString *)templateID
                                       receiverFriend:(KOFriend *)receiverFriend
                                     messageArguments:(NSDictionary *)messageArguments
                                                image:(UIImage *)image
                                    completionHandler:(void (^)(NSError *error))completionHandler;

+ (KOSessionTask *)multiChatListTaskWithContext:(MultiChatContext *)context
                          completionHandler:(void (^)(NSArray *chats, NSError *error))completionHandler;

+ (KOSessionTask *)sendMultiChatMessageTaskWithTemplateID:(NSString *)templateID
                                     receiverChat:(KOChat *)receiverChat
                                 messageArguments:(NSDictionary *)messageArguments
                                completionHandler:(void (^)(NSError *error))completionHandler;

+ (KOSessionTask *)storageImageUploadTaskWithImage:(UIImage *)image completionHandler:(KOSessionStorageImageTaskCompletionHandler)completionHandler;

+ (KOSessionTask *)storyIsStoryUserTaskWithCompletionHandler:(void (^)(BOOL isStoryUser, NSError *error))completionHandler;

+ (KOSessionTask *)postStoryWithTemplateId:(NSString *)templateId content:(NSString *)content completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

+ (KOSessionTask *)joinGuildChatWithWorldId:(NSString *)worldId guildId:guildId;

+ (KOSessionTask *)sendGuildMessageWithWorldId:(NSString *)worldId guildId:(NSString *)guildId templateId:(NSString *)templateId messageArguments:(NSDictionary *)messageArguments completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

+ (void)showMessageBlockDialogWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

+ (KOSessionTask *)invitationEventsWithCompletionHandler:(KOSessionInvitationEventsTaskCompletionHandler)completionHandler;

+ (KOSessionTask *)invitationEventInfoWithId:(NSNumber *)eventId CompletionHandler:(KOSessionInvitationEventInfoTaskCompletionHandler)completionHandler;

+ (KOSessionTask *)invitationStatesWithId:(NSNumber *)eventId CompletionHandler:(KOSessionInvitationStatesTaskCompletionHandler)completionHandler;

+ (KOSessionTask *)invitationSenderWithId:(NSNumber *)eventId CompletionHandler:(KOSessionInvitationSenderTaskCompletionHandler)completionHandler;

@end




