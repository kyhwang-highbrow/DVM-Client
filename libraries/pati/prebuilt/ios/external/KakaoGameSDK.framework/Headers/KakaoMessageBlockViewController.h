//
// Created by house.dr on 2015. 11. 11..
// Copyright (c) 2015 Kakao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void(^KGCompletionSuccessBlock)(BOOL success, NSError *error);

@interface KakaoMessageBlockViewController : UIViewController

+(void)showMessageBlockDialogWithCompletionHandler:(KGCompletionSuccessBlock)successHandler;

@end