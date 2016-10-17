//
//  KAError.h
//  kakao-ios-sdk
//
//  Created by Insoo Kim on 4/22/12.
//  Copyright (c) 2012 KAKAO Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const KAErrorDomain;

enum {
    KAErrorUnknown = 1,
    KAErrorCancelled = 2,
    KAErrorOperationInProgress = 3,
    KAErrorTokenNotFound = 4,
    KAErrorBadResponse = 5,
    KAErrorNetworkError = 6,
    KAErrorHTTP = 7,
    KAErrorNotSupported = 8,
    KAErrorInvalidParameter = 9,
    KAErrorDontHaveGameMeResult = 11,

    // server error
    KAServerErrorUnkown = -500,
    KAServerErrorNotAuthorized = -1000,
    KAServerErrorInvaidGrant = -400,
    KAServerErrorPermissionDenied = -100,
    KAServerErrorAccountNotFound = -13,
    KAServerErrorNotFound = -10
};
typedef NSInteger KAErrorCode;