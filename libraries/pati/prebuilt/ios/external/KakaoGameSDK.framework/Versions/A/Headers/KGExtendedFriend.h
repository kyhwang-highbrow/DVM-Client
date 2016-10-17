//
// Created by house.dr on 2016. 3. 17..
// Copyright (c) 2016 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>


@interface KGExtendedFriend : KOFriend

@property (nonatomic, readonly) NSString *impressionId;

+ (instancetype)responseWithDictionary:(NSDictionary *)dictionary;

@end