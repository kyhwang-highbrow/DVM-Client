//
// Created by house.dr on 2015. 9. 24..
// Copyright (c) 2015 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RoleType) {
    Member = 0,
    Leader,
    Sub_Leader
};

typedef NS_ENUM(NSInteger, JoinStatus) {
    Pending = 0,
    Join,
    Ban
};

@interface KGGuildMember : NSObject

@property (nonatomic, readonly) NSNumber *userId;
@property (nonatomic, readonly) NSString *guildId;
@property (nonatomic, readonly) NSString *nickName;
@property (nonatomic, readonly) NSString *profileImage;
@property (nonatomic, readonly) RoleType role;
@property (nonatomic, readonly) JoinStatus joinStatus;
@property (nonatomic, readonly) NSNumber *createdAt;
@property (nonatomic, readonly) NSNumber *updatedAt;
@property (nonatomic, readonly) NSNumber *lastAccessAt;

+ (instancetype)responseWithDictionary:(NSDictionary *)dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end