//
// Created by house.dr on 2016. 3. 16..
// Copyright (c) 2016 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KGInvitationState : NSObject

@property (nonatomic, readonly) NSNumber *userId;
@property (nonatomic, readonly) NSString *profileImageUrl;
@property (nonatomic, readonly) NSString *nickname;
@property (nonatomic, readonly) NSString *senderReward;
@property (nonatomic, readonly) NSString *senderRewardState;
@property (nonatomic, readonly) NSString *receiverReward;
@property (nonatomic, readonly) NSString *receiverRewardState;
@property (nonatomic, readonly) NSString *createdAt;

+ (instancetype)responseWithDictionary:(NSDictionary *)dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;
@end