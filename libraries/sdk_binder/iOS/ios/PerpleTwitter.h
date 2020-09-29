//
//  PerpleTwitter.h
//  PerpleSDK
//
//  Created by PerpleLab on 2018. 3. 1..
//  Copyright © 2018년 PerpleLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TwitterKit/TWTRKit.h>
#import "PerpleSDK.h"

@interface PerpleTwitter : NSObject

#pragma mark - Properties
@property TWTRSession *mTwitterSession;

#pragma mark - Initialization
- (id) initWithCustomerKey:(NSString *)customerKey secret:(NSString *)customerSecret;

#pragma mark - APIs
- (void) loginWithCompletion:(PerpleSDKCallback)callback;
- (void) logout;
- (void) composeTweet:(NSString *)imageUrl completion:(PerpleSDKCallback)callback;
- (void) _composeTweet:(NSString *)imageUrl completion:(PerpleSDKCallback)callback;

#pragma mark - Public Method
- (NSDictionary *) getProfileData;

#pragma mark - AppDelegate
- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options;
@end
