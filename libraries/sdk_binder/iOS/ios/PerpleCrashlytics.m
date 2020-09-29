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
    [[Crashlytics sharedInstance] crash];
}

+ (void) setUid:(NSString *)uid {
    [CrashlyticsKit setUserIdentifier:uid];
}

+ (void) setLog:(NSString *)message {
    CLS_LOG(@"%@", message);
}

+ (void) setObjectValue:(id)value forKey:(NSString *)key {
    [CrashlyticsKit setObjectValue:value forKey:key];
}

+ (void) setIntValue:(int)value forKey:(NSString *)key {
    [CrashlyticsKit setIntValue:value forKey:key];
}

+ (void) setBoolValue:(BOOL)value forKey:(NSString *)key {
    [CrashlyticsKit setBoolValue:value forKey:key];
}

@end
