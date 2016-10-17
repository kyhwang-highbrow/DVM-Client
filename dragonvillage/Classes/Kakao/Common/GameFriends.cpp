//
// Created by Harvey on 2013. 12. 11..
//


#include "Kakao/Common/GameFriends.h"

GameFriends *GameFriends::instance = 0;

GameFriends *GameFriends::getInstance() {
    if ( instance == 0 ) instance = new GameFriends();
    return instance;
}

void GameFriends::setGameFriendFromJSON(const rapidjson::Value &json) {
    const rapidjson::Value &leaderboardFriendArray = json["app_friends"];
    for (rapidjson::SizeType i = 0; i < leaderboardFriendArray.Size(); ++i) {
        const rapidjson::Value &lFriend = leaderboardFriendArray[i];
        LeaderBoardFriend *leaderboardFriend = new LeaderBoardFriend(lFriend);
        leaderboardFriends->setObject(leaderboardFriend, leaderboardFriend->userId);
    }

    const rapidjson::Value &kakaotalkFriendArray = json["friends"];
    for (rapidjson::SizeType i = 0; i < kakaotalkFriendArray.Size(); ++i) {
        const rapidjson::Value &kFriend = kakaotalkFriendArray[i];
        KakaotalkFriend *kakaotalkFriend = new KakaotalkFriend(kFriend);
        kakaotalkFriends->setObject(kakaotalkFriend, kakaotalkFriend->userId);
    }
}

void GameFriends::updateGameFriendsWithJSON(const rapidjson::Value &json) {
    std::string receiverId = json["receiver_id"].GetString();

    if (leaderboardFriends->objectForKey(receiverId)) {
        LeaderBoardFriend *lFriend = static_cast<LeaderBoardFriend*>(leaderboardFriends->objectForKey(receiverId));
        lFriend->lastMessageSentAt = json["message_sent_at"].GetInt64();
        leaderboardFriends->setObject(lFriend, receiverId);
        return;
    }

    if (kakaotalkFriends->objectForKey(receiverId)) {
        KakaotalkFriend *kFriend = static_cast<KakaotalkFriend*>(kakaotalkFriends->objectForKey(receiverId));
        kFriend->lastMessageSentAt = json["message_sent_at"].GetInt64();
        kakaotalkFriends->setObject(kFriend, receiverId);
        return;
    }
}

bool GameFriends::hasGameFriends() {
    return leaderboardFriends->count() != 0 || kakaotalkFriends->count() != 0;
}
