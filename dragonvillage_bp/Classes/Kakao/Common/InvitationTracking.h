//
// Created by House on 14. 10. 27..
//


#ifndef __InvitationTracking_H_
#define __InvitationTracking_H_

#include "cocos2d.h"
#include "document.h"

USING_NS_CC;

class InvitationEvent {
private:
    static InvitationEvent *instance;
    ~InvitationEvent() {}

public:
    static InvitationEvent* getInstance();

    std::string eventId;
    int maxSenderRewardCount;
    std::string eventStartsAt;
    std::string eventEndsAt;
    std::string senderRewardCode;
    std::string receiverRewardCode;
    std::string invitationUrl;
    int totalReveiversCount;

    void setInvitationEventFromJSON(const rapidjson::Value&);

    void clear() {
        eventId = "";
        maxSenderRewardCount = 0;
        eventStartsAt = "";
        eventEndsAt = "";
        senderRewardCode = "";
        receiverRewardCode = "";
        invitationUrl = "";
        totalReveiversCount = 0;
    }
};

class InvitationStates {
private:
    static InvitationStates *instance;
    ~InvitationStates() {}

public:
    class State : public CCObject {
    public:
        std::string registeredUserId;
        std::string profileImageUrl;
        std::string nickName;
        std::string senderRewardState;
        std::string receiverRewardState;
        std::string senderReward;
        std::string createdAt;

        State(const rapidjson::Value &json) {
//            registeredUserId = json["user_id"].
//        #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
            long long value = json["user_id"].GetInt64();
            std::stringstream strstream;
            strstream << value;
            strstream >> registeredUserId;
//        #endif
//        #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//            registeredUserId = json["user_id"].GetString();
//        #endif
            profileImageUrl = json["profile_image_url"].GetString();
            nickName = json["nickname"].GetString();
            senderRewardState = json["sender_reward_state"].GetString();
            receiverRewardState = json["receiver_reward_state"].GetString();
            senderReward = json["sender_reward"].GetString();
            createdAt = json["created_at"].GetString();
        }
    };

    static InvitationStates* getInstance();

    CCDictionary *invitationStates = new CCDictionary();

    void setInvitationStatesFromJSON(const rapidjson::Value &json);

    void clear() {
        invitationStates->release();
        invitationStates = new CCDictionary();
    }
};

class InvitationHost {
private:
    static InvitationHost *instance;
    ~InvitationHost() {}

public:
    static InvitationHost* getInstance();

    std::string eventId;
    std::string receiverRewardCode;
    std::string invitaionUrl;
    std::string hostUserId;
    std::string hostProfileImageUrl;
    std::string hostNickName;
    int totalRegisterdUserFromHost;

    void setInvitationHostFromJSON(const rapidjson::Value&);

    void clear() {
        eventId = "";
        receiverRewardCode = "";
        invitaionUrl = "";
        hostUserId = "";
        hostProfileImageUrl = "";
        hostNickName = "";
        totalRegisterdUserFromHost = 0;
    }
};
#endif //__InvitationTracking_H_
