//
// Created by House on 14. 10. 27..
//

#include "InvitationTracking.h"

InvitationEvent *InvitationEvent::instance = 0;


InvitationEvent *InvitationEvent::getInstance() {
    if ( instance == 0 ) instance = new InvitationEvent();
    return instance;
}

void InvitationEvent::setInvitationEventFromJSON(const rapidjson::Value& json) {
    const rapidjson::Value &event = json["invitation_event"];
    if (!event.HasMember("id")) {
        return;
    }

//    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
//        eventId = event["id"].GetInt64();
    long long value = event["id"].GetInt64();
    std::stringstream strstream;
    strstream << value;
    strstream >> eventId;
//    #endif
//    #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//        eventId = event["id"].GetString();
//    #endif
    maxSenderRewardCount = event["max_sender_rewards_count"].GetInt();
    eventStartsAt = event["starts_at"].GetString();
    eventEndsAt = event["ends_at"].GetString();
    senderRewardCode = event["sender_reward"].GetString();
    receiverRewardCode = event["receiver_reward"].GetString();
    const rapidjson::Value &invitation_sender = event["invitation_sender"];
    invitationUrl = invitation_sender["invitation_url"].GetString();
    totalReveiversCount = invitation_sender["total_receivers_count"].GetInt();
}

InvitationStates* InvitationStates::instance = 0;

InvitationStates* InvitationStates::getInstance() {
    if (instance == 0) instance = new InvitationStates();
    return instance;
}

void InvitationStates::setInvitationStatesFromJSON(const rapidjson::Value &json) {
    invitationStates->removeAllObjects();

    const rapidjson::Value& states = json["invitation_states"];
    for (rapidjson::SizeType i = 0; i < states.Size(); i++) {
        const rapidjson::Value&stateJSON = states[i];
        State *state = new State(stateJSON);
        invitationStates->setObject(state, state->registeredUserId);
    }
}

InvitationHost* InvitationHost::instance  =0;

InvitationHost* InvitationHost::getInstance() {
    if (instance == 0) instance = new InvitationHost();
    return instance;
}

void InvitationHost::setInvitationHostFromJSON(const rapidjson::Value &json) {
    const rapidjson::Value &invitationSender = json["invitation_sender"];
    if (!invitationSender.HasMember("user_id")) {
         return;
    }
    const rapidjson::Value &event = json["invitation_event"];

    long long value = event["id"].GetInt64();
    std::stringstream strstream;
    strstream << value;
    strstream >> eventId;

    receiverRewardCode = event["receiver_reward"].GetString();
    invitaionUrl = invitationSender["invitation_url"].GetString();

    long long userId = invitationSender["user_id"].GetInt64();
    std::stringstream aStrstream;
    aStrstream << userId;
    aStrstream >> hostUserId;

    hostProfileImageUrl = invitationSender["profile_image_url"].GetString();
    hostNickName = invitationSender["nickname"].GetString();
    totalRegisterdUserFromHost = invitationSender["total_receivers_count"].GetInt();
}
