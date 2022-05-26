//
//  PerpleSDK.h
//  PerpleSDK
//
//  Created by PerpleLab on 2016. 7. 28..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <CommonCrypto/CommonHMAC.h>
#import <AuthenticationServices/AuthenticationServices.h>


#pragma mark -

#define PERPLESDK_ERROR_UNDER_IOS_13                        "-0013"
#define PERPLESDK_ERROR_UNDER_IOS_14                        "-0014"

#define PERPLESDK_ERROR_UNKNOWN                             "-999"
#define PERPLESDK_ERROR_IOEXCEPTION                         "-998"
#define PERPLESDK_ERROR_JSONEXCEPTION                       "-997"
#define PERPLESDK_ERROR_USERRECOVERABLEAUTHEXCEPTION        "-996"
#define PERPLESDK_ERROR_GOOGLEAUTHEXCEPTION                 "-995"

#define PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED             "-1000"
#define PERPLESDK_ERROR_FIREBASE_SENDPUSHMESSAGE            "-1001"
#define PERPLESDK_ERROR_FIREBASE_LOGIN                      "-1002"
#define PERPLESDK_ERROR_FIREBASE_FCMTOKENNOTREADY           "-1003"
#define PERPLESDK_ERROR_FIREBASE_GOOGLENOTLINKED            "-1004"
#define PERPLESDK_ERROR_FIREBASE_FACEBOOKNOTLINKED          "-1005"

#define PERPLESDK_ERROR_GOOGLE_NOTINITIALIZED               "-1200"
#define PERPLESDK_ERROR_GOOGLE_LOGIN                        "-1201"
#define PERPLESDK_ERROR_GOOGLE_NOTSIGNEDIN                  "-1202"
#define PERPLESDK_ERROR_GOOGLE_ACHIEVEMENTS                 "-1203"
#define PERPLESDK_ERROR_GOOGLE_LEADERBOARDS                 "-1204"
#define PERPLESDK_ERROR_GOOGLE_QUESTS                       "-1205"
#define PERPLESDK_ERROR_GOOGLE_NOTSETLOGINCALLBACK          "-1206"
#define PERPLESDK_ERROR_GOOGLE_NOTSETPLAYSERVICESCALLBACK   "-1207"
#define PERPLESDK_ERROR_GOOGLE_NOTSETQUESTSCALLBACK         "-1208"
#define PERPLESDK_ERROR_GOOGLE_NOTAVAILABLEPLAYSERVICES     "-1209"
#define PERPLESDK_ERROR_GOOGLE_LOGOUT                       "-1210"
#define PERPLESDK_ERROR_GOOGLE_PERMISSIONDENIED             "-1211"
#define PERPLESDK_ERROR_GOOGLE_GETIDTOKEN                   "-1212"
#define PERPLESDK_ERROR_GOOGLE_NOTAVAILABLEPLAYGAMES        "-1213"

#define PERPLESDK_ERROR_FACEBOOK_NOTINITIALIZED             "-1300"
#define PERPLESDK_ERROR_FACEBOOK_FACEBOOKEXCEPTION          "-1301"
#define PERPLESDK_ERROR_FACEBOOK_AUTHORIZATIONEXCEPTION     "-1302"
#define PERPLESDK_ERROR_FACEBOOK_DIALOGEXCEPTION            "-1303"
#define PERPLESDK_ERROR_FACEBOOK_GRAPHRESPONSEEXCEPTION     "-1304"
#define PERPLESDK_ERROR_FACEBOOK_OPERATIONCANCELEDEXCEPTION "-1305"
#define PERPLESDK_ERROR_FACEBOOK_SDKNOTINITIALIZEDEXCEPTION "-1306"
#define PERPLESDK_ERROR_FACEBOOK_SERVICEEXCEPTION           "-1307"
#define PERPLESDK_ERROR_FACEBOOK_GRAPHAPI                   "-1308"
#define PERPLESDK_ERROR_FACEBOOK_REQUEST                    "-1309"
#define PERPLESDK_ERROR_FACEBOOK_SHARE                      "-1310"

#define PERPLESDK_ERROR_BILLING_NOTINITIALIZED              "-1500"
#define PERPLESDK_ERROR_BILLING_SETUP                       "-1501"
#define PERPLESDK_ERROR_BILLING_QUARYINVECTORY              "-1502"
#define PERPLESDK_ERROR_BILLING_CHECKRECEIPT                "-1503"
#define PERPLESDK_ERROR_BILLING_PURCHASEFINISH              "-1504"
#define PERPLESDK_ERROR_BILLING_INVALIDPRODUCT              "-1505"
#define PERPLESDK_ERROR_BILLING_REQUEST_FAIL                "-1506"

#define PERPLESDK_ERROR_TAPJOY_NOTINITIALIZED               "-1600"
#define PERPLESDK_ERROR_TAPJOY_NOTSETPLACEMENT              "-1601"
#define PERPLESDK_ERROR_TAPJOY_GETCURRENCY                  "-1602"
#define PERPLESDK_ERROR_TAPJOY_SPENDCURRENCY                "-1603"
#define PERPLESDK_ERROR_TAPJOY_AWARDCURRENCY                "-1604"
#define PERPLESDK_ERROR_TAPJOY_ONEARNEDCURRENCY             "-1605"
#define PERPLESDK_ERROR_TAPJOY_SETPLACEMENT                 "-1606"
#define PERPLESDK_ERROR_TAPJOY_SHOWPLACEMENT                "-1607"

#define PERPLESDK_ERROR_GAMECENTER_NOTINITIALIZED           "-1700"
#define PERPLESDK_ERROR_GAMECENTER_LOGIN                    "-1701"
#define PERPLESDK_ERROR_GAMECENTER_GETCUSTOMTOKEN           "-1702"

#define PERPLESDK_ERROR_UNITYADS_NOTINITIALIZED             "-1800"

#define PERPLESDK_ERROR_ADJUST_NOTINITIALIZED               "-1900"

#define PERPLESDK_ERROR_TWITTER_NOTINITIALIZED              "-2000"
#define PERPLESDK_ERROR_TWITTER_LOGIN                       "-2001"

#define PERPLESDK_ERROR_ADMOB_NOTINITIALIZED                "-2100"
#define PERPLESDK_ERROR_ADMOB_START                         "-2101"
#define PERPLESDK_ERROR_ADMOB_INVALIDADUNITID               "-2102"
#define PERPLESDK_ERROR_ADMOB_NOTLOADEDAD                   "-2103"
#define PERPLESDK_ERROR_ADMOB_FAILLOAD                      "-2104"

#define PERPLESDK_ERROR_APPLE_NOTINITIALIZED                "-2200"
#define PERPLESDK_ERROR_APPLE_LOGIN                         "-2201"



#pragma mark -

@class PerpleFirebase;
@class PerpleGoogle;
@class PerpleFacebook;
@class PerpleTwitter;
@class PerpleTapjoy;
@class PerpleGameCenter;
@class PerpleUnityAds;
@class PerpleAdColony;
@class PerpleBilling;
@class PerpleAdjust;
@class PerpleAdMob;
@class PerpleCrashlytics;
@class HbApple;

typedef void(^PerpleSDKCallback)(NSString *result, NSString *info);

@interface PerpleSDK : NSObject

#pragma mark - Properties
@property (nonatomic, retain) UIViewController *mViewController;

@property (nonatomic, retain) PerpleFirebase *mFirebase;
@property (nonatomic, retain) PerpleGoogle *mGoogle;
@property (nonatomic, retain) PerpleFacebook *mFacebook;
@property (nonatomic, retain) PerpleTwitter *mTwitter;
@property (nonatomic, retain) PerpleTapjoy *mTapjoy;
@property (nonatomic, retain) PerpleGameCenter *mGameCenter;
@property (nonatomic, retain) PerpleUnityAds *mUnityAds;
@property (nonatomic, retain) PerpleAdColony *mAdColony;
@property (nonatomic, retain) PerpleBilling *mBilling;
@property (nonatomic, retain) PerpleAdjust *mAdjust;
@property (nonatomic, retain) PerpleAdMob *mAdMob;
@property (nonatomic, retain) HbApple *mApple;

@property (nonatomic, copy) NSString *mPlatformServerEncryptSecretKey;
@property (nonatomic, copy) NSString *mPlatformServerEncryptAlgorithm;

#pragma mark - APIs

- (void) setPlatformServerSecretKey:(NSString *)secretKey algorithm:(NSString *)algorithm;

- (void) setFCMPushOnForeground:(BOOL)isReceive;
- (void) setFCMTokenRefreshWithCompletion:(PerpleSDKCallback)callback;
- (void) getFCMTokenWithCompletion:(PerpleSDKCallback)callback;
- (void) subscribeToTopic:(NSString *)topic;
- (void) unsubscribeFromTopic:(NSString *)topic;

- (void) logEvent:(NSString *)arg0 param:(NSString *)arg1;
- (void) setUserProperty:(NSString *)arg0 param:(NSString *)arg1;

- (void) autoLoginWithCompletion:(PerpleSDKCallback)callback;
- (void) loginAnonymouslyWithCompletion:(PerpleSDKCallback)callback;
- (void) loginWithGoogleWithCompletion:(PerpleSDKCallback)callback;
- (void) loginWithFacebookWithCompletion:(PerpleSDKCallback)callback;
- (void) loginWithTwitterWithCompletion:(PerpleSDKCallback)callback;
- (void) loginWithGameCenter:(NSString *)param1 completion:(PerpleSDKCallback)callback;
- (void) loginWithAppleWithCompletion:(PerpleSDKCallback)callback;
- (void) loginWithEmail:(NSString *)email password:(NSString *)password completion:(PerpleSDKCallback)callback;
- (void) loginWithCustomToken:(NSString *)customToken completion:(PerpleSDKCallback)callback;

- (void) linkWithGoogleWithCompletion:(PerpleSDKCallback)callback;
- (void) linkWithFacebookWithCompletion:(PerpleSDKCallback)callback;
- (void) linkWithTwitterWithCompletion:(PerpleSDKCallback)callback;
- (void) linkWithAppleWithCompletion:(PerpleSDKCallback)callback;
- (void) linkWithEmail:(NSString *)email password:(NSString *)password completion:(PerpleSDKCallback)callback;

- (void) unlinkWithGoogleWithCompletion:(PerpleSDKCallback)callback;
- (void) unlinkWithFacebookWithCompletion:(PerpleSDKCallback)callback;
- (void) unlinkWithTwitterWithCompletion:(PerpleSDKCallback)callback;
- (void) unlinkWithAppleWithCompletion:(PerpleSDKCallback)callback;
- (void) unlinkWithEmailWithCompletion:(PerpleSDKCallback)callback;

- (void) logout;
- (void) deleteUserWithCompletion:(PerpleSDKCallback)callback;
- (void) createUserWithEmail:(NSString *)email password:(NSString *)password completion:(PerpleSDKCallback)callback;
- (void) sendPasswordResetWithEmail:(NSString *)email completion:(PerpleSDKCallback)callback;

// @facebook
- (void) facebookLoginWithCompletion:(PerpleSDKCallback)callback;
- (void) facebookLogout;
- (void) facebookSendRequest:(NSString *)data completion:(PerpleSDKCallback)callback;
- (void) facebookSendSharing:(NSString *)data completion:(PerpleSDKCallback)callback;
- (void) facebookGetFriendsWithCompletion:(PerpleSDKCallback)callback;
- (void) facebookGetInvitableFriendsWithCompletion:(PerpleSDKCallback)callback;
- (void) facebookNotifications:(NSString *)receiverId message:(NSString *)message completion:(PerpleSDKCallback)callback;
- (BOOL) facebookIsGrantedPermission:(NSString *)permission;
- (void) facebookAskPermission:(NSString *)permission completion:(PerpleSDKCallback)callback;

// @twitter
- (void) twitterLoginWithCompletion:(PerpleSDKCallback)callback;
- (void) twitterLogout;
- (void) twitterComposeTweet:(NSString *)imageUri completion:(PerpleSDKCallback)callback;

// @tapjoy
- (void) tapjoyEvent:(NSString *)cmd param1:(NSString *)param1 param2:(NSString *)param2;
- (void) tapjoySetTrackPurchase:(BOOL)flag;
- (void) tapjoySetPlacement:(NSString *)placemantName completion:(PerpleSDKCallback)callback;
- (void) tapjoyShowPlacement:(NSString *)placemantName completion:(PerpleSDKCallback)callback;
- (void) tapjoyGetCurrencyWithCompletion:(PerpleSDKCallback)callback;
- (void) tapjoySetEarnedCurrencyCallback:(PerpleSDKCallback)callback;
- (void) tapjoySpendCurrency:(int)amount completion:(PerpleSDKCallback)callback;
- (void) tapjoyAwardCurrency:(int)amount completion:(PerpleSDKCallback)callback;

// @google
- (void) googleLogin:(PerpleSDKCallback)callback;
- (void) googleSilentLogin:(PerpleSDKCallback)callback;
- (void) googleLogout;
- (void) googleRevokeAccess;
- (void) googleShowAchievementsWithCompletion:(PerpleSDKCallback)callback;
- (void) googleShowLeaderboardsWithCompletion:(PerpleSDKCallback)callback;
- (void) googleUpdateAchievements:(NSString *)achievementId numSteps:(NSString *)numSteps completion:(PerpleSDKCallback)callback;
- (void) googleUpdateLeaderboards:(NSString *)leaderboardId finalScore:(NSString *)finalScore completion:(PerpleSDKCallback)callback;

// @gamecenter
- (void) gameCenterLoginWithCompletion:(PerpleSDKCallback)callback;

// @unityads
- (void) unityAdsStart:(BOOL)isTestMode metaData:(NSString *)metaData completion:(PerpleSDKCallback)callback;
- (void) unityAdsShow:(NSString *)placementId metaData:(NSString *)metaData;

// @adColonoy
- (void) adColonyStart:(NSString *)zoneIds userId:(NSString *)userId;
- (void) adColonySetUserId:(NSString *)userId;
- (void) adColonyRequest:(NSString *)zoneId completion:(PerpleSDKCallback)callback;
- (void) adColonyShow:(NSString *)zoneId;

// @billing
- (void) billingSetup:(NSString *)checkReceiptServerUrl saveTransactionUrl:saveTransactionUrl completion:(PerpleSDKCallback)callback;
- (void) billingConfirm:(NSString *)orderId;
- (void) billingPurchase:(NSString *)sku payload:(NSString *)payload completion:(PerpleSDKCallback)callback;
- (void) billingSubscription:(NSString *)sku payload:(NSString *)payload completion:(PerpleSDKCallback)callback;
- (void) billingGetItemList:(NSString *)skuList completion:(PerpleSDKCallback)callback;
- (void) billingGetIncompletePurchaseList:(PerpleSDKCallback)callback;

// @adjust
- (void) adjustTrackEvent:(NSString *)eventKey;
- (void) adjustTrackPayment:(NSString *)key price:(NSString *)price currency:(NSString *)currency;
- (void) adjustGdprForgetMe;
- (NSString *) adjustGetAdid;

// @adMob
- (void) adMobInitRewardedVideoAd;
- (void) adMobInitInterstitialAd;

- (void) rvAdLoadRequestWithId:(NSString *)adUnitId;
- (void) rvAdSetResultCallback:(PerpleSDKCallback)callback;
- (void) rvAdShow:(NSString *)adUnitId;

- (void) itAdSetAdUnitId:(NSString *)adUnitId;
- (void) itAdSetResultCallback:(PerpleSDKCallback)callback;
- (void) itAdLoadRequest;
- (void) itAdShow;

// @crashlytics
- (void) crashlyticsForceCrash;
- (void) crashlyticsSetUid:(NSString *)uid;
- (void) crashlyticsSetLog:(NSString *)message;
- (void) crashlyticsSetObejctValue:(id)value forKey:(NSString *)key;
- (void) crashlyticsSetIntValue:(int)value forKey:(NSString *)key;
- (void) crashlyticsSetBoolValue:(BOOL)value forKey:(NSString *)key;

// @apple
- (void) appleLoginWithCompletion:(PerpleSDKCallback)callback;
- (void) appleLogout;

#pragma mark - Initialization

// Initialization
// AppDelegate, application:didFinishLaunchingWithOptions:에서 호출
- (BOOL) initSDKWithGcmSenderId:(NSString *)gcmSenderId debug:(BOOL)isDebug;
- (BOOL) initGoogleWithClientId:(NSString *)clientId parentView:(UIViewController *)parentView;
- (BOOL) initFacebookWithParentView:(UIViewController *)parentView;
- (BOOL) initTwitterWithCustomerKey:(NSString *)customerKey secret:(NSString *)customerSecret;
- (BOOL) initTapjoyWithAppKey:(NSString *)appKey usePush:(BOOL)isUsePush debug:(BOOL)isDebug;
- (BOOL) initGameCenterWithParentView:(UIViewController *)parentView;
- (BOOL) initUnityAdsWithParentView:(UIViewController *)parentView gameId:(NSString *)gameId debug:(BOOL)isDebug;
- (BOOL) initAdColonyWithParentView:(UIViewController *)parentView appId:(NSString *)appId;
- (BOOL) initBilling;
- (BOOL) initAdjustWithAppKey:(NSString *)appKey secret:(NSArray *)secretKey debug:(BOOL)isDebug;
- (BOOL) initAdMobWithAppId:(NSString *)appId;
- (BOOL) initAppleWithWindow:(UIWindow *)window;


#pragma mark - Static methods

+ (id) sharedInstance;
+ (void) resetProcessId;
+ (int) getProcessId;
+ (BOOL) isCurrentProcessId:(int)processId;
+ (BOOL) isDebug;

+ (NSString *) getErrorInfo:(NSString *)code msg:(NSString *)msg;
+ (NSString *) getErrorInfo:(NSString *)code subcode:(NSString *)subcode msg:(NSString *)msg;
+ (NSString *) getJSONStringFromNSDictionary:(NSDictionary *)obj;
+ (NSString *) getJSONStringFromNSArray:(NSArray *)obj;
+ (NSDictionary *) getNSDictionaryFromJSONString:(NSString *)str;
+ (NSArray *) getNSArrayFromJSONString:(NSString *)str;
+ (NSString *) getHmacEncrypt:(NSString *)secret data:(NSString *)data;
+ (NSString *) getHmacEncryptMD5:(NSString *)secret data:(NSString *)data;
+ (NSString *) getHmacEncryptSHA1:(NSString *)secret data:(NSString *)data;
+ (NSString *) getHmacEncryptSHA256:(NSString *)secret data:(NSString *)data;
+ (void) requestHttpPostWithUrl:(NSString *)url contentBody:(NSDictionary *)contentBody result:(NSString **)result error:(NSError **)error;

// @fcm
+ (void) onFCMTokenRefresh:(NSString *)token;

#pragma mark - AppDelegate

// AppDelegate
- (void) applicationDidBecomeActive:(UIApplication *)application;
- (void) applicationWillEnterForeground:(UIApplication *)application;
- (void) applicationDidEnterBackground:(UIApplication *)application;
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options;
- (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler;
// AppDelegate, Push notifications
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
// Before iOS 7.0
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
// iOS 7.0
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void) payment:(SKPaymentTransaction *)transaction product:(SKProduct *)product;

@end
