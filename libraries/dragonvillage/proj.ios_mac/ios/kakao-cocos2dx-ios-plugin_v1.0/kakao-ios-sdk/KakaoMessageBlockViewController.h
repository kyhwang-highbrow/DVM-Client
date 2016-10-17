//
//  KakaoMessageBlockViewController.h
//  kakao-ios-sdk-test
//
//  Created by Cody on 2014. 7. 15..
//  Copyright (c) 2014년 KAKAO Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "KALocalUser.h"

@protocol KakaoMessageBlockViewDelegate <NSObject>
@required
- (void)onKakaoMessageBlockViewDidClickClose;
@end


@interface KakaoMessageBlockViewController : UIViewController

+(void)showMessageBlockDialog:(KACompletionSuccessBlock)successHandler withDelegate:(id<KakaoMessageBlockViewDelegate>)delegate;

@end