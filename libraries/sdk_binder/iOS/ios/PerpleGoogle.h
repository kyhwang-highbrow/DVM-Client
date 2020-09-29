//
//  PerpleGoogle.h
//  PerpleSDK
//
//  Created by PerpleLab on 2016. 8. 30..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "PerpleSDK.h"

@interface PerpleGoogle : NSObject <GIDSignInDelegate>

#pragma mark - Properties

@property (nonatomic, copy) NSString *mClientID;
@property PerpleSDKCallback mLoginCallback;

#pragma mark - Initialization

- (id) initWithClientID:(NSString *)clientID parentView:(UIViewController *)parentView;

#pragma mark - APIs

- (void) login:(PerpleSDKCallback)callback;
- (void) loginSilently:(PerpleSDKCallback)callback;
- (void) logout;

#pragma mark - Public methods

- (NSDictionary *) getProfileData;

#pragma mark - AppDelegate

// AppDelegate
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
