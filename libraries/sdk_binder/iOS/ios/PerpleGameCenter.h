//
//  PerpleGameCenter.h
//  PerpleSDK
//
//  Created by Yonghak on 2016. 9. 4..
//  Copyright © 2016년 PerpleLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "PerpleSDK.h"

@interface PerpleGameCenter : NSObject

#pragma mark - Properties

@property (nonatomic, retain) UIViewController* mParentView;

#pragma mark - Initialization

- (id) initWithParentView:(UIViewController *)parentView;

#pragma mark - APIs

- (void) loginWithParam:(NSString *)param1 completion:(PerpleSDKCallback)callback;

#pragma mark - Public methods

- (NSDictionary *) getProfileData;

@end
