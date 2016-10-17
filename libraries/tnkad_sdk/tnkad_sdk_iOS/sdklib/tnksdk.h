//
//  tnksdk.h
//  tnksdk
//
//  Created by TnkFactory on 12. 3. 5..
//  Copyright (c) 2012 TnkFactory Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 게시앱 상태값 정의
#define TNK_STATE_NO        0
#define TNK_STATE_YES       1
#define TNK_STATE_TEST      2
#define TNK_STATE_CHECK     3
#define TNK_STATE_PASSED    4
#define TNK_STATE_STOP      8
#define TNK_STATE_ERROR     9
#define TNK_STATE_UNKNOWN   99

#define TNK_CODE_MALE       @"M"
#define TNK_CODE_FEMALE     @"F"

// Interstitial TnkAdViewDelegate 관련 상수값 정의
#define AD_CLOSE_SIMPLE     0   // 사용자가 닫기버튼을 눌러서 광고화면을 닫은 경우
#define AD_CLOSE_CLICK      1   // 사용자가 광고를 클릭해서 화면이 닫히는 경우
#define AD_CLOSE_EXIT       2   // 사용자가 종료버튼을 클릭해서 화면을 닫은 경우

#define AD_FAIL_NO_AD       -1  // no ad available
#define AD_FAIL_NO_IMAGE    -2  // ad image not available
#define AD_FAIL_TIMEOUT     -3  // ad arrived after 5 secs.
#define AD_FAIL_CANCEL      -4  // ad frequency settings
#define AD_FAIL_NOT_PREPARED     -5      // not prepared (2015.05.12)

#define AD_FAIL_SYSTEM      -9

#define TNK_PPI             @"__tnk_ppi__"
#define TNK_CPC             @"__tnk_cpc__"

// for Native Ad
#define AD_STYLE_TEXT_ONLY      0
#define AD_STYLE_PORTRAIT       1
#define AD_STYLE_LANDSCAPE      2
#define AD_STYLE_SQUARE         3
#define AD_STYLE_ICON           4

@protocol TnkAdViewDelegate <NSObject>
@optional

// Called when AdListView is closed
- (void)adListViewClosed;

// 전면광고 화면 닫힐 때 호출됩니다. 화면이 닫히는 이유를 파라메터로 전달해 줍니다.
- (void)adViewDidClose:(int)type;

// 전면 광고를 화면에 띄우지 못했을 경우 호출됩니다.
// 시스템 오류나 광고가 없어서 광고를 띄우지 못했을 경우,
// 광고가 늦게 도착(5초 이상) 하여 광고가 뜨지 않은 경우,
// 광고 노출 주기에 따라서 노출이 취소된 경우에 호출됩니다.
- (void)adViewDidFail:(int)errCode;

// 전면광고 화면이 나타나는 시점에 호출됩니다.
- (void)adViewDidShow;

// 전면 광고 prepare: API 호출 후 show: API 호출 전에 광고가 도착하면 호출됩니다.
// 만약 광고 도착 전에 show: API 가 호출된 경우에는 이후 광고가 도착하였을 때
// 바로 광고가 표시되고 adViewDidShow:가 호출됩니다.
- (void)adViewDidLoad;
@end

@protocol IconLoaderCell <NSObject>

- (void) setImageIcon:(UIImage *)image;
- (void) setKey:(id)key;
- (id) getKey;

@end

// adlistitem 용 abstract class
@interface AdListItemView : UIControl <IconLoaderCell>

+ (float) calculateHeight:(float)width;
- (void) setData:(NSDictionary *)dic;
- (void) setImageIcon:(UIImage *)image; // from IconLoaderCell

@end

// 광고리스트 아이템 커스터마이징할 때 제공해야할 protocol
@protocol AdListItemViewFactory <NSObject>

- (AdListItemView *) getViewInstance:(CGRect)frame;
- (float) getViewHeight:(float)width;

@end

// ServiceCallback
@protocol TnkServiceCallback <NSObject>

@required
- (void)onServiceReturn:(id)sender;

@optional
- (void)onServiceError:(id)sender;

@end

// Native Ad (2015.05.14)

@class TnkNativeAd;

@protocol TnkNativeAdDelegate <NSObject>

@optional

- (void) didNativeAdFail:(TnkNativeAd *)ad error:(int)errCode;
- (void) didNativeAdLoad:(TnkNativeAd *)ad;
- (void) didNativeAdClick:(TnkNativeAd *)ad;
- (void) didNativeAdShow:(TnkNativeAd *)ad;

@end

@interface TnkNativeAd : NSObject <TnkServiceCallback>

@property (nonatomic, weak) id<TnkNativeAdDelegate> delegate;
@property (nonatomic, strong) NSString *logicName;
@property (nonatomic, assign) NSInteger adStyle;

- (void) prepare:(NSString *)logicName;
- (void) prepare:(NSString *)logicName delegate:(id<TnkNativeAdDelegate>)delegate;
- (void) prepare;

// Common data for PPI, CPC
- (UIImage *) getCoverImage;
- (UIImage *) getIconImage;
- (NSString *) getTitle;
- (NSString *) getDescription;

// for PPI only
- (NSString *) getPointName;
- (NSNumber *) getRewardPoint;
- (NSInteger) getRewardType;
- (NSString *) getActionText;

// attach, detach
- (void) attachLayout:(UIView *)view;
- (void) attachLayout:(UIView *)view clickView:(UIView *)clickView;
- (UIView *) getAttachedLayout;

- (void) detachLayout;

- (void) handleClick;
@end

// New API for Interstitial Ad (2015.05.14)

@class TnkInterstitialAd;

@protocol TnkInterstitialDelegate <NSObject>

@optional

- (void)didInterstitialClose:(TnkInterstitialAd *)ad close:(int)type;
- (void)didInterstitialFail:(TnkInterstitialAd *)ad error:(int)errCode;
- (void)didInterstitialShow:(TnkInterstitialAd *)ad;
- (void)didInterstitialLoad:(TnkInterstitialAd *)ad;

@end

@interface TnkInterstitialAd : NSObject <TnkServiceCallback>

@property (nonatomic, weak) UIViewController *viewControllerToShow;
@property (nonatomic, weak) id<TnkInterstitialDelegate> delegate;
@property (nonatomic, strong) NSString *logicName;
@property (nonatomic, assign) NSTimeInterval timeoutSec;

- (void) prepare;
- (void) prepare:(NSString *)logicName;
- (void) prepare:(NSString *)logicName delegate:(id<TnkInterstitialDelegate>) delegate;

- (void) show:(UIViewController *)viewController;
- (void) show;

@end

// New API for Video Ad (2015.09.30)

@protocol TnkVideoDelegate <NSObject>
@optional

- (void)didVideoClose:(NSString *)logicName close:(int)type;
- (void)didVideoShow:(NSString *)logicName;
- (void)didVideoLoad:(NSString *)logicName;
- (void)didVideoCompleted:(NSString *)logicName skip:(BOOL)skipped;

@end

@interface TnkSession : NSObject {
    
    // 아래의 속성들은 광고 목록 스타일 지정을 위하여 사용됨
    /*
     * 적용 예시
     // set styles
     [[TnkSession sharedInstance] setHeaderColor:TITLE_BAR_COLOR];
     [[TnkSession sharedInstance] setHeaderTitle:LocalString(@"adlist")];
     [[TnkSession sharedInstance] setDetailBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_detail.png"]]];
     [[TnkSession sharedInstance] setListItemBackgroundColorNormal:[UIColor colorWithPatternImage:[UIImage imageNamed:@"adlist_bg_normal.png"]]];
     [[TnkSession sharedInstance] setListItemBackgroundColorStripe:[UIColor colorWithPatternImage:[UIImage imageNamed:@"adlist_bg_stripe.png"]]];
     [[TnkSession sharedInstance] setListItemBackgroundColorHighlight:[UIColor colorWithPatternImage:[UIImage imageNamed:@"adlist_bg_highlight.png"]]];
     [[TnkSession sharedInstance] setDetailHeaderBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"detail_header_bg.png"]]];
     
     [[TnkSession sharedInstance] setWebBoxButtonImage:[UIImage imageNamed:@"az_list_bt_web.png"]];
     [[TnkSession sharedInstance] setFreeBoxButtonImage:[UIImage imageNamed:@"az_list_bt_free.png"]];
     [[TnkSession sharedInstance] setPaidBoxButtonImage:[UIImage imageNamed:@"az_list_bt_pay.png"]];
     [[TnkSession sharedInstance] setConfirmBoxButtonImage:[UIImage imageNamed:@"az_list_bt_install.png"]];
     
     [[TnkSession sharedInstance] setCoinImage:[UIImage imageNamed:@"az_list_icon_coin.png"]];
     [[TnkSession sharedInstance] setBadgeNewImage:[UIImage imageNamed:@"icon_new_triangle.png"]];
     [[TnkSession sharedInstance] setBadgeBestImage:[UIImage imageNamed:@"event_bt_best.png"]];
     
     UIImage *detailButtonNormal = [UIImage imageNamed:@"detail_bt_bg.png"];
     UIImage *stretchableDetailButtonNormal = [detailButtonNormal stretchableImageWithLeftCapWidth:10 topCapHeight:0];
     [[TnkSession sharedInstance] setDetailButtonImageNormal:stretchableDetailButtonNormal];
     */
}

/*
 * 초기화. AppDelegate에서 앱 기동시 Tnk가 부여한 app Id를 사용하여 초기화한다.
 */
+ (id) initInstance:(NSString *)appId;

/*
 * Tnk에 접근하기 위한 단일 객체를 반환한다.
 */
+ (TnkSession *) sharedInstance;

/*
 * Tnk가 사용하는 단말기 고유 ID를 반환한다.
 */
- (NSString *) getUid;

/*
 * 매체에서 사용하는 고유 사용자 ID를 지정할 수 있다. 
 * 지정된 값은 매체서버에 포인트 전달할 때 같이 전달된다.
 */
- (void) setUserName:(NSString *)name;

/*
 * 광고목록 ViewController를 생성해준다.
 */
- (UIViewController *) adListViewController;

/*
 * 광고 목록을 띄운다. 모달 형태로 띄운다.
 */
- (void) showAdListAsModal:(UIViewController *)viewController title:(NSString *)title;
- (void) showAdListAsModal:(UIViewController *)viewController title:(NSString *)title delegate:(id<TnkAdViewDelegate>)delegate;

/*
 * 광고 목록을 띄운다. NavigationController 기반으로 하위 레벨로 이동하는 방식이다.
 */
- (void) showAdListNavigation:(UIViewController *)viewController title:(NSString *)title;
- (void) showAdListNavigation:(UIViewController *)viewController title:(NSString *)title delegate:(id<TnkAdViewDelegate>)delegate;

/*
 * 현재 포인트 조회 (비동기 방식) : 결곽를 받을 객체와 메소드를 지정해준다.
 * action에 전달되는 인자 값은 현재 포인트 값으로 NSNumber 객체이다. (오류 발생시 -1 전달됨)
 */
- (void) queryPoint:(id)target action:(SEL)action;

// 현재 포인트 조회 (동기방식) : 조회된 포인트 결과를 반환한다.
- (NSInteger) queryPoint;

/*
 * 현재 개시앱의 상태 값을 조회한다. (비동기 방식) : 결과를 받을 객체와 매소드를 지정해준다.
 * action에 전달되는 인자값은 게시앱의 상태값으로 NSNumber 객체이다. (오류 발생시 TNK_STATE_ERROR 전달됨)
 */
- (void) queryPublishState:(id)target action:(SEL)action;

// 현재 게시앱의 상태 값을 조회한다.
- (NSInteger) queryPublishState;

/*
 * 아이템 구매를 수행한다. (비동기 방식)
 * 구매하는 itemId 와 사용포인트를 전달하면 서버에서 해당 포인트만큼 차감한 후 로그를 남기고 결과를 반환한다.
 * action에 전달되는 인자값은 2개이며 첫번째 인자는 남은포인트, 두번째 인자는 고유한 거래 ID 값으로 모누 NSNumber 객체이다.
 * 네트워크 오류 또는 포인트 부족 등으로 아이템 구매가 성공하지 못한 경우 두번째 인자값은 음수를 갖는다.
 */
- (void) purchaseItem:(NSString *)itemId cost:(NSInteger)pointCost target:(id)target action:(SEL)action;

/*
 * 적립되어 있는 전체 포인트를 인출한다. (비동기 방식)
 * action에 전달하는 인자값은 인출한 포인트 값으로 NSNumber 객체이다. (오류 발생시 -1 전달됨)
 */
- (void) withdrawPoints:(NSString *)desc target:(id)target action:(SEL)action;

/*
 * 적립되어 있는 전체 포인트를 인출한다. (동기방식)
 * 인출된 포인트 값을 반환한다.
 */
- (NSInteger) withdrawPoints:(NSString *)desc;

/*
 * 사용자에게 제공될 수 있는 광고 개수와 포인트 합계를 반환한다. (비동기 방식)
 * action에 전달되는 인자값은 2개이며 첫번째 인자는 광고 개수, 두번째 인자는 제공되는 광고들의 포인트 합께 값으로 모누 NSNumber 객체이다.
 * 오류 발생시 광고개수는 -1, 포인트 합계는 0 이 리턴됨
 */
- (void) queryAdvertiseCount:(id)target action:(SEL)action;

/*
 * 실행형 지급 광고앱의 경우 앱이 정상적으로 실행되었다고 판단되는 시점에 호출한다.
 */
- (void) applicationStarted;

/*
 * 액션형 지급 광고앱의 경우 설정한 액션이 수행되었다고 판단되는 시점에 호출한다.
 */
- (void) actionCompleted;
- (void) actionCompleted:(NSString *)actionName;

/*
 * 사용자가 유료구매를 완료하는 시점에 호출한다.(구매활동 분석)
 */
- (void) buyCompleted:(NSString *)itemName;

/*
 * App Tracking 기능 사용 여부 설정 (default : YES)
 */
- (void) setTrackingEnabled:(BOOL)enabled;

/*
 * 사용자 정보 설정
 */
- (void) setUserAge:(int)age;
- (void) setUserGender:(NSString *)gender;

/*
 * 중간 전면 광고
 */
- (void) prepareInterstitialAd:(NSString *)logicName delegate:(id<TnkAdViewDelegate>)delegate;
- (void) showInterstitialAd;
- (void) showInterstitialAd:(id<TnkAdViewDelegate>)delegate;
- (void) showInterstitialAd:(id<TnkAdViewDelegate>)delegate on:(UIViewController *)viewController;
- (BOOL) isInterstitialAdVisible;
- (BOOL) isInterstitialAdVisible:(UIViewController *)viewController;
- (void) removeCurrentInterstitialAd;
- (void) removeCurrentInterstitialAd:(UIViewController *)viewController;

/*
 * 동영상 광고
 */
/*
 * 동영상 광고
 */
- (void) prepareVideoAd:(NSString *)logicName delegate:(id<TnkVideoDelegate>)delegate;
- (BOOL) showVideoAd:(NSString *)logicName on:(UIViewController *)viewController;
- (BOOL) showVideoAd;
- (BOOL) hasVideoAd:(NSString *)logicName;
- (BOOL) hasVideoAd;
- (BOOL) isVideoPresenting;

// Properties
@property (nonatomic, retain) NSString *headerTitle;
@property (nonatomic, retain) UIColor *headerColor;
@property (nonatomic, retain) UIColor *headerTextColor;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *listItemBackgroundColorNormal;
@property (nonatomic, retain) UIColor *listItemBackgroundColorStripe;
@property (nonatomic, retain) UIColor *listItemBackgroundColorHighlight;

@property (nonatomic, retain) UIImage *webBoxButtonImage;
@property (nonatomic, retain) UIImage *freeBoxButtonImage;
@property (nonatomic, retain) UIImage *paidBoxButtonImage;
@property (nonatomic, retain) UIImage *confirmBoxButtonImage;

@property (nonatomic, retain) UIImage *badgeNewImage;
@property (nonatomic, retain) UIImage *badgeBestImage;
@property (nonatomic, retain) UIImage *coinImage;

@property (nonatomic, retain) UIColor *detailHeaderBackgroundColor;
@property (nonatomic, retain) UIColor *detailBackgroundColor;
@property (nonatomic, retain) UIImage *detailButtonImageNormal;
@property (nonatomic, retain) UIImage *detailButtonImageHighlight;
@property (nonatomic, retain) UIColor *detailButtonTextColor;

@property (nonatomic, assign) UITableViewStyle tableViewStyle;
@property (nonatomic, assign) BOOL onVideoPlay;

@property (nonatomic, assign) int detailImageType; // offerwall 상세화면에서 전면이미지 보여줄지 여부, 0:안보여줌, 1:세로, 2:가로이미지, (3: 정사각형이미지), 9: 스크린샷
@property (nonatomic, strong) id<AdListItemViewFactory> adItemViewFactory; // 광고리스트 아이템 뷰 객체 생성용

@end
