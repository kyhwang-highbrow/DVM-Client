//
// Created by Harvey on 2013. 11. 8..
//


#ifndef __KakaoNativeExtension_H_
#define __KakaoNativeExtension_H_

#include <map>
#include <functional>
#include "Kakao/Plugins/KakaoResponseHandler.h"


typedef enum {
    AppFriendsType,
    FriendsType
} friendsType;

class KakaoNativeExtension {
private:
    KakaoNativeExtension() {};
    ~KakaoNativeExtension() {};

    static KakaoNativeExtension* instance;

public:
    static KakaoNativeExtension* getInstance();

    void init(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void auth(std::function<void (bool)> _callback, std::function<void (char const*, char const*)> error_callback);

    void login(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void tokenListener(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void logout(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void localUser(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void unregister(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void friends(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void sendLinkMessage(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::string templateId, std::string receiverId, std::string imageUrl, std::string executeUrl, std::string metaInfo);

    void showMessageBlockDialog(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void postToKakaoStory(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::string message, std::string imageUrl, std::string executeUrl);

    void loadGameInfo(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void loadGameUserInfo(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void updateUser(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, int addHeart, int currentHeart, std::string publicData, std::string privateData);

    void useHeart(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, int heart_count);

    void updateResult(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::string leaderboardKey, long score, long exp, std::string publicData, std::string privateData);

    void updateMultipleResults(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::map<std::string, long> leaderboards, long exp, std::string publicData, std::string privateData);

    void loadLeaderBoard(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::string key);

    void loadGameFriends(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void sendLinkGameMessage(std::function<void()> _callback, std::function<void(char const *, char const *)> error_callback, std::string templateId, std::string receiverId, std::string gameMessage, int heart, std::string imageUrl, std::string executeUrl, std::string data, std::string metaInfo);

    void sendInviteLinkGameMessage(std::function<void()> _callback, std::function<void(char const *, char const *)> error_callback, std::string templateId, std::string receiverId, std::string executeUrl, std::string metaInfo);

    void loadGameMessages(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void acceptGameMessage(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::string gameMessageId);

    void acceptAllGameMessages(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void blockGameMessage(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, bool messageBlocked);

    void deleteUserInfo(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void invitationEvent(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void invitationStates(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void invitationHost(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback);

    void runAction(char const *param);
};


#endif //__KakaoNativeExtension_H_
