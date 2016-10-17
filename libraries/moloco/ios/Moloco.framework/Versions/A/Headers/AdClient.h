//
//  AdClient.h
//  Moloco
//
//  MolocoAds
//

#import "BuildConfig.h"
#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "AdClientDelegate.h"


@interface MolocoAdClient : UIView
    <
    UIWebViewDelegate,
    UIGestureRecognizerDelegate
    >

- (void) displayAdWebView:(UIViewController*)callingController :(UIView*)callingView :(bool)isInterstitial;
- (void) presentClickAd;

@property (nonatomic, assign) id <MolocoAdClientDelegate> adDelegate;

@end
