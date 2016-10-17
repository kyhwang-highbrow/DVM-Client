//
// Created by house.dr on 2015. 9. 15..
// Copyright (c) 2015 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>


@interface MultiChatContext : KOChatContext

+ (instancetype)contextWithLimit:(NSInteger)limit;

@end