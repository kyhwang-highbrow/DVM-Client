//
//  PerpleAdColony.m
//  PerpleSDK
//
//  Created by PerpleLab on 2017. 9. 21..
//  Copyright © 2017년 PerpleLab. All rights reserved.
//
/*
 #import "PerpleAdColony.h"
 
 @implementation PerpleAdColony
 
 @synthesize mParentView;
 @synthesize mAppId;
 @synthesize mZones;
 @synthesize mCallback;
 
 - (id) initWithAppId:(NSString *)appId
 parentView:(UIViewController *)view {
 if (self = [super init]) {
 self.mParentView = view;
 self.mAppId = appId;
 self.mZones = [NSMutableDictionary dictionary];
 } else {
 NSLog(@"PerpleAdColony, AdColony initializing fail.");
 }
 
 return self;
 }
 
 - (void) dealloc {
 self.mParentView = nil;
 self.mZones = nil;
 self.mAppId = nil;
 
 #if !__has_feature(objc_arc)
 [super dealloc];
 #endif
 }
 
 - (void)start:(NSString *)zoneIds
 userId:(NSString *)userId {
 
 NSArray *zoneIdArray = [zoneIds componentsSeparatedByString:@";"];
 
 AdColonyAppOptions *appOptions = nil;
 if (![userId isEqualToString:@""]) {
 appOptions = [AdColonyAppOptions new];
 appOptions.userID = userId;
 }
 
 [AdColony configureWithAppID:self.mAppId
 zoneIDs:zoneIdArray
 options:appOptions
 completion:^(NSArray<AdColonyZone *> * _Nonnull zones) {
 for (int i = 0; i < zones.count; i++) {
 __weak AdColonyZone *zone = zones[i];
 NSString *zoneId = zone.identifier;
 zone.reward = ^(BOOL success, NSString *name, int amount) {
 if (success) {
 NSLog(@"AdColony reward callback - zoneId:%@, rewardName:%@, rewardAmount:%d", zoneId, name, amount);
 if (self.mCallback) {
 NSString *info = [PerpleSDK getJSONStringFromNSDictionary:@{@"zoneID":zoneId,
 @"rewardName":name,
 @"rewardAmount":[NSString stringWithFormat:@"%d", amount]}];
 self.mCallback(@"reward", info);
 }
 }
 };
 }
 }];
 }
 
 - (void)setUserId:(NSString *)userId {
 AdColonyAppOptions *appOptions = [AdColony getAppOptions];
 if (appOptions != nil) {
 appOptions.userID = userId;
 } else {
 AdColonyAppOptions *newAppOptions = [AdColonyAppOptions new];
 newAppOptions.userID = userId;
 [AdColony setAppOptions:newAppOptions];
 }
 }
 
 - (void)request:(NSString *)zoneId
 completion:(PerpleSDKCallback)callback {
 
 self.mCallback = callback;
 
 [AdColony requestInterstitialInZone:zoneId options:nil success:^(AdColonyInterstitial * _Nonnull ad) {
 NSLog(@"AdColony, Ad request(zoneId:%@) was successful.", zoneId);
 ad.open = ^{
 NSLog(@"AdColony, Ad was opened - zoneId: %@", zoneId);
 if (self.mCallback) {
 self.mCallback(@"open", zoneId);
 }
 };
 ad.close = ^{
 NSLog(@"AdColony, Ad was closed - zoneId: %@", zoneId);
 if (self.mCallback) {
 self.mCallback(@"close", zoneId);
 }
 };
 [self.mZones setObject:ad
 forKey:zoneId];
 if (self.mCallback) {
 self.mCallback(@"ready", zoneId);
 }
 } failure:^(AdColonyAdRequestError * _Nonnull error) {
 NSLog(@"AdColony, Ad request(zoneId:%@) failed with error: %@", zoneId, [error localizedDescription]);
 if (self.mCallback) {
 self.mCallback(@"error", [error localizedDescription]);
 }
 }];
 }
 
 - (void)show:(NSString *)zoneId {
 AdColonyInterstitial *ad = self.mZones[zoneId];
 if (ad != nil) {
 [self.mZones removeObjectForKey:zoneId];
 [ad showWithPresentingViewController:self.mParentView];
 }
 }
 
 @end
 */
