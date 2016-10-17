#ifndef __PATISDK_CALLBACKS_H__
#define __PATISDK_CALLBACKS_H__

#include <string>
#include <functional>

#ifdef _WIN32
#ifdef _DLL_EXPORT
#define DLL_EXPORT __declspec(dllexport)
#else
#define DLL_EXPORT __declspec(dllimport)
#endif
#else
#define DLL_EXPORT
#endif

namespace PatiSDK
{
	enum PatiAuthType
	{
		NONE = -1,

		GUEST,
		PATIFRIENDS,
		KAKAO,
		FACEBOOK,
		GOOGLEPLUS,
		NAVER,
		TWITTER,
	};

	class PatiAuthInfo
	{
	public:
		PatiAuthInfo() : 
			_authType(NONE),
			_uid(0),
			_cancelUnregister(false), 
			_switchingAccount(false),
			_guestAuthData(""),
			_patifriendsid(0),
			_kakaouid(0),
			_kakaogameid(0),
			_kakaoheader(""),
			_fbid(0),
			_profileUrl(""),
			_googleToken(""),
			_googleId(""),
			_googleProfileUrl(""),
			_googleAccount(""),
			_naverid(0),
			_naverTokenType(""),
			_naverAccessToken(""),
			_twitterId(0),
			_twitterAccessToken(""),
			_twitterSecretToken("")
		{
		}
		PatiAuthInfo(PatiAuthType type) :
			_authType(type),
			_uid(0),
			_cancelUnregister(false), 
			_switchingAccount(false),
			_guestAuthData(""),
			_patifriendsid(0),
			_kakaouid(0),
			_kakaogameid(0),
			_kakaoheader(""),
			_fbid(0),
			_profileUrl(""),
			_googleToken(""),
			_googleId(""),
			_googleProfileUrl(""),
			_googleAccount(""),
			_naverid(0),
			_naverTokenType(""),
			_naverAccessToken(""),
			_twitterId(0),
			_twitterAccessToken(""),
			_twitterSecretToken("")
		{
		}

		PatiAuthType getAuthType() const { return _authType; }
		bool isNull() const { return _authType == NONE; }

		void setUid(long long uid)
		{
			_uid = uid;
		}
		long long getUid()
		{
			return _uid;
		}

		PatiAuthInfo& setGuest()
		{
			_authType = GUEST;
			return *this;
		}
		PatiAuthInfo& setGuest(const char* guestAuthData)
		{
			setGuest();
			if (guestAuthData)
			{
				_guestAuthData = guestAuthData;
			}

			return *this;
		}

		PatiAuthInfo& setPati(const char* email, const char* password, const char* nickname = 0)
		{
			_authType = PATIFRIENDS;
			if (email)
				_email = email;
			if (password)
				_password = password;
			if (nickname)
				_nick = nickname;

			return *this;
		}
		
		PatiAuthInfo& setKakao()
		{
			_authType = KAKAO;
			return *this;
		}
		PatiAuthInfo& setKakao(long long user_id, const char* accessToken, const char* refreshToken, const char* profileUrl)
		{
			_authType = KAKAO;
			_kakaouid = user_id;
			_accessToken = accessToken;
            _refreshToken = refreshToken;
			_profileUrl = profileUrl;
			return *this;
		}
		PatiAuthInfo& setKakaoV2(long long user_id, long long user_game_id, const char* kakao_header, const char* accessToken, const char* profileUrl)
		{
			_authType = KAKAO;
			_kakaouid = user_id;
			_kakaogameid = user_game_id;
			_kakaoheader = kakao_header;
			_accessToken = accessToken;
			_profileUrl = profileUrl;
			return *this;
		}

		PatiAuthInfo& setFacebook()
		{
			_authType = FACEBOOK;
			return *this;
		}
		PatiAuthInfo& setFacebook(long long fbid, const char* accessToken)
		{
			_authType = FACEBOOK;
			_fbid = fbid;
			_accessToken = accessToken;
			return *this;
		}
		PatiAuthInfo& setFacebook(long long fbid, const char* accessToken, const char* profileUrl)
		{
			_authType = FACEBOOK;
			_fbid = fbid;
			_accessToken = accessToken;
			_profileUrl = profileUrl;
			return *this;
		}

		PatiAuthInfo& setGooglePlus()
		{
			_authType = GOOGLEPLUS;
			return *this;
		}
		PatiAuthInfo& setGooglePlus(const char* token, const char* id, const char* profileUrl = "", const char* account = "")
		{
			_authType = GOOGLEPLUS;
			_googleToken = token;
			_googleId = id;
			_googleProfileUrl = profileUrl;
			_googleAccount = account;
			return *this;
		}

		PatiAuthInfo& setNaver()
		{
			_authType = NAVER;
			return *this;
		}
		PatiAuthInfo& setNaver(long long nuid, const char* tokenType, const char* accessToken, const char* profileUrl)
		{
			_authType = NAVER;
			
			_naverid = nuid;
			_naverTokenType = tokenType;
			_naverAccessToken = accessToken;
			_profileUrl = profileUrl;
			return *this;
		}

		PatiAuthInfo& setTwitter()
		{
			_authType = TWITTER;
			return *this;
		}
		PatiAuthInfo& setTwitter(long long id, const char* accessToken, const char* secretToken)
		{
			_authType = TWITTER;

			_twitterId = id;
			_twitterAccessToken = accessToken;
			_twitterSecretToken = secretToken;
			return *this;
		}

		bool __isCancelUnregister() const { return _cancelUnregister; }
		bool __isSwitchingAccount() const { return _switchingAccount; }
		void __setCancelUnregister() { _cancelUnregister = true; }
		void __setSwitchingAccount() { _switchingAccount = true; }

	private:
		PatiAuthType _authType;
		long long _uid;

	public:
		// guest info
		std::string _guestAuthData;

		// pati info
		long long	_patifriendsid;
		std::string _email;
		std::string _password;
		std::string _nick;

		// kakao info
		long long	_kakaouid;
		long long	_kakaogameid;
		std::string _kakaoheader;
		// facebook info
		long long	_fbid;
		std::string _accessToken;
		std::string _refreshToken;
		std::string _profileUrl;
		// google+ info
		std::string _googleToken;
		std::string _googleId;
		std::string _googleProfileUrl;
		std::string _googleAccount;
		// naver info
		long long	_naverid;
		std::string _naverTokenType;
		std::string _naverAccessToken;
		// twitter info
		long long	_twitterId;
		std::string _twitterAccessToken;
		std::string _twitterSecretToken;

		// login desc
		bool	_cancelUnregister;
		bool	_switchingAccount;
	};

	class JsonString : public std::string
	{
	public:
		JsonString() : std::string() { }
		JsonString(std::string& str) : std::string(str) { }
		JsonString(std::string str) : std::string(str) { }
		JsonString(const char* str) : std::string(str) { }
		virtual ~JsonString() { }
	};

	namespace Callbacks
	{
		typedef std::function<void (int /*errorCode*/, std::string /*errorMsg*/, JsonString /*otherInfos*/)> OnFailure;

		typedef std::function<void (long long /*uid*/, int /*timestamp*/, std::string /*authToken*/, JsonString /*otherInfos*/)> OnLoginSuccess;
		typedef std::function<void (int /*uid*/, int /*timestamp*/, std::string /*authToken*/, JsonString /*otherInfos*/)> OnSignupPatiSuccess;
		typedef std::function<void ()> OnAddAuthSuccess;
		typedef std::function<void ()> OnLogoutSuccess;
		typedef std::function<void ()> OnUnregisterSuccess;
		typedef std::function<void ()> OnChangeNickSuccess;
		typedef std::function<void ()> OnForgotPasswordSuccess;
		typedef std::function<void ()> OnChangePasswordSuccess;
		typedef std::function<void (std::string /*termsOfService*/, std::string /*termsOfServiceLink*/, std::string /*privacyPolicy*/, std::string /*privacyPolicyLink*/)> OnCheckTermsSuccess;
		typedef std::function<void (JsonString /*friends*/)> OnGetGameFriendsSuccess;
		typedef std::function<void (int /*relation*/)> OnFriendRelationSuccess;
		typedef std::function<void ()> OnUseCouponSuccess;
		typedef std::function<void (JsonString /* gifts */)> OnGetGiftsSuccess;
		typedef std::function<void()> OnConsumeGiftSuccess;
		typedef std::function<void (std::string /* url */, std::string /* filePath */)> OnUploadProfileImageSuccess;
		typedef std::function<void (std::string /* url */)> OnRollbackProfileImageSuccess;
		typedef std::function<void (JsonString /* profileInfos */)> OnGetUsersProfileSuccess;
		typedef std::function<void ()> OnPlatformLoginWithLoggedinAuthSuccess;
		typedef std::function<void (bool /*isMaintenance*/, std::string /*maintenanceMsg*/, JsonString /*versionInfo*/)> OnGetVersionInfoSuccess;
		typedef std::function<void (bool /*needRefreshGiftbox*/, JsonString /*pushRawData*/)> OnPushCallback;

		// Channel Callbacks

		typedef std::function<void (JsonString /*infos*/)> OnSelectChannelSuccess;
		typedef std::function<void ()> OnExitChannelSuccess;
		typedef std::function<void ()> OnUpdateChannelSummarySuccess;

		// Payment Callbacks
		
		typedef std::function<void (int /* paid */, int /* bonus */, int /* free */)> OnGetCashBalanceSuccess;

		typedef std::function<void (std::string /*errorCode*/, std::string /*errorMsg*/, JsonString /*otherInfos*/)> OnPaymentFailure;
		typedef std::function<void (JsonString /*productlist*/)> OnGetCashProductsSuccess;
		typedef std::function<void (bool /*hasSuccess*/, JsonString /*otherInfos*/)> OnPurchaseCashResult;

		// Kakao Callbacks

		typedef std::function<void (JsonString /*appFriends*/, JsonString /*nonAppFriends*/)> OnGetKakaoFriendsSuccess;
		typedef std::function<void ()> OnSendKakaoLinkMessageSuccess;
		typedef std::function<void ()> OnPostKakaoStorySuccess;
        typedef std::function<void (bool /*enabled*/)> OnKakaoMessageConfigSuccess;

		// Facebook Callbacks
		
		typedef std::function<void (JsonString /*appFriends*/, JsonString /*nonAppFriends*/)> OnGetFacebookFriendsSuccess;
		typedef std::function<void (std::string)> OnSendFacebookRequestWithRequestDialogSuccess;
		typedef std::function<void (std::string)> OnPostFacebookFeedWithFeedDialogSuccess;
		typedef std::function<void ()> OnSendFacebookInviteSuccess;
		typedef std::function<void (JsonString /*permissions*/)> OnGetFacebookPermissionsSuccess;
		typedef std::function<void ()> OnReAskFacebookPermisssionSuccess;

		// Twitter Callbacks
		typedef std::function<void (JsonString)> OnTwitterSuccess;

		// Chat Callbacks
		typedef std::function<void (JsonString /*message*/)> OnReceiveMessage;
		typedef std::function<void (bool /*success*/, JsonString /*errorInfos*/)> OnJoinPublicChannel;
	}
}

#endif
