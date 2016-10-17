/**
 * Copyright 2015 Kakao Corp.
 *
 * Redistribution and modification in source or binary forms are not permitted without specific prior written permission.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "KOError.h"

extern NSString *const KOHTTPStatusCodeKey;

@interface NSError (KakaoAdditions)

+ (NSError *)ko_errorWithCode:(NSInteger)code description:(NSString *)description;

+ (NSError *)ko_badResponseErrorWithUnderlyingError:(NSError *)underlyingError;

+ (NSError *)ko_operationInProgressError;

+ (NSError *)ko_networkErrorWithUnderlyingError:(NSError *)underlyingError;

+ (NSError *)ko_notAuthorizedErrorWithUnderlyingError:(NSError *)underlyingError;

+ (NSError *)ko_invalidGrantErrorWithUnderlyingError:(NSError *)underlyingError;

+ (NSError *)ko_tokenNotFoundError;

+ (NSError *)ko_alreadyLoginedUserError;

+ (NSError *)ko_operationCancelledErrorWithFailureReason:(NSString *)failureReason;

+ (NSError *)ko_httpErrorWithStatusCode:(NSInteger)statusCode;

+ (NSError *)ko_badParameterError;

+ (NSError *)ko_errorWithDictionary:(NSDictionary *)dictionary;

@end
