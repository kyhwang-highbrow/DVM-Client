//
// Created by house.dr on 2016. 3. 16..
// Copyright (c) 2016 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KGInvitationSender : NSObject

@property (nonatomic, readonly) NSNumber *eventId;
@property (nonatomic, readonly) NSString *invitationUrl;
@property (nonatomic, readonly) NSNumber *userId;
@property (nonatomic, readonly) NSString *profileImageUrl;
@property (nonatomic, readonly) NSString *nickname;
@property (nonatomic, readonly) NSNumber *totalReceiversCount;

+ (instancetype)responseWithDictionary:(NSDictionary *)dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;
@end