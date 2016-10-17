//
// Created by Harvey on 2013. 11. 20..
//


#ifndef __KakaoLocalUser_H_
#define __KakaoLocalUser_H_

#include <string>
#include "document.h"


class KakaoLocalUser {
private:
    static KakaoLocalUser *instance;
    ~KakaoLocalUser() {}

public:
    static KakaoLocalUser* getInstance();

    std::string userId;
    std::string nickName;
    std::string profileImageUrl;
    std::string hashedTalkUserId;
    std::string countryIso;
    bool messageBlocked;
    bool verified;

    void setLocalUserFromJSON(const rapidjson::Value&);

    void clear() {
        userId = "";
        nickName = "";
        profileImageUrl = "";
        hashedTalkUserId = "";
        countryIso = "";
        messageBlocked = false;
        verified = false;
    }
};


#endif //__KakaoLocalUser_H_
