//
// Created by Harvey on 2013. 11. 20..
//


#include "cocos2d.h"
#include "Kakao/Common/KakaoLocalUser.h"

USING_NS_CC;

KakaoLocalUser *KakaoLocalUser::instance = 0;

KakaoLocalUser *KakaoLocalUser::getInstance() {
    if ( instance == 0 ) instance = new KakaoLocalUser();
    return instance;
}

void KakaoLocalUser::setLocalUserFromJSON(const rapidjson::Value& json) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    long long value = json["user_id"].GetInt64();
    std::stringstream strstream;
    strstream << value;
    strstream >> userId;
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    userId = json["user_id"].GetString();
#endif
    nickName = json["nickname"].GetString();
    profileImageUrl = json["profile_image_url"].GetString();
    hashedTalkUserId = json["hashed_talk_user_id"].GetString();
    countryIso = json["country_iso"].GetString();
    messageBlocked = json["message_blocked"].GetBool();
    verified = json["verified"].GetBool();
}
