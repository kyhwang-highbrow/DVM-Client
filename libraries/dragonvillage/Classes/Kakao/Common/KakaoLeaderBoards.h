//
// Created by Harvey on 2013. 12. 5..
//


#ifndef __KakaoLeaderBoards_H_
#define __KakaoLeaderBoards_H_

#include <string>
#include "cocos2d.h"
#include "document.h"

USING_NS_CC;

class KakaoLeaderBoards {
private:
    static KakaoLeaderBoards *instance;
    ~KakaoLeaderBoards() {}

public:
    class LeaderBoard : public CCObject {
    public:
        class Score : public CCObject {
        public:
            long bestScore;
            long seasonScore;
            long lastSeasonScore;

            Score(long _bestScore, long _seasonScore, long _lastSeasonScore) {
                bestScore = _bestScore;
                seasonScore = _seasonScore;
                lastSeasonScore = _lastSeasonScore;
            };
        };

        CCDictionary *scores = new CCDictionary();
        void setScore(std::string userId, long bestScore, long seasonScore, long lastScore) {
            if (scores->objectForKey(userId) != NULL) {
                scores->removeObjectForKey(userId);
            }
            scores->setObject(new Score(bestScore, seasonScore, lastScore), userId);
        }
    };

    static KakaoLeaderBoards* getInstance();

    int friendsCount;
    CCDictionary *leaderBoards = new CCDictionary();
    void setLeaderBoard(std::string key) {
        if (leaderBoards->objectForKey(key) == NULL) {
            LeaderBoard *leaderBoard = new LeaderBoard();
            leaderBoards->setObject(leaderBoard, key);
        }
    }

    void setLeaderBoardFromJSON(const rapidjson::Value &json);

    void clear() {
        friendsCount = 0;
        leaderBoards->release();
        leaderBoards = new CCDictionary();
    }
};


#endif //__KakaoLeaderBoards_H_
