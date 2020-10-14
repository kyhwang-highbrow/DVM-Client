//
//  PerpleCrashlytics.m
//  PerpleSDK
//
//  Created by PerpleLab on 10/01/2019.
//  Copyright © 2019 PerpleLab. All rights reserved.
//

#import "PerpleCrashlytics.h"

@implementation PerpleCrashlytics

#pragma mark - class method
+ (void) forceCrash {
    id _ = @[][1];
}

+ (void) setUid:(NSString *)uid {
    [[FIRCrashlytics crashlytics] setUserID:uid];
}

+ (void) setLog:(NSString *)message {
    [[FIRCrashlytics crashlytics] log:message];
}

+ (void) setObjectValue:(id)value forKey:(NSString *)key {
    [[FIRCrashlytics crashlytics] setCustomValue:value forKey:key];
}

+ (void) setIntValue:(int)value forKey:(NSString *)key {
    [[FIRCrashlytics crashlytics] setCustomValue:@(value) forKey:key];
}

+ (void) setBoolValue:(BOOL)value forKey:(NSString *)key {
    [[FIRCrashlytics crashlytics] setCustomValue:@(value) forKey:key];
}

@end
