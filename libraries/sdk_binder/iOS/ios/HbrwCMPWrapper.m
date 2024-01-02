//
//  HbrwCMPWrapper.m
//  sdk_binder
//
//  Created by 황기영 on 2024/01/02.
//  Copyright © 2024 PerpleLab. All rights reserved.
//

#import "PerpleSDK.h"
#import <Foundation/Foundation.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <FBSDKCoreKit/FBSDKSettings.h>
#import "sdk_binder-swift.h"
#import "HbrwCMPWrapper.h"

@implementation HbrwCMPWrapper
+ (instancetype)shared {
    static HbrwCMPWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (void)loadConsentIfNeeded:(int)funcID {
    [[HbrwCMP shared] loadConsentIfNeeded:^(NSString *result, NSString *info) {

    }];
}
- (BOOL)canRequestAds {
    return [[HbrwCMP shared] canRequestAds];
}
- (BOOL)requirePrivacyOption {
    return [[HbrwCMP shared] requirePrivacyOption];
}
- (void)presentPrivacyOptionForm:(int)funcID {
    [[HbrwCMP shared] presentPrivacyOptionForm:^(NSString *result, NSString *info) {

    }];
}
@end
