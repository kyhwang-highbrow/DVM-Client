//
// Created by house.dr on 2015. 9. 14..
// Copyright (c) 2015 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KageImageInfo : NSObject

@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) NSString *accessToken;

+ (instancetype)responseWithDictionary:(NSDictionary *)dictionary;

- (NSString *)imageUrl;

@end