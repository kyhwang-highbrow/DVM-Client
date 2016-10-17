// Copyright (C) 2014 by Tapjoy Inc.
//
// This file is part of the Tapjoy SDK.
//
// By using the Tapjoy SDK in your software, you agree to the terms of the Tapjoy SDK License Agreement.
//
// The Tapjoy SDK is bound by the Tapjoy SDK License Agreement and can be found here: https://www.tapjoy.com/sdk/license

#import "TJAppDelegate.h"
#import <Tapjoy/Tapjoy.h>

@implementation TJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Tapjoy Connect Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectSuccess:)
                                                 name:TJC_CONNECT_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tjcConnectFail:)
                                                 name:TJC_CONNECT_FAILED
                                               object:nil];
	
    // Registering for remote notifications
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

	// NOTE: This is the only step required if you're an advertiser.
	// NOTE: This must be replaced by your App ID. It is retrieved from the Tapjoy website, in your account.
	[Tapjoy connect:@"E7CuaoUWRAWdz_5OUmSGsgEBXHdOwPa8de7p4aseeYP01mecluf-GfNgtXlF"
						 options:@{ TJC_OPTION_ENABLE_LOGGING : @(YES) }
		// If you are not using Tapjoy Managed currency, you would set your own user ID here.
        // TJC_OPTION_USER_ID : @"A_UNIQUE_USER_ID"
	];
	
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Add an observer for when a user has successfully earned currency.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(showEarnedCurrencyAlert:)
												 name:TJC_CURRENCY_EARNED_NOTIFICATION
											   object:nil];
	
	// Best Practice: We recommend calling getCurrencyBalance as often as possible so the user’s balance is always up-to-date.
	[Tapjoy getCurrencyBalance];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Remove this to prevent the possibility of multiple redundant notifications.
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TJC_CURRENCY_EARNED_NOTIFICATION object:nil];
}

-(void)tjcConnectSuccess:(NSNotification*)notifyObj
{
	NSLog(@"Tapjoy connect Succeeded");
}


- (void)tjcConnectFail:(NSNotification*)notifyObj
{
	NSLog(@"Tapjoy connect Failed");
}

- (void)showEarnedCurrencyAlert:(NSNotification*)notifyObj
{
	NSNumber *currencyEarned = notifyObj.object;
	int earnedNum = [currencyEarned intValue];
	
	NSLog(@"Currency earned: %d", earnedNum);
	
	// Pops up a UIAlert notifying the user that they have successfully earned some currency.
	// This is the default alert, so you may place a custom alert here if you choose to do so.
	[Tapjoy showDefaultEarnedCurrencyAlert];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
    [Tapjoy setDeviceToken: deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [Tapjoy setReceiveRemoteNotification:userInfo];
}

@end
