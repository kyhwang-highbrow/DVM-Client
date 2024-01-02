//
//  runtime_ios.mm
//  PerpleSDK
//
//  Created by PerpleLab on 2016. 7. 27..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import "PerpleCore.h"
#import "PerpleSDK.h"
#import <Foundation/Foundation.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <FBSDKCoreKit/FBSDKSettings.h>
#import "sdk_binder-swift.h"


// autoLogin, loginWithGoogle
// "success" :
//{
//    "fuid":"@uid",
//    "name":"@name",
//    "providerId":"@providerId"
//    "providerData":
//    [
//        {
//            "providerId":"@providerId"
//        },
//        ...
//    ],
//    "pushToken":"@token",
//    "google":
//    {
//        "id":"@id",
//        "name":"@name",
//    }
//}

// all functions
// "fail" : {"code":"-999","subcode":"0","msg":"Unknown error"}

#pragma mark - Lua binding initialization

void resetLuaBinding(int funcID) {
    [PerpleSDK resetProcessId];
}

#pragma mark - Platform Server Hmac MD5 encryption

void setPlatformServerSecretKey(int funcID, const char* secretKey, const char* algorithm) {
    [[PerpleSDK sharedInstance] setPlatformServerSecretKey:[NSString stringWithUTF8String:secretKey]
                                                 algorithm:[NSString stringWithUTF8String:algorithm]];
}

#pragma mark - FCM(Firebase cloud messaging)

void setFCMPushOnForeground(int funcID, int isReceive) {
    [[PerpleSDK sharedInstance] setFCMPushOnForeground:(isReceive == 0 ? NO : YES)];
}

void setFCMTokenRefresh(int funcID) {
    // refresh / error
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] setFCMTokenRefreshWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void getFCMToken(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] getFCMTokenWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void subscribeToTopic(int funcID, const char* topic) {
    [[PerpleSDK sharedInstance] subscribeToTopic:[NSString stringWithUTF8String:topic]];
}

void unsubscribeFromTopic(int funcID, const char* topic) {
    [[PerpleSDK sharedInstance] unsubscribeFromTopic:[NSString stringWithUTF8String:topic]];
}

#pragma mark - Firebase Analytics

void logEvent(int funcID, const char* arg0, const char* arg1) {
    [[PerpleSDK sharedInstance] logEvent:[NSString stringWithUTF8String:arg0]
                                   param:[NSString stringWithUTF8String:arg1]];
}

void setUserProperty(int funcID, const char* arg0, const char* arg1) {
    [[PerpleSDK sharedInstance] setUserProperty:[NSString stringWithUTF8String:arg0]
                                          param:[NSString stringWithUTF8String:arg1]];
}

#pragma mark - Firebase Authentification

void autoLogin(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] autoLoginWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void loginAnonymously(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] loginAnonymouslyWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void loginWithGoogle(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] loginWithGoogleWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void loginWithFacebook(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] loginWithFacebookWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void loginWithTwitter(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] loginWithTwitterWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void loginWithGameCenter(int funcID, const char* param1) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] loginWithGameCenter:[NSString stringWithUTF8String:param1]
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
}

void loginWithApple(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] loginWithAppleWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void loginWithEmail(int funcID, const char* email, const char* password) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] loginWithEmail:[NSString stringWithUTF8String:email]
                                      password:[NSString stringWithUTF8String:password]
                                    completion:^(NSString *result, NSString *info) {
                                        if ([PerpleSDK isCurrentProcessId:processId]) {
                                            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                        }
                                    }];
}

void loginWithCustomToken(int funcID, const char* customToken) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] loginWithCustomToken:[NSString stringWithUTF8String:customToken]
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
}

void linkWithGoogle(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] linkWithGoogleWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void linkWithFacebook(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] linkWithFacebookWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void linkWithTwitter(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] linkWithTwitterWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void linkWithApple(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] linkWithAppleWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void linkWithEmail(int funcID, const char* email, const char* password) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] linkWithEmail:[NSString stringWithUTF8String:email]
                                     password:[NSString stringWithUTF8String:password]
                                   completion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void unlinkWithGoogle(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] unlinkWithGoogleWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void unlinkWithFacebook(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] unlinkWithFacebookWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void unlinkWithTwitter(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] unlinkWithTwitterWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void unlinkWithApple(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] unlinkWithAppleWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void unlinkWithEmail(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] unlinkWithEmailWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void logout(int funcID) {
    [[PerpleSDK sharedInstance] logout];
}

void deleteUser(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] deleteUserWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void createUserWithEmail(int funcID, const char* email, const char* password) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] createUserWithEmail:[NSString stringWithUTF8String:email]
                                           password:[NSString stringWithUTF8String:password]
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
}

void sendPasswordResetEmail(int funcID, const char* email) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] sendPasswordResetWithEmail:[NSString stringWithUTF8String:email]
                                                completion:^(NSString *result, NSString *info) {
                                                    if ([PerpleSDK isCurrentProcessId:processId]) {
                                                        PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                                    }
                                                }];
}

#pragma mark - Facebook

void facebookLogin(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] facebookLoginWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void facebookLogout(int funcID) {
    [[PerpleSDK sharedInstance] facebookLogout];
}

void facebookSendRequest(int funcID, const char* data) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] facebookSendRequest:[NSString stringWithUTF8String:data]
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
}

void facebookSendSharing(int funcID, const char* data) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] facebookSendSharing:[NSString stringWithUTF8String:data]
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
}

void facebookGetFriends(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] facebookGetFriendsWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void facebookGetInvitableFriends(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] facebookGetInvitableFriendsWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void facebookNotifications(int funcID, const char* receiverId, const char* message) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] facebookNotifications:[NSString stringWithUTF8String:receiverId]
                                              message:[NSString stringWithUTF8String:message]
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
}

bool facebookIsGrantedPermission(int funcID, const char* permission) {
    return [[PerpleSDK sharedInstance] facebookIsGrantedPermission:[NSString stringWithUTF8String:permission]];
}

void facebookAskPermission(int funcID, const char* permission) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] facebookAskPermission:[NSString stringWithUTF8String:permission]
                                           completion:^(NSString *result, NSString *info) {
                                               if ([PerpleSDK isCurrentProcessId:processId]) {
                                                   PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                               }
                                           }];
}

#pragma mark - Twitter
void twitterLogin(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] twitterLoginWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void twitterLogout(int funcID) {
    [[PerpleSDK sharedInstance] twitterLogout];
}

void twitterComposeTweet(int funcID, const char* filePath) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] twitterComposeTweet:[NSString stringWithUTF8String:filePath] completion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

#pragma mark - Tapjoy

void tapjoyEvent(int funcID, const char* cmd, const char* arg0, const char* arg1) {
    /*
    [[PerpleSDK sharedInstance] tapjoyEvent:[NSString stringWithUTF8String:cmd]
                                     param1:[NSString stringWithUTF8String:arg0]
                                     param2:[NSString stringWithUTF8String:arg1]];
     */
}

void tapjoySetTrackPurchase(int funcID, int flag) {
    //[[PerpleSDK sharedInstance] tapjoySetTrackPurchase:(flag == 1)];
}

void tapjoySetPlacement(int funcID, const char* placementName) {
    /*
    // success / fail / ready / purchase / reward / error
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] tapjoySetPlacement:[NSString stringWithUTF8String:placementName]
                                        completion:^(NSString *result, NSString *info) {
                                            if ([PerpleSDK isCurrentProcessId:processId]) {
                                                PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                            }
                                        }];
     */
}

void tapjoyShowPlacement(int funcID, const char* placementName) {
    // show / wait / dismiss / error
    /*
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] tapjoyShowPlacement:[NSString stringWithUTF8String:placementName]
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
     */
}

void tapjoyGetCurrency(int funcID) {
    // success / fail
    /*
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] tapjoyGetCurrencyWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
     */
}

void tapjoySetEarnedCurrencyCallback(int funcID) {
    // earn / error
    /*
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] tapjoySetEarnedCurrencyCallback:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
     */
}

void tapjoySpendCurrency(int funcID, int amount) {
    // success / fail
    /*
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] tapjoySpendCurrency:amount
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
     */
}

void tapjoyAwardCurrency(int funcID, int amount) {
    // success / fail
    /*
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] tapjoyAwardCurrency:amount
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
     */
}

#pragma mark - Google

void googleLogin(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] googleLogin:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void googleSilentLogin(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] googleSilentLogin:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void googlePlayServiceLogin(int funcID) {
    // iOS don't use google play service
}

void googleLogout(int funcID) {
    [[PerpleSDK sharedInstance] googleLogout];
}

void googleRevokeAccess(int funcID) {
    [[PerpleSDK sharedInstance] googleRevokeAccess];
}

void googleShowAchievements(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] googleShowAchievementsWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void googleShowLeaderboards(int funcID, const char* leaderBoardId) {
    // success / fail
    // @leaderBoardId not use
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] googleShowLeaderboardsWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void googleUpdateAchievements(int funcID, const char* achievementId, const char* steps) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] googleUpdateAchievements:[NSString stringWithUTF8String:achievementId]
                                                numSteps:[NSString stringWithUTF8String:steps]
                                              completion:^(NSString *result, NSString *info) {
                                                  if ([PerpleSDK isCurrentProcessId:processId]) {
                                                      PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                                  }
                                              }];
}

void googleUpdateLeaderboards(int funcID, const char* leaderboardId, const char* score) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] googleUpdateLeaderboards:[NSString stringWithUTF8String:leaderboardId]
                                              finalScore:[NSString stringWithUTF8String:score]
                                              completion:^(NSString *result, NSString *info) {
                                                  if ([PerpleSDK isCurrentProcessId:processId]) {
                                                      PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                                  }
                                              }];
}

#pragma mark - GameCenter

void gameCenterLogin(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] gameCenterLoginWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

#pragma mark - UnityAds

void unityAdsStart(int funcID, const char* mode, const char* metaData) {
    // start / ready / finish / error
    const int processId = [PerpleSDK getProcessId];
    /*[[PerpleSDK sharedInstance] unityAdsStart:(!strcmp(mode, "test"))
                                     metaData:[NSString stringWithUTF8String:metaData]
                                   completion:^(NSString *result, NSString *info) {
                                       if ([PerpleSDK isCurrentProcessId:processId]) {
                                           PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                       }
                                   }];*/
}

void unityAdsShow(int funcID, const char* placementId, const char* metaData) {
    /*[[PerpleSDK sharedInstance] unityAdsShow:[NSString stringWithUTF8String:placementId]
                                    metaData:[NSString stringWithUTF8String:metaData]];*/
}

#pragma mark - AdColony

void adColonyStart(int funcID, const char* zoneIds, const char* userId) {
    /*[[PerpleSDK sharedInstance] adColonyStart:[NSString stringWithUTF8String:zoneIds]
                                       userId:[NSString stringWithUTF8String:userId]];*/
}

void adColonySetUserId(int funcID, const char* userId) {
    //[[PerpleSDK sharedInstance] adColonySetUserId:[NSString stringWithUTF8String:userId]];
}

void adColonyReqeust(int funcID, const char* zoneId) {
    // ready / reward / error
    const int processId = [PerpleSDK getProcessId];
    /*[[PerpleSDK sharedInstance] adColonyRequest:[NSString stringWithUTF8String:zoneId]
                                     completion:^(NSString *result, NSString *info) {
                                         if ([PerpleSDK isCurrentProcessId:processId]) {
                                             PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                         }
                                     }];*/
}

void adColonyShow(int funcID, const char* zoneId) {
   // [[PerpleSDK sharedInstance] adColonyShow:[NSString stringWithUTF8String:zoneId]];
}

#pragma mark - Billing

void billingSetup(int funcID, const char* checkReceiptServerUrl, const char* saveTransactionUrl) {
    // purchase / error
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] billingSetup:[NSString stringWithUTF8String:checkReceiptServerUrl]
                          saveTransactionUrl:[NSString stringWithUTF8String:saveTransactionUrl]
                                  completion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void billingConfirm(int funcID, const char* orderId, const char* purchaseToken) {
    [[PerpleSDK sharedInstance] billingConfirm:[NSString stringWithUTF8String:orderId]];
}

void billingPurchase(int funcID, const char* sku, const char* payload) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] billingPurchase:[NSString stringWithUTF8String:sku]
                                        payload:[NSString stringWithUTF8String:payload]
                                     completion:^(NSString *result, NSString *info) {
                                         if ([PerpleSDK isCurrentProcessId:processId]) {
                                             PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                         }
                                     }];
}

void billingSubscription(int funcID, const char* sku, const char* payload) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] billingSubscription:[NSString stringWithUTF8String:sku]
                                            payload:[NSString stringWithUTF8String:payload]
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
}

void billingGetItemList(int funcID, const char* skuList) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] billingGetItemList:[NSString stringWithUTF8String:skuList]
                                        completion:^(NSString *result, NSString *info) {
                                            if ([PerpleSDK isCurrentProcessId:processId]) {
                                                
                                                //PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                                
                                                // @sgkim 2019.10.11 billingGetItemList함수의 콜백 함수가 main thread에서 동작하도록 변경함
                                                // ios 12이하에서는 이 콜백이 main thread에서 호출되었으나 ios 13이상부터 background thread에서 호출됨
                                                // Lua 환경에서 PerpleSDK의 콜백 함수는 항상 main thread에서 호출되어야 한다
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                                });
                                            }
                                        }];
}

void billingGetIncompletePurchaseList(int funcID) {
    // success / fail
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] billingGetIncompletePurchaseList:^(NSString *result, NSString *info) {
                                            if ([PerpleSDK isCurrentProcessId:processId]) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                                });
                                            }
                                        }];
}


#pragma mark    --adjust
void adjustTrackEvent( int funcID, const char* eventKey ) {
    @try {
        [[PerpleSDK sharedInstance] adjustTrackEvent:[NSString stringWithUTF8String:eventKey]];
    }
    @catch (NSException * e) {
        NSLog(@"Error: %@%@", [e name], [e reason]);
    }
}

void adjustTrackPayment( int funcID, const char* eventKey, const char* price, const char* currency ) {
    [[PerpleSDK sharedInstance] adjustTrackPayment:[NSString stringWithUTF8String:eventKey]
                                             price:[NSString stringWithUTF8String:price]
                                          currency:[NSString stringWithUTF8String:currency]];
}

void adjustGdprForgetMe( int funcID) {
    [[PerpleSDK sharedInstance] adjustGdprForgetMe];
}

const char*  adjustGetAdid( int funcID) {
    NSString* adid = [[PerpleSDK sharedInstance] adjustGetAdid];
    return [adid UTF8String];
}

#pragma mark - AdMob
void adMobInitialize(int funcID) {
    const int processId = [PerpleSDK getProcessId];
    
    NSLog(@"# runtime_ios - adMobInitialize");
    [[PerpleSDK sharedInstance] adMobInitialize:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void adMobLoadRewardAd(int funcID, const char* adUnitId) {
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] adMobLoadRewardAd:[NSString stringWithUTF8String:adUnitId]
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
}

void adMobShowRewardAd(int funcID, const char* adUnitId) {
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] adMobShowRewardAd:[NSString stringWithUTF8String:adUnitId]
                                         completion:^(NSString *result, NSString *info) {
                                             if ([PerpleSDK isCurrentProcessId:processId]) {
                                                 PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
                                             }
                                         }];
}

void adMobInitRewardedVideoAd(int funcID) {
    [[PerpleSDK sharedInstance] adMobInitRewardedVideoAd];
}

void adMobInitInterstitialAd(int funcID) {
    [[PerpleSDK sharedInstance] adMobInitInterstitialAd];
}

void rvAdLoadRequestWithId(int funcID, const char* adUnitId) {
    [[PerpleSDK sharedInstance] rvAdLoadRequestWithId:[NSString stringWithUTF8String:adUnitId]];
}

void rvAdSetResultCallback(int funcID) {
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] rvAdSetResultCallback:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void rvAdShow(int funcID, const char* adUnitId) {
    [[PerpleSDK sharedInstance] rvAdShow:[NSString stringWithUTF8String:adUnitId]];
}

void itAdSetAdUnitId(int funcID, const char* adUnitId) {
    [[PerpleSDK sharedInstance] itAdSetAdUnitId:[NSString stringWithUTF8String:adUnitId]];
}

void itAdSetResultCallback(int funcID) {
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] itAdSetResultCallback:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void itAdLoadRequest(int funcID) {
    [[PerpleSDK sharedInstance] itAdLoadRequest];
}

void itAdShow(int funcID) {
    [[PerpleSDK sharedInstance] itAdShow];
}

#pragma mark - Facebook Audience Network
void facebookAudienceNetworkInitRewardedVideoAd(int funcID) {
	
}

void rvFacebookAudienceNetworkSetResultCallback(int funcID) {
	
}

void rvFacebookAudienceNetworkLoadWithId(int funcID, char const*) {
	
}

void rvFacebookAudienceNetworkAdShow(int funcID, char const*) {
	
}

#pragma mark - Xsolla // not support iOS
BOOL xsollaIsAvailable(int funcID) {
    return false;
}
void xsollaSetPaymentInfoUrl(int funcID, const char* url) {}
void xsollaOpenPaymentUI(int funcID, const char* payload) {}

#pragma util
const char* getABI(int funcID) {
    return "iOS";
}

#pragma crashlytics
void crashlyticsForceCrash(int funcID) {
    [[PerpleSDK sharedInstance] crashlyticsForceCrash];
}

void crashlyticsSetUid(int funcID, const char* uid) {
    [[PerpleSDK sharedInstance] crashlyticsSetUid:[NSString stringWithUTF8String:uid]];
}

void crashlyticsSetLog(int funcID, const char* message) {
    [[PerpleSDK sharedInstance] crashlyticsSetLog:[NSString stringWithUTF8String:message]];
}

void crashlyticsSetExceptionLog(int funcID, const char* message) {
	
}

void crashlyticsSetKeyString(int funcID, const char* key, const char* value) {
    [[PerpleSDK sharedInstance] crashlyticsSetObejctValue:[NSString stringWithUTF8String:value] forKey:[NSString stringWithUTF8String:key]];
}

void crashlyticsSetKeyInt(int funcID, const char* key, int value) {
    [[PerpleSDK sharedInstance] crashlyticsSetIntValue:value forKey:[NSString stringWithUTF8String:key]];
}

void crashlyticsSetKeyBool(int funcID, const char* key, bool value) {
    [[PerpleSDK sharedInstance] crashlyticsSetBoolValue:value forKey:[NSString stringWithUTF8String:key]];
}

#pragma onestore
void onestoreSetUid(int funcID, const char* uid) {
}
bool onestoreIsAvailable(int funcID) {
    return false;
}
void onestoreConsumeByOrderid(int funcID, const char* orderId) {
}
void onestoreRequestPurchases(int funcID) {
}
void onestoreGetPurchases(int funcID) {
}
void billingPurchaseForOnestore(int funcID, const char* sku, const char* payload) {
}
void billingGetItemListForOnestore(int funcID, const char* skuList) {
}
void billingPurchaseSubscriptionForOnestore(int funcID, const char* sku, const char* payload) {
}
void cancelSubscriptionForOnestore(int funcID, const char* sku) {
}

#pragma mark - Apple
void appleLogin(int funcID) {
    // success / fail / cancel
    const int processId = [PerpleSDK getProcessId];
    [[PerpleSDK sharedInstance] appleLoginWithCompletion:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:processId]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

void appleLogout(int funcID) {
    [[PerpleSDK sharedInstance] appleLogout];
}

#pragma mark - Google CMP
void cmpLoadConsentIfNeeded(int funcID) {
    [[HbrwCMP shared] loadConsentIfNeeded:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:[PerpleSDK getProcessId]]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

bool cmpCanRequestAds(int funcID) {
    return [[HbrwCMP shared] canRequestAds];
}

bool cmpRequirePrivacyOption(int funcID) {
    return [[HbrwCMP shared] requirePrivacyOption];
}

void cmpPresentPrivacyOptionForm(int funcID) {
    [[HbrwCMP shared] presentPrivacyOptionForm:^(NSString *result, NSString *info) {
        if ([PerpleSDK isCurrentProcessId:[PerpleSDK getProcessId]]) {
            PerpleCore::OnSDKResult(funcID, [result UTF8String], [info UTF8String]);
        }
    }];
}

