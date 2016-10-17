/****************************************************************************
 Copyright (c) 2010-2011 cocos2d-x.org
 Copyright (c) 2010      Ricardo Quesada

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "RootViewController.h"
#import "cocos2d.h"
#import "CCEAGLView.h"
#import "ConfigParser.h"

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
// @ppsdk
#import <PPAppPlatformKit/PPAppPlatformKit.h>
#endif

// @google+, @adbrix, @5rocks, @tapjoy, @patisdk, @ppsdk
extern void sdkEventResult(const char *id, const char *result, const char *info);

@implementation RootViewController

#ifdef USE_GOOGLEPLAY
#ifndef GOOGLEPLAY_LOGIN_PATI
// @google+
@synthesize googleClientID;
#endif
#endif

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
// @ppsdk
@synthesize ppsdkDylibLoaded;
@synthesize ppsdkLoginReady;
@synthesize ppsdkUid;

// @ppsdk
@synthesize manager;
@synthesize blockVerifyingAuthToken;
#endif

// The designated initializer. Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
        // @ppsdk
        self.ppsdkDylibLoaded = 0;
        self.ppsdkLoginReady = 0;
        self.ppsdkIsPayAndExchange = false;
        self.ppsdkUid = @"";

        // @ppsdk
        self.blockVerifyingAuthToken = nil;

        // @ppsdk
        self.manager = [PPCallBackManager new];
        self.manager.delegate = self;
#endif

#ifdef USE_GOOGLEPLAY
#ifndef GOOGLEPLAY_LOGIN_PATI
        // @google+
        [GPGManager sharedInstance].statusDelegate = self;

        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        self.googleClientID = [infoDic objectForKey:@"GooglePlusClientId"];
#endif
#endif
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

// Override to allow orientations other than the default portrait orientation.
// This method is deprecated on iOS6.
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (ConfigParser::getInstance()->isLanscape()) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
}
#else
// For iOS6, use supportedInterfaceOrientations & shouldAutorotate instead
- (NSUInteger)supportedInterfaceOrientations{
    if (ConfigParser::getInstance()->isLandscape()) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotate {
    if (ConfigParser::getInstance()->isLandscape()) {
        return YES;
    } else {
        return NO;
    }
}
#endif

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    cocos2d::GLView *glview = cocos2d::Director::getInstance()->getOpenGLView();

    if (glview) {
        CCEAGLView *eaglview = (__bridge CCEAGLView*) glview->getEAGLView();

        if (eaglview) {
            CGSize s = CGSizeMake([eaglview getWidth], [eaglview getHeight]);
            cocos2d::Application::getInstance()->applicationScreenSizeChanged((int)s.width, (int)s.height);
        }
    }
}

// Fix not hide status on iOS7.
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

#ifdef USE_GOOGLEPLAY
#ifndef GOOGLEPLAY_LOGIN_PATI
// @google+
- (void)gpgSetClientID:(NSString *)cid {
    self.googleClientID = cid;
}

// @google+
- (void)gpgSignIn {
    [[GPGManager sharedInstance] signInWithClientID:self.googleClientID silently:NO];
}

// @google+
- (void)gpgSignOut {
    [[GPGManager sharedInstance] signOut];
}

// @google+
- (void)gpgIsSignedIn {
    BOOL signedIn = [GPGManager sharedInstance].isSignedIn;
    if (signedIn) {
        sdkEventResult("googleplay_isSignedIn", "true", "");
    } else {
        sdkEventResult("googleplay_isSignedIn", "false", "");
    }
}
#endif

// @google+
- (void)gpgCheckLogin {
    if (![GPGManager sharedInstance].isSignedIn) {
        [[GPGManager sharedInstance] signIn];
    }
    sdkEventResult("googleplay_checkLogin", "true", "");
}

// @google+
- (void)gpgShowAchievements {
    if ([GPGManager sharedInstance].isSignedIn) {
        [[GPGLauncherController sharedInstance] presentAchievementList];
        sdkEventResult("googleplay_showAchievements", "true", "");
    } else {
        sdkEventResult("googleplay_showAchievements", "false", "");
    }
}

// @google+
- (void)gpgShowLeaderboards {
    if ([GPGManager sharedInstance].isSignedIn) {
        [[GPGLauncherController sharedInstance] presentLeaderboardList];
        sdkEventResult("googleplay_showLeaderboards", "true", "");
    } else {
        sdkEventResult("googleplay_showLeaderboards", "false", "");
    }
}

// @google+
- (void)gpgShowQuests {
    if ([GPGManager sharedInstance].isSignedIn) {
        [[GPGLauncherController sharedInstance] presentQuestList];
        sdkEventResult("googleplay_showQuests", "true", "");
    } else {
        sdkEventResult("googleplay_showQuests", "false", "");
    }
}

// @google+
- (void)gpgSetAchievements:(NSString *)aid count:(int)count {
    if ([GPGManager sharedInstance].isSignedIn) {
        GPGAchievement *unlockMe = [GPGAchievement achievementWithId:aid];
        if (count > 0) {
            [unlockMe setSteps:count completionHandler:^(BOOL newlyUnlocked, int currentSteps, NSError *error) {
                if (error) {
                    // Handle the error
                    NSLog(@"Error while setSteps: %@", error);
                    sdkEventResult("googleplay_setAchievements", "false", "fail setSteps");
                } else if (newlyUnlocked) {
                    NSLog(@"Incremental achievement unlocked!");
                    sdkEventResult("googleplay_setAchievements", "true", "unlocked");
                } else {
                    NSLog(@"User has completed %i steps total", currentSteps);
                    sdkEventResult("googleplay_setAchievements", "true", "setSteps");
                }
            }];
        } else if (count == 0) {
            [unlockMe unlockAchievementWithCompletionHandler:^(BOOL newlyUnlocked, NSError *error) {
                if (error) {
                    // Handle the error
                    NSLog(@"Error while unlockAchievementWithCompletionHandler: %@", error);
                    sdkEventResult("googleplay_setAchievements", "false", "fail unlock");
                } else if (!newlyUnlocked) {
                    // Achievement was already unlocked
                    NSLog(@"Achievement was already unlocked!");
                    sdkEventResult("googleplay_setAchievements", "true", "already unlocked");
                } else {
                    NSLog(@"Hooray! Achievement unlocked!");
                    sdkEventResult("googleplay_setAchievements", "true", "unlocked");
                }
            }];
        }
    } else {
        sdkEventResult("googleplay_setAchievements", "false", "not signedin");
    }
}

// @google+
- (void)gpgSetLeaderboards:(NSString *)lid score:(int)score {
    if ([GPGManager sharedInstance].isSignedIn) {
        GPGScore *myScore = [[GPGScore alloc] initWithLeaderboardId:lid];
        myScore.value = score;
        [myScore submitScoreWithCompletionHandler: ^(GPGScoreReport *report, NSError *error) {
            NSLog(@"Report: %@ Error: %@", report, error);
            if (error) {
                // Handle the error
                NSLog(@"Error while submitScoreWithCompletionHandler: %@", error);
                sdkEventResult("googleplay_setLeaderboards", "false", "fail submit");
            } else {
                // Analyze the report, if you'd like
                NSLog(@"Leaderboard score submited: %llxl", report.reportedScoreValue);
                sdkEventResult("googleplay_setLeaderboards", "true", "");
            }
        }];
    } else {
        sdkEventResult("googleplay_setLeaderboards", "false", "not signedin");
    }
}

// @google+
- (void)gpgSetEvents:(NSString *)eid count:(int)count {
    if ([GPGManager sharedInstance].isSignedIn) {
        [GPGEvent eventForId:eid completionHandler:^(GPGEvent *event, NSError *error) {
            NSLog(@"Event: %@ Error: %@", event, error);
            if (event) {
                [event incrementBy:count completionHandler:^(GPGEvent *event, NSError *error) {
                    if (error) {
                        NSLog(@"Error while incrementBy: %@", error);
                        sdkEventResult("googleplay_setEvents", "false", "fail increment");
                    } else {
                        NSLog(@"Event count incremented, now: %llxl", event.count);
                        //NSString info = event.eventId + ";" + [[NSNumber numberWithUnsignedInteger:event.count] stringValue];
                        sdkEventResult("googleplay_setEvents", "true", "");
                    }
                }];
            } else {
                NSLog(@"Error while eventForId: %@", error);
                sdkEventResult("googleplay_setEvents", "false", "no event");
            }
        }];
    } else {
        sdkEventResult("googleplay_setEvents", "false", "not signedin");
    }
}

#ifndef GOOGLEPLAY_LOGIN_PATI
// @google+
- (void)didFinishGamesSignInWithError:(NSError *)error {
    if (error) {
        CCLOG("Received an error while signing in - code:%d, desc:%s", (int)[error code], [[error localizedDescription] UTF8String]);
        sdkEventResult("googleplay_login", "error", [[[NSNumber numberWithInteger:[error code]] stringValue] UTF8String]);
    } else {
        CCLOG("Signed in!");
        sdkEventResult("googleplay_login", "success", "");
    }
}

// @google+
- (void)didFinishGamesSignOutWithError:(NSError *)error {
    if (error) {
        CCLOG("Received an error while signing out - code:%d, desc:%s", (int)[error code], [[error localizedDescription] UTF8String]);
        sdkEventResult("googleplay_logout", "false", [[[NSNumber numberWithInteger:[error code]] stringValue] UTF8String]);
    } else {
        CCLOG("Signed out!");
        sdkEventResult("googleplay_logout", "true", "");
    }
}

// @google+
- (void)didFinishGoogleAuthWithError:(NSError *)error {
    if (error) {
        CCLOG("Received an error while auth - code:%d, desc:%s", (int)[error code], [[error localizedDescription] UTF8String]);
        if ([error code] == -1) {
            sdkEventResult("googleplay_login", "cancel", "");
        }
    }
}
#endif

// @google+
/** Message handler for when the player accepts a reward for a quest.
 *  @param questMilestone An object representing an important progression
 *                        point within the quest.
 */
- (void)questListLauncherDidClaimRewardsForQuestMilestone:(GPGQuestMilestone *)questMilestone {
    if (questMilestone.state == GPGQuestMilestoneStateCompletedNotClaimed) {
        [questMilestone claimWithCompletionHandler:^(NSError *error) {
            if (!error) {
                NSLog(@"Quest reward with id %@ has been claimed.", questMilestone.questMilestoneId);
                NSString *reward = [[NSString alloc] initWithData:questMilestone.rewardData encoding:NSUTF8StringEncoding];
                sdkEventResult("googleplay_setEvents", "completed", [reward UTF8String]);
            }
        }];
    }
}

// @google+
- (void)questListLauncherDidAcceptQuest:(GPGQuest *)quest {

}
#endif

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
// @ppsdk
- (void)ppsdkLoginStart {
    int state = [[PPAppPlatformKit share] loginState];
    if (state == 0) {
        NSLog(@"PERP : ppsdk try login ...");
        [[PPAppPlatformKit share] login];
    } else {
        NSString *info = self.ppsdkUid;
        sdkEventResult("ppsdk_login", "already login", [info UTF8String]);
    }
}

/*
// @ppsdk
- (void)ppsdkLogin {
    NSLog(@"PERP : ppsdkDylibLoaded = %d", self.ppsdkDylibLoaded);
    self.ppsdkLoginReady = 1;

    if (self.ppsdkDylibLoaded == 1) {
        [self ppsdkLoginStart];
    }
}

// @ppsdk
- (void)ppsdkLogout {
    [[PPAppPlatformKit share] logout];
}

// @ppsdk
- (void)ppsdkLoginAuth:(int)result {
    // cp必须回调(cp must Callback)
    tokenVerifyingSuccessCallBack block = self.blockVerifyingAuthToken;
    if (block) {
        if (result == 1) {
            block(YES);
            self.ppsdkUid = info;
            [self SDKLoginSuccess];
        } else {
            block(NO);
            self.ppsdkUid = info;
            [self SDKLoginFail];
        }
    }
    self.blockVerifyingAuthToken = nil;
}

 // @ppsdk
- (void)ppsdkExchangeGoods:(NSString *)arg0 {
    NSLog(@"PERP : ppsdk_exchangeGoods - param:%@", arg0);

    if (![arg0 isEqualToString:@""]) {
        NSArray *params = [arg0 componentsSeparatedByString:@";"];
        int paramsCount = (int)[params count];
        if (paramsCount == 3) {
            int price = [[params objectAtIndex:0] intValue];
            NSString *billNo = [params objectAtIndex:1];
            NSString *billTitle = [params objectAtIndex:2];

            NSLog(@"PERP : ppsdk try exchangeGoods - price:%d, billNo:%@, billTitle:%@ ...", price, billNo, billTitle);
            [[PPAppPlatformKit share] exchangeGoods:price BillNo:billNo BillTitle:billTitle RoleId:@"0" ZoneId:0];
        } else {
            sdkEventResult("ppsdk_exchangeGoods", "fail", "param count");
        }
    } else {
        sdkEventResult("ppsdk_exchangeGoods", "fail", "empty param");
    }
}

 // @ppsdk
- (void)ppsdkShowSDKCenter {
    [[PPAppPlatformKit share] showSDKCenter];
}
*/

// @ppsdk
- (void)SDKLoginSuccess {
    NSLog(@"PERP : ppsdk login success !");
    sdkEventResult("ppsdk_loginAuth", "success", "");

    //[[PPAppPlatformKit share] showSDKCenter];
}

// @ppsdk
- (void)SDKLoginFail {
    NSLog(@"PERP : ppsdk login fail !");
    sdkEventResult("ppsdk_loginAuth", "fail", "");

    //[[PPAppPlatformKit share] showSDKCenter];
}

// @ppsdk
- (void)SDKLogOut {
    NSLog(@"PERP : ppsdk logout !");
    self.ppsdkUid = @"";
    sdkEventResult("ppsdk_login", "logout", "");

    //[[PPAppPlatformKit share] showSDKCenter];
}

// @ppsdk
- (void)SDKSetUpDylibSuccess {
    NSLog(@"PERP : ppsdk setup dylib success !");
    NSLog(@"PERP : ppsdkLoginReady = %d", self.ppsdkLoginReady);

    self.ppsdkDylibLoaded = 1;

    if (self.ppsdkLoginReady == 1) {
        [self ppsdkLoginStart];
    }
}

// @ppsdk
- (void)SDKLoginAuth:(NSString *)strToken callBack:(tokenVerifyingSuccessCallBack)block {
    NSLog(@"PERP : ppsdk login auth token : %@", strToken);

    self.blockVerifyingAuthToken = block;
    sdkEventResult("ppsdk_login", "success", [strToken UTF8String]);
}

// @ppsdk
- (void)SDKPayResult:(int)resultCode resultMsg:(NSString *)resultMsg {
    NSLog(@"PERP : ppsdk pay result - code:%d, msg:%@", resultCode, resultMsg);

    // 进入充值并兑换流程(Enter recharge and exchange processes)
    // PPPayResultCodePayAndExchange
    if (resultCode == 1) {
        self.ppsdkIsPayAndExchange = true;
    } else {
        self.ppsdkIsPayAndExchange = false;
    }

    sdkEventResult("ppsdk_exchangeGoods", [[@(resultCode) stringValue] UTF8String], [resultMsg UTF8String]);
}

// @ppsdk
- (void)SDKCenterDidClose {
    cocos2d::Director::getInstance()->resume();

    if (self.ppsdkIsPayAndExchange) {
        self.ppsdkIsPayAndExchange = false;
        sdkEventResult("ppsdk_exchangeGoods", "close", "");
    }
}

// @ppsdk
- (void)SDKCenterDidShow {
    cocos2d::Director::getInstance()->pause();
}
#endif

@end
