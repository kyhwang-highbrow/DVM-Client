//
//  HbrwCMPWrapper.h
//  sdk_binder
//
//  Created by 황기영 on 2024/01/02.
//  Copyright © 2024 PerpleLab. All rights reserved.
//

#ifndef HbrwCMPWrapper_h
#define HbrwCMPWrapper_h

#import <Foundation/Foundation.h>
@interface HbrwCMPWrapper : NSObject
+ (instancetype)shared;
- (void)loadConsentIfNeeded:(int)funcID;
- (BOOL)canRequestAds;
- (BOOL)requirePrivacyOption;
- (void)presentPrivacyOptionForm:(int)funcID;
@end


#endif /* HbrwCMPWrapper_h */
