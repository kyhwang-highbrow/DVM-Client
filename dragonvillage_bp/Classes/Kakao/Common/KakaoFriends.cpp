//
// Created by Harvey on 2013. 11. 21..
//

#include "Kakao/Common/KakaoFriends.h"

KakaoFriends *KakaoFriends::instance = 0;

KakaoFriends *KakaoFriends::getInstance() {
    if ( instance == 0 ) instance = new KakaoFriends();
    return instance;
}

void KakaoFriends::setFriendsFromJSON(const rapidjson::Value &param) {
    const rapidjson::Value& appFriendsArray = param["app_friends_info"];
    for (rapidjson::SizeType i = 0; i < appFriendsArray.Size(); i++) {
        const rapidjson::Value& appFriend = appFriendsArray[i];
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        long long value = appFriend["user_id"].GetInt64();
        std::string number;
        std::stringstream strstream;
        strstream << value;
        strstream >> number;
        appFriends->setObject(new Friend(appFriend), number.c_str());
    #endif
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        appFriends->setObject(new Friend(appFriend), appFriend["user_id"].GetString());
    #endif
    }

    const rapidjson::Value& friendsArray = param["friends_info"];
    for (rapidjson::SizeType i = 0; i < friendsArray.Size(); i++) {
        const rapidjson::Value& aFriend = friendsArray[i];
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        long long value = aFriend["user_id"].GetInt64();
        std::string number;
        std::stringstream strstream;
        strstream << value;
        strstream >> number;
        friends->setObject(new Friend(aFriend), number.c_str());
        #endif
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        friends->setObject(new Friend(aFriend), aFriend["user_id"].GetString());
    #endif
    }
}


