//
//  PerpleNaver.h
//  PerpleSDK
//
//  Created by PerpleLab on 2016. 8. 29..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NaverCafeSDK/NCSDKManager.h>
#import <NaverCafeSDK/NCSDKLoginManager.h>
#import <NaverCafeSDK/NCSDKRecordManager.h>
#import "PerpleSDK.h"

@interface PerpleNaver : NSObject <NCSDKManagerDelegate, NCSDKRecordManagerDelegate>

#pragma mark - Properties

@property PerpleSDKCallback mCafeCallback;
@property BOOL mIsShowGlink;
@property (nonatomic, retain) UIViewController *mParentView;

#pragma mark - Initialization

- (id) initWithParentView:(UIViewController *)parentView isLandspape:(BOOL)isLandscape clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret cafeId:(NSInteger)cafeId neoIdConsumerKey:(NSString *)neoIdConsumerKey communityId:(NSInteger)communityId urlScheme:(NSString *)urlScheme;

#pragma mark - APIs

- (BOOL) cafeIsShowGlink;
- (void) cafeShowWidgetWhenUnloadSdk:(BOOL)isShowWidget;
- (void) cafeSetWidgetStartPosition:(BOOL)isLeft heightPercentage:(int)heightPercentage;
- (void) cafeStartWidget;
- (void) cafeStopWidget;
- (void) cafeStartWithTapIndex:(NSUInteger)tapIndex;
- (void) cafeStop;
- (void) cafeStartWrite;
- (void) cafeStartWriteWithType:(GLArticlePostType)type filePath:(NSString *)filePath;
- (void) cafeStartWithArticle:(int)articleId;
- (void) cafeSyncGameUserId:(NSString *)gameUserId;
- (void) cafeSetUseVideoRecord:(BOOL)isSetUseVideoRecord;
- (void) cafeSetUseScreenshot:(BOOL)isSetUseScreenshot;
- (void) cafeScreenshot;
- (void) cafeSetCallback:(PerpleSDKCallback)callback;
- (void) cafeInitGlobalPlug:(NSString *)neoIdConsumerKey communityId:(NSInteger)communityId channelID:(NSInteger)channelID;
- (void) cafeSetChannelCode:(NSString*)code;
- (NSString *) cafeGetChannelCode;

- (NSString *) screenShotFilePath;

#pragma mark - AppDelegate

// AppDelegate
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options;

@end
