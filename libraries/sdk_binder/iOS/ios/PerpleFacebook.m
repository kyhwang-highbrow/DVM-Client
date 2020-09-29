//
//  PerpleFacebook.m
//  PerpleSDK
//
//  Created by PerpleLab on 2016. 8. 31..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import "PerpleFacebook.h"

@implementation PerpleFacebook

#pragma mark - Properties

@synthesize mParentView;
@synthesize mLoginManager;
@synthesize mGameRequestCallback;
@synthesize mGameSharingCallback;

#pragma mark - Initializaton

- (id) initWithParentView:(UIViewController *)parentView {
    NSLog(@"PerpleFacebook, Facebook initializing.");

    if (self = [super init]) {
        self.mLoginManager = [[FBSDKLoginManager alloc] init];
        self.mParentView = parentView;
    } else {
        NSLog(@"PerpleFacebook, Facebook initializing fail.");
    }

    return self;
}

- (void) dealloc {
    self.mParentView = nil;
    self.mLoginManager = nil;

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs

- (void) loginWithCompletion:(PerpleSDKCallback)callback {

    if ([self isGrantedPermission:@"public_profile"]) {
        if ([self isGrantedPermission:@"email"]) {
            FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
            FBSDKProfile *profile = [FBSDKProfile currentProfile];
            if (accessToken != nil && profile != nil) {
                callback(@"success", accessToken.tokenString);
                return;
            }
        }
    }

    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];

    [self.mLoginManager logInWithPermissions:@[@"public_profile", @"email"]
                              fromViewController:mParentView
                                         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                             if (error != nil) {
                                                 NSLog(@"PerpleFacebook, Facebook login error - desc:%@", error);
                                                 callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_FACEBOOKEXCEPTION
                                                                                   subcode:[@(error.code) stringValue]
                                                                                       msg:error.localizedDescription]);
                                             } else if (result.isCancelled) {
                                                 callback(@"cancel", @"Login has been cancelled.");
                                             } else {
                                                 if ([FBSDKProfile currentProfile] != nil) {
                                                     NSString *token = [[FBSDKAccessToken currentAccessToken] tokenString];
                                                     callback(@"success", token);
                                                 } else {
                                                     NSNotificationCenter * __weak center = [NSNotificationCenter defaultCenter];
                                                     id __block observerId = [center addObserverForName:FBSDKProfileDidChangeNotification
                                                                                                 object:nil
                                                                                                  queue:nil
                                                                                             usingBlock:^(NSNotification * _Nonnull note) {
                                                                                                 [center removeObserver:observerId];
                                                                                                 NSString *token = [[FBSDKAccessToken currentAccessToken] tokenString];
                                                                                                 callback(@"success", token);
                                                                                             }];
                                                 }
                                             }
                                         }];
}

- (void) logout {
    [self.mLoginManager logOut];
}

- (void) sendGameRequest:(NSDictionary *)data
              completion:(PerpleSDKCallback)callback {
    self.mGameRequestCallback = callback;

    FBSDKGameRequestContent *content = [[FBSDKGameRequestContent alloc] init];
    content.message = data[@"message"];
    content.title = data[@"title"];
    content.recipients = @[data[@"to"]];

    [FBSDKGameRequestDialog showWithContent:content
                                   delegate:self];
}

- (void) sendGameSharing:(NSDictionary *)data
              completion:(PerpleSDKCallback)callback {
    self.mGameSharingCallback = callback;

    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [[NSURL alloc] initWithString:data[@"url"]];
    content.peopleIDs = @[data[@"to"]];

    [FBSDKShareDialog showFromViewController:self.mParentView
                                 withContent:content
                                    delegate:self];
}

- (BOOL) isGrantedPermission:(NSString *)permission {
    BOOL result = NO;
    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
    if (accessToken != nil) {
        result = [accessToken hasGranted:permission];
    }
    return result;
}

- (void) askPermission:(NSString *)permission
            completion:(PerpleSDKCallback)callback {
    [self.mLoginManager logInWithPermissions:@[permission]
                              fromViewController:mParentView
                                         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                             if (error) {
                                                 NSLog(@"PerpleFacebook, Facebook askPermission error - desc:%@", error);
                                                 callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_FACEBOOKEXCEPTION
                                                                                   subcode:[@(error.code) stringValue]
                                                                                       msg:error.localizedDescription]);
                                             } else if (result.isCancelled) {
                                                 callback(@"cancel", @"");
                                             } else {
                                                 callback(@"success", [[result token] tokenString]);
                                             }
                                         }];
}

- (void) getFriendsWithCompletion:(PerpleSDKCallback)callback {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friends"
                                           parameters:@{@"limit":@5000}
                                           HTTPMethod:@"GET"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 callback(@"success", [self convertFriendsListFormat:result]);
             } else {
                 callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_GRAPHAPI
                                                   subcode:[@(error.code) stringValue]
                                                       msg:error.localizedDescription]);
             }
         }];
    }
}

- (void) getInvitableFriendsWithCompletion:(PerpleSDKCallback)callback {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/invitable_friends"
                                           parameters:@{@"limit":@5000}
                                           HTTPMethod:@"GET"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 callback(@"success", [self convertInvitableFriendsListFormat:result]);
             } else {
                 callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_GRAPHAPI
                                                   subcode:[@(error.code) stringValue]
                                                       msg:error.localizedDescription]);
             }
         }];
    }
}

- (void) notifications:(NSString *)receiverId
               message:(NSString *)message
            completion:(PerpleSDKCallback)callback {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:[NSString stringWithFormat:@"/%@/notifications", receiverId]
                                           parameters:@{@"template":message}
                                           HTTPMethod:@"POST"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 callback(@"success", @"");
             } else {
                 callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_GRAPHAPI
                                                   subcode:[@(error.code) stringValue]
                                                       msg:error.localizedDescription]);
             }
         }];
    }
}

#pragma mark - FBSDKGameRequestDialogDelegate

// FBSDKGameRequestDialogDelegate
- (void) gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog
    didCompleteWithResults:(NSDictionary *)results {
    if (self.mGameRequestCallback != nil) {
        self.mGameRequestCallback(@"success", @"");
    }
}

// FBSDKGameRequestDialogDelegate
- (void) gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog
          didFailWithError:(NSError *)error {
    if (self.mGameRequestCallback != nil) {
        self.mGameRequestCallback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_REQUEST
                                                           subcode:[@(error.code) stringValue]
                                                               msg:error.localizedDescription]);
    }
}

// FBSDKGameRequestDialogDelegate
- (void) gameRequestDialogDidCancel:(FBSDKGameRequestDialog *)gameRequestDialog {
    if (self.mGameRequestCallback != nil) {
        self.mGameRequestCallback(@"cancel", @"");
    }
}

#pragma mark - FBSDKSharingDelegate

//FBSDKSharingDelegate
- (void) sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    if (self.mGameSharingCallback != nil) {
        self.mGameSharingCallback(@"success", @"");
    }
}

//FBSDKSharingDelegate
- (void) sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    if (self.mGameSharingCallback != nil) {
        self.mGameSharingCallback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_FACEBOOK_SHARE
                                                           subcode:[@(error.code) stringValue]
                                                               msg:error.localizedDescription]);
    }
}

//FBSDKSharingDelegate
- (void) sharerDidCancel:(id<FBSDKSharing>)sharer {
    if (self.mGameSharingCallback != nil) {
        self.mGameSharingCallback(@"cancel", @"");
    }
}

#pragma mark - Public methods

- (NSDictionary *) getProfileData {
    FBSDKProfile *profile = [FBSDKProfile currentProfile];
    if (profile == nil) {
        return @{};
    }

    //NSURL *url = [profile imageURLForPictureMode:FBSDKProfilePictureModeSquare
    //                                        size:CGSizeMake(64, 64)];

    return @{@"id":profile.userID,
             @"name":(profile.name ? profile.name : @"")
             /*,@"photoUrl":(url ? url.absoluteString : @"")*/};
}

#pragma mark - Private methods

- (NSString *) convertFriendsListFormat:(NSDictionary *)info {
    NSMutableArray *outArray = [NSMutableArray array];

    NSArray *inArray = info[@"data"];
    for (id friend in inArray) {
        [outArray addObject:@{@"id":friend[@"id"],
                              @"name":friend[@"name"]}];
    }

    return [PerpleSDK getJSONStringFromNSArray:outArray];
}

- (NSString *) convertInvitableFriendsListFormat:(NSDictionary *)info {
    NSMutableArray *outArray = [NSMutableArray array];

    NSArray *inArray = info[@"data"];
    for (id friend in inArray) {
        NSString *photoUrl = friend[@"picture"][@"data"][@"url"];
        [outArray addObject:@{@"id":friend[@"id"],
                              @"name":friend[@"name"],
                              @"photoUrl":(photoUrl ? photoUrl : @"")}];
    }

    return [PerpleSDK getJSONStringFromNSArray:outArray];
}

#pragma mark - AppDelegate

// AppDelegate.m
- (void) applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

// AppDelegate.m
- (BOOL) application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
}

// AppDelegate.m
- (BOOL) application:(UIApplication *)application
             openURL:(NSURL *)url
   sourceApplication:(NSString *)sourceApplication
          annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
