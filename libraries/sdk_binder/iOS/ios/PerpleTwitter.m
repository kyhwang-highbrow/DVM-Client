//
//  PerpleTwitter.m
//  PerpleSDK
//
//  Created by PerpleLab on 2018. 3. 1..
//  Copyright © 2018년 PerpleLab. All rights reserved.
//

#import "PerpleTwitter.h"

@implementation PerpleTwitter

#pragma mark - Properties
@synthesize mTwitterSession;

#pragma mark - Initialization

- (id) initWithCustomerKey:(NSString *)customerKey secret:(NSString *)customerSecret {
    NSLog(@"PerpleTwitter, Twitter initializing. key : %@, secret : %@", customerKey, customerSecret);

    if (self = [super init]) {
        [[TWTRTwitter sharedInstance] startWithConsumerKey:customerKey consumerSecret:customerSecret];
    }else{
        NSLog(@"PerpleTwitter, Twitter Initializing failed.");
    }

    return self;
}

- (void) dealloc {
    self.mTwitterSession = nil;
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs

- (void) loginWithCompletion:(PerpleSDKCallback)callback{
    [[TWTRTwitter sharedInstance] logInWithCompletion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
        if (session) {
            NSLog(@"PerpleTwitter, login success / name : %@ ID : %@", [session userName], [session userID]);

            self.mTwitterSession = session;
            NSString* info = [PerpleSDK getJSONStringFromNSDictionary:@{@"authToken":session.authToken, @"authTokenSecret":session.authTokenSecret}];
            callback(@"success", info);
        } else {
            NSLog(@"PerpleTwitter, login failed : %@", [error localizedDescription]);

            if ([error code] == TWTRLogInErrorCodeCancelled) {
                callback(@"cancel", [error localizedDescription]);
            }
            else{
                callback(@"fail", [PerpleSDK getErrorInfo:@PERPLESDK_ERROR_TWITTER_LOGIN
                                                  subcode:[@(error.code) stringValue]
                                                      msg:error.localizedDescription]);
            }
        }
    }];
}

- (void) logout {
    TWTRSessionStore *store = [[TWTRTwitter sharedInstance] sessionStore];
    NSString * userId = store.session.userID;
    [store logOutUserID:userId];
}

- (void) composeTweet:(NSString *)imageUri completion:(PerpleSDKCallback)callback {
    // if user already login twitter
    if ([[[TWTRTwitter sharedInstance] sessionStore] hasLoggedInUsers]) {
        [self _composeTweet:imageUri completion:callback];
    }

    // else tweet afeter login
    else {
        [[TWTRTwitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
            if (session) {
                [self _composeTweet:imageUri completion:callback];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Twitter Accounts Available" message:@"You must log in before presenting a composer." preferredStyle:UIAlertControllerStyleAlert];
                [[[PerpleSDK sharedInstance] mViewController] presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
}

- (void) _composeTweet:(NSString *)imageUri completion:(PerpleSDKCallback)callback{
    TWTRComposer *composer = [[TWTRComposer alloc] init];

    [composer setText:@""];
    [composer setImage:[UIImage imageNamed:imageUri]];

    // Called from a UIViewController
    [composer showFromViewController:[[PerpleSDK sharedInstance] mViewController] completion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
            callback(@"fail", @"fail");
        }
        else {
            NSLog(@"Sending Tweet!");
            callback(@"success", @"success");
        }
    }];
}

#pragma mark - Public methods

- (NSDictionary *) getProfileData {
    NSString *userId = [self.mTwitterSession userID];
    NSString *userName = [self.mTwitterSession userName];

    return @{@"id":userId,
             @"name":userName};
}

#pragma mark - AppDelegate

- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [[TWTRTwitter sharedInstance] application:app openURL:url options:options];
}
@end
