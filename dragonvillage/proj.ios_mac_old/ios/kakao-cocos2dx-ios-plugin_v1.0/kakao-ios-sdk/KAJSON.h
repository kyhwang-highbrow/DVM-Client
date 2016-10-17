//
//  KAJSON.h
//  kakao-ios-sdk
//
//  Created by Cody on 2014. 4. 22..
//  Copyright (c) 2014년 KAKAO Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KakaoJsonDeserializing)
- (id)kakaoObjectFromJSONStringWithError:(NSError**)error;
@end


@interface NSData (KakaoJsonDeserializing)
- (id)kakaoObjectFromJSONDataWithError:(NSError**)error;
@end

@interface NSDictionary (KakaoJsonDeserializing)

- (NSString*)kakaoJSONStringWithError:(NSError**)error;
@end

@interface NSArray (KakaoJsonDeserializing)
- (NSString*) kakaoJSONStringWithError:(NSError**)error;
@end



