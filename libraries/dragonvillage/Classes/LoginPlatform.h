#ifndef __LOGIN_PLATFORM_H__
#define __LOGIN_PLATFORM_H__


#define LOGIN_PLATFORM_PATISDK  1
#define LOGIN_PLATFORM_PPSDK    2
#define LOGIN_PLATFORM_GAMECENTER 3

// @patisdk
#define LOGIN_PLATFORM  0

// @ppsdk
//#define LOGIN_PLATFORM  LOGIN_PLATFORM_PPSDK

// @gameCenter
//#define LOGIN_PLATFORM  LOGIN_PLATFORM_GAMECENTER

// @kakao
//#define USE_KAKAO
//#define KAKAO_LOGIN_PATI

#ifndef USE_KAKAO

// @google+
#define USE_GOOGLEPLAY
#define GOOGLEPLAY_LOGIN_PATI

// @facebook
#define USE_FACEBOOK
#define FACEBOOK_LOGIN_PATI

#endif

#if (LOGIN_PLATFORM == LOGIN_PLATFORM_PPSDK)

#ifdef USE_KAKAO
#undef USE_KAKAO
#endif

#ifdef USE_GOOGLEPLAY
#undef USE_GOOGLEPLAY
#endif

#ifdef USE_FACEBOOK
#undef USE_FACEBOOK
#endif

// @umeng
#define USE_UMENG

#elif (LOGIN_PLATFORM == LOGIN_PLATFORM_GAMECENTER)

#ifdef USE_KAKAO
#undef USE_KAKAO
#endif

#ifdef USE_GOOGLEPLAY
#undef USE_GOOGLEPLAY
#endif

#ifdef USE_FACEBOOK
#undef USE_FACEBOOK
#endif

// @umeng
#define USE_UMENG

// @stroe kit
#define USE_BILLING

#elif (LOGIN_PLATFORM == LOGIN_PLATFORM_PATISDK)

// @moloco
#define USE_MOLOCO

// @partytrack
#define USE_PARTYTRACK

#else
#endif


#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
// @shipping build
#define SHIPPING_BUILD
#endif


#endif