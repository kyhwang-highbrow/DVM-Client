//
// Created by Harvey on 2013. 12. 11..
//



#ifndef __GameFriends_H_
#define __GameFriends_H_

#include "cocos2d.h"
#include "document.h"

USING_NS_CC;


class GameFriends {
private:
    static GameFriends *instance;
    ~GameFriends() {}

public:
    class LeaderBoardFriend : public CCObject {
    public:
        std::string nickname;
        std::string friendNickname;
        std::string userId;
        std::string profileImageUrl;
        std::string publicData;
        bool messageBlocked;
        int rank;
        long long exp;
        long long lastMessageSentAt;
        long long bestScore;
        long long seasonScore;
        long long lastSeasonScore;

        LeaderBoardFriend(const rapidjson::Value &json) {
            nickname = json["nickname"].GetString();
            friendNickname = json["friend_nickname"].GetString();
        #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
            long long value = json["user_id"].GetInt64();
            std::stringstream strstream;
            strstream << value;
            strstream >> userId;
        #endif
        #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
            userId = json["user_id"].GetString();
        #endif
            profileImageUrl = json["profile_image_url"].GetString();
            publicData = json["public_data"].GetString();
            messageBlocked = json["message_blocked"].GetBool();
            rank = json["rank"].GetInt();
            exp = json["exp"].GetInt64();
            if( json["last_message_sent_at"].IsString() ) {
                std::string str = json["last_message_sent_at"].GetString();
                lastMessageSentAt = strtoll(str.c_str(), NULL, 10 );
            } else {
                lastMessageSentAt = json["last_message_sent_at"].GetInt64();
            }
            bestScore = json["best_score"].GetInt64();
            seasonScore = json["season_score"].GetInt64();
            lastSeasonScore = json["last_season_score"].GetInt64();
        }
    };

    class KakaotalkFriend : public CCObject {
    public:
        std::string nickname;
        std::string friendNickname;
        std::string userId;
        std::string profileImageUrl;
        bool messageBlocked;
        bool supportedDevice;
        long long lastMessageSentAt;

        KakaotalkFriend(const rapidjson::Value &json) {
            nickname = json["nickname"].GetString();
            friendNickname = json["friend_nickname"].GetString();
        #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
            long long value = json["user_id"].GetInt64();
            std::stringstream strstream;
            strstream << value;
            strstream >> userId;
        #endif
        #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
            userId = json["user_id"].GetString();
        #endif
            profileImageUrl = json["profile_image_url"].GetString();
            messageBlocked = json["message_blocked"].GetBool();
            supportedDevice = strcmp(json["supported_device"].GetString(), "true") == 0;
            lastMessageSentAt = json["last_message_sent_at"].GetInt64();
        };
    };

    static GameFriends* getInstance();

    CCDictionary *leaderboardFriends = new CCDictionary();
    CCDictionary *kakaotalkFriends = new CCDictionary();

    void setGameFriendFromJSON(const rapidjson::Value &json);

    void updateGameFriendsWithJSON(const rapidjson::Value &json);

    bool hasGameFriends();

    void clear() {
        leaderboardFriends->release();
        leaderboardFriends = new CCDictionary();
        kakaotalkFriends->release();
        kakaotalkFriends = new CCDictionary();
    }
};


#endif //__GameFriends_H_
