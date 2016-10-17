//
//  AdClientDelegate.h
//  Moloco
//
//  MolocoAds
//

#import "BuildConfig.h"


@class MolocoAdClient;


@protocol MolocoAdClientDelegate <NSObject>
@optional
- (void) molocoAdLoaded:(MolocoAdClient *)adView :(bool)isInterstitial;
- (void) molocoFullScreenAdWillLoad:(MolocoAdClient *)adView;
- (void) molocoFullScreenAdDidUnload:(MolocoAdClient *)adView;
@end
