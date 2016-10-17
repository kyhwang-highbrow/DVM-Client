//
// Created by Harvey on 2013. 12. 4..
//


#ifndef __GameInfo_H_
#define __GameInfo_H_

#include <string>
#include "document.h"

class GameInfo {
private:
    static GameInfo *instance;
    ~GameInfo() {}

public:
    static GameInfo* getInstance();

    std::string gameName;
    std::string nextScoreResetTime;
    std::string lastScoreResetTime;
    std::string minVersionForIos;
    std::string minVersionForAndroid;
    std::string currentVersionForIos;
    std::string currentVersionForAndroid;
    std::string seasonType;
    std::string notice;

    int maxHeart;
    int rechargeableHeart;
    int scoreResetHour;
    int scoreResetWday;
    int messageExpireDay;
    int messageLimit;
    int gameMessageInterval;
    int heartRegenInterval;

    long long invitationInterval;
    long long lastScoreResetTimestamp;
    long long nextScoreResetTimestamp;

    void setGameInfoFromJSON(const rapidjson::Value&);

    void clear() {
        gameName = "";
        nextScoreResetTime = "";
        lastScoreResetTime = "";
        minVersionForIos = "";
        minVersionForAndroid = "";
        currentVersionForIos = "";
        currentVersionForAndroid = "";
        seasonType = "";
        notice = "";

        maxHeart = 0;
        rechargeableHeart = 0;
        scoreResetHour = 0;
        scoreResetWday = 0;
        messageExpireDay = 0;
        messageLimit = 0;
        gameMessageInterval = 0;
        heartRegenInterval = 0;

        invitationInterval = 0;
        lastScoreResetTimestamp = 0;
        nextScoreResetTimestamp = 0;
    }
};


#endif //__GameInfo_H_
