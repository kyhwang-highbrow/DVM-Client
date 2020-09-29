//
//  PerpleGoogle.m
//  PerpleSDK
//
//  Created by PerpleLab on 2016. 8. 30..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import "PerpleGoogle.h"

@implementation PerpleGoogle

#pragma mark - Properties

@synthesize mClientID;
@synthesize mLoginCallback;

#pragma mark - Initialization

- (id) initWithClientID:(NSString *)clientID
             parentView:(UIViewController *) parentView {
    NSLog(@"PerpleGoogle, Initializing Google.");
    if (self = [super init]) {
        self.mClientID = clientID;

        [GIDSignIn sharedInstance].clientID = clientID;
        [GIDSignIn sharedInstance].delegate = self;
        [GIDSignIn sharedInstance].presentingViewController = parentView;

    } else {
        NSLog(@"PerpleGoogle, Initializing Google failed.");
    }

    return self;
}

- (void) dealloc {
    self.mClientID = nil;

#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

//----------------------------------------------------------------------------------------------------

#pragma mark - APIs

- (void) login:(PerpleSDKCallback)callback {
    self.mLoginCallback = callback;
    [[GIDSignIn sharedInstance] signIn];
}

- (void) loginSilently:(PerpleSDKCallback)callback {
    callback(@"success", @"");
}

- (void) logout {
    [[GIDSignIn sharedInstance] signOut];
}

//----------------------------------------------------------------------------------------------------

#pragma mark - GIDSignInDelegate

// GIDSignInDelegate
- (void) signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
      withError:(NSError *)error {
    if (error == nil) {
        if (self.mLoginCallback) {
            self.mLoginCallback(@"success", [PerpleSDK getJSONStringFromNSDictionary:@{@"idToken":user.authentication.idToken,
                                                                                       @"accessToken":user.authentication.accessToken}]);
        }
    } else {
        if (self.mLoginCallback) {
            if (error.code == kGIDSignInErrorCodeCanceled) {
                self.mLoginCallback(@"cancel", error.localizedDescription);
            } else {
                self.mLoginCallback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_GOOGLE_LOGIN
                                                             subcode:[@(error.code) stringValue]
                                                                 msg:error.localizedDescription]);
            }
        }
    }
}

// GIDSignInDelegate
- (void) signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
      withError:(NSError *)error {
    // Sign out
    // Perform any operations when the user disconnects from app here.
    // ...
}

//----------------------------------------------------------------------------------------------------

#pragma mark - Public methods

- (NSDictionary *) getProfileData {
    NSString *playerId = @"";
    NSString *displayName = @"";
    //NSString *photoUrl = @"";

    GIDGoogleUser *user = [GIDSignIn sharedInstance].currentUser;
    if (user != nil) {
        playerId = user.userID;

        GIDProfileData *profile = user.profile;
        if (profile != nil) {
            if (profile.name != nil) {
                displayName = profile.name;
            }

            //if (profile.hasImage) {
            //    NSURL *url = [profile imageURLWithDimension:120];
            //    if (url != nil) {
            //        photoUrl = url.absoluteString;
            //    }
            //}
        }
    }

    return @{@"id":playerId,
             @"name":displayName
             /*,@"photoUrl":photoUrl*/};
}

//----------------------------------------------------------------------------------------------------

#pragma mark - AppDelegate

// AppDelegate
- (BOOL) application:(UIApplication *)application
             openURL:(NSURL *)url
   sourceApplication:(NSString *)sourceApplication
          annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url];
    
}

@end
