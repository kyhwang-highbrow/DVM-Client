//
//  KakaoiOS.h
//  kakao-cocos2dx-ios-plugin
//
//  Created by Cody on 13. 9. 14..
//  Copyright (c) 2013년 Game Dept. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KakaoStringKey.h"

@interface KakaoiOS : NSObject

@property (nonatomic,assign) BOOL isProccessLogin;
@property (nonatomic,retain) NSURL *launchURL;

+(KakaoiOS*)sharedInstance;

-(void)registerEvent;
-(BOOL)handleOpenURL:(NSURL*)url;

-(void)sendSuccess:(NSString*)action withParam:(NSDictionary*)param;
-(void)sendError:(NSString*)action withError:(NSError*)error;


@end
