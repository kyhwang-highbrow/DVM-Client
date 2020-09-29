//
//  PerpleFacebook.h
//  PerpleSDK
//
//  Created by PerpleLab on 2016. 8. 31..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "PerpleSDK.h"

@interface PerpleFacebook : NSObject <FBSDKGameRequestDialogDelegate, FBSDKSharingDelegate>

#pragma mark - Properties

@property (nonatomic, retain) UIViewController *mParentView;
@property (nonatomic, retain) FBSDKLoginManager *mLoginManager;
@property PerpleSDKCallback mGameRequestCallback;
@property PerpleSDKCallback mGameSharingCallback;

#pragma mark - Initialization

- (id) initWithParentView:(UIViewController *)parentView;

#pragma mark - APIs

- (void) loginWithCompletion:(PerpleSDKCallback)callback;
- (void) logout;
- (void) sendGameRequest:(NSDictionary *)data completion:(PerpleSDKCallback)callback;
- (void) sendGameSharing:(NSDictionary *)data completion:(PerpleSDKCallback)callback;
- (BOOL) isGrantedPermission:(NSString *)permission;
- (void) askPermission:(NSString *)permission completion:(PerpleSDKCallback)callback;
- (void) getFriendsWithCompletion:(PerpleSDKCallback)callback;
- (void) getInvitableFriendsWithCompletion:(PerpleSDKCallback)callback;
- (void) notifications:(NSString *)receiverId message:(NSString *)message completion:(PerpleSDKCallback)callback;

#pragma mark - Public methods

- (NSDictionary *) getProfileData;

#pragma mark - AppDelegate

// AppDelegate.m
- (void) applicationDidBecomeActive:(UIApplication *)application;
- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end
