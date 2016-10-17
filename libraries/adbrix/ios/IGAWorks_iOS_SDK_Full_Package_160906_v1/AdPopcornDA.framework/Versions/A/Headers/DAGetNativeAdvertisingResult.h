//
//  DAGetNativeAdvertisingResult.h
//  IgaworksAd
//
//  Created by wonje,song on 2014. 7. 11..
//  Copyright (c) 2014년 wonje,song. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DAGetNativeAdvertisingCampaign.h"

@interface DAGetNativeAdvertisingResult : NSObject

@property (nonatomic, unsafe_unretained, getter = isTeset) BOOL test;
@property (nonatomic, unsafe_unretained, getter = isResult) BOOL result;
@property (nonatomic, unsafe_unretained) NSUInteger resultCode;
@property (nonatomic, copy) NSString *resultMsg;

@property (nonatomic, strong) NSMutableArray *campaignListArray;

- (void)addCampaignArray:(NSArray *)objects;
- (void)removeCampaignArray;
- (void)addCampaignObject:(DAGetNativeAdvertisingCampaign *)object;
- (void)removeCampaignObject:(DAGetNativeAdvertisingCampaign *)object;

@end
