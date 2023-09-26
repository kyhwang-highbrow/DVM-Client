//
//  PerpleSDK.m
//  PerpleSDK
//
//  Created by PerpleLab on 2016. 7. 28..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import "PerpleSDK.h"
#import "PerpleFirebase.h"
#import "PerpleGoogle.h"
#import "PerpleFacebook.h"
#import "PerpleTwitter.h"
//#import "PerpleTapjoy.h"
#import "PerpleGameCenter.h"
//#import "PerpleUnityAds.h"
//#import "PerpleAdColony.h"
#import "PerpleBilling.h"
#import "PerpleAdjust.h"
#import "PerpleAdMob.h"
#import "PerpleCrashlytics.h"

#import "sdk_binder-Swift.h"

static int sProcessId;
static BOOL sIsDebug;

// @fcm
static PerpleSDKCallback sFCMTokenRefreshCallback;

@implementation PerpleSDK

#pragma mark - Properties
@synthesize mViewController;

@synthesize mFirebase;
@synthesize mGoogle;
@synthesize mFacebook;
@synthesize mTwitter;
//@synthesize mTapjoy;
@synthesize mGameCenter;
//@synthesize mUnityAds;
//@synthesize mAdColony;
@synthesize mBilling;
@synthesize mAdMob;
@synthesize mApple;

@synthesize mPlatformServerEncryptSecretKey;
@synthesize mPlatformServerEncryptAlgorithm;

//----------------------------------------------------------------------------------------------------

#pragma mark - APIs

- (void) setPlatformServerSecretKey:(NSString *)secretKey
                          algorithm:(NSString *)algorithm {
    mPlatformServerEncryptSecretKey = secretKey;
    mPlatformServerEncryptAlgorithm = algorithm;
}

// @fcm
- (void) setFCMPushOnForeground:(BOOL)isReceive {
    if (self.mFirebase != nil) {
        [self.mFirebase setFCMPushOnForeground:isReceive];
    }
}

// @fcm
- (void) setFCMTokenRefreshWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"error", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                               msg:@"Firebase is not initialized."]);
        return;
    }

    sFCMTokenRefreshCallback = callback;

    NSString *token = [PerpleFirebase getPushToken];
    if ([token isEqualToString:@""]) {
        callback(@"error", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_FCMTOKENNOTREADY
                                               msg:@"FCM token is not ready."]);
    } else {
        callback(@"refresh", token);
    }
}

// @fcm
- (void) getFCMTokenWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    NSString *token = [PerpleFirebase getPushToken];
    if ([token isEqualToString:@""]) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_FCMTOKENNOTREADY
                                              msg:@"FCM token is not ready."]);
    } else {
        callback(@"success", token);
    }
}

- (void) subscribeToTopic:(NSString *)topic {
    if (self.mFirebase != nil) {
        [self.mFirebase subscribeToTopic:topic];
    }
}

- (void) unsubscribeFromTopic:(NSString *)topic {
    if (self.mFirebase != nil) {
        [self.mFirebase unsubscribeFromTopic:topic];
    }
}

- (void) logEvent:(NSString *)arg0 param:(NSString *)arg1 {
    if (self.mFirebase != nil) {
        [self.mFirebase logEvent:arg0
                           param:arg1];
    }
}

- (void) setUserProperty:(NSString *)arg0 param:(NSString *)arg1 {
    if (self.mFirebase != nil) {
        [self.mFirebase setUserProperty:arg0
                                  param:arg1];
    }
}

- (void) autoLoginWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase autoLoginWithCompletion:^(NSString *result, NSString *info) {
        if ([result isEqualToString:@"success"]) {
            callback(@"success", info);
        } else {
            callback(@"fail", info);
        }
    }];
}

- (void) loginAnonymouslyWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase loginAnonymouslyWithCompletion:callback];
}

- (void) loginWithGoogleWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    if (self.mGoogle == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GOOGLE_NOTINITIALIZED
                                              msg:@"Google is not initialized."]);
        return;
    }

    [self.mGoogle login:^(NSString *result, NSString *info) {
        if ([result isEqualToString:@"success"]) {
            NSDictionary *dict = [PerpleSDK getNSDictionaryFromJSONString:info];
            FIRAuthCredential *credential = [PerpleFirebase getGoogleCredentialWithIdToken:dict[@"idToken"]
                                                                               accessToken:dict[@"accessToken"]];
            [self.mFirebase signInWithCredential:credential
                                                     providerId:@"google.com"
                                                     completion:^(NSString *result, NSString *info) {
                                                         if ([result isEqualToString:@"success"]) {
                                                             callback(@"success", [PerpleFirebase addGoogleLoginInfo:info]);
                                                         } else {
                                                             callback(result, info);
                                                         }
                                                     }];
        } else {
            callback(result, info);
        }
    }];
}

- (void) loginWithFacebookWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    if (self.mFacebook == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_NOTINITIALIZED
                                              msg:@"Facebook is not initialized."]);
        return;
    }

    [self.mFacebook loginWithCompletion:^(NSString *result, NSString *info) {
        if ([result isEqualToString:@"success"]) {
            FIRAuthCredential *credential = [PerpleFirebase getFacebookCredentialWithAccessToken:info];
            [self.mFirebase signInWithCredential:credential
                                                     providerId:@"facebook.com"
                                                     completion:^(NSString *result, NSString *info) {
                                                         if ([result isEqualToString:@"success"]) {
                                                             callback(@"success", [PerpleFirebase addFacebookLoginInfo:info]);
                                                         } else {
                                                             callback(result, info);
                                                         }
                                                     }];
        } else {
            callback(result, info);
        }
    }];
}

- (void) loginWithTwitterWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    if (self.mTwitter == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TWITTER_NOTINITIALIZED
                                              msg:@"Twitter is not initialized."]);
        return;
    }

    [self.mTwitter loginWithCompletion:^(NSString *result, NSString *info) {
        if ([result isEqualToString:@"success"]) {
            NSDictionary *dict = [PerpleSDK getNSDictionaryFromJSONString:info];
            FIRAuthCredential *credential = [PerpleFirebase getTwitterCredentialWithAccessToken:dict[@"authToken"] secret:dict[@"authTokenSecret"]];
            [self.mFirebase signInWithCredential:credential
                                                     providerId:@"twitter.com"
                                                     completion:^(NSString *result, NSString *info) {
                                                         if ([result isEqualToString:@"success"]) {
                                                             callback(@"success", [PerpleFirebase addTwitterLoginInfo:info]);
                                                         } else {
                                                             callback(result, info);
                                                         }
                                                     }];
        } else {
            callback(result, info);
        }
    }];
}

- (void) loginWithGameCenter:(NSString *)param1
                  completion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }
    
    if (self.mGameCenter == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GAMECENTER_NOTINITIALIZED
                                              msg:@"GameCenter is not initialized."]);
        return;
    }

    [self.mGameCenter loginWithParam:param1
                          completion:^(NSString *result, NSString *info) {
                              if ([result isEqualToString:@"success"]) {
                                  [self.mFirebase signInWithCustomToken:info
                                                             completion:^(NSString *result, NSString *info) {
                                                                 if ([result isEqualToString:@"success"]) {
                                                                     callback(@"success", [PerpleFirebase addGameCenterLoginInfo:info]);
                                                                 } else {
                                                                     callback(result, info);
                                                                 }
                                                             }];
                              } else {
                                  callback(result, info);
                              }
                          }];
}

- (void) loginWithAppleWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    if (self.mApple == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_APPLE_NOTINITIALIZED
                                              msg:@"Apple is not initialized."]);
        return;
    }

    // 애플 로그인은 iOS 13 이상부터 가능
    if (@available(iOS 13, *)) {
        [self.mApple signInIsLink:false handler:callback];
    } else {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_UNDER_IOS_13
                                              msg:@"Sign in with Apple is available on iOS 13 or newer."]);
        return;
    }
}

- (void) loginWithEmail:(NSString *)email password:(NSString *)password completion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase signInWithEmail:email
                           password:password
                         completion:callback];
}

- (void) loginWithCustomToken:(NSString *)customToken completion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase signInWithCustomToken:customToken
										  completion:callback];
}

- (void) linkWithGoogleWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    if (self.mGoogle == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GOOGLE_NOTINITIALIZED
                                              msg:@"Google is not initialized."]);
        return;
    }

    [self.mGoogle login:^(NSString *result, NSString *info) {
        if ([result isEqualToString:@"success"]) {
            NSDictionary *dict = [PerpleSDK getNSDictionaryFromJSONString:info];
            FIRAuthCredential *credential = [PerpleFirebase getGoogleCredentialWithIdToken:dict[@"idToken"]
                                                                               accessToken:dict[@"accessToken"]];
            [self.mFirebase linkWithCredential:credential
                                    providerId:@"google.com"
                                    completion:^(NSString *result, NSString *info) {
                                        if ([result isEqualToString:@"success"]) {
                                            callback(@"success", [PerpleFirebase addGoogleLoginInfo:info]);
                                        } else {
                                            NSString *subcode = [PerpleSDK getNSDictionaryFromJSONString:info][@"subcode"];
                                            if ([subcode isEqualToString:@"CREDENTIAL_ALREADY_IN_USE"]) {
                                                callback(@"already_in_use", [PerpleFirebase addGoogleLoginInfo:info]);
                                            } else {
                                                callback(@"fail", info);
                                            }
                                        }
                                    }];
        } else {
            callback(result, info);
        }
    }];
}

- (void) linkWithFacebookWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    if (self.mFacebook == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_NOTINITIALIZED
                                              msg:@"Facebook is not initialized."]);
        return;
    }

    [self.mFacebook loginWithCompletion:^(NSString *result, NSString *info) {
        if ([result isEqualToString:@"success"]) {
            FIRAuthCredential *credential = [PerpleFirebase getFacebookCredentialWithAccessToken:info];
            [self.mFirebase linkAndRetrieveDataWithCredential:credential
                                                   providerId:@"facebook.com"
                                                   completion:^(NSString *result, NSString *info) {
                                                       if ([result isEqualToString:@"success"]) {
                                                           callback(@"success", [PerpleFirebase addFacebookLoginInfo:info]);
                                                       } else {
                                                           NSString *subcode = [PerpleSDK getNSDictionaryFromJSONString:info][@"subcode"];
                                                           if ([subcode isEqualToString:@"CREDENTIAL_ALREADY_IN_USE"]) {
                                                               callback(@"already_in_use", [PerpleFirebase addFacebookLoginInfo:info]);
                                                           } else {
                                                               callback(@"fail", info);
                                                           }
                                                       }
                                                   }];
        } else {
            callback(result, info);
        }
    }];
}

- (void) linkWithTwitterWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    if (self.mTwitter == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TWITTER_NOTINITIALIZED
                                              msg:@"Twitter is not initialized."]);
        return;
    }

    [self.mTwitter loginWithCompletion:^(NSString *result, NSString *info) {
        if ([result isEqualToString:@"success"]) {
            NSDictionary *dict = [PerpleSDK getNSDictionaryFromJSONString:info];
            FIRAuthCredential *credential = [PerpleFirebase getTwitterCredentialWithAccessToken:dict[@"authToken"] secret:dict[@"authTokenSecret"]];
            [self.mFirebase linkAndRetrieveDataWithCredential:credential
                                                   providerId:@"twitter.com"
                                                   completion:^(NSString *result, NSString *info) {
                                                       if ([result isEqualToString:@"success"]) {
                                                           callback(@"success", [PerpleFirebase addTwitterLoginInfo:info]);
                                                       } else {
                                                           NSString *subcode = [PerpleSDK getNSDictionaryFromJSONString:info][@"subcode"];
                                                           if ([subcode isEqualToString:@"CREDENTIAL_ALREADY_IN_USE"]) {
                                                               callback(@"already_in_use", [PerpleFirebase addTwitterLoginInfo:info]);
                                                           } else {
                                                               callback(@"fail", info);
                                                           }
                                                       }
                                                   }];
        } else {
            callback(result, info);
        }
    }];
}

- (void) linkWithAppleWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    if (self.mApple == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_APPLE_NOTINITIALIZED
                                              msg:@"Twitter is not initialized."]);
        return;
    }
    
    // 애플 로그인은 iOS 13 이상부터 가능
    if (@available(iOS 13, *)) {
        [self.mApple signInIsLink:true handler:callback];
    } else {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_UNDER_IOS_13
                                              msg:@"Sign in with Apple is available on iOS 13 or newer."]);
        return;
    }
}

- (void) linkWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    FIRAuthCredential *credential = [PerpleFirebase getEmailCredentialWithEmail:email
                                                                       password:password];
    [self.mFirebase linkWithCredential:credential
                            providerId:@"email"
                            completion:callback];

}

- (void) unlinkWithGoogleWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase unlink:@"google.com"
                completion:callback];
}

- (void) unlinkWithFacebookWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase unlink:@"facebook.com"
                completion:callback];
}

- (void) unlinkWithTwitterWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase unlink:@"twitter.com"
                completion:callback];
}

- (void) unlinkWithAppleWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase unlink:@"apple.com"
                completion:callback];
}

- (void) unlinkWithEmailWithCompletion:(PerpleSDKCallback)callback {

    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase unlink:@"email"
                completion:callback];
}

- (void) logout {
    if (self.mFirebase != nil) {
        [self.mFirebase logout];
    }
}

- (void) deleteUserWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase deleteUserWithCompletion:callback];
}

- (void) createUserWithEmail:(NSString *)email
                    password:(NSString *)password
                  completion:(PerpleSDKCallback)callback {

    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase createUserWithEmail:email
                               password:password
                             completion:callback];
}

- (void) sendPasswordResetWithEmail:(NSString *)email
                         completion:(PerpleSDKCallback)callback {

    if (self.mFirebase == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_NOTINITIALIZED
                                              msg:@"Firebase is not initialized."]);
        return;
    }

    [self.mFirebase sendPasswordResetWithEmail:email
                                    completion:callback];
}

- (void) facebookLoginWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFacebook == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_NOTINITIALIZED
                                              msg:@"Facebook is not initialized."]);
        return;
    }

    [self.mFacebook loginWithCompletion:^(NSString *result, NSString *info) {
        if ([result isEqualToString:@"success"]) {
            callback(result, [PerpleSDK getJSONStringFromNSDictionary:[self.mFacebook getProfileData]]);
        } else {
            callback(result, info);
        }
    }];
}

- (void) facebookLogout {
    if (self.mFacebook != nil) {
        [self.mFacebook logout];
    }
}

- (void) facebookSendRequest:(NSString *)data completion:(PerpleSDKCallback)callback {
    if (self.mFacebook == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_NOTINITIALIZED
                                              msg:@"Facebook is not initialized."]);
        return;
    }

    [self.mFacebook sendGameRequest:[PerpleSDK getNSDictionaryFromJSONString:data]
                         completion:callback];
}

- (void) facebookSendSharing:(NSString *)data completion:(PerpleSDKCallback)callback {
    if (self.mFacebook == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_NOTINITIALIZED
                                              msg:@"Facebook is not initialized."]);
        return;
    }

    [self.mFacebook sendGameSharing:[PerpleSDK getNSDictionaryFromJSONString:data]
                         completion:callback];
}

- (void) facebookGetFriendsWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFacebook == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_NOTINITIALIZED
                                              msg:@"Facebook is not initialized."]);
        return;
    }

    [self.mFacebook getFriendsWithCompletion:callback];
}

- (void) facebookGetInvitableFriendsWithCompletion:(PerpleSDKCallback)callback {
    if (self.mFacebook == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_NOTINITIALIZED
                                              msg:@"Facebook is not initialized."]);
        return;
    }

    [self.mFacebook getInvitableFriendsWithCompletion:callback];
}

- (void) facebookNotifications:(NSString *)receiverId
                       message:(NSString *)message
                    completion:(PerpleSDKCallback)callback {

    if (self.mFacebook == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_NOTINITIALIZED
                                              msg:@"Facebook is not initialized."]);
        return;
    }

    [self.mFacebook notifications:receiverId
                          message:message
                       completion:callback];
}

- (BOOL) facebookIsGrantedPermission:(NSString *)permission {
    BOOL ret = NO;
    if (self.mFacebook != nil) {
        ret = [self.mFacebook isGrantedPermission:permission];
    }
    return ret;
}

- (void) facebookAskPermission:(NSString *)permission
                    completion:(PerpleSDKCallback)callback {
    if (self.mFacebook == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_NOTINITIALIZED
                                              msg:@"Facebook is not initialized."]);
        return;
    }

    [self.mFacebook askPermission:permission
                       completion:callback];
}

- (void) twitterLoginWithCompletion:(PerpleSDKCallback)callback {
    if (self.mTwitter == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TWITTER_NOTINITIALIZED
                                              msg:@"Twitter is not initialized."]);
        return;
    }

    [self.mTwitter loginWithCompletion:^(NSString *result, NSString *info) {
        if ([result isEqualToString:@"success"]) {
            callback(result, [PerpleSDK getJSONStringFromNSDictionary:[self.mTwitter getProfileData]]);
        } else {
            callback(result, info);
        }
    }];
}

- (void) twitterLogout {
    if (self.mTwitter != nil) {
        [self.mTwitter logout];
    }
}

- (void) twitterComposeTweet:(NSString *)imageUri
                  completion:(PerpleSDKCallback)callback {
    if (self.mTwitter != nil) {
        [self.mTwitter composeTweet:imageUri completion:callback];
    }
}
/*
- (void) tapjoyEvent:(NSString *)cmd
              param1:(NSString *)param1
              param2:(NSString *)param2 {
    if (self.mTapjoy != nil) {
        [self.mTapjoy trackEvent:cmd
                          param1:param1
                          param2:param2];
    }
}

- (void) tapjoySetTrackPurchase:(BOOL)flag {
    if (self.mTapjoy != nil) {
        [self.mTapjoy trackPurchase:flag];
    }
}

- (void) tapjoySetPlacement:(NSString *)placemantName
                 completion:(PerpleSDKCallback)callback {
    if (self.mTapjoy == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TAPJOY_NOTINITIALIZED
                                              msg:@"Tapjoy is not initialized."]);
        return;
    }

    [self.mTapjoy setPlacementWithName:placemantName
                            completion:callback];
}

- (void) tapjoyShowPlacement:(NSString *)placemantName
                  completion:(PerpleSDKCallback)callback {
    if (self.mTapjoy == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TAPJOY_NOTINITIALIZED
                                              msg:@"Tapjoy is not initialized."]);
        return;
    }

    [self.mTapjoy showPlacementWithName:placemantName
                             completion:callback];
}

- (void) tapjoyGetCurrencyWithCompletion:(PerpleSDKCallback)callback {
    if (self.mTapjoy == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TAPJOY_NOTINITIALIZED
                                              msg:@"Tapjoy is not initialized."]);
        return;
    }

    [self.mTapjoy getCurrencyWithCompletion:callback];
}

- (void) tapjoySetEarnedCurrencyCallback:(PerpleSDKCallback)callback {
    if (self.mTapjoy == nil) {
        callback(@"error", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TAPJOY_NOTINITIALIZED
                                              msg:@"Tapjoy is not initialized."]);
        return;
    }

    [self.mTapjoy setEarnedCurrencyCallback:callback];
}

- (void) tapjoySpendCurrency:(int)amount
                  completion:(PerpleSDKCallback)callback {
    if (self.mTapjoy == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TAPJOY_NOTINITIALIZED
                                              msg:@"Tapjoy is not initialized."]);
        return;
    }

    [self.mTapjoy spendCurrencyWithAmount:amount
                               completion:callback];
}

- (void) tapjoyAwardCurrency:(int)amount
                  completion:(PerpleSDKCallback)callback {
    if (self.mTapjoy == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TAPJOY_NOTINITIALIZED
                                              msg:@"Tapjoy is not initialized."]);
        return;
    }

    [self.mTapjoy awardCurrencyWithAmount:amount
                               completion:callback];
}
 */

- (void) googleLogin:(PerpleSDKCallback)callback {
    if (self.mGoogle == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GOOGLE_NOTINITIALIZED
                                              msg:@"Google is not initialized."]);
        return;
    }

    [self.mGoogle login:^(NSString *result, NSString *info) {
        if ([result isEqualToString:@"success"]) {
            callback(result, [PerpleSDK getJSONStringFromNSDictionary:[self.mGoogle getProfileData]]);
        } else {
            callback(result, info);
        }
    }];
}

- (void) googleSilentLogin:(PerpleSDKCallback)callback {
    [self.mGoogle loginSilently:callback];
}

- (void) googleLogout {
    if (self.mGoogle != nil) {
        [self.mGoogle logout];
    }
}

- (void) googleRevokeAccess {
    [self googleLogout];
}

- (void) googleShowAchievementsWithCompletion:(PerpleSDKCallback)callback {
    if (self.mGoogle == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GOOGLE_NOTINITIALIZED
                                              msg:@"Google is not initialized."]);
        return;
    }

    callback(@"success", @"");
}

- (void) googleShowLeaderboardsWithCompletion:(PerpleSDKCallback)callback {
    if (self.mGoogle == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GOOGLE_NOTINITIALIZED
                                              msg:@"Google is not initialized."]);
        return;
    }

    callback(@"success", @"");
}

- (void) googleUpdateAchievements:(NSString *)achievementId
                         numSteps:(NSString *)numSteps
                       completion:(PerpleSDKCallback)callback {
    if (self.mGoogle == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GOOGLE_NOTINITIALIZED
                                              msg:@"Google is not initialized."]);
        return;
    }

    callback(@"success", @"");
}

- (void) googleUpdateLeaderboards:(NSString *)leaderboardId
                       finalScore:(NSString *)finalScore
                       completion:(PerpleSDKCallback)callback {
    if (self.mGoogle == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GOOGLE_NOTINITIALIZED
                                              msg:@"Google is not initialized."]);
        return;
    }

    callback(@"success", @"");
}

- (void) gameCenterLoginWithCompletion:(PerpleSDKCallback)callback {
    if (self.mGameCenter == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GAMECENTER_NOTINITIALIZED
                                              msg:@"GameCenter is not initialized."]);
        return;
    }

    [self.mGameCenter loginWithParam:@""
                          completion:^(NSString *result, NSString *info) {
                                  callback(result, info);
                          }];
}

/*
- (void) unityAdsStart:(BOOL)isTestMode
              metaData:(NSString *)metaData
            completion:(PerpleSDKCallback)callback {
    if (self.mUnityAds == nil) {
        callback(@"error", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_UNITYADS_NOTINITIALIZED
                                               msg:@"UnityAds is not initialized."]);
        return;
    }

    [self.mUnityAds start:isTestMode
                 metaData:metaData
               completion:callback];
}

- (void) unityAdsShow:(NSString *)placementId
             metaData:(NSString *)metaData {
    if (self.mUnityAds) {
        [self.mUnityAds show:placementId
                    metaData:metaData];
    }
}*/
/*
- (void) adColonyStart:(NSString *)zoneIds
                userId:(NSString *)userId {
    if (self.mAdColony) {
        [self.mAdColony start:zoneIds
                       userId:userId];
    }
}

- (void) adColonySetUserId:(NSString *)userId {
    if (self.mAdColony) {
        [self.mAdColony setUserId:userId];
    }
}

- (void) adColonyRequest:(NSString *)zoneId
              completion:(PerpleSDKCallback)callback {
    if (self.mAdColony) {
        [self.mAdColony request:zoneId
                     completion:callback];
    }
}

- (void) adColonyShow:(NSString *)zoneId {
    if (self.mAdColony) {
        [self.mAdColony show:zoneId];
    }
}*/

- (void) billingSetup:(NSString *)checkReceiptServerUrl
   saveTransactionUrl:saveTransactionUrl
           completion:(PerpleSDKCallback)callback {
    if (self.mBilling == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_NOTINITIALIZED
                                              msg:@"Billing is not initialized."]);
        return;
    }

    [self.mBilling startSetupWithCheckReceiptServerUrl:checkReceiptServerUrl
                                        saveTransactionUrl:saveTransactionUrl
                                            completion:callback];
}

- (void) billingConfirm:(NSString *)orderId {
    if (self.mBilling == nil) {
        return;
    }

    [self.mBilling finishPurchaseTransaction:orderId];
}

- (void) billingPurchase:(NSString *)sku
                 payload:(NSString *)payload
              completion:(PerpleSDKCallback)callback {
    if (self.mBilling == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_NOTINITIALIZED
                                              msg:@"Billing is not initialized."]);
        return;
    }

    [self.mBilling purchaseWithSku:sku
                           payload:payload
                        completion:callback];
}

- (void) billingSubscription:(NSString *)sku
                     payload:(NSString *)payload
                  completion:(PerpleSDKCallback)callback {
    if (self.mBilling == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_NOTINITIALIZED
                                              msg:@"Billing is not initialized."]);
        return;
    }

    [self.mBilling subscriptionWithSku:sku
                               payload:payload
                            completion:callback];
}

- (void) billingGetItemList:(NSString *)skuList
                 completion:(PerpleSDKCallback)callback
{
    if (self.mBilling == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_NOTINITIALIZED
                                              msg:@"Billing is not initialized."]);
        return;
    }

    [self.mBilling getItemList:skuList completion:callback];
}

- (void) billingGetIncompletePurchaseList:(PerpleSDKCallback)callback
{
    if (self.mBilling == nil) {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_BILLING_NOTINITIALIZED
                                              msg:@"Billing is not initialized."]);
        return;
    }

    [self.mBilling getIncompletePurchaseList:callback];
}

- (void) adjustTrackEvent:(NSString *)eventKey {
    if( self.mAdjust ) {
        [self.mAdjust trackEvent:eventKey];
    }
}

- (void) adjustTrackPayment:(NSString *)key price:(NSString *)price currency:(NSString *)currency {
    if( self.mAdjust ) {
        [self.mAdjust trackPayment:key price:price currency:currency];
    }
}

- (void) adjustGdprForgetMe {
    if(self.mAdjust == nil) {
        return;
    }
    [self.mAdjust gdprForgetMe];
}

- (NSString *) adjustGetAdid {
    return [self.mAdjust getAdid];
}

- (void) adMobInitialize:(PerpleSDKCallback)callback {
    if (self.mAdMob == nil) {
        
        NSLog(@"# mAdMob == nil");
        return;
    }
    
    NSLog(@"# PerpleSDK - adMobInitialize");
    [self.mAdMob initialize:callback];
}

- (void) adMobLoadRewardAd:(NSString *)adUnitId completion:(PerpleSDKCallback)callback {
    if (self.mAdMob == nil) {
        return;
    }
    [self.mAdMob loadRewardAd:adUnitId completion:callback];
}

- (void) adMobShowRewardAd:(NSString *)adUnitId completion:(PerpleSDKCallback)callback {
    if (self.mAdMob == nil) {
        return;
    }
    [self.mAdMob showRewardAd:adUnitId completion:callback];
}

- (void) adMobInitRewardedVideoAd {
    if (self.mAdMob == nil) {
        return;
    }
    //[self.mAdMob initRewardedVideoAd];
}

- (void) adMobInitInterstitialAd {
    if (self.mAdMob == nil) {
        return;
    }
    //[self.mAdMob initInterstitialAd];
}

- (void) rvAdLoadRequestWithId:(NSString *)adUnitId {
    if (self.mAdMob == nil) {
        return;
    }
    //[[self.mAdMob mRewardedVideoAd] loadRequestWithId:adUnitId];
}

- (void) rvAdSetResultCallback:(PerpleSDKCallback)callback {
    if (self.mAdMob == nil) {
        return;
    }
    //[[self.mAdMob mRewardedVideoAd] setResultCallback:callback];
}

- (void) rvAdShow:(NSString *)adUnitId {
    if (self.mAdMob == nil) {
        return;
    }
    //[[self.mAdMob mRewardedVideoAd] show:adUnitId];
}

- (void) itAdSetAdUnitId:(NSString *)adUnitId {
    if (self.mAdMob == nil) {
        return;
    }
    //[[self.mAdMob mInterstitialAd] setAdUnitId:adUnitId];
}

- (void) itAdSetResultCallback:(PerpleSDKCallback)callback {
    if (self.mAdMob == nil) {
        return;
    }
    //[[self.mAdMob mInterstitialAd] setResultCallback:callback];
}

- (void) itAdLoadRequest {
    if (self.mAdMob == nil) {
        return;
    }
    //[[self.mAdMob mInterstitialAd] loadRequest];
}

- (void) itAdShow {
    if (self.mAdMob == nil) {
        return;
    }
    //[[self.mAdMob mInterstitialAd] show];
}

- (void) crashlyticsForceCrash {
    [PerpleCrashlytics forceCrash];
}

- (void) crashlyticsSetUid:(NSString *)uid {
    [PerpleCrashlytics setUid:uid];
}

- (void) crashlyticsSetLog:(NSString *)message {
    [PerpleCrashlytics setLog:message];
}

- (void) crashlyticsSetObejctValue:(id)value forKey:(NSString *)key {
    [PerpleCrashlytics setObjectValue:value forKey:key];
}

- (void) crashlyticsSetIntValue:(int)value forKey:(NSString *)key {
    [PerpleCrashlytics setIntValue:value forKey:key];
}

- (void) crashlyticsSetBoolValue:(BOOL)value forKey:(NSString *)key {
    [PerpleCrashlytics setBoolValue:value forKey:key];
}

- (void) appleLoginWithCompletion:(PerpleSDKCallback)callback {
    if (@available(iOS 13, *)) {
        [self.mApple signInIsLink:false handler:callback];
    } else {
        callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_UNDER_IOS_13
                                              msg:@"Sign in with Apple is available on iOS 13 or newer."]);
        return;
    }
}

- (void) appleLogout {
    [self.mApple signOut];
}

//----------------------------------------------------------------------------------------------------

#pragma mark - Initialization

- (BOOL) initSDKWithGcmSenderId:(NSString *)gcmSenderId
                          debug:(BOOL)isDebug {
    self.mFirebase = [[PerpleFirebase alloc] initWithGCMSenderId:gcmSenderId];
    if (self.mFirebase == nil) {
        return NO;
    }

    sIsDebug = isDebug;

    return YES;
}

- (BOOL) initGoogleWithClientId:(NSString *)clientId
                     parentView:(UIViewController *)parentView {
    self.mGoogle = [[PerpleGoogle alloc] initWithClientID:clientId
                                               parentView:parentView];
    if (self.mGoogle == nil) {
        return NO;
    }
    return YES;
}

- (BOOL) initFacebookWithParentView:(UIViewController *)parentView {
    self.mFacebook = [[PerpleFacebook alloc] initWithParentView:parentView];
    if (self.mFacebook == nil) {
        return NO;
    }
    return YES;
}

- (BOOL) initTwitterWithCustomerKey:(NSString *)customerKey secret:(NSString *)customerSecret {
    self.mTwitter = [[PerpleTwitter alloc] initWithCustomerKey:customerKey secret:customerSecret];

    if (self.mTwitter == nil) {
        return NO;
    }
    return YES;
}

- (BOOL) initTapjoyWithAppKey:(NSString *)appKey
                      usePush:(BOOL)isUsePush
                        debug:(BOOL)isDebug {
    /*self.mTapjoy = [[PerpleTapjoy alloc] initWithAppKey:appKey
                                                usePush:isUsePush
                                                  debug:isDebug];
    if (self.mTapjoy == nil) {
        return NO;
    }
     */
    
    return YES;
}

- (BOOL) initGameCenterWithParentView:(UIViewController *)parentView {
    self.mGameCenter = [[PerpleGameCenter alloc] initWithParentView:parentView];
    if (self.mGameCenter == nil) {
        return NO;
    }
    return YES;
}

/*- (BOOL) initUnityAdsWithParentView:(UIViewController *)parentView
                             gameId:(NSString *)gameId
                              debug:(BOOL)isDebug {
    self.mUnityAds = [[PerpleUnityAds alloc] initWithGameId:gameId
                                                 parentView:parentView
                                                      debug:isDebug];
    if (self.mUnityAds == nil) {
        return NO;
    }
    return YES;
}*/
/*
- (BOOL) initAdColonyWithParentView:(UIViewController *)parentView
                              appId:(NSString *)appId {
    self.mAdColony = [[PerpleAdColony alloc] initWithAppId:appId
                                                parentView:parentView];

    if (self.mAdColony == nil) {
        return NO;
    }
    return YES;
}*/

- (BOOL) initBilling {
    self.mBilling = [[PerpleBilling alloc] init];
    if (self.mBilling == nil) {
        return NO;
    }
    return YES;
}

- (BOOL) initAdjustWithAppKey:(NSString *)appKey secret:(NSArray *)secretKey debug:(BOOL)isDebug {
    self.mAdjust = [[PerpleAdjust alloc] initWithAppKey:appKey secret:secretKey
                                                  debug:isDebug];
    if (self.mAdjust == nil) {
        return NO;
    }
    return YES;
}

- (BOOL) initAdMobWithParentView:(UIViewController *)parentView {
    self.mAdMob = [[PerpleAdMob alloc] initWithParentView:parentView];

    if (self.mAdMob == nil) {
        return NO;
    }
    return YES;
}


- (BOOL) initAppleWithWindow:(UIWindow *)window {
    self.mApple = [[HbApple alloc] initAppleWithWindow:window];

    if (self.mApple == nil) {
        return NO;
    }
    return YES;
}

- (void) dealloc {
    self.mFirebase = nil;
    self.mGoogle = nil;
    self.mFacebook = nil;
    self.mTwitter = nil;
    //self.mTapjoy = nil;
    self.mGameCenter = nil;
    //self.mUnityAds = nil;
    //self.mAdColony = nil;
    self.mBilling = nil;
    self.mAdMob = nil;

    self.mPlatformServerEncryptSecretKey = nil;
    self.mPlatformServerEncryptAlgorithm = nil;

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

//----------------------------------------------------------------------------------------------------

#pragma mark - Static methods

+ (id) sharedInstance {
    static PerpleSDK *mySharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedInstance = [[self alloc] init];
    });

    return mySharedInstance;
}

+ (void) resetProcessId {
    sProcessId++;
    if (sProcessId > 65534) {
        sProcessId = 1;
    }
}

+ (int) getProcessId {
    return sProcessId;
}

+ (BOOL) isCurrentProcessId:(int)processId {
    if (processId == sProcessId) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL) isDebug {
    return sIsDebug;
}

+ (NSString *) getErrorInfo:(NSString *)code
                        msg:(NSString *)msg {
    return [PerpleSDK getErrorInfo:code
                           subcode:@"0"
                               msg:msg];
}

+ (NSString *) getErrorInfo:(NSString *)code
                    subcode:(NSString *)subcode
                        msg:(NSString *)msg {

    return [PerpleSDK getJSONStringFromNSDictionary:@{@"code":code,
                                                      @"subcode":subcode,
                                                      @"msg":msg}];
}

+ (NSString *) getJSONStringFromNSDictionary:(NSDictionary *)obj {
    if (obj != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:0
                                                         error:&error];
        if (data != nil) {
            NSString *result = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            if (result != nil) {
                return result;
            }
        } else {
            if ([PerpleSDK isDebug]) {
                NSLog(@"PerpleSDK, Error in getJSONStringFromNSDictionary - %@", error);
            }
        }
    }
    return @"";
}

+ (NSString *) getJSONStringFromNSArray:(NSArray *)obj {
    if (obj != nil) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:0
                                                         error:&error];
        if (data != nil) {
            NSString *result = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            if (result != nil) {
                return result;
            }
        } else {
            if ([PerpleSDK isDebug]) {
                NSLog(@"PerpleSDK, Error in getJSONStringFromNSArray - %@", error);
            }
        }
    }
    return @"";
}

+ (NSDictionary *) getNSDictionaryFromJSONString:(NSString *)str {
    if (str != nil) {
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        if (data != nil) {
            NSError *error;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:kNilOptions
                                                                     error:&error];
            if (result != nil) {
                return result;
            } else {
                if ([PerpleSDK isDebug]) {
                    NSLog(@"PerpleSDK, Error in getNSDictionaryFromJSONString - %@", error);
                }
            }
        }
    }
    return @{};
}

+ (NSArray *) getNSArrayFromJSONString:(NSString *)str {
    if (str != nil) {
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        if (data != nil) {
            NSError *error;
            NSArray *result = [NSJSONSerialization JSONObjectWithData:data
                                                              options:kNilOptions
                                                                error:&error];
            if (result != nil) {
                return result;
            } else {
                if ([PerpleSDK isDebug]) {
                    NSLog(@"PerpleSDK, Error in getNSArrayFromJSONString - %@", error);
                }
            }
        }
    }
    return @[];
}

+ (NSString *) getHmacEncrypt:(NSString *)secret
                         data:(NSString *)data {

    NSString *algorithm = [[PerpleSDK sharedInstance] mPlatformServerEncryptAlgorithm];
    if ([algorithm isEqualToString:@"HmacMD5"]) {
        return [PerpleSDK getHmacEncryptMD5:secret data:data];
    } else if ([algorithm isEqualToString:@"HmacSHA1"]) {
        return [PerpleSDK getHmacEncryptSHA1:secret data:data];
    } else if ([algorithm isEqualToString:@"HmacSHA256"]) {
        return [PerpleSDK getHmacEncryptSHA256:secret data:data];
    }

    return data;
}

+ (NSString *) getHmacEncryptMD5:(NSString *)secret
                            data:(NSString *)data {
    CCHmacContext    ctx;
    const char       *key = [secret UTF8String];
    const char       *str = [data UTF8String];
    unsigned char    mac[CC_MD5_DIGEST_LENGTH];
    char             hexmac[2 * CC_MD5_DIGEST_LENGTH + 1];
    char             *p;

    CCHmacInit(&ctx, kCCHmacAlgMD5, key, strlen(key));
    CCHmacUpdate(&ctx, str, strlen(str));
    CCHmacFinal(&ctx, mac);

    p = hexmac;
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        snprintf(p, 3, "%02x", mac[ i ]);
        p += 2;
    }

    return [NSString stringWithUTF8String:hexmac];
}

+ (NSString *) getHmacEncryptSHA1:(NSString *)secret
                             data:(NSString *)data {
    CCHmacContext    ctx;
    const char       *key = [secret UTF8String];
    const char       *str = [data UTF8String];
    unsigned char    mac[CC_SHA1_DIGEST_LENGTH];
    char             hexmac[2 * CC_SHA1_DIGEST_LENGTH + 1];
    char             *p;

    CCHmacInit(&ctx, kCCHmacAlgSHA1, key, strlen(key));
    CCHmacUpdate(&ctx, str, strlen(str));
    CCHmacFinal(&ctx, mac);

    p = hexmac;
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        snprintf(p, 3, "%02x", mac[ i ]);
        p += 2;
    }

    return [NSString stringWithUTF8String:hexmac];
}

+ (NSString *) getHmacEncryptSHA256:(NSString *)secret
                               data:(NSString *)data {
    CCHmacContext    ctx;
    const char       *key = [secret UTF8String];
    const char       *str = [data UTF8String];
    unsigned char    mac[CC_SHA256_DIGEST_LENGTH];
    char             hexmac[2 * CC_SHA256_DIGEST_LENGTH + 1];
    char             *p;

    CCHmacInit(&ctx, kCCHmacAlgSHA256, key, strlen(key));
    CCHmacUpdate(&ctx, str, strlen(str));
    CCHmacFinal(&ctx, mac);

    p = hexmac;
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        snprintf(p, 3, "%02x", mac[ i ]);
        p += 2;
    }

    return [NSString stringWithUTF8String:hexmac];
}

+ (void) requestHttpPostWithUrl:(NSString *)url contentBody:(NSDictionary *)contentBody result:(NSString **)result error:(NSError **)error {
    *result = nil;
    *error = nil;

    NSURL *requestUrl = [[NSURL alloc] initWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];

    request.HTTPMethod = @"POST";
    request.timeoutInterval = 15.0;

    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSError *err1= nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:contentBody
                                                       options:0
                                                         error:&err1];
    if (err1 != nil) {
        *error = err1;
        return;
    }

    NSString *secretKey = [[PerpleSDK sharedInstance] mPlatformServerEncryptSecretKey];
    if (secretKey != nil && ![secretKey isEqualToString:@""]) {
        NSString *inputData = [[NSString alloc] initWithData:bodyData
                                                    encoding:NSUTF8StringEncoding];
        NSString *encryptData = [PerpleSDK getHmacEncrypt:secretKey
                                                     data:inputData];
        [request setValue:encryptData forHTTPHeaderField:@"HMAC"];
    }

    request.HTTPBody = bodyData;

    NSError *err2 = nil;
    NSURLResponse *response = nil;
    NSData *responseData = [PerpleSDK sendSynchronousRequest:request
                                           returningResponse:&response
                                                       error:&err2];

    if (err2 != nil) {
        *error = err2;
        return;
    }

    *result = [[NSString alloc] initWithData:responseData
                                    encoding:NSUTF8StringEncoding];
}

+ (NSData *) sendSynchronousRequest:(NSURLRequest *)request
                  returningResponse:(NSURLResponse **)response
                              error:(NSError **)error {
    NSError __block *err;
    NSData __block *data;
    NSURLResponse __block *resp;

    BOOL __block isProcessed = NO;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _response, NSError * _Nullable _error) {
                                         resp = _response;
                                         err = _error;
                                         data = _data;
                                         isProcessed = YES;
                                     }] resume];

    while (!isProcessed) {
        [NSThread sleepForTimeInterval:0];
    }

    *response = resp;
    *error = err;
    return data;
}

// @fcm
+ (void) onFCMTokenRefresh:(NSString *)token {
    if (sFCMTokenRefreshCallback != nil) {
        sFCMTokenRefreshCallback(@"refresh", token);
    }
}

//----------------------------------------------------------------------------------------------------

#pragma mark - AppDelegate

// AppDelegate
- (void) applicationDidBecomeActive:(UIApplication *)application {
    if (self.mFirebase != nil) {
        [self.mFirebase applicationDidBecomeActive:application];
    }

    if (self.mFacebook != nil) {
        [self.mFacebook applicationDidBecomeActive:application];
    }
}

// AppDelegate
- (void) applicationWillEnterForeground:(UIApplication *)application {
    /*
    if (self.mTapjoy != nil) {
        [self.mTapjoy applicationWillEnterForeground:application];
    }
     */
}

// AppDelegate
- (void) applicationDidEnterBackground:(UIApplication *)application {
    if (self.mFirebase != nil) {
        [self.mFirebase applicationDidEnterBackground:application];
    }

    /*
    if (self.mTapjoy != nil) {
        [self.mTapjoy applicationDidEnterBackground:application];
    }
     */
}

// AppDelegate
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    if (self.mFirebase != nil) {
        [self.mFirebase application:application didFinishLaunchingWithOptions:launchOptions];
    }

    if (self.mFacebook != nil) {
        [self.mFacebook application:application didFinishLaunchingWithOptions:launchOptions];
    }

    if (self.mAdMob != nil) {
        [self.mAdMob application:application didFinishLaunchingWithOptions:launchOptions];
    }
    return YES;
}

// AppDelegate
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    if ([PerpleSDK isDebug]){
        NSLog(@"PerpleSDK application open url : %@", [url absoluteString]);
    }

    if (self.mTwitter != nil) {
        [self.mTwitter application:application openURL:url options:options];
    }

    if (self.mAdjust != nil ) {
        [self.mAdjust application:application openURL:url options:options];
    }

    NSString* sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
    id annotation = options[UIApplicationOpenURLOptionsAnnotationKey];

    if (self.mFacebook != nil) {
        [self.mFacebook application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }

    if (self.mGoogle != nil) {
        [self.mGoogle application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }


    return YES;
}

// AppDelegate
- (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSLog(@"continueUserActivity method called with URL: %@", [userActivity webpageURL]);

        if( self.mAdjust != nil ) {
            [self.mAdjust application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
        }
    }

    return YES;
}

// AppDelegate, Push notifications
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (self.mFirebase != nil) {
        [self.mFirebase application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }

    /*
    if (self.mTapjoy != nil) {
        [self.mTapjoy application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }
     */
}

// AppDelegate, Push notifications
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // @fcm
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:nil];
}

// AppDelegate, Push notifications
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // @fcm
    if (self.mFirebase != nil) {
        [self.mFirebase application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }

    /*
    if (self.mTapjoy != nil) {
        [self.mTapjoy application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
     */
}

- (void)payment:(SKPaymentTransaction *)transaction
        product:(SKProduct *)product {
    /*
    if (self.mTapjoy != nil) {
        [self.mTapjoy payment:transaction product:product];
    }
     */
}

//----------------------------------------------------------------------------------------------------

@end
