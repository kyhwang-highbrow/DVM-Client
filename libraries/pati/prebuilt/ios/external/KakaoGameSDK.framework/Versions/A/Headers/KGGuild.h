//
// Created by house.dr on 2015. 9. 23..
// Copyright (c) 2015 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGGuildMember.h"

@class KGGuildMember;


typedef NS_ENUM(NSInteger, JoinType) {
    AutoJoinType = 0,
    ManualJoinType
};

typedef NS_ENUM(NSInteger, PrivacyType) {
    PublicType = 0,
    PrivateType
};

typedef NS_ENUM(NSInteger, MemberListAccessLevel) {
    AnyoneAccess = 0,
    MemberAccess,
    AdminAccess
};


@interface KGGuild : NSObject

@property (nonatomic, readonly) NSString *guildId;
@property (nonatomic, readonly) NSString *explanation;
@property (nonatomic, readonly) NSString *guildName;
@property (nonatomic, readonly) NSString *imageUrl;
@property (nonatomic, readonly) NSString *chatLink;
@property (nonatomic, readonly) JoinType joinType;
@property (nonatomic, readonly) KGGuildMember *leader;
@property (nonatomic, readonly) PrivacyType privacy;
@property (nonatomic, readonly) MemberListAccessLevel memberListAccessLevel;
@property (nonatomic, readonly, getter=isAllowRejoin) BOOL allowRejoin;
@property (nonatomic, readonly, getter=isDenyExitChatRoom) BOOL denyExitChatRoom;
@property (nonatomic, readonly) NSNumber *memberCount;
@property (nonatomic, readonly) NSNumber *maxMemberCount;
@property (nonatomic, readonly) NSNumber *createdAt;
@property (nonatomic, readonly) NSNumber *updatedAt;
@property (nonatomic, readonly) KGGuildMember *me;
@property (nonatomic, readonly) NSArray *subLeaders;

+ (instancetype)responseWithDictionary:(NSDictionary *)dictionary;

+ (NSString *)convertJoinType:(JoinType)joinType;

+ (NSString *)convertPrivacy:(PrivacyType)privacy;

+ (NSString *)convertMemberListAccessLevel:(MemberListAccessLevel)level;

+ (NSString *)convertIsAllowRejoin:(BOOL)isAllowRejoin;

+ (NSString *)convertIsDenyExitChatRoom:(BOOL)isAllowRejoin;

- (BOOL)isAdmin;

- (BOOL)isLeader;

- (BOOL)canJoin;

- (BOOL)isJoined;

- (BOOL)isPending;

- (id)initWithDictionary:(NSDictionary *)dictionary;


@end