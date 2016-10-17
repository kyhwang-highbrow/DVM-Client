//
// Created by house.dr on 2015. 9. 23..
// Copyright (c) 2015 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "KGGuild.h"

typedef void(^KOSessionMyGuildsTaskCompletionHandler)(NSArray *myGuilds, NSError *error);

typedef void(^KOSessionGuildsTaskCompletionHandler)(NSDictionary *guilds, NSError *error);

typedef void(^KOSessionGuildInfoTaskCompletionHandler)(KGGuild *guild, NSError *error);

typedef void(^KOSessionCreateGuildCompletionHandler)(NSString *guildId, NSError *error);

typedef void(^KOSessionGuildMembersTaskCompletionHandler)(NSArray *guildMembers, NSError *error);

@interface KOSessionTask (GuildAPI)

+ (instancetype)joinGuildChatWithWorldId:(NSString *)worldId guildId:(NSString *)guildId;

+ (instancetype)sendGuildMessageWithWorldId:(NSString *)worldId guildId:(NSString *)guildId templateId:(NSString *)templateId messageArguments:(NSDictionary *)messageArguments completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;
@end