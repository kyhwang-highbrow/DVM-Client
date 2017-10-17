//
// Created by Harvey on 2013. 12. 5..
//


#include "Kakao/Common/GameUserInfo.h"

GameUserInfo *GameUserInfo::instance = 0;

GameUserInfo *GameUserInfo::getInstance() {
    if ( instance == 0 ) instance = new GameUserInfo();
    return instance;
}

void GameUserInfo::setGameUserInfoFromJSON(const rapidjson::Value &json) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    long long value = json["user_id"].GetInt64();
    std::stringstream strstream;
    strstream << value;
    strstream >> userId;
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    userId = json["user_id"].GetString();
#endif
    nickname = json["nickname"].GetString();
    profileImageUrl = json["profile_image_url"].GetString();
    messageBlocked = json["message_blocked"].GetBool();
    exp = json["exp"].GetInt64();
    heart = json["heart"].GetInt();
    messageCount = json["message_count"].GetInt();
    heartRegenStartsAt = json["heart_regen_starts_at"].GetInt64();
    privateData = json["private_data"].GetString();
    publicData = json["public_data"].GetString();
    server_time = json["server_time"].GetInt64();

    scores->removeAllObjects();
    const rapidjson::Value& scoreArray = json["scores"];
    for (rapidjson::SizeType i = 0; i < scoreArray.Size(); i++) {
        const rapidjson::Value& score = scoreArray[i];
        scores->addObject(new GameUserInfo::Score(score));
    }
}
