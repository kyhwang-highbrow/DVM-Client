//
// Created by Harvey on 2013. 12. 4..
//


#include "Kakao/Common/GameInfo.h"
#include "Kakao/Common/KakaoLeaderBoards.h"

GameInfo *GameInfo::instance = 0;

GameInfo *GameInfo::getInstance() {
    if ( instance == 0 ) instance = new GameInfo();
    return instance;
}

void GameInfo::setGameInfoFromJSON(const rapidjson::Value &json) {
    gameName = json["name"].GetString();
    nextScoreResetTime = json["next_score_reset_time"].GetString();
    lastScoreResetTime = json["last_score_reset_time"].GetString();
    minVersionForIos = json["min_version_for_ios"].GetString();
    minVersionForAndroid = json["min_version_for_android"].GetString();
    currentVersionForIos = json["current_version_for_ios"].GetString();
    currentVersionForAndroid = json["current_version_for_android"].GetString();
    seasonType = json["season_type"].GetString();
    notice = json["notice"].GetString();

    maxHeart = json["max_heart"].GetInt();
    rechargeableHeart = json["rechargeable_heart"].GetInt();
    scoreResetHour = json["score_reset_hour"].GetInt();
    scoreResetWday = json["score_reset_wday"].GetInt();
    messageExpireDay = json["message_expire_day"].GetInt();
    messageLimit = json["message_limit"].GetInt();
    gameMessageInterval = json["game_message_interval"].GetInt();
    heartRegenInterval = json["heart_regen_interval"].GetInt();

    invitationInterval = json["invitation_interval"].GetInt64();
    lastScoreResetTimestamp = json["last_score_reset_timestamp"].GetInt64();
    nextScoreResetTimestamp = json["next_score_reset_timestamp"].GetInt64();

    const rapidjson::Value& leaderboardArray = json["leaderboards"];
    for (rapidjson::SizeType i = 0; i < leaderboardArray.Size(); ++i) {
        const rapidjson::Value& leaderBoard = leaderboardArray[i];
        KakaoLeaderBoards::getInstance()->setLeaderBoard(leaderBoard["key"].GetString());
    }
}
