//
//  TrackerClientDelegate.h
//  Moloco
//
//  MolocoAds
//

#import "BuildConfig.h"
#import <Foundation/Foundation.h>


@protocol MolocoTrackerClientDelegate <NSObject>
@optional
- (void) molocoAttributionResult:(NSDictionary *)attributionResult;
- (void) molocoPresentInitAd:(bool)presentInitAdResult;
- (void) molocoiBeaconBarrierCrossed:(NSDictionary *)iBeaconBarrierAction;
@end
