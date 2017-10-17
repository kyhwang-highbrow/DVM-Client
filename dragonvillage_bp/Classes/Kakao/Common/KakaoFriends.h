//
// Created by Harvey on 2013. 11. 21..
//


#ifndef __KakaoFriends_H_
#define __KakaoFriends_H_

#include <string>
#include "document.h"
#include "cocos2d.h"

USING_NS_CC;

class KakaoFriends {

private:
    static KakaoFriends *instance;
    ~KakaoFriends() {}

public:
    class Friend : public CCObject {
    public:
        std::string hashedTalkUserId;
        std::string nickname;
        std::string friendNickname;
        std::string profileImageUrl;
        bool messageBlocked;
        bool supportedDevice;

        Friend(const rapidjson::Value& json) {
            hashedTalkUserId = json["hashed_talk_user_id"].GetString();
            nickname = json["nickname"].GetString();
            friendNickname = json["friend_nickname"].GetString();
            profileImageUrl = json["profile_image_url"].GetString();
            messageBlocked = json["message_blocked"].GetBool();
            if (json.HasMember("supported_device")) {
                supportedDevice = json["supported_device"].GetBool();
            }
        }
    };

    static KakaoFriends* getInstance();
    CCDictionary *appFriends = new CCDictionary();
    CCDictionary *friends = new CCDictionary();
    void setFriendsFromJSON(const rapidjson::Value&);

    bool isFriends() {
        if (appFriends->count() == 0 && friends->count() == 0) {
            return false;
        } else {
            return true;
        }
    }

    void clear() {
        appFriends->release();
        friends->release();
        appFriends = new CCDictionary();
        friends = new CCDictionary();
    }
};


#endif //__KakaoFriends_H_
