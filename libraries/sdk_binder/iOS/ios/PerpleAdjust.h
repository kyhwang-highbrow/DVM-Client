//
//  PerpleAdjust.h
//  PerpleSDK
//

#import <Adjust/Adjust.h>
#import "PerpleSDK.h"

@interface PerpleAdjust : UIResponder<AdjustDelegate>

#pragma mark - Properties


#pragma mark - Initialization

- (id) initWithAppKey:(NSString *)appKey secret:(NSArray*)secretKey debug:(BOOL)isDebug;

#pragma mark - APIs
- (void) trackEvent:(NSString *)eventKey;
- (void) trackPayment:(NSString *)key price:(NSString *)price currency:(NSString *)currency;
- (void) gdprForgetMe;
- (NSString *) getAdid;

#pragma mark - AdjustDelegate
- (void) adjustAttributionChanged:(ADJAttribution *)attribution;
- (void) adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData;
- (void) adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData;
- (void) adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData;
- (void) adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData;

#pragma mark - AppDelegate
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options;
- (BOOL) application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler;

@end
