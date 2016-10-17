//
// Created by Harvey on 2013. 12. 5..
//


#ifndef __GameUserInfo_H_
#define __GameUserInfo_H_

#include <string>
#include "document.h"
#include "cocos2d.h"

USING_NS_CC;

class GameUserInfo {
private:
    static GameUserInfo *instance;
    ~GameUserInfo() {}

public:
    static GameUserInfo* getInstance();

    std::string userId = "";
    std::string nickname;
    std::string profileImageUrl;
    bool messageBlocked;
    long long exp;
    int heart;
    int messageCount;
    long long heartRegenStartsAt;
    std::string privateData;
    std::string publicData;
    long long server_time;

    class Score : public CCObject {
    public:
        std::string leaderBoardKey;
        long long seasonScore;
        long long lastSeasonScore;
        long long bestScore;

        Score(const rapidjson::Value& score) {
            leaderBoardKey = score["leaderboard_key"].GetString();
            seasonScore = score["season_score"].GetInt64();
            lastSeasonScore = score["last_season_score"].GetInt64();
            bestScore = score["best_score"].GetInt64();
        };
    };

    CCArray* scores = new CCArray();

    void setGameUserInfoFromJSON(const rapidjson::Value&);

    bool hasGameUserInfo() {
        return std::strcmp(userId.c_str(), "") != 0;
    }

    void clear() {
        userId = "";
        nickname = "";
        profileImageUrl = "";
        privateData = "";
        publicData = "";
        messageBlocked = false;
        exp = 0;
        heart = 0;
        messageCount = 0;
        heartRegenStartsAt = 0;
        scores->release();
        scores = new CCArray();
        server_time = 0;
    }
};


#endif //__GameUserInfo_H_
