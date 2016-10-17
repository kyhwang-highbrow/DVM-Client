//
// Created by house.dr on 2016. 3. 16..
// Copyright (c) 2016 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@class KGExtendedFriend;

@interface KOSessionTask (RecommendedFriendsAPI)

+ (instancetype)recommendedFriendsWithContext:(KOFriendContext *)context
                 completionHandler:(KOSessionFriendsTaskCompletionHandler)completionHandler;

+ (instancetype)sendKGMessageTaskWithTemplateID:(NSString *)templateID
                                 receiverFriend:(KGExtendedFriend *)receiverFriend
                               messageArguments:(NSDictionary *)messageArguments
                              completionHandler:(void (^)(NSError *error))completionHandler;
@end