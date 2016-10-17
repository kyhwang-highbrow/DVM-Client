//
//  Kakao.h
//  kakao-ios-sdk
//
//  Created by Insoo Kim on 4/23/12.
//  Copyright (c) 2012 KAKAO Corp. All rights reserved.
//

#import "KAAuth.h"
#import "KALocalUser.h"
#import "KAError.h"
#import "KALinkMessageRequest.h"


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 // iOS6 and later
#   define NEEDS_DISPATCH_RETAIN_RELEASE 1
#   define kLabelAlignmentCenter    UITextAlignmentCenter
#   define kLabelAlignmentLeft      UITextAlignmentLeft
#   define kLabelAlignmentRight     UITextAlignmentRight
#   define kLabelTruncationTail     UILineBreakModeTailTruncation
#   define kLabelTruncationMiddle   UILineBreakModeMiddleTruncation
#   define kLabelWordWrapping       UILineBreakModeWordWrap
#else
#   define NEEDS_DISPATCH_RETAIN_RELEASE 0
#   define kLabelAlignmentCenter    NSTextAlignmentCenter
#   define kLabelAlignmentLeft      NSTextAlignmentLeft
#   define kLabelAlignmentRight     NSTextAlignmentRight
#   define kLabelTruncationTail     NSLineBreakByTruncatingTail
#   define kLabelTruncationMiddle   NSLineBreakByTruncatingMiddle
#   define kLabelWordWrapping       NSLineBreakByWordWrapping
#endif
//#else // older versions
//#   define NEEDS_DISPATCH_RETAIN_RELEASE 1
//#   define kLabelAlignmentCenter    UITextAlignmentCenter
//#   define kLabelAlignmentLeft      UITextAlignmentLeft
//#   define kLabelAlignmentRight     UITextAlignmentRight
//#   define kLabelTruncationTail     UILineBreakModeTailTruncation
//#   define kLabelTruncationMiddle   UILineBreakModeMiddleTruncation
//#   define kLabelWordWrapping       UILineBreakModeWordWrap
//#endif

extern NSString *const kKASdkVer;