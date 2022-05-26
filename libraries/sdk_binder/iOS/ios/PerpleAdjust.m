//
//  PerpleAdjust.m
//  PerpleSDK

#import "PerpleAdjust.h"

@implementation PerpleAdjust

#pragma mark - Properties

#pragma mark - Initialization

- (id) initWithAppKey:(NSString *)appKey secret:(NSArray *)secretKey
                debug:(BOOL)isDebug {
    NSLog(@"PerpleAdjust, Initializing Adjust.");

    // Configure adjust SDK.
    NSString *environment;
    if( isDebug == TRUE ) {
        environment = ADJEnvironmentSandbox;
    }
    else {
        environment = ADJEnvironmentProduction;
    }

    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:appKey environment:environment];

    // Change the log level.
    if( isDebug == TRUE ) {
        [adjustConfig setLogLevel:ADJLogLevelDebug];
    }
    else {
        [adjustConfig setLogLevel:ADJLogLevelWarn];
    }

    // Set an attribution delegate.
    [adjustConfig setDelegate:self];

    // SDK Signature - App Secret setting
    [adjustConfig setAppSecret:[secretKey[0] integerValue]
                         info1:[secretKey[1] integerValue]
                         info2:[secretKey[2] integerValue]
                         info3:[secretKey[3] integerValue]
                         info4:[secretKey[4] integerValue]];

    // Initialise the SDK.
    [Adjust appDidLaunch:adjustConfig];

    return self;
}

- (void) dealloc {
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

#pragma mark - APIs
- (void) trackEvent:(NSString *)eventKey {
    if ([PerpleSDK isDebug]) {
        NSLog(@"trackEvent!");
        NSLog(@"eventKey: %@", eventKey);
    }

    ADJEvent* event = [ADJEvent eventWithEventToken:eventKey];
    [Adjust trackEvent:event];
}

- (void) trackPayment:(NSString *)key price:(NSString *)price currency:(NSString *)currency {
    double retPrice = [price doubleValue];

    if ([PerpleSDK isDebug]) {
        NSLog(@"trackPayment!");
        NSLog(@"key: %@, price: %@, currency: %@", key, price, currency);
        NSLog(@"price: %f", retPrice);
    }

    ADJEvent* event = [ADJEvent eventWithEventToken:key];
    [event setRevenue:retPrice currency:currency];
    [Adjust trackEvent:event];
}

- (void) gdprForgetMe {
    [Adjust gdprForgetMe];
}

- (NSString *) getAdid {
    // @sgkim 2021.09.27
    //NSString *idfaString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return [Adjust idfa];
}

#pragma mark - AdjustDelegate

- (void) adjustAttributionChanged:(ADJAttribution *)attribution {
    if ([PerpleSDK isDebug]) {
        NSLog(@"Attribution callback called!");
        NSLog(@"Attribution: %@", attribution);
    }
}

- (void) adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
    if ([PerpleSDK isDebug]) {
        NSLog(@"Event success callback called!");
        NSLog(@"Event success data: %@", eventSuccessResponseData);
    }
}

- (void) adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
    if ([PerpleSDK isDebug]) {
        NSLog(@"Event failure callback called!");
        NSLog(@"Event failure data: %@", eventFailureResponseData);
    }
}

- (void) adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
    if ([PerpleSDK isDebug]) {
        NSLog(@"Session success callback called!");
        NSLog(@"Session success data: %@", sessionSuccessResponseData);
    }
}

- (void) adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
    if ([PerpleSDK isDebug]) {
        NSLog(@"Session failure callback called!");
        NSLog(@"Session failure data: %@", sessionFailureResponseData);
    }
}

#pragma mark - AppDelegate
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    NSLog(@"openURL method called with URL: %@", url);

    [Adjust appWillOpenUrl:url];

    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSLog(@"continueUserActivity method called with URL: %@", [userActivity webpageURL]);
        [Adjust convertUniversalLink:[userActivity webpageURL] scheme:@"adjustExample"];
        [Adjust appWillOpenUrl:[userActivity webpageURL]];
    }

    return YES;
}


@end
