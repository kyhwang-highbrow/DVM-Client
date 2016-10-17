//
//  KakaoSDKViewController.h
//  TouchRevolution
//
//  Created by Lucas Ryu on 12. 8. 20..
//  Copyright (c) 2012년 KAKAO Corp. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class UIImage;

@interface KakaoSDKViewController : NSObject

@property (nonatomic, copy) NSString *storyViewString;

+ (KakaoSDKViewController*)controller;
- (UIWindow*)currentKeyWindow;
- (void)addWindowSubview:(UIView*)subview;

- (void)showStoryViewWithImage:(UIImage*)image metaInfoArray:(NSArray *)metaInfoArray completionHandler:(void(^)(BOOL success, NSError *error))completionHandler;
- (void)showStoryViewWithImage:(UIImage*)image postString:(NSString *)postString metaInfoArray:(NSArray *)metaInfoArray completionHandler:(void (^)(BOOL, NSError *))completionHandler;
- (void)closeStoryView;

@end
