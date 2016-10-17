//
//  NSString+KakaoAdditions.h
//  kakao-ios-sdk
//
//  Created by Lucas Ryu on 4/22/12.
//  Copyright (c) 2012 KAKAO Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ChosungSeparate)

- (NSArray *)ka_spliteChosung;
- (BOOL)ka_hasChoSungString:(NSString *)str;
- (BOOL)ka_hasChoSungs:(NSArray *)choSungs;

@end
