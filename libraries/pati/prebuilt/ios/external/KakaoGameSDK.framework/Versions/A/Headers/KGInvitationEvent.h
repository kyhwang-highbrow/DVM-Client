//
// Created by house.dr on 2016. 3. 15..
// Copyright (c) 2016 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KGInvitationEvent : NSObject

@property (nonatomic, readonly) NSNumber *eventId;
@property (nonatomic, readonly, getter=isEnabled) BOOL enabled;
@property (nonatomic, readonly) NSString *startsAt;
@property (nonatomic, readonly) NSString *endsAt;
@property (nonatomic, readonly) NSNumber *maxSenderRewardsCount;
@property (nonatomic, readonly) NSString *senderReward;
@property (nonatomic, readonly) NSString *receiverReward;
@property (nonatomic, readonly) NSString *invitationUrl;
@property (nonatomic, readonly) NSNumber *totalReceiversCount;

+ (instancetype)responseWithDictionary:(NSDictionary *)dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end