#include "lua_perplesdk.h"
#include "tolua_fix.h"
#include "PerpleCore.h"
#include "lua_perplesdk_macro.h"

#define LOG_TAG "PerpleSDKLua"

#if defined(__ANDROID__) && !defined(NDEBUG)
#include <android/log.h>
#define LOG(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#else
#define LOG(...)
#endif

void executeLuaFunction(lua_State* L, int funcID, int numArgs)
{
    int funcIdx = -(numArgs + 1);

    toluafix_get_function_by_refid(L, funcID);
    if (!lua_isfunction(L, -1))
    {
        LOG("lua callback function id is invalid");
        lua_pop(L, numArgs + 1);
        return;
    }

    lua_insert(L, funcIdx);

    int traceback = 0;

    lua_getglobal(L, "__G__TRACKBACK__");
    if (!lua_isfunction(L, -1))
    {
        lua_pop(L, 1);
    }
    else
    {
        lua_insert(L, funcIdx - 1);
        traceback = funcIdx - 1;
    }

    int error = lua_pcall(L, numArgs, 1, traceback);
    if (error)
    {
        if (traceback == 0)
        {
            LOG("[LUA ERROR(PerpleSDK)] %s", lua_tostring(L, -1));
            lua_pop(L, 1);
        }
        else
        {
            lua_pop(L, 2);
        }
        return;
    }

    lua_pop(L, 1);

    if (traceback)
    {
        lua_pop(L, 1);
    }
}

void onSdkResult(lua_State* L, const int funcID, const std::string result, const std::string info)
{
    LOG("Lua callback, result - funcID:%d, ret:%s, info:%s", funcID, result.c_str(), info.c_str());

    lua_pushstring(L, result.c_str());
    lua_pushstring(L, info.c_str());

    executeLuaFunction(L, funcID, 2);

    lua_settop(L, 0);
}

// ----------------------------------
// perpleSDK
// ----------------------------------
IMPL_LUABINDING_FUNC(updateLuaCallbacks)
IMPL_LUABINDING_FUNC_I(getVersion)
IMPL_LUABINDING_FUNC_S(getVersionString)
IMPL_LUABINDING_FUNC_V_V(resetLuaBinding)
IMPL_LUABINDING_FUNC_V_SS(setPlatformServerSecretKey)

IMPL_LUABINDING_FUNC_S_V(getABI)

IMPL_LUABINDING_FUNC_V_I(setFCMPushOnForeground)
IMPL_LUABINDING_FUNC_V_V(setFCMTokenRefresh)
IMPL_LUABINDING_FUNC_V_V(getFCMToken)
IMPL_LUABINDING_FUNC_V_S(subscribeToTopic)
IMPL_LUABINDING_FUNC_V_S(unsubscribeFromTopic)

IMPL_LUABINDING_FUNC_V_SS(logEvent)
IMPL_LUABINDING_FUNC_V_SS(setUserProperty)
IMPL_LUABINDING_FUNC_V_V(autoLogin)
IMPL_LUABINDING_FUNC_V_V(loginAnonymously)
IMPL_LUABINDING_FUNC_V_V(loginWithGoogle)
IMPL_LUABINDING_FUNC_V_V(loginWithFacebook)
IMPL_LUABINDING_FUNC_V_V(loginWithTwitter)
IMPL_LUABINDING_FUNC_V_S(loginWithGameCenter)
IMPL_LUABINDING_FUNC_V_V(loginWithApple)
IMPL_LUABINDING_FUNC_V_SS(loginWithEmail)
IMPL_LUABINDING_FUNC_V_S(loginWithCustomToken)
IMPL_LUABINDING_FUNC_V_V(linkWithGoogle)
IMPL_LUABINDING_FUNC_V_V(linkWithFacebook)
IMPL_LUABINDING_FUNC_V_V(linkWithTwitter)
IMPL_LUABINDING_FUNC_V_SS(linkWithEmail)
IMPL_LUABINDING_FUNC_V_V(linkWithApple)
IMPL_LUABINDING_FUNC_V_V(unlinkWithGoogle)
IMPL_LUABINDING_FUNC_V_V(unlinkWithFacebook)
IMPL_LUABINDING_FUNC_V_V(unlinkWithTwitter)
IMPL_LUABINDING_FUNC_V_V(unlinkWithEmail)
IMPL_LUABINDING_FUNC_V_V(unlinkWithApple)
IMPL_LUABINDING_FUNC_V_V(logout)
IMPL_LUABINDING_FUNC_V_V(deleteUser)
IMPL_LUABINDING_FUNC_V_SS(createUserWithEmail)
IMPL_LUABINDING_FUNC_V_S(sendPasswordResetEmail)

IMPL_LUABINDING_FUNC_V_V(facebookLogin)
IMPL_LUABINDING_FUNC_V_V(facebookLogout)
IMPL_LUABINDING_FUNC_V_S(facebookSendRequest)
IMPL_LUABINDING_FUNC_V_S(facebookSendSharing)
IMPL_LUABINDING_FUNC_V_V(facebookGetFriends)
IMPL_LUABINDING_FUNC_V_V(facebookGetInvitableFriends)
IMPL_LUABINDING_FUNC_V_SS(facebookNotifications)
IMPL_LUABINDING_FUNC_Z_S(facebookIsGrantedPermission)
IMPL_LUABINDING_FUNC_V_S(facebookAskPermission)

IMPL_LUABINDING_FUNC_V_V(twitterLogin)
IMPL_LUABINDING_FUNC_V_V(twitterLogout)
IMPL_LUABINDING_FUNC_V_S(twitterComposeTweet)

IMPL_LUABINDING_FUNC_V_SSS(tapjoyEvent)
IMPL_LUABINDING_FUNC_V_I(tapjoySetTrackPurchase)
IMPL_LUABINDING_FUNC_V_S(tapjoySetPlacement)
IMPL_LUABINDING_FUNC_V_S(tapjoyShowPlacement)
IMPL_LUABINDING_FUNC_V_V(tapjoyGetCurrency)
IMPL_LUABINDING_FUNC_V_V(tapjoySetEarnedCurrencyCallback)
IMPL_LUABINDING_FUNC_V_I(tapjoySpendCurrency)
IMPL_LUABINDING_FUNC_V_I(tapjoyAwardCurrency)

IMPL_LUABINDING_FUNC_V_V(googleLogin)
IMPL_LUABINDING_FUNC_V_V(googleLogout)
IMPL_LUABINDING_FUNC_V_V(googleSilentLogin)
IMPL_LUABINDING_FUNC_V_V(googlePlayServiceLogin)
IMPL_LUABINDING_FUNC_V_V(googleRevokeAccess)
IMPL_LUABINDING_FUNC_V_V(googleShowAchievements)
IMPL_LUABINDING_FUNC_V_S(googleShowLeaderboards)
IMPL_LUABINDING_FUNC_V_SS(googleUpdateAchievements)
IMPL_LUABINDING_FUNC_V_SS(googleUpdateLeaderboards)

IMPL_LUABINDING_FUNC_V_V(gameCenterLogin)

IMPL_LUABINDING_FUNC_V_V(appleLogin)
IMPL_LUABINDING_FUNC_V_V(appleLogout)

IMPL_LUABINDING_FUNC_V_SS(billingSetup)
IMPL_LUABINDING_FUNC_V_SS(billingConfirm)
IMPL_LUABINDING_FUNC_V_SS(billingPurchase)
IMPL_LUABINDING_FUNC_V_SS(billingSubscription)
IMPL_LUABINDING_FUNC_V_S(billingGetItemList)
IMPL_LUABINDING_FUNC_V_V(billingGetIncompletePurchaseList)

IMPL_LUABINDING_FUNC_V_S(adjustTrackEvent)
IMPL_LUABINDING_FUNC_V_SSS(adjustTrackPayment)
IMPL_LUABINDING_FUNC_V_V(adjustGdprForgetMe)
IMPL_LUABINDING_FUNC_S_V(adjustGetAdid)

IMPL_LUABINDING_FUNC_V_V(adMobInitialize)
IMPL_LUABINDING_FUNC_V_S(adMobLoadRewardAd)
IMPL_LUABINDING_FUNC_V_S(adMobShowRewardAd)

IMPL_LUABINDING_FUNC_Z_V(xsollaIsAvailable)
IMPL_LUABINDING_FUNC_V_S(xsollaSetPaymentInfoUrl)
IMPL_LUABINDING_FUNC_V_S(xsollaOpenPaymentUI)

IMPL_LUABINDING_FUNC_V_V(crashlyticsForceCrash)
IMPL_LUABINDING_FUNC_V_S(crashlyticsSetUid)
IMPL_LUABINDING_FUNC_V_S(crashlyticsSetLog)
IMPL_LUABINDING_FUNC_V_S(crashlyticsSetExceptionLog)
IMPL_LUABINDING_FUNC_V_SS(crashlyticsSetKeyString)
IMPL_LUABINDING_FUNC_V_SI(crashlyticsSetKeyInt)
IMPL_LUABINDING_FUNC_V_SZ(crashlyticsSetKeyBool)

IMPL_LUABINDING_FUNC_V_S(onestoreSetUid)
IMPL_LUABINDING_FUNC_Z_V(onestoreIsAvailable)
IMPL_LUABINDING_FUNC_V_S(onestoreConsumeByOrderid)
IMPL_LUABINDING_FUNC_V_V(onestoreRequestPurchases)
IMPL_LUABINDING_FUNC_V_V(onestoreGetPurchases)
IMPL_LUABINDING_FUNC_V_SS(billingPurchaseForOnestore)
IMPL_LUABINDING_FUNC_V_S(billingGetItemListForOnestore)
IMPL_LUABINDING_FUNC_V_SS(billingPurchaseSubscriptionForOnestore)
IMPL_LUABINDING_FUNC_V_S(cancelSubscriptionForOnestore)

IMPL_LUABINDING_FUNC_V_V(cmpLoadConsentIfNeeded)
IMPL_LUABINDING_FUNC_Z_V(cmpCanRequestAds)
IMPL_LUABINDING_FUNC_Z_V(cmpRequirePrivacyOption)
IMPL_LUABINDING_FUNC_V_V(cmpPresentPrivacyOptionForm)


int registerAllPerpleSdk(lua_State* L)
{
    if (nullptr == L)
    {
        return 0;
    }

    tolua_open(L);
    toluafix_open(L);

    tolua_module(L, NULL, 0);
    tolua_beginmodule(L, NULL);
        tolua_usertype(L, "PerpleSDK");
        tolua_cclass(L, "PerpleSDK", "PerpleSDK", "", NULL);
        tolua_beginmodule(L,"PerpleSDK");

            DECL_LUABINDING_FUNC(updateLuaCallbacks)
            DECL_LUABINDING_FUNC(getVersion)
            DECL_LUABINDING_FUNC(getVersionString)
            DECL_LUABINDING_FUNC(resetLuaBinding)
            DECL_LUABINDING_FUNC(setPlatformServerSecretKey)

            DECL_LUABINDING_FUNC(getABI)

            DECL_LUABINDING_FUNC(setFCMPushOnForeground)
            DECL_LUABINDING_FUNC(setFCMTokenRefresh)
            DECL_LUABINDING_FUNC(getFCMToken)
            DECL_LUABINDING_FUNC(subscribeToTopic)
            DECL_LUABINDING_FUNC(unsubscribeFromTopic)

            DECL_LUABINDING_FUNC(logEvent)
            DECL_LUABINDING_FUNC(setUserProperty)
            DECL_LUABINDING_FUNC(autoLogin)
            DECL_LUABINDING_FUNC(loginAnonymously)
            DECL_LUABINDING_FUNC(loginWithGoogle)
            DECL_LUABINDING_FUNC(loginWithFacebook)
            DECL_LUABINDING_FUNC(loginWithTwitter)
            DECL_LUABINDING_FUNC(loginWithGameCenter)
            DECL_LUABINDING_FUNC(loginWithEmail)
            DECL_LUABINDING_FUNC(loginWithCustomToken)
            DECL_LUABINDING_FUNC(loginWithApple)
            DECL_LUABINDING_FUNC(linkWithGoogle)
            DECL_LUABINDING_FUNC(linkWithFacebook)
            DECL_LUABINDING_FUNC(linkWithTwitter)
            DECL_LUABINDING_FUNC(linkWithEmail)
            DECL_LUABINDING_FUNC(linkWithApple)
            DECL_LUABINDING_FUNC(unlinkWithGoogle)
            DECL_LUABINDING_FUNC(unlinkWithFacebook)
            DECL_LUABINDING_FUNC(unlinkWithTwitter)
            DECL_LUABINDING_FUNC(unlinkWithEmail)
            DECL_LUABINDING_FUNC(unlinkWithApple)
            DECL_LUABINDING_FUNC(logout)
            DECL_LUABINDING_FUNC(deleteUser)
            DECL_LUABINDING_FUNC(createUserWithEmail)
            DECL_LUABINDING_FUNC(sendPasswordResetEmail)

            DECL_LUABINDING_FUNC(facebookLogin)
            DECL_LUABINDING_FUNC(facebookLogout)
            DECL_LUABINDING_FUNC(facebookSendRequest)
            DECL_LUABINDING_FUNC(facebookSendSharing)
            DECL_LUABINDING_FUNC(facebookGetFriends)
            DECL_LUABINDING_FUNC(facebookGetInvitableFriends)
            DECL_LUABINDING_FUNC(facebookNotifications)
            DECL_LUABINDING_FUNC(facebookIsGrantedPermission)
            DECL_LUABINDING_FUNC(facebookAskPermission)

            DECL_LUABINDING_FUNC(twitterLogin)
            DECL_LUABINDING_FUNC(twitterLogout)
            DECL_LUABINDING_FUNC(twitterComposeTweet)

            DECL_LUABINDING_FUNC(tapjoyEvent)
            DECL_LUABINDING_FUNC(tapjoySetTrackPurchase)
            DECL_LUABINDING_FUNC(tapjoySetPlacement)
            DECL_LUABINDING_FUNC(tapjoyShowPlacement)
            DECL_LUABINDING_FUNC(tapjoyGetCurrency)
            DECL_LUABINDING_FUNC(tapjoySetEarnedCurrencyCallback)
            DECL_LUABINDING_FUNC(tapjoySpendCurrency)
            DECL_LUABINDING_FUNC(tapjoyAwardCurrency)

            DECL_LUABINDING_FUNC(googleLogin)
            DECL_LUABINDING_FUNC(googleLogout)
            DECL_LUABINDING_FUNC(googleSilentLogin)
            DECL_LUABINDING_FUNC(googlePlayServiceLogin)
            DECL_LUABINDING_FUNC(googleRevokeAccess)
            DECL_LUABINDING_FUNC(googleShowAchievements)
            DECL_LUABINDING_FUNC(googleShowLeaderboards)
            DECL_LUABINDING_FUNC(googleUpdateAchievements)
            DECL_LUABINDING_FUNC(googleUpdateLeaderboards)

            DECL_LUABINDING_FUNC(gameCenterLogin)

            DECL_LUABINDING_FUNC(appleLogin)
            DECL_LUABINDING_FUNC(appleLogout)

            DECL_LUABINDING_FUNC(billingSetup)
            DECL_LUABINDING_FUNC(billingConfirm)
            DECL_LUABINDING_FUNC(billingPurchase)
            DECL_LUABINDING_FUNC(billingSubscription)
            DECL_LUABINDING_FUNC(billingGetItemList)
            DECL_LUABINDING_FUNC(billingGetIncompletePurchaseList)

            DECL_LUABINDING_FUNC(adjustTrackEvent)
            DECL_LUABINDING_FUNC(adjustTrackPayment)
            DECL_LUABINDING_FUNC(adjustGdprForgetMe)
            DECL_LUABINDING_FUNC(adjustGetAdid)

            DECL_LUABINDING_FUNC(adMobInitialize)
            DECL_LUABINDING_FUNC(adMobLoadRewardAd)
            DECL_LUABINDING_FUNC(adMobShowRewardAd)

            DECL_LUABINDING_FUNC(xsollaIsAvailable)
            DECL_LUABINDING_FUNC(xsollaSetPaymentInfoUrl)
            DECL_LUABINDING_FUNC(xsollaOpenPaymentUI)

            DECL_LUABINDING_FUNC(crashlyticsForceCrash)
            DECL_LUABINDING_FUNC(crashlyticsSetUid)
            DECL_LUABINDING_FUNC(crashlyticsSetLog)
			DECL_LUABINDING_FUNC(crashlyticsSetExceptionLog)
            DECL_LUABINDING_FUNC(crashlyticsSetKeyString)
            DECL_LUABINDING_FUNC(crashlyticsSetKeyInt)
            DECL_LUABINDING_FUNC(crashlyticsSetKeyBool)

            DECL_LUABINDING_FUNC(onestoreSetUid)
            DECL_LUABINDING_FUNC(billingPurchaseForOnestore)
            DECL_LUABINDING_FUNC(billingGetItemListForOnestore)
            DECL_LUABINDING_FUNC(onestoreIsAvailable)
            DECL_LUABINDING_FUNC(onestoreConsumeByOrderid)
            DECL_LUABINDING_FUNC(onestoreRequestPurchases)
            DECL_LUABINDING_FUNC(onestoreGetPurchases)
            DECL_LUABINDING_FUNC(billingPurchaseSubscriptionForOnestore)
            DECL_LUABINDING_FUNC(cancelSubscriptionForOnestore)

            DECL_LUABINDING_FUNC(cmpLoadConsentIfNeeded)
            DECL_LUABINDING_FUNC(cmpCanRequestAds)
            DECL_LUABINDING_FUNC(cmpRequirePrivacyOption)
            DECL_LUABINDING_FUNC(cmpPresentPrivacyOptionForm)

        tolua_endmodule(L);
    tolua_endmodule(L);

    return 0;
}
