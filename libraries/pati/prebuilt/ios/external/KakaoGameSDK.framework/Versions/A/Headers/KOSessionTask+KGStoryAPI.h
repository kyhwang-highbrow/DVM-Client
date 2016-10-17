//
// Created by house.dr on 2015. 10. 20..
// Copyright (c) 2015 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@interface KOSessionTask (KGStoryAPI)

+ (instancetype)postStoryWithTemplateId:(NSString *)templateId content:(NSString *)content completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

@end