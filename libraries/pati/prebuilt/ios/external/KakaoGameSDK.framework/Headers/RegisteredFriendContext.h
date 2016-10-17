//
// Created by house.dr on 2015. 9. 13..
// Copyright (c) 2015 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>


@interface RegisteredFriendContext : KOFriendContext

+ (instancetype)contextWithLimit:(NSInteger)limit;

@end