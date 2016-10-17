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

#import <UIKit/UIKit.h>

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
// @ppsdk
#import "PPCallBackManager.h"
#endif

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
@interface RootViewController : UIViewController
<
#ifdef USE_GOOGLEPLAY
#ifndef GOOGLEPLAY_LOGIN_PATI
    GPGStatusDelegate,
#endif
    GPGQuestListLauncherDelegate,
#endif
    PPCallBackManagerDelegate
>
#else
#ifdef USE_GOOGLEPLAY
@interface RootViewController : UIViewController
<
#ifndef GOOGLEPLAY_LOGIN_PATI
    GPGStatusDelegate,
#endif
    GPGQuestListLauncherDelegate
>
#else
@interface RootViewController : UIViewController
#endif
#endif
{
}

#ifdef USE_GOOGLEPLAY
#ifndef GOOGLEPLAY_LOGIN_PATI
// @google+
@property (nonatomic, copy) NSString * googleClientID;
#endif
#endif

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
// @ppsdk
@property int ppsdkDylibLoaded;
@property int ppsdkLoginReady;
@property bool ppsdkIsPayAndExchange;
@property (nonatomic, copy) NSString * ppsdkUid;

// @ppsdk
@property (nonatomic, strong) PPCallBackManager * manager;
@property (nonatomic, strong) tokenVerifyingSuccessCallBack blockVerifyingAuthToken;
#endif

- (BOOL)prefersStatusBarHidden;

#ifdef USE_GOOGLEPLAY
#ifndef GOOGLEPLAY_LOGIN_PATI
// @google+
- (void)gpgSetClientID:(NSString *)cid;
- (void)gpgSignIn;
- (void)gpgSignOut;
- (void)gpgIsSignedIn;
#endif
// @google+
- (void)gpgCheckLogin;
- (void)gpgShowAchievements;
- (void)gpgShowLeaderboards;
- (void)gpgShowQuests;
- (void)gpgSetAchievements:(NSString *)aid count:(int)count;
- (void)gpgSetLeaderboards:(NSString *)lid score:(int)score;
- (void)gpgSetEvents:(NSString *)eid count:(int)count;
#endif

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)
// @ppsdk
- (void)ppsdkLoginStart;

// @ppsdk
//- (void)ppsdkLogin;
//- (void)ppsdkLogout;
//- (void)ppsdkLoginAuth:(int)result param:(NSString *)info;
//- (void)ppsdkExchangeGoods:(NSString *)arg0;
//- (void)ppsdkShowSDKCenter;
#endif

@end
