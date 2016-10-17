//
// Created by house.dr on 2015. 10. 7..
// Copyright (c) 2015 Kakao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (KGSafeValue)
- (NSNumber *)safeNumberAndNilForKey:(NSString *)key;
@end