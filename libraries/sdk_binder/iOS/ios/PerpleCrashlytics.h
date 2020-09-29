//
//  PerpleCrashlytics.h
//  PerpleSDK
//
//  Created by PerpleLab on 10/01/2019.
//  Copyright © 2019 PerpleLab. All rights reserved.
//

#ifndef PerpleCrashlytics_h
#define PerpleCrashlytics_h

#import <Foundation/Foundation.h>
#import <Crashlytics/Crashlytics.h>
#import "PerpleSDK.h"

@interface PerpleCrashlytics : NSObject

#pragma mark - class method
+ (void) forceCrash;
+ (void) setUid:(NSString *)uid;
+ (void) setLog:(NSString *)message;
+ (void) setObjectValue:(id)value forKey:(NSString *)key;
+ (void) setIntValue:(int)value forKey:(NSString *)key;
+ (void) setBoolValue:(BOOL)value forKey:(NSString *)key;

@end

#endif /* PerpleCrashlytics_h */
