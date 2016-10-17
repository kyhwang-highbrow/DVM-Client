//
// Created by Harvey on 2013. 12. 12..
//



#ifndef __KakaoGameMessage_H_
#define __KakaoGameMessage_H_


#include "cocos2d.h"
#include "document.h"

USING_NS_CC;

class KakaoGameMessages {
private:
    static  KakaoGameMessages *instance;
    ~KakaoGameMessages() {}

public:
    class GameMessage : public CCObject {
    public:
        std::string messageId;
        std::string senderId;
        std::string senderNickname;
        std::string senderProfileImageUrl;
        std::string data;
        std::string message;
        long long sentAt;

        GameMessage(const rapidjson::Value &json) {
            messageId = json["message_id"].GetString();
        #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
            long long value = json["sender_id"].GetInt64();
            std::stringstream strstream;
            strstream << value;
            senderId = strstream.str();
        #endif
        #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
            senderId = json["sender_id"].GetString();
        #endif
            senderNickname = json["sender_nickname"].GetString();
            senderProfileImageUrl = json["sender_profile_image_url"].GetString();
            data = json["data"].GetString();
            message = json["message"].GetString();
            sentAt = json["sent_at"].GetInt64();
        }
    };

    static KakaoGameMessages* getInstance();

    CCDictionary *gameMessages = new CCDictionary();

    void setGameMessagesFromJSON(const rapidjson::Value &json);

    void clear() {
        gameMessages->release();
        gameMessages = new CCDictionary();
    }
};


#endif //__KakaoGameMessage_H_
