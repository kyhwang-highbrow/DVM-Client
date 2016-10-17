#ifndef __PATISDK_PUBLISHSDK_H__
#define __PATISDK_PUBLISHSDK_H__

#include <functional>
#include "PatiTypes.h"

namespace PatiSDK
{
	struct PlatformIdInfo
	{
		std::string patifriendsId;
		std::string kakaoId;
		std::string facebookId;
		std::string googleplusId;
		std::string naverId;
		std::string twitterId;
	};

	DLL_EXPORT const int	getGameId();
	DLL_EXPORT const char*	getClientKey();
	DLL_EXPORT const bool	getUsingPrivacyInfo();
	DLL_EXPORT const char*	getSDKVersion();

	DLL_EXPORT void updateCallbacks();

	DLL_EXPORT bool initSDK();
	DLL_EXPORT void setTestMode();
	DLL_EXPORT void gameLaunched();
	
	DLL_EXPORT void getVersionInfo(Callbacks::OnGetVersionInfoSuccess success, Callbacks::OnFailure failure);

	DLL_EXPORT void tryAutoLogin(Callbacks::OnLoginSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void loginWithUserOnDeviceIdx(const char* idx, PatiAuthInfo auth, Callbacks::OnLoginSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void login(bool enableAutoLogin, PatiAuthInfo auth, Callbacks::OnLoginSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void loginCancelUnregister(PatiAuthInfo auth, Callbacks::OnLoginSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void switchingAnotherAccount(PatiAuthInfo auth, Callbacks::OnLoginSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void switchingAnotherAccountWithCancelUnregister(PatiAuthInfo auth, Callbacks::OnLoginSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void loginPlatformWithLoggedInAuth(PatiAuthType authType, Callbacks::OnPlatformLoginWithLoggedinAuthSuccess success, Callbacks::OnFailure);
	DLL_EXPORT void addAuth(PatiAuthInfo auth, Callbacks::OnAddAuthSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void addAuthWithLogoutOption(PatiAuthInfo auth, bool logoutOnFailure, Callbacks::OnAddAuthSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void signupPati(PatiAuthInfo auth, Callbacks::OnSignupPatiSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void logout(Callbacks::OnLogoutSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT bool clearLocalLoginInfo();
	DLL_EXPORT void unregister(const char* password, Callbacks::OnUnregisterSuccess success, Callbacks::OnFailure failure);

	DLL_EXPORT void selectChannel(int channelnum, Callbacks::OnSelectChannelSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void exitChannel(Callbacks::OnExitChannelSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void updateChannelSummary(int level, JsonString jsonSummary, bool forceOverwrite, Callbacks::OnUpdateChannelSummarySuccess success, Callbacks::OnFailure failure); 
	DLL_EXPORT int getCurrentChannelNumber();

	DLL_EXPORT void setExternalSessionCookie(const char* sessionCookie);
	DLL_EXPORT void migrateAutoLoginData(PatiAuthType authType);
	DLL_EXPORT bool removeGuestInfoPermanently();
	DLL_EXPORT void removeTermsPermanently();

	DLL_EXPORT bool isGuest();
	DLL_EXPORT bool isEnableAutoLogin();
	DLL_EXPORT bool isEnablePlatformService(PatiAuthType platformType);

	DLL_EXPORT int getLoggedInUserId();
	DLL_EXPORT PatiAuthType getLoggedInAuthType();
	DLL_EXPORT PlatformIdInfo getLoggedInPlatformId();
	DLL_EXPORT const char* getLoggedInGuestAuthData();

	DLL_EXPORT void getGifts(Callbacks::OnGetGiftsSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void consumeGift(int giftSN, Callbacks::OnConsumeGiftSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void useCoupon(const char* couponStr, Callbacks::OnUseCouponSuccess success, Callbacks::OnFailure failure);

	DLL_EXPORT void getCashBalance(Callbacks::OnGetCashBalanceSuccess success, Callbacks::OnFailure failure);

    DLL_EXPORT void getCashProducts(Callbacks::OnGetCashProductsSuccess success, Callbacks::OnPaymentFailure failure);
	DLL_EXPORT void setPurchaseCashCallback(Callbacks::OnPurchaseCashResult callback);
	DLL_EXPORT void purchaseCashProduct(const char* pid, Callbacks::OnPaymentFailure failure);

	DLL_EXPORT void getGameFriends(Callbacks::OnGetGameFriendsSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void requestGameFriend(long long fuid, Callbacks::OnFriendRelationSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void cancelGameFriend(long long fuid, Callbacks::OnFriendRelationSuccess success, Callbacks::OnFailure failure);

	DLL_EXPORT void searchGameUsersByNick(const char* nick, Callbacks::OnGetGameFriendsSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void changeNick(const char* nick, Callbacks::OnChangeNickSuccess success, Callbacks::OnFailure failure);

	DLL_EXPORT void forgotPassword(const char* email, Callbacks::OnForgotPasswordSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void changePassword(const char* curPassword, const char* newPassword, Callbacks::OnChangePasswordSuccess success, Callbacks::OnFailure failure);

	DLL_EXPORT void checkTerms(Callbacks::OnCheckTermsSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT bool agreeTerms();
	DLL_EXPORT void disagreeTerms();
	DLL_EXPORT bool isTermsAgreed();

	DLL_EXPORT bool isEnablePushService();
	DLL_EXPORT void enablePushService();
	DLL_EXPORT void disablePushService();
	DLL_EXPORT void setPushArrivedCallback(Callbacks::OnPushCallback callback);

	DLL_EXPORT void registerRemoteNotification();	// deprecated
	DLL_EXPORT void unregisterRemoteNotification();	// deprecated

	DLL_EXPORT bool setGameLanguage(const char* lang);

	DLL_EXPORT bool handleOpenURLScheme(std::string url, std::string sourceApplication);
	DLL_EXPORT JsonString getLaunchInfo();
	DLL_EXPORT void setLaunchInfo(std::string launchURL, std::string noti);
	DLL_EXPORT void removeLaunchInfo();

	DLL_EXPORT void openCSWebPage();
	DLL_EXPORT void openWebBrowser(const char* url);
	DLL_EXPORT void openWebView(const char* url);
	DLL_EXPORT void openWebViewDialog(const char* url, int width, int height);

	DLL_EXPORT void cacheNotice();
	DLL_EXPORT JsonString getNoticeInfoList();
	DLL_EXPORT bool showNoticeView(std::string placement, bool ignoreFrequency);

	DLL_EXPORT void uploadProfileInGallery(int width, int height, Callbacks::OnUploadProfileImageSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void uploadProfileByTakeshot(int width, int height, Callbacks::OnUploadProfileImageSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void rollbackProfileImage(Callbacks::OnRollbackProfileImageSuccess, Callbacks::OnFailure failure);
	DLL_EXPORT void getUsersProfile(JsonString userids, Callbacks::OnGetUsersProfileSuccess, Callbacks::OnFailure failure);

	DLL_EXPORT bool initKakao(const char* clientID, const char* clientSecret);
	DLL_EXPORT bool initKakao_v1(const char* clientID, const char* clientSecret);
	DLL_EXPORT void getKakaoFriends(Callbacks::OnGetKakaoFriendsSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void sendKakaoInvite(const char* receiver, const char* templateId, const char* nick, const char* params, 
		Callbacks::OnSendKakaoLinkMessageSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void sendKakaoMessageWithImage(const char* receiver, const char* msg, const char* imagePath, const char* templateId, 
		Callbacks::OnSendKakaoLinkMessageSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void sendKakaoTagMessageWithImage(JsonString jsonString, Callbacks::OnSendKakaoLinkMessageSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void sendKakaoLinkMessage(const char* receiver, const char* templateId, JsonString messageMetainfo, 
		Callbacks::OnSendKakaoLinkMessageSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void postKakaoStory(const char* imagePath, const char* message, Callbacks::OnPostKakaoStorySuccess success, Callbacks::OnFailure failure);
    DLL_EXPORT void showKakaoMessageBlockDialog(Callbacks::OnKakaoMessageConfigSuccess success, Callbacks::OnFailure failure);

	DLL_EXPORT bool initFacebook();
	DLL_EXPORT void getFacebookFriends(Callbacks::OnGetFacebookFriendsSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void sendFacebookRequestWithRequestDialog(JsonString params, const char* message, const char* title, Callbacks::OnSendFacebookRequestWithRequestDialogSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void postFacebookFeedWithFeedDialog(JsonString params, Callbacks::OnPostFacebookFeedWithFeedDialogSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT bool isFacebookGrantedPermission(const char* permissionName);
	DLL_EXPORT void getFacebookPermissions(Callbacks::OnGetFacebookPermissionsSuccess, Callbacks::OnFailure failure);
	DLL_EXPORT void reAskFacebookDeclinedPermission(const char* permissionName, Callbacks::OnReAskFacebookPermisssionSuccess, Callbacks::OnFailure failure);
	
	DLL_EXPORT bool initGooglePlus();
	
	DLL_EXPORT bool initNaver(const char* clientID, const char* clientSecret, const char* clientName, const char* redirectURL);

	DLL_EXPORT void followTwitterUser(long long user_id, Callbacks::OnTwitterSuccess success, Callbacks::OnFailure failure);
	DLL_EXPORT void showRelationshipTwitterUser(long long user_id, Callbacks::OnTwitterSuccess success, Callbacks::OnFailure failure);

	namespace MeRS
	{
		enum MessageType
		{
			PRIVATE,
			PUBLIC,
		};

		DLL_EXPORT void init(Callbacks::OnReceiveMessage receiver);
		DLL_EXPORT void joinPublicChannel(int channelNum);
		DLL_EXPORT void leavePublicChannel(int channelNum);
		DLL_EXPORT void sendMessage(MessageType msgType, const char* receiverID, const char* message);
		DLL_EXPORT void updateReceiver(Callbacks::OnReceiveMessage receiver);
	}
}

#endif
