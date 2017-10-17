//
// Created by Harvey on 2013. 12. 5..
//


#include "Kakao/Common/KakaoLeaderBoards.h"

KakaoLeaderBoards *KakaoLeaderBoards::instance = 0;

KakaoLeaderBoards *KakaoLeaderBoards::getInstance() {
    if ( instance == 0 ) instance = new KakaoLeaderBoards();
    return instance;
}

void KakaoLeaderBoards::setLeaderBoardFromJSON(const rapidjson::Value &json) {
    friendsCount = json["friends_count"].GetInt();
    std::string leaderboardKey = json["leaderboardKey"].GetString();
    LeaderBoard *leaderBoard = static_cast<LeaderBoard*>(leaderBoards->objectForKey(leaderboardKey));
    if (leaderBoard == NULL) {
        leaderBoard = new LeaderBoard();
    }
    const rapidjson::Value& scoreArray = json["app_friends"];
    for (rapidjson::SizeType i = 0; i < scoreArray.Size(); i++) {
        const rapidjson::Value& score = scoreArray[i];
        std::ostringstream ss;
        ss << score["user_id"].GetInt64();
        leaderBoard->setScore(ss.rdbuf()->str(), score["best_score"].GetInt64(), score["season_score"].GetInt64(), score["last_season_score"].GetInt64());
    }

    leaderBoards->setObject(leaderBoard, leaderboardKey);
}
