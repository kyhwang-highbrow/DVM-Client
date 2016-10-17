//
//  Tracker.h
//  Moloco
//
//  MolocoAds
//

#import "BuildConfig.h"
#import <Foundation/Foundation.h>

#import "TrackerClientDelegate.h"


extern NSString *const kMLCParamPartnerName; // => NSString
extern NSString *const kMLCParamCurrency;            // => NSString
extern NSString *const kMLCParamLimitAdTracking;     // => [... boolValue]
extern NSString *const kMLCParamEnableLogging;       // => [... boolValue]
extern NSString *const kMLCParamRetrieveAttribution; // => [... boolValue]
extern NSString *const kMLCParamIdentityLink;        // => NSDictionary


@interface MolocoTracker : NSObject

#pragma mark Initializers

- (id) initWithParams:(NSDictionary*)initDict;


#pragma mark API

- (void) enableConsoleLogging:(bool)enableLogging;

- (void) trackEvent:(NSString*)eventTitle :(NSString*)eventValue;
- (void) identityLinkEvent:(NSDictionary*)identityLinkData;
- (void) spatialEvent:(NSString*)eventTitle :(float)x :(float)y :(float)z;
- (void) setLimitAdTracking:(bool)limitAdTracking;
- (id) retrieveAttribution;
- (void) sendDeepLink:(NSURL*)url :(NSString*)sourceApplication;
- (NSString*) getDeviceId;
- (bool) presentInitAd;

// Apple Watch
- (void) handleWatchEvents;
- (void) handleWatchEvents:(NSString*)watchLink;
- (void) handleWatchEvents:(NSString*)watchLink :(bool)calledByTrackEvent;

- (void) trackWatchEvent:(NSString*)eventTitle :(NSString*)eventValue;


#pragma mark Delegates

@property (nonatomic, assign) id <MolocoTrackerClientDelegate> trackerDelegate;


#pragma mark Deprecated Initializers

- (id) initWithAppId:(NSString*)appId
MOLOCO_DEPRECATED("Please initialize a tracker using a parameters dictionary");
- (id) initWithAppId:(NSString*)appId :(NSString*)currency
MOLOCO_DEPRECATED("Please initialize a tracker using a parameters dictionary");
- (id) initWithAppId:(NSString*)appId :(NSString*)currency :(bool)enableLogging
MOLOCO_DEPRECATED("Please initialize a tracker using a parameters dictionary");
- (id) initWithAppId:(NSString*)appId :(NSString*)currency :(bool)enableLogging :(bool)limitAdTracking
MOLOCO_DEPRECATED("Please initialize a tracker using a parameters dictionary");
- (id) initWithAppId:(NSString*)appId :(NSString*)currency :(bool)enableLogging :(bool)limitAdTracking :(bool)isNewUser
MOLOCO_DEPRECATED("Please initialize a tracker using a parameters dictionary");

@end
