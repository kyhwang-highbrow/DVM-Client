#ifndef __PATISDK_PUBLISHPLATFORM_H__
#define __PATISDK_PUBLISHPLATFORM_H__

#include <string>
#include <functional>
#include <map>
#include "PatiTypes.h"

#if TARGET_OS_IPHONE && __OBJC__
#import <Foundation/Foundation.h>
#endif

namespace PatiSDK
{
#ifdef _WIN32
	namespace Win32
	{
		DLL_EXPORT void setEncryptedClientData(const char*);
		DLL_EXPORT void setUsingPrivacyInfo(bool);
		DLL_EXPORT void setMarketName(const char*);
		DLL_EXPORT void setAppRevision(const char*);
		DLL_EXPORT void setPackageName(const char*);
		DLL_EXPORT void registerPushToken(const char*);

		DLL_EXPORT void enableMinidump();

#define	PREFERENCES_PATH_WORKING_DIR 0		// 작업 디렉토리
#define PREFERENCES_PATH_EXECUTABLE_PATH 1	// exe파일 위치
#define PREFERENCES_PATH_CUSTOM 2			// customPath 사용. 사용될 파일의 이름까지 적어야함. (상대 경로이면 작업디렉토리 기준)
		DLL_EXPORT void setPreferencesPath(int type, const char* customPath);
	}
#endif
#if TARGET_OS_IPHONE && __OBJC__
	namespace iOS
	{
		DLL_EXPORT void registerPushToken(NSData* deviceToken);
		DLL_EXPORT bool handleOpenURL(NSURL* url, NSString* sourceApplication, id annotation);
		DLL_EXPORT void didReceiveRemoteNotification(NSDictionary* userinfo);
	}
#endif
	
#define PATISDK_TARGET_ANDROID	1 << 0
#define PATISDK_TARGET_IOS		1 << 1
#define PATISDK_TARGET_WIN		1 << 2

	namespace PlatformDependencies
	{
		DLL_EXPORT bool isAndroid();
		DLL_EXPORT bool isIOS();
		DLL_EXPORT bool isWindows();

		DLL_EXPORT void switchOS(std::string os);

		DLL_EXPORT std::string getDeviceId();
		DLL_EXPORT std::string getOSName();
		DLL_EXPORT std::string getOSVersion();
		DLL_EXPORT std::string getDeviceModel();
		DLL_EXPORT std::string getMarketAccount();
		DLL_EXPORT std::string getPhoneNumber();
		DLL_EXPORT std::string getCountryCode();
		DLL_EXPORT std::string getMarketName();
		DLL_EXPORT std::string getPackageVersion();
		DLL_EXPORT std::string getPackageName();
		DLL_EXPORT std::string getCachedDir();
		DLL_EXPORT std::string getDeviceLanguage();

		DLL_EXPORT double getTimeOfDay();

		DLL_EXPORT bool initSDK();
		DLL_EXPORT std::string getClientData();
		DLL_EXPORT bool getUsingPrivacyInfo();

		DLL_EXPORT std::string getPushToken();
		DLL_EXPORT void registerRemoteNotification();
		DLL_EXPORT void unregisterRemoteNotification();
		
		// deprecated. instead use iOS::handleOpenURL
		DLL_EXPORT bool handleOpenURL(std::string url, std::string sourceApplication);

		typedef std::function<void (std::string, bool)> OnGetAdvertisementInfoSuccess;
		void getAdvertisementInfo(OnGetAdvertisementInfoSuccess success, Callbacks::OnFailure);

        typedef std::function<void (JsonString)> OnRetrieveCashProducts;
        void retrieveCashProducts(JsonString products, OnRetrieveCashProducts success, Callbacks::OnPaymentFailure failure);
		void setPurchaseResultCallback(Callbacks::OnPurchaseCashResult callback);
		void purchaseCashProducts(const char* pid, const char* serial, Callbacks::OnPaymentFailure failure);
		
		DLL_EXPORT bool initFacebook();
		typedef std::function<void (JsonString)> OnFacebookCallback;
		typedef std::function<void (JsonString, JsonString, JsonString)> OnFacebookGetFriends;
		void facebookLogin(OnFacebookCallback success, OnFacebookCallback failure);
		void facebookLogout();
		void facebookUnregister();
		void facebookGetFriends(OnFacebookGetFriends success, OnFacebookCallback failure);
		void facebookRequestWithRequestDialog(JsonString params, const char* message, const char* title, OnFacebookCallback success, OnFacebookCallback failure);
		void facebookFeedWithFeedDialog(JsonString params, OnFacebookCallback success, OnFacebookCallback failure);
		bool facebookIsGrantedPermission(const char* permissionName);
		void facebookGetPermissions(OnFacebookCallback success, OnFacebookCallback failure);
		void facebookReAskForDeclinedPermission(const char* permissionName, OnFacebookCallback success, OnFacebookCallback failure);

		DLL_EXPORT bool initKakao(const char* clientID, const char* clientSecret);
		DLL_EXPORT bool initKakao_v1(const char* clientID, const char* clientSecret);
		typedef std::function<void (JsonString)> OnKakaoCallback;
		void kakaoLogin(OnKakaoCallback success, OnKakaoCallback failure);
		void kakaoLogout(OnKakaoCallback success, OnKakaoCallback failure);
		void kakaoUnregister(OnKakaoCallback success, OnKakaoCallback failure);
		void kakaoGetFriends(OnKakaoCallback success, OnKakaoCallback failure);
		void kakaoSendInvite(const char* receiver, const char* templateId, const char* nick, const char* params, OnKakaoCallback success, OnKakaoCallback failure);
		void kakaoSendMessageWithImage(const char* receiver, const char* msg, const char* imagePath, const char* templateId, OnKakaoCallback success, OnKakaoCallback failure);
		void kakaoSendTagMessageWithImage(JsonString jsonString, OnKakaoCallback success, OnKakaoCallback failure);
		void kakaoSendLinkMessage(const char* receiverId, const char* templateId, JsonString messageMetainfo, OnKakaoCallback success, OnKakaoCallback failure);
		void postKakaoStory(const char* imagePath, const char* message, OnKakaoCallback success, OnKakaoCallback failure);
        void kakaoShowMessageBlockDialog(OnKakaoCallback success, OnKakaoCallback failure);

		DLL_EXPORT bool initGooglePlus();
		typedef std::function<void(JsonString)> OnGooglePlusCallback;
		void googplusLogin(OnGooglePlusCallback success, OnGooglePlusCallback failure);
		void googplusLogout(OnGooglePlusCallback success, OnGooglePlusCallback failure);
		void googplusUnregister(OnGooglePlusCallback success, OnGooglePlusCallback failure);

		DLL_EXPORT bool initNaver(const char* clientId, const char* clientSecret, const char* clientName, const char* callbackIntent);
		typedef std::function<void(JsonString)> OnNaverCallback;
		void naverLogin(OnNaverCallback success, OnNaverCallback failure);
		void naverLogout(OnNaverCallback success, OnNaverCallback failure);
		void naverUnregister(OnNaverCallback success, OnNaverCallback failure);

		enum WebViewOrientation
		{
			AUTO		= -1,

			LANDSCAPE	= 0,
			PORTRAIT	= 1,
		};
		void openWebBrowser(const char* url);
		void openWebView(const char* url, WebViewOrientation orientation, const char* postData = 0);
		void openWebViewDialog(const char* url, int width, int height, const char* postData = 0);

		typedef std::function<void (bool, std::string)> OnCropCallback;
		void cropImageInGallery(const char* outFilePath, int width, int height, OnCropCallback callback);
		void cropImageByTakeshot(const char* outFilePath, int width, int height, OnCropCallback callback);

		typedef std::function<void (JsonString)> OnReceiveMessage;
		void initializeMeRSService(int gameid, const char* uid, const char* token, OnReceiveMessage callback);
		void joinPubCh(int channel);
		void leavePubCh(int channel);
		void sendMsg(int msgType, const char* receiverID, const char* message);
		void setMsgCallback(OnReceiveMessage callback);

		void lockCallbackThread();
		void unlockCallbackThread();

		bool isExistsSessionStr();

		void showToastMessage(const char* fmt, ...);
		
		DLL_EXPORT void runAsync(std::function<void ()>);
		DLL_EXPORT void printLog(const char* fmt, ...);
		DLL_EXPORT void debugLog(const char* fmt, ...);
		DLL_EXPORT void devLog(const char* fmt, ...);
	}
}

#endif
