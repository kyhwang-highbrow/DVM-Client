//
//  PerpleNaver.m
//  PerpleSDK
//
//  Created by PerpleLab on 2016. 8. 29..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import "PerpleNaver.h"

@implementation PerpleNaver

#pragma mark - Properties

@synthesize mCafeCallback;
@synthesize mIsShowGlink;
@synthesize mParentView;

#pragma mark - Initialization

- (id) initWithParentView:(UIViewController *)parentView
              isLandspape:(BOOL)isLandscape
                 clientId:(NSString *)clientId
             clientSecret:(NSString *)clientSecret
                   cafeId:(NSInteger)cafeId
         neoIdConsumerKey:(NSString *)neoIdConsumerKey
              communityId:(NSInteger)communityId
                urlScheme:(NSString *)urlScheme {
    NSLog(@"PerpleNaver, Naver initializing.");

    if (self = [super init]) {
        self.mParentView = parentView;

        // Do any additional setup after loading the view, typically from a nib.
        if (cafeId > 0) {
            [[NCSDKManager getSharedInstance] setNaverLoginClientId:clientId
                                             naverLoginClientSecret:clientSecret
                                                             cafeId:cafeId];
        }

        //use Plug (global)
        if (communityId > 0) {
            [[NCSDKManager getSharedInstance] setNeoIdConsumerKey:neoIdConsumerKey
                                                      communityId:communityId];
        }

        if (cafeId > 0 || communityId > 0) {
            [[NCSDKManager getSharedInstance] setParentViewController:self.mParentView];
            [[NCSDKManager getSharedInstance] setNcSDKDelegate:self];
            //[[NCSDKManager getSharedInstance] setChannelCode:KOREAN];
            [[NCSDKManager getSharedInstance] setOrientationIsLandscape:isLandscape];
            [[NCSDKLoginManager getSharedInstance] setNaverLoginURLScheme:urlScheme];

            //record init
            [[NCSDKRecordManager getSharedInstance] setBaseViewController:parentView];
            [[NCSDKRecordManager getSharedInstance] setNcSDKRecordDelegate:self];

            //record widget on
            [[NCSDKManager getSharedInstance] setUseWidgetVideoRecord:YES];
        }
    } else {
        NSLog(@"PerpleNaver, Naver initializing fail.");
    }

    return self;
}

- (void) dealloc {
    self.mParentView = nil;

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs

- (BOOL) cafeIsShowGlink {
    return self.mIsShowGlink;
}

- (void) cafeShowWidgetWhenUnloadSdk:(BOOL)isShowWidget {
    [NCSDKManager getSharedInstance].showWidgetWhenUnloadSDK = isShowWidget;
}

- (void) cafeSetWidgetStartPosition:(BOOL)isLeft
                   heightPercentage:(int)heightPercentage {
    [[NCSDKManager getSharedInstance] setWidgetStartPosition:isLeft andY:heightPercentage];
}


- (void) cafeStartWidget {
    [[NCSDKManager getSharedInstance] startWidget];
}

- (void) cafeStopWidget {
    [[NCSDKManager getSharedInstance] stopWidget];
}

- (void) cafeStartWithTapIndex:(NSUInteger)tapIndex {
    [[NCSDKManager getSharedInstance] setParentViewController:self.mParentView];
    [[NCSDKManager getSharedInstance] setNcSDKDelegate:self];

    [[NCSDKManager getSharedInstance] presentMainViewControllerWithTabIndex:tapIndex];
}

- (void) cafeStop {
    [[NCSDKManager getSharedInstance] dismissMainViewController];
}

- (void) cafeStartWrite {
    [[NCSDKManager getSharedInstance] setParentViewController:self.mParentView];
    [[NCSDKManager getSharedInstance] setNcSDKDelegate:self];

    [[NCSDKManager getSharedInstance] presentArticlePostViewController];
}

// type : 1 (Image), 2 (Video)
// filePath : uri 형식의 동영상/이미지 파일 경로
- (void) cafeStartWriteWithType:(GLArticlePostType)type
                       filePath:(NSString *)filePath {
    [[NCSDKManager getSharedInstance] setParentViewController:self.mParentView];
    [[NCSDKManager getSharedInstance] setNcSDKDelegate:self];

    [[NCSDKManager getSharedInstance] presentArticlePostViewControllerWithType:type filePath:filePath];
}

- (void) cafeStartWithArticle:(int)articleId {
    [[NCSDKManager getSharedInstance] setParentViewController:self.mParentView];
    [[NCSDKManager getSharedInstance] setNcSDKDelegate:self];

    [[NCSDKManager getSharedInstance] presentMainViewControllerWithArticleId:articleId];
}

- (void) cafeSyncGameUserId:(NSString *)gameUserId {
    [[NCSDKManager getSharedInstance] syncGameUserId:gameUserId];
}

- (void) cafeSetUseVideoRecord:(BOOL)isSetUseVideoRecord {
    [[NCSDKManager getSharedInstance] setUseWidgetVideoRecord:isSetUseVideoRecord];
}

- (void) cafeSetUseScreenshot:(BOOL)isSetUseScreenshot {
    [[NCSDKManager getSharedInstance] setUseWidgetScreenShot:isSetUseScreenshot];
}

- (void) cafeScreenshot {
    [[NCSDKManager getSharedInstance] setParentViewController:self.mParentView];
    [[NCSDKManager getSharedInstance] setNcSDKDelegate:self];

    NSString *filePath = [self screenShotFilePath];
    [[NCSDKManager getSharedInstance] presentArticlePostViewControllerWithType:kGLArticlePostTypeImage filePath:filePath];
}

- (void) cafeSetCallback:(PerpleSDKCallback)callback {
    self.mCafeCallback = callback;
}

- (void) cafeInitGlobalPlug:(NSString *)neoIdConsumerKey communityId:(NSInteger)communityId channelID:(NSInteger)channelID {
    if( channelID > 0 ) {
        [[NCSDKManager getSharedInstance] setNeoIdConsumerKey:neoIdConsumerKey
                                                  communityId:communityId
                                                    channelId:channelID];
    }
    else {
        [[NCSDKManager getSharedInstance] setNeoIdConsumerKey:neoIdConsumerKey
                                                  communityId:communityId];
    }
}

- (void) cafeSetChannelCode:(NSString*)code {
    [[NCSDKManager getSharedInstance] setChannelCode:code];
}

- (NSString *) cafeGetChannelCode {
    return [[NCSDKManager getSharedInstance] currentChannelCode];
}

- (NSString *) screenShotFilePath {
    UIView *targetScreen = self.mParentView.view;

    UIGraphicsBeginImageContextWithOptions(targetScreen.bounds.size, targetScreen.opaque, 0.0);
    [targetScreen.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *pngData = UIImagePNGRepresentation(screengrab);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"GLAttachImage.png"];
    [pngData writeToFile:filePath atomically:YES];

    return filePath;
}

#pragma mark - NCSDKManagerDelegate

// NCSDKManagerDelegate
// SDK 시작
- (void) ncSDKViewDidLoad {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, ncSDKViewDidLoad");
    }

    self.mIsShowGlink = YES;

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"start", @"");
    }
}

// NCSDKManagerDelegate
// SDK 종료
- (void) ncSDKViewDidUnLoad {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, ncSDKViewDidUnLoad");
    }

    self.mIsShowGlink = NO;

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"stop", @"");
    }
}

// NCSDKManagerDelegate
// 카페 가입 완료
- (void) ncSDKJoinedCafeMember {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, 카페 가입 완료");
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"join", @"");
    }
}

// NCSDKManagerDelegate
// 게시글 등록 완료
- (void) ncSDKPostedArticleAtMenu:(NSInteger)menuId
                 attachImageCount:(NSInteger)imageCount
                 attachVideoCount:(NSInteger)videoCount {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, 게시글 등록 완료, 게시판 아이디[%@], 이미지 카운트[%@], 비디오 카운트[%@]", @(menuId), @(imageCount), @(videoCount));
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"article", [PerpleSDK getJSONStringFromNSDictionary:@{@"menuId":@(menuId),
                                                                                  @"imageCount":@(imageCount),
                                                                                  @"videoCount":@(videoCount)}]);
    }
}

// NCSDKManagerDelegate
// 댓글 등록 완료
- (void) ncSDKPostedCommentAtArticle:(NSInteger)articleId {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, 댓글 등록 완료, 게시글 아이디[%@]", @(articleId));
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"comment", [@(articleId) stringValue]);
    }
}

// NCSDKManagerDelegate
// 스크린샷 요청
- (void) ncSDKRequestScreenShot {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, 스크린샷 요청");
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"screenshot", @"");
    }
}

// NCSDKManagerDelegate
// 투표 완료
- (void) ncSDKDidVoteAtArticle:(NSInteger)articleId {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, 투표 완료, 게시글 아이디[%@]", @(articleId));
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"vote", [@(articleId) stringValue]);
    }
}

// NCSDKManagerDelegate
// 이미지 포함 게시글 등록 완료
- (void) ncSDKWidgetPostArticleWithImage {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, ncSDKWidgetPostArticleWithImage");
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"article", @"image");
    }
}

// NCSDKManagerDelegate
// 동영상 녹화 완료
- (void) ncSDKWidgetSuccessVideoRecord {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, ncSDKWidgetSuccessVideoRecord");
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"record", @"");
    }
}

- (void) ncSDKAppSchemeBanner:(NSString *)appScheme {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, ncSDKAppSchemeBanner");
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"banner", @"");
    }
}

// 스트리밍 종료
- (void)ncSDKDidEndStreamingLiveViewCount:(NSInteger)viewCount
                                likeCount:(NSInteger)likeCount {
    if( [PerpleSDK isDebug] ) {
        NSLog(@"스트리밍 종료, 조회수: [%@], 좋아요 수: [%@]", viewCount, likeCount);
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"end_streaming", [PerpleSDK getJSONStringFromNSDictionary:@{@"viewCount":@(viewCount),
                                                                                        @"likeCount":@(likeCount)}] );
    }
}

// 라이브 시청 종료
- (void)ncSDKDidEndWatchingLiveSeconds:(NSInteger)seconds {
    if( [PerpleSDK isDebug] ) {
        NSLog(@"라이브 시청 종료, 시청시간: [%@]", seconds);
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"end_live_watch", [@(seconds) stringValue]);
    }
}

#pragma mark - NCSDKRecordDelegate
- (void)ncSDKRecordStart {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, ncSDKRecordStart");
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"record_start", @"");
    }
}
- (void)ncSDKRecordError:(NSString *)errorMsg {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, ncSDKRecordError : %@", errorMsg);
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"record_error", errorMsg);
    }
}
- (void)ncSDKRecordFinish {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, ncSDKRecordFinish");
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"record", @"");
    }
}
- (void)ncSDKRecordFinishWithPreview {
    if ([PerpleSDK isDebug]) {
        NSLog(@"PerpleNaver, ncSDKRecordFinishWithPreview");
    }

    if (self.mCafeCallback != nil) {
        self.mCafeCallback(@"record_FinishWithPreview", @"");
    }
}

#pragma mark - AppDelegate

// AppDelegate
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    return [[NCSDKLoginManager getSharedInstance] finishNaverLoginWithURL:url];
}

@end
