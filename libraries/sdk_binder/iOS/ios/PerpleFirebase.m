//
//  PerpleFirebase.m
//  PerpleSDK
//
//  Created by PerpleLab on 2016. 7. 28..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import "PerpleFirebase.h"
#import "PerpleGoogle.h"
#import "PerpleFacebook.h"
#import "PerpleTwitter.h"
#import "PerpleGameCenter.h"

@implementation PerpleFirebase

static NSString * fcmToken = nil;

#pragma mark - Properties

@synthesize mIsSignedIn;
@synthesize mIsReceivePushOnForeground;
@synthesize mGCMSenderId;

#pragma mark - Initialization

- (id) initWithGCMSenderId:(NSString *)gcmSenderId {
    NSLog(@"PerpleFirebase, Initializing Firebase.");

    if (self = [super init]) {
        [FIRApp configure];

        [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
            if (user != nil) {
                // User is signed in.
                self.mIsSignedIn = YES;
            } else {
                // No user is signed in.
                self.mIsSignedIn = NO;
            }
        }];

        self.mGCMSenderId = gcmSenderId;

    } else {
        NSLog(@"PerpleFirebase, Initializing Firebase fail.");
    }

    return self;
}

- (void) dealloc {
    self.mGCMSenderId = nil;

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs

- (void) setFCMPushOnForeground:(BOOL)isReceive {
    self.mIsReceivePushOnForeground = isReceive;
}

- (void) subscribeToTopic:(NSString *)topic {
    [[FIRMessaging messaging] subscribeToTopic:topic];
}

- (void) unsubscribeFromTopic:(NSString *)topic {
    [[FIRMessaging messaging] unsubscribeFromTopic:topic];
}

- (void) logEvent:(NSString *)arg0 param:(NSString *)arg1 {
    [FIRAnalytics logEventWithName:arg0
                        parameters:[PerpleSDK getNSDictionaryFromJSONString:arg1]];
}

- (void) setUserProperty:(NSString *)arg0 param:(NSString *)arg1 {
    [FIRAnalytics setUserPropertyString:arg1
                                forName:arg0];
}

- (void) autoLoginWithCompletion:(PerpleSDKCallback)callback {
    if (self.mIsSignedIn) {
        NSString *info = [PerpleFirebase getLoginInfo:[FIRAuth auth].currentUser providerId:nil];
        if ([PerpleSDK isDebug]) {
            NSLog(@"PerpleFirebase, Firebase autoLogin success - info:%@", info);
        }
        callback(@"success", info);
    } else {
        if ([PerpleSDK isDebug]) {
            NSLog(@"PerpleFirebase, Firebase autoLogin fail.");
        }
        callback(@"fail", @"");
    }
}

- (void) loginAnonymouslyWithCompletion:(PerpleSDKCallback)callback {
    [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authData, NSError * _Nullable error) {
        if (error == nil) {
            NSString *info = [PerpleFirebase getLoginInfo:[authData user] providerId:@"firebase"];
            if ([PerpleSDK isDebug]) {
                NSLog(@"PerpleFirebase, Firebase loginAnonymously success - info:%@", info);
            }
            callback(@"success", info);
        } else {
            NSString *info = [PerpleFirebase getErrorInfoFromFirebaseError:error];
            if ([PerpleSDK isDebug]) {
                NSLog(@"PerpleFirebase, Firebase loginAnonymously fail - info:%@", info);
            }
            callback(@"fail", info);
        }
    }];
}

- (void) logout {
    NSError *error = nil;
    [[FIRAuth auth] signOut:&error];
    if (error == nil) {
        // Sign-out succeeded
        if ([PerpleSDK isDebug]) {
            NSLog(@"PerpleFirebase, Firebase logout success");
        }
    } else {
        NSString *info = [PerpleFirebase getErrorInfoFromFirebaseError:error];
        if ([PerpleSDK isDebug]) {
            NSLog(@"PerpleFirebase, Firebase logout fail - info:%@", info);
        }
    }
}

- (void) deleteUserWithCompletion:(PerpleSDKCallback)callback {
    // Important: To delete a user, the user must have signed in recently. See Re-authenticate a user.
    [[FIRAuth auth].currentUser deleteWithCompletion:^(NSError * _Nullable error) {
        if (error == nil) {
            if ([PerpleSDK isDebug]) {
                NSLog(@"PerpleFirebase, Firebase deleteUser success");
            }
            callback(@"success", @"");
        } else {
            NSString *info = [PerpleFirebase getErrorInfoFromFirebaseError:error];
            if ([PerpleSDK isDebug]) {
                NSLog(@"PerpleFirebase, Firebase deleteUser fail - info:%@", info);
            }
            callback(@"fail", info);
        }
    }];
}

- (void) signInWithCredential:(FIRAuthCredential *)credential
                   providerId:(NSString *)providerId
                   completion:(PerpleSDKCallback)callback {
    [[FIRAuth auth] signInWithCredential:credential
                              completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                                 if (error == nil) {
                                     NSString *info = [PerpleFirebase getLoginInfoFromAuthResult:authResult providerId:providerId];
                                     if ([PerpleSDK isDebug]) {
                                         NSLog(@"PerpleFirebase, Firebase signInWithCredential success - info:%@", info);
                                     }
                                     callback(@"success", info);
                                 } else {
                                     NSString *info = [PerpleFirebase getErrorInfoFromFirebaseError:error];
                                     if ([PerpleSDK isDebug]) {
                                         NSLog(@"PerpleFirebase, Firebase signInWithCredential fail - info:%@", info);
                                     }
                                     callback(@"fail", info);
                                 }
                             }];
}

- (void) signInWithCustomToken:(NSString *)customToken
                    completion:(PerpleSDKCallback)callback {
    [[FIRAuth auth] signInWithCustomToken:customToken
                               completion:^(FIRAuthDataResult * _Nullable authData, NSError * _Nullable error) {
                                   if (error == nil) {
                                       FIRUser *user = [authData user];
                                       NSString *displayName = [PerpleFirebase getDisplayName:user providerId:@"gamecenter"];
                                       NSString *newDisplayName = [[[PerpleSDK sharedInstance] mGameCenter] getProfileData][@"name"];
                                       if ([displayName isEqualToString:newDisplayName]) {
                                           NSString *info = [PerpleFirebase getLoginInfo:user providerId:@"gamecenter"];
                                           if ([PerpleSDK isDebug]) {
                                               NSLog(@"PerpleFirebase, Firebase signInWithCustomToken success - info:%@", info);
                                           }
                                           callback(@"success", info);
                                       } else {
                                           displayName = newDisplayName;
                                           FIRUserProfileChangeRequest *changeRequest = [user profileChangeRequest];
                                           changeRequest.displayName = displayName;
                                           [changeRequest commitChangesWithCompletion:^(NSError * _Nullable error) {
                                               NSString *info = [PerpleFirebase getLoginInfo:[authData user] providerId:@"gamecenter"];
                                               if ([PerpleSDK isDebug]) {
                                                   NSLog(@"PerpleFirebase, Firebase signInWithCustomToken success - info:%@", info);
                                               }
                                               callback(@"success", info);
                                           }];
                                       }
                                   } else {
                                       NSString *info = [PerpleFirebase getErrorInfoFromFirebaseError:error];
                                       if ([PerpleSDK isDebug]) {
                                           NSLog(@"PerpleFirebase, Firebase signInWithCustomToken fail - info:%@", info);
                                       }
                                       callback(@"fail", info);
                                   }
                               }];
}

- (void) signInWithEmail:(NSString *)email
                password:(NSString *)password
              completion:(PerpleSDKCallback)callback {
    [[FIRAuth auth] signInWithEmail:email
                           password:password
                         completion:^(FIRAuthDataResult * _Nullable authData, NSError * _Nullable error) {
                             if (error == nil) {
                                 NSString *info = [PerpleFirebase getLoginInfo:[authData user] providerId:@"password"];
                                 if ([PerpleSDK isDebug]) {
                                     NSLog(@"PerpleFirebase, Firebase signInWithEmail success - info:%@", info);
                                 }
                                 callback(@"success", info);
                             } else {
                                 NSString *info = [PerpleFirebase getErrorInfoFromFirebaseError:error];
                                 if ([PerpleSDK isDebug]) {
                                     NSLog(@"PerpleFirebase, Firebase signInWithEmail fail - info:%@", info);
                                 }
                                 callback(@"fail", info);
                             }
                         }];
}

- (void) linkWithCredential:(FIRAuthCredential *)credential
                 providerId:(NSString *)providerId
                 completion:(PerpleSDKCallback)callback {
    [[FIRAuth auth].currentUser linkWithCredential:credential
                                        completion:^(FIRAuthDataResult * _Nullable authData, NSError * _Nullable error) {
                                            if (error == nil) {
                                                NSString *info = [PerpleFirebase getLoginInfo:[authData user] providerId:providerId];
                                                if ([PerpleSDK isDebug]) {
                                                    NSLog(@"PerpleFirebase, Firebase linkWithCredential success - info:%@", info);
                                                }
                                                callback(@"success", info);
                                            } else {
                                                NSString *info = [PerpleFirebase getErrorInfoFromFirebaseError:error];
                                                if ([PerpleSDK isDebug]) {
                                                    NSLog(@"PerpleFirebase, Firebase linkWithCredential fail - info:%@", info);
                                                }
                                                callback(@"fail", info);
                                            }
                                        }];
}

- (void) linkAndRetrieveDataWithCredential:(FIRAuthCredential *)credential
                                providerId:(NSString *)providerId
                                completion:(PerpleSDKCallback)callback {
    [[FIRAuth auth].currentUser linkWithCredential:credential
                                       completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                                           if (error == nil) {
                                               NSString *info = [PerpleFirebase getLoginInfoFromAuthResult:authResult providerId:providerId];
                                               if ([PerpleSDK isDebug]) {
                                                   NSLog(@"PerpleFirebase, Firebase linkWithCredential success - info:%@", info);
                                               }
                                               callback(@"success", info);
                                           } else {
                                               NSString *info = [PerpleFirebase getErrorInfoFromFirebaseError:error];
                                               if ([PerpleSDK isDebug]) {
                                                   NSLog(@"PerpleFirebase, Firebase linkWithCredential fail - info:%@", info);
                                               }
                                               callback(@"fail", info);
                                           }
                                       }];
}

- (void) unlink:(NSString *)providerId completion:(PerpleSDKCallback)callback {
    [[FIRAuth auth].currentUser unlinkFromProvider:providerId
                                        completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                                            if (error == nil) {
                                                NSString *info = [PerpleFirebase getLoginInfo:user providerId:nil];
                                                if ([PerpleSDK isDebug]) {
                                                    NSLog(@"PerpleFirebase, Firebase unlink success - info:%@", info);
                                                }
                                                callback(@"success", info);
                                            } else {
                                                NSString *info = [PerpleFirebase getErrorInfoFromFirebaseError:error];
                                                if ([PerpleSDK isDebug]) {
                                                    NSLog(@"PerpleFirebase, Firebase unlink fail - info:%@", info);
                                                }
                                                callback(@"fail", info);
                                            }
                                        }];
}

- (void) createUserWithEmail:(NSString *)email
                    password:(NSString *)password
                  completion:(PerpleSDKCallback)callback {
    [[FIRAuth auth] createUserWithEmail:email
                               password:password
                             completion:^(FIRAuthDataResult * _Nullable authData, NSError * _Nullable error) {
                                 if (error == nil) {
                                     NSString *info = [PerpleFirebase getLoginInfo:[authData user] providerId:@"password"];
                                     if ([PerpleSDK isDebug]) {
                                         NSLog(@"PerpleFirebase, Firebase createUserWithEmail success - info:%@", info);
                                     }
                                     callback(@"success", info);
                                 } else {
                                     NSString *info = [PerpleFirebase getErrorInfoFromFirebaseError:error];
                                     if ([PerpleSDK isDebug]) {
                                         NSLog(@"PerpleFirebase, Firebase createUserWithEmail fail - info:%@", info);
                                     }
                                     callback(@"fail", info);
                                 }
                             }];
}

- (void) sendPasswordResetWithEmail:(NSString *)email
                         completion:(PerpleSDKCallback)callback {
    [[FIRAuth auth] sendPasswordResetWithEmail:email
                                    completion:^(NSError * _Nullable error) {
                                        if (error == nil) {
                                            if ([PerpleSDK isDebug]) {
                                                NSLog(@"PerpleFirebase, Firebase sendPasswordResetEmail success");
                                            }
                                            callback(@"success", @"");
                                        } else {
                                            NSString *info = [PerpleFirebase getErrorInfoFromFirebaseError:error];
                                            if ([PerpleSDK isDebug]) {
                                                NSLog(@"PerpleFirebase, Firebase sendPasswordResetEmail fail - info:%@", info);
                                            }
                                            callback(@"fail", info);
                                        }
                                    }];
}

#pragma mark - Static utility methods

+ (FIRAuthCredential *) getGoogleCredentialWithIdToken:(NSString *)idToken
                                           accessToken:(NSString *)accessToken {
    return [FIRGoogleAuthProvider credentialWithIDToken:idToken
                                            accessToken:accessToken];
}

+ (FIRAuthCredential *) getFacebookCredentialWithAccessToken:(NSString *)accessToken {
    return [FIRFacebookAuthProvider credentialWithAccessToken:accessToken];
}

+ (FIRAuthCredential *) getTwitterCredentialWithAccessToken:(NSString *)authToken secret:(NSString* )authTokenSecret {
    return [FIRTwitterAuthProvider credentialWithToken:authToken secret:authTokenSecret];
}

+ (FIRAuthCredential *) getEmailCredentialWithEmail:(NSString *)email
                                           password:(NSString *)password {
    return [FIREmailAuthProvider credentialWithEmail:email
                                            password:password];
}

+ (FIRAuthCredential *) getGameCenterCredentialWithCustomToken:(NSString *)customToken {
    return [FIROAuthProvider credentialWithProviderID:@"gamecenter" IDToken:customToken accessToken:nil];
}

+ (NSString *) getLoginInfo:(FIRUser *)user
                 providerId:(NSString *)providerId {
    if (user != nil) {
        return [PerpleSDK getJSONStringFromNSDictionary:@{@"fuid":user.uid,
                                                          @"name":[PerpleFirebase getDisplayName:user providerId:providerId],
                                                          @"providerId":[PerpleFirebase getProviderId:user providerId:providerId],
                                                          @"providerData":[PerpleFirebase getProviderData:user],
                                                          @"pushToken":[PerpleFirebase getPushToken]}];
    }
    return @"";
}

+ (NSString *) getLoginInfoFromAuthResult:(FIRAuthDataResult *)authResult
                 providerId:(NSString *)providerId {

    FIRUser *user = authResult.user;
    if (user == nil) {
        return @"";
    }

    NSString *displayName = [PerpleFirebase getDisplayName:user providerId:providerId];

    FIRAdditionalUserInfo *userInfo = authResult.additionalUserInfo;
    if (userInfo != nil && userInfo.profile != nil) {

        NSString *name = @"";
        NSObject *nameObj = [userInfo.profile objectForKey:@"name"];
        if (nameObj != nil) {
            name = (NSString *)nameObj;
        }

        NSString *email = @"";
        NSObject *emailObj = [userInfo.profile objectForKey:@"email"];
        if (emailObj != nil) {
            email = (NSString *)emailObj;
        }

        NSString *newDisplayName = name;
        if (![email isEqualToString:@""]) {
            //newDisplayName = [newDisplayName stringByAppendingString:@"("];
            //newDisplayName = [newDisplayName stringByAppendingString:email];
            //newDisplayName = [newDisplayName stringByAppendingString:@")"];
            newDisplayName = email;
        }

        if (![displayName isEqualToString:newDisplayName]) {
            displayName = newDisplayName;
            FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
            changeRequest.displayName = displayName;
            [changeRequest commitChangesWithCompletion:^(NSError * _Nullable error) {}];
        }
    }

    return [PerpleSDK getJSONStringFromNSDictionary:@{@"fuid":user.uid,
                                                      @"name":displayName,
                                                      @"providerId":[PerpleFirebase getProviderId:user providerId:providerId],
                                                      @"providerData":[PerpleFirebase getProviderData:user],
                                                      @"pushToken":[PerpleFirebase getPushToken]}];
}

/*
+ (NSDictionary *) getUserProfile:(FIRUser *)user {

    NSString *uid = user.uid;
    NSString *name = (user.displayName ? user.displayName : @"");
    NSString *email = (user.email ? user.email : @"");
    NSString *photoUrl = (user.photoURL ? user.photoURL.absoluteString : @"");
    NSString *providerId = [user.providerID lowercaseString];

    return  @{@"fuid":uid,
              @"name":name,
              @"email":email,
              @"photoUrl":photoUrl,
              @"providerId":providerId};
}
*/

+ (NSString *) getDisplayName:(FIRUser *)user
                   providerId:(NSString *)providerId {
    if (user == nil) {
        return @"";
    }

    if (user.isAnonymous) {
        return @"Guest";
    }

    return (user.displayName ? user.displayName : @"");
}

+ (NSString *) getProviderId:(FIRUser *)user
                  providerId:(NSString *)providerId {
    if (user == nil) {
        return @"firebase";
    }

    if (user.isAnonymous) {
        return [user.providerID lowercaseString];
    }

    if (providerId != nil) {
        return providerId;
    }

    // autoLogin, unlink 인 경우 providerId가 nil로 온다.

    if ([user.providerData count] > 0) {
        int lastIdx = (int)[user.providerData count] - 1;
        return [[[user.providerData objectAtIndex:lastIdx] providerID] lowercaseString];
    }

    // Anonymous가 아니면서 providerData에 정보가 없는 경우는 gamecenter
    return @"gamecenter";
}

+ (NSArray *) getProviderData:(FIRUser *)user {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (id<FIRUserInfo> info in user.providerData) {
        [array addObject:@{
                           @"providerId":[info.providerID lowercaseString],
                           //@"uid":info.uid,
                           //@"name":(info.displayName ? info.displayName : @""),
                           //@"email":(info.email ? info.email : @""),
                           //@"photoUrl":(info.photoURL ? info.photoURL.absoluteString : @"")
                           }];
    }
    return array;
}

+ (void) setPushToken:(NSString *)token {
    fcmToken = token;
}

+ (NSString *) getPushToken {
    //NSString *token = [[FIRInstanceID instanceID] token];
    NSString *token = fcmToken;
    if (token != nil) {
        return token;
    } else {
        return @"";
    }
}

+ (BOOL) loginInfo:(NSString *)info
isLinkedWithProvider:(NSString *)provider {
    NSDictionary *dict = [PerpleSDK getNSDictionaryFromJSONString:info];
    NSArray *array = dict[@"providerData"];
    if (array != nil) {
        for (id obj in array) {
            if ([obj[@"providerId"] isEqualToString:provider]) {
                return YES;
            }
        }
    }
    return NO;
}

+ (NSString *) addGoogleLoginInfo:(NSString *)info {
    NSMutableDictionary *dict = [[PerpleSDK getNSDictionaryFromJSONString:info] mutableCopy];
    [dict setObject:[[[PerpleSDK sharedInstance] mGoogle] getProfileData] forKey:@"google"];
    return [PerpleSDK getJSONStringFromNSDictionary:dict];
}

+ (NSString *) addFacebookLoginInfo:(NSString *)info {
    NSMutableDictionary *dict = [[PerpleSDK getNSDictionaryFromJSONString:info] mutableCopy];
    [dict setObject:[[[PerpleSDK sharedInstance] mFacebook] getProfileData] forKey:@"facebook"];
    return [PerpleSDK getJSONStringFromNSDictionary:dict];
}

+ (NSString *) addTwitterLoginInfo:(NSString *)info {
    NSMutableDictionary *dict = [[PerpleSDK getNSDictionaryFromJSONString:info] mutableCopy];
    [dict setObject:[[[PerpleSDK sharedInstance] mTwitter] getProfileData] forKey:@"twitter"];
    return [PerpleSDK getJSONStringFromNSDictionary:dict];
}

+ (NSString *) addGameCenterLoginInfo:(NSString *)info {
    NSMutableDictionary *dict = [[PerpleSDK getNSDictionaryFromJSONString:info] mutableCopy];
    [dict setObject:[[[PerpleSDK sharedInstance] mGameCenter] getProfileData] forKey:@"gamecenter"];
    return [PerpleSDK getJSONStringFromNSDictionary:dict];
}

+ (NSString *) getErrorInfoFromFirebaseError:(NSError *)error {
    NSString *subcode = [@(error.code) stringValue];
    switch (error.code) {
        case FIRAuthErrorCodeInvalidCustomToken:
            subcode = @"INVALID_CUSTOM_TOKEN";
            break;
        case FIRAuthErrorCodeCustomTokenMismatch:
            subcode = @"CUSTOM_TOKEN_MISMATCH";
            break;
        case FIRAuthErrorCodeInvalidCredential:
            subcode = @"INVALID_CREDENTIAL";
            break;
        case FIRAuthErrorCodeUserDisabled:
            subcode = @"USER_DISABLED";
            break;
        case FIRAuthErrorCodeOperationNotAllowed:
            subcode = @"OPERATION_NOT_ALLOWED";
            break;
        case FIRAuthErrorCodeEmailAlreadyInUse:
            subcode = @"EMAIL_ALREADY_IN_USE";
            break;
        case FIRAuthErrorCodeInvalidEmail:
            subcode = @"INVALID_EMAIL";
            break;
        case FIRAuthErrorCodeWrongPassword:
            subcode = @"WRONG_PASSWORD";
            break;
        case FIRAuthErrorCodeTooManyRequests:
            subcode = @"TOO_MANY_REQUESTS";
            break;
        case FIRAuthErrorCodeUserNotFound:
            subcode = @"USER_NOT_FOUND";
            break;
        case FIRAuthErrorCodeAccountExistsWithDifferentCredential:
            subcode = @"EXIST_WITH_DIFFERENT_CREDENTIAL";
            break;
        case FIRAuthErrorCodeRequiresRecentLogin:
            subcode = @"REQUIRES_RECENT_LOGIN";
            break;
        case FIRAuthErrorCodeProviderAlreadyLinked:
            subcode = @"PROVIDER_ALREADY_LINKED";
            break;
        case FIRAuthErrorCodeNoSuchProvider:
            subcode = @"NO_SUCH_PROVIDER";
            break;
        case FIRAuthErrorCodeInvalidUserToken:
            subcode = @"INVALID_USER_TOKEN";
            break;
        case FIRAuthErrorCodeNetworkError:
            subcode = @"NETWORK_ERROR";
            break;
        case FIRAuthErrorCodeUserTokenExpired:
            subcode = @"USER_TOKEN_EXPIRED";
            break;
        case FIRAuthErrorCodeInvalidAPIKey:
            subcode = @"INVALID_API_KEY";
            break;
        case FIRAuthErrorCodeUserMismatch:
            subcode = @"USER_MISMATCH";
            break;
        case FIRAuthErrorCodeCredentialAlreadyInUse:
            subcode = @"CREDENTIAL_ALREADY_IN_USE";
            break;
        case FIRAuthErrorCodeWeakPassword:
            subcode = @"WEAK_PASSWORD";
            break;
        case FIRAuthErrorCodeAppNotAuthorized:
            subcode = @"APP_NOT_AUTHORIZED";
            break;
        case FIRAuthErrorCodeExpiredActionCode:
            subcode = @"EXPIRED_ACTION_CODE";
            break;
        case FIRAuthErrorCodeInvalidActionCode:
            subcode = @"INVALID_ACTION_CODE";
            break;
        case FIRAuthErrorCodeInvalidMessagePayload:
            subcode = @"INVALID_MESSAGE_PAYLOAD";
            break;
        case FIRAuthErrorCodeInvalidSender:
            subcode = @"INVALID_SENDER";
            break;
        case FIRAuthErrorCodeInvalidRecipientEmail:
            subcode = @"INVALID_RECIPIENT_EMAIL";
            break;
        case FIRAuthErrorCodeMissingPhoneNumber:
            subcode = @"MISSING_PHONE_NUMBER";
            break;
        case FIRAuthErrorCodeInvalidPhoneNumber:
            subcode = @"INVALID_PHONE_NUMBER";
            break;
        case FIRAuthErrorCodeMissingVerificationCode:
            subcode = @"MISSING_VERIFICATION_CODE";
            break;
        case FIRAuthErrorCodeInvalidVerificationCode:
            subcode = @"INVALID_VERIFICATION_CODE";
            break;
        case FIRAuthErrorCodeMissingVerificationID:
            subcode = @"MISSING_VERIFICATION_ID";
            break;
        case FIRAuthErrorCodeInvalidVerificationID:
            subcode = @"INVALID_VERIFICATION_ID";
            break;
        case FIRAuthErrorCodeMissingAppCredential:
            subcode = @"MISSING_APP_CREDENTIAL";
            break;
        case FIRAuthErrorCodeInvalidAppCredential:
            subcode = @"INVALID_APP_CREDENTIAL";
            break;
        case FIRAuthErrorCodeSessionExpired:
            subcode = @"SESSION_EXPIRED";
            break;
        case FIRAuthErrorCodeQuotaExceeded:
            subcode = @"QUOTA_EXCEEDED";
            break;
        case FIRAuthErrorCodeMissingAppToken:
            subcode = @"MISSING_APP_TOKEN";
            break;
        case FIRAuthErrorCodeNotificationNotForwarded:
            subcode = @"NOTIFICATION_NOT_FORWARDED";
            break;
        case FIRAuthErrorCodeAppNotVerified:
            subcode = @"APP_NOT_VERIFIED";
            break;
        case FIRAuthErrorCodeKeychainError:
            subcode = @"KEYCHAIN_ERROR";
            break;
        case FIRAuthErrorCodeInternalError:
            subcode = @"INTERNAL_ERROR";
            break;
    }

    return [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FIREBASE_LOGIN
                           subcode:subcode
                               msg:error.localizedDescription];
}

#pragma mark - AppDelegate

// AppDelegate.m
- (void) applicationDidBecomeActive:(UIApplication *)application {
}

// AppDelegate.m
- (void) applicationDidEnterBackground:(UIApplication *)application {
}

// AppDelegate.m
// @fcm
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // @fcm
    // [START set_messaging_delegate]
    [FIRMessaging messaging].delegate = self;
    // [END set_messaging_delegate]

    
    // @fcm
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    // [START register_for_notifications]
    if ([UNUserNotificationCenter class] != nil) {
      // iOS 10 or later
      // For iOS 10 display notification (sent via APNS)
      [UNUserNotificationCenter currentNotificationCenter].delegate = self;
      UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
          UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
      [[UNUserNotificationCenter currentNotificationCenter]
          requestAuthorizationWithOptions:authOptions
          completionHandler:^(BOOL granted, NSError * _Nullable error) {
            // ...
          }];
    } else {
      // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
      UIUserNotificationType allNotificationTypes =
      (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
      UIUserNotificationSettings *settings =
      [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
      [application registerUserNotificationSettings:settings];
    }

    [application registerForRemoteNotifications];
    // [END register_for_notifications]
    
    return YES;
}

// AppDelegate.m
// @fcm
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [FIRMessaging messaging].APNSToken = deviceToken;
}

// AppDelegate.m
// @fcm
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fire till the user taps on the notification launching the application.

    // Let FCM know about the message for analytics etc.
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

    // Handle data of notification on foreground
    if (self.mIsReceivePushOnForeground) {
        UILocalNotification *localNoti = [[UILocalNotification alloc] init];
        localNoti.userInfo = userInfo;
        localNoti.soundName = UILocalNotificationDefaultSoundName;
        localNoti.applicationIconBadgeNumber = 1;
        [application presentLocalNotificationNow:localNoti];
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - FIRMessagingDelegate

// FIRMessagingDelegate
// @fcm
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
    
    [PerpleFirebase setPushToken:fcmToken];
    
    NSString * refreshedToken = fcmToken;
    [PerpleSDK onFCMTokenRefresh:refreshedToken];
}

@end
