//
//  PerpleFirebase.h
//  PerpleSDK
//
//  Created by PerpleLab on 2016. 7. 28..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseMessaging/FirebaseMessaging.h>
#import <FirebaseAnalytics/FirebaseAnalytics.h>

#import "PerpleSDK.h"

@interface PerpleFirebase : NSObject <FIRMessagingDelegate, UNUserNotificationCenterDelegate>

#pragma mark - Properties

@property BOOL mIsSignedIn;
@property BOOL mIsReceivePushOnForeground;
@property (nonatomic, copy) NSString *mGCMSenderId;

#pragma mark - Initialization

- (id) initWithGCMSenderId:(NSString *)gcmSenderId;

#pragma mark - APIs

- (void) setFCMPushOnForeground:(BOOL)isReceive;
- (void) subscribeToTopic:(NSString *)topic;
- (void) unsubscribeFromTopic:(NSString *)topic;
- (void) autoLoginWithCompletion:(PerpleSDKCallback)callback;
- (void) logEvent:(NSString *)arg0 param:(NSString *)arg1;
- (void) setUserProperty:(NSString *)arg0 param:(NSString *)arg1;
- (void) loginAnonymouslyWithCompletion:(PerpleSDKCallback)callback;
- (void) logout;
- (void) deleteUserWithCompletion:(PerpleSDKCallback)callback;
- (void) signInWithCredential:(FIRAuthCredential *)credential providerId:(NSString *)providerId completion:(PerpleSDKCallback)callback;
- (void) signInWithCustomToken:(NSString *)customToken completion:(PerpleSDKCallback)callback;
- (void) signInWithEmail:(NSString *)email password:(NSString *)password completion:(PerpleSDKCallback)callback;
- (void) linkWithCredential:(FIRAuthCredential *)credential providerId:(NSString *)providerId completion:(PerpleSDKCallback)callback;
- (void) linkAndRetrieveDataWithCredential:(FIRAuthCredential *)credential providerId:(NSString *)providerId completion:(PerpleSDKCallback)callback;
- (void) unlink:(NSString *)providerId completion:(PerpleSDKCallback)callback;
- (void) createUserWithEmail:(NSString *)email password:(NSString *)password completion:(PerpleSDKCallback)callback;
- (void) sendPasswordResetWithEmail:(NSString *)email completion:(PerpleSDKCallback)callback;

#pragma mark - Static utility methods

+ (FIRAuthCredential *) getGoogleCredentialWithIdToken:(NSString *)idToken accessToken:(NSString *)accessToken;
+ (FIRAuthCredential *) getFacebookCredentialWithAccessToken:(NSString *)accessToken;
+ (FIRAuthCredential *) getTwitterCredentialWithAccessToken:(NSString *)authToken secret:(NSString* )authTokenSecret;
+ (FIRAuthCredential *) getEmailCredentialWithEmail:(NSString *)email password:(NSString *)password;
+ (FIRAuthCredential *) getGameCenterCredentialWithCustomToken:(NSString *)customToken;
+ (NSString *) getLoginInfo:(FIRUser *)user providerId:(NSString *)providerId;
+ (NSString *) getLoginInfoFromAuthResult:(FIRAuthDataResult *)authResult providerId:(NSString *)providerId;
//+ (NSDictionary *) getUserProfile:(FIRUser *)user;
+ (NSString *) getDisplayName:(FIRUser *)user providerId:(NSString *)providerId;
+ (NSString *) getProviderId:(FIRUser *)user providerId:(NSString *)providerId;
+ (NSArray *) getProviderData:(FIRUser *)user;
+ (void) setPushToken:(NSString *)token;
+ (NSString *) getPushToken;
+ (BOOL) loginInfo:(NSString *)info isLinkedWithProvider:(NSString *)provider;
+ (NSString *) addGoogleLoginInfo:(NSString *)info;
+ (NSString *) addFacebookLoginInfo:(NSString *)info;
+ (NSString *) addTwitterLoginInfo:(NSString *)info;
+ (NSString *) addGameCenterLoginInfo:(NSString *)info;
+ (NSString *) getErrorInfoFromFirebaseError:(NSError *)error;

#pragma mark - AppDelegate

// AppDelegate.m
- (void) applicationDidBecomeActive:(UIApplication *)application;
- (void) applicationDidEnterBackground:(UIApplication *)application;
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

#pragma mark - FIRMessagingDelegate
- (void)messaging:(nonnull FIRMessaging *)messaging didReceiveRegistrationToken:(nonnull NSString *)fcmToken;

@end
