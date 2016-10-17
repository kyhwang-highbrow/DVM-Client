//
// Created by Harvey on 2013. 11. 8..
//

#include "cocos2d.h"
#include "Kakao/Plugins/KakaoResponseHandler.h"
#include "document.h"
#include "Kakao/Common/KakaoLocalUser.h"
#include "Kakao/Common/KakaoFriends.h"
#include "Kakao/Common/GameInfo.h"
#include "Kakao/Common/GameUserInfo.h"
#include "Kakao/Common/KakaoLeaderBoards.h"
#include "Kakao/Common/GameFriends.h"
#include "Kakao/Common/KakaoGameMessages.h"
#include "Kakao/Common/InvitationTracking.h"

USING_NS_CC;

KakaoResponseHandler *KakaoResponseHandler::instance = 0;

KakaoResponseHandler *KakaoResponseHandler::getInstance() {
    if ( instance == 0 ) instance = new KakaoResponseHandler();
    return instance;
}

KakaoResponseHandler::KakaoResponseHandler() {

}

void KakaoResponseHandler::onSuccessComplete(const std::string &param) {
    CCLog("onSuccessComplete : %s", param.c_str());
    rapidjson::Document document;
    document.Parse<0>(param.c_str());
    if (document.HasMember("action")) {
        char const *action = document["action"].GetString();
        CCLog("action in : %s", document["action"].GetString());
        if (strcmp(action, "Init") == 0) {
            KakaoResponseHandler::getInstance()->onInitComplete();
        } else if (strcmp(action, "Authorized") == 0) {
            const rapidjson::Value& result = document["result"];
            bool isAuthed = false;
            if (strcmp(result["authorized"].GetString(), "true") == 0) {
                isAuthed = true;
            }

            KakaoResponseHandler::getInstance()->onAuthComplete(isAuthed);
        } else if (strcmp(action, "Login") == 0) {
            KakaoResponseHandler::getInstance()->onLoginComplete();
        } else if (strcmp(action, "Token") == 0) {
            const rapidjson::Value& result = document["result"];
            if (result.HasMember("access_token") && result.HasMember("refresh_token") && strcmp(result["access_token"].GetString(), "") != 0 && strcmp(result["refresh_token"].GetString(), "") != 0) {
                CCUserDefault::sharedUserDefault()->setStringForKey("access_token", result["access_token"].GetString());
                CCUserDefault::sharedUserDefault()->setStringForKey("refresh_token", result["refresh_token"].GetString());
            } else {
                CCUserDefault::sharedUserDefault()->setStringForKey("access_token", "");
                CCUserDefault::sharedUserDefault()->setStringForKey("refresh_token", "");
            }
            CCUserDefault::sharedUserDefault()->flush();

            KakaoResponseHandler::getInstance()->onTokenComplete();
        } else if (strcmp(action, "Logout") == 0) {
            KakaoResponseHandler::getInstance()->kakaoClear();
            KakaoResponseHandler::getInstance()->onLogoutComplete();
        } else if (strcmp(action, "LocalUser") == 0) {
            const rapidjson::Value &result = document["result"];
            KakaoLocalUser::getInstance()->setLocalUserFromJSON(result);
            KakaoResponseHandler::getInstance()->onLocalUserComplete();
        } else if (strcmp(action, "Unregister") == 0) {
            KakaoResponseHandler::getInstance()->kakaoClear();
            KakaoResponseHandler::getInstance()->onUnregisterComplete();
        } else if (strcmp(action, "Friends") == 0) {
            const rapidjson::Value& result = document["result"];
            KakaoFriends::getInstance()->setFriendsFromJSON(result);
            KakaoResponseHandler::getInstance()->onFriendsComplete();
        } else if (strcmp(action, "SendLinkMessage") == 0) {
            KakaoResponseHandler::getInstance()->onSendLinkMessageComplete();
        } else if (strcmp(action, "ShowMessageBlockDialog") == 0) {
            KakaoResponseHandler::getInstance()->onShowMessageBlockDialogComplete();
        } else if (strcmp(action, "PostToKakaoStory") == 0) {
            KakaoResponseHandler::getInstance()->onPostToKakaoStoryComplete();
        } else if (strcmp(action, "LoadGameInfo") == 0) {
            const rapidjson::Value& result = document["result"];
            GameInfo::getInstance()->setGameInfoFromJSON(result);
            KakaoResponseHandler::getInstance()->onLoadGameInfoComplete();
        } else if (strcmp(action, "LoadGameUserInfo") == 0) {
            const rapidjson::Value& result = document["result"];
            GameUserInfo::getInstance()->setGameUserInfoFromJSON(result);
            KakaoResponseHandler::getInstance()->onLoadGameUserInfoComplete();
        } else if (strcmp(action, "UpdateUser") == 0) {
            KakaoResponseHandler::getInstance()->onUpdateUserComplete();
        } else if (strcmp(action, "UseHeart") == 0) {
            KakaoResponseHandler::getInstance()->onUseHeartComplete();
        } else if (strcmp(action, "UpdateResult") == 0) {
            KakaoResponseHandler::getInstance()->onUpdateResultComplete();
        } else if (strcmp(action, "UpdateMultipleResults") == 0) {
            KakaoResponseHandler::getInstance()->onUpdateMultipleResultsComplete();
        } else if (strcmp(action, "LoadLeaderboard") == 0) {
            const rapidjson::Value& result = document["result"];
            KakaoLeaderBoards::getInstance()->setLeaderBoardFromJSON(result);
            KakaoResponseHandler::getInstance()->onLoadLeaderBoardComplete();
        } else if (strcmp(action, "LoadGameFriends") == 0) {
            const rapidjson::Value& result = document["result"];
            GameFriends::getInstance()->setGameFriendFromJSON(result);
            KakaoResponseHandler::getInstance()->onLoadGameFriendsComplete();
        } else if (strcmp(action, "SendLinkGameMessage") == 0) {
            const rapidjson::Value& result = document["result"];
            GameFriends::getInstance()->updateGameFriendsWithJSON(result);
            KakaoResponseHandler::getInstance()->onSendLinkGameMessageComplete();
        } else if (strcmp(action, "SendInviteLinkGameMessage") == 0) {
            const rapidjson::Value& result = document["result"];
            GameFriends::getInstance()->updateGameFriendsWithJSON(result);
            KakaoResponseHandler::getInstance()->onSendInviteGameMessageComplete();
        } else if (strcmp(action, "LoadGameMessages") == 0) {
            const rapidjson::Value& result = document["result"];
            KakaoGameMessages::getInstance()->setGameMessagesFromJSON(result);
            KakaoResponseHandler::getInstance()->onLoadGameMessagesComplete();
        } else if (strcmp(action, "AcceptGameMessage") == 0) {
            const rapidjson::Value& result = document["result"];
            KakaoGameMessages::getInstance()->gameMessages->removeObjectForKey(result["message_id"].GetString());
            KakaoResponseHandler::getInstance()->onAcceptGameMessageComplete();
        } else if (strcmp(action, "AcceptAllGameMessages") == 0) {
            KakaoResponseHandler::getInstance()->onAcceptAllGameMessagesComplete();
        } else if (strcmp(action, "BlockMessage") == 0) {
            GameUserInfo::getInstance()->messageBlocked = !GameUserInfo::getInstance()->messageBlocked;
            KakaoResponseHandler::getInstance()->onBlockGameMessagesComplete();
        } else if (strcmp(action, "DeleteUser") == 0) {
            KakaoResponseHandler::getInstance()->onDeleteUserInfoComplete();
        } else if (strcmp(action, "InvitationEvent") == 0) {
            const rapidjson::Value& result = document["result"];
            InvitationEvent::getInstance()->setInvitationEventFromJSON(result);
            KakaoResponseHandler::getInstance()->onInvitationEventComplete();
        } else if (strcmp(action, "InvitationStates") == 0) {
            const rapidjson::Value& result = document["result"];
            InvitationStates::getInstance()->setInvitationStatesFromJSON(result);
            KakaoResponseHandler::getInstance()->onInvitationStatesComplete();
        } else if (strcmp(action, "InvitationHost") == 0) {
            const rapidjson::Value& result = document["result"];
            InvitationHost::getInstance()->setInvitationHostFromJSON(result);
            KakaoResponseHandler::getInstance()->onInvitationHostComplete();
        }
    }
}

void KakaoResponseHandler::onErrorComplete(const std::string &param) {
    CCLog("onErrorComplete : %s", param.c_str());
    rapidjson::Document document;
    document.Parse<0>(param.c_str());
    if (document.HasMember("action")) {
        char const *action = document["action"].GetString();
        CCLog("action in : %s", document["action"].GetString());
        const rapidjson::Value& result = document["error"];
        char const *status;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        int value = result["status"].GetInt();
        std::stringstream strstream;
        strstream << value;
        std::string temp_str = strstream.str();
        status = temp_str.c_str();
    #endif
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        status = (char*)result["status"].GetString();
    #endif
        char const *error = result["message"].GetString();
        if (strcmp(action, "Init") == 0) {
            KakaoResponseHandler::getInstance()->onInitErrorComplete(status, error);
        } else if (strcmp(action, "Login") == 0) {
            KakaoResponseHandler::getInstance()->onLoginErrorComplete(status, error);
        } else if (strcmp(action, "Token") == 0) {
            KakaoResponseHandler::getInstance()->onTokenErrorComplete(status, error);
        } else if (strcmp(action, "Authorized") == 0) {
            KakaoResponseHandler::getInstance()->onAuthErrorComplete(status, error);
        } else if (strcmp(action, "Logout") == 0) {
            KakaoResponseHandler::getInstance()->onLogoutErrorComplete(status, error);
        } else if (strcmp(action, "LocalUser") == 0) {
            KakaoResponseHandler::getInstance()->onLocalUserErrorComplete(status, error);
        } else if (strcmp(action, "Unregister") == 0) {
            KakaoResponseHandler::getInstance()->onUnregisterErrorComplete(status, error);
        } else if (strcmp(action, "Friends") == 0) {
            KakaoResponseHandler::getInstance()->onFriendsErrorComplete(status, error);
        } else if (strcmp(action, "SendLinkMessage") == 0) {
            KakaoResponseHandler::getInstance()->onSendLinkMessageErrorComplete(status, error);
        } else if (strcmp(action, "ShowMessageBlockDialog") == 0) {
            KakaoResponseHandler::getInstance()->onShowMessageBlockDialogErrorComplete(status, error);
        } else if (strcmp(action, "PostToKakaoStory") == 0) {
            KakaoResponseHandler::getInstance()->onPostToKakaoStoryErrorComplete(status, error);
        } else if (strcmp(action, "LoadGameInfo") == 0) {
            KakaoResponseHandler::getInstance()->onLoadGameInfoErrorComplete(status, error);
        } else if (strcmp(action, "LoadGameUserInfo") == 0) {
            KakaoResponseHandler::getInstance()->onLoadGameUserInfoErrorComplete(status, error);
        } else if (strcmp(action, "UpdateUser") == 0) {
            KakaoResponseHandler::getInstance()->onUpdateUserErrorComplete(status, error);
        } else if (strcmp(action, "UseHeart") == 0) {
            KakaoResponseHandler::getInstance()->onUseHeartErrorComplete(status, error);
        } else if (strcmp(action, "UpdateResult") == 0) {
            KakaoResponseHandler::getInstance()->onUpdateResultErrorComplete(status, error);
        } else if (strcmp(action, "UpdateMultipleResults") == 0) {
            KakaoResponseHandler::getInstance()->onUpdateMultipleResultsErrorComplete(status, error);
        } else if (strcmp(action, "LoadLeaderboard") == 0) {
            KakaoResponseHandler::getInstance()->onLoadLeaderBoardErrorComplete(status, error);
        } else if (strcmp(action, "LoadGameFriends") == 0) {
            KakaoResponseHandler::getInstance()->onLoadGameFriendsErrorComplete(status, error);
        } else if (strcmp(action, "SendLinkGameMessage") == 0) {
            KakaoResponseHandler::getInstance()->onSendLinkGameMessageErrorComplete(status, error);
        } else if (strcmp(action, "SendInviteLinkGameMessage") == 0) {
            KakaoResponseHandler::getInstance()->onSendInviteGameMessageErrorComplete(status, error);
        } else if (strcmp(action, "LoadGameMessages") == 0) {
            KakaoResponseHandler::getInstance()->onLoadGameMessagesErrorComplete(status, error);
        } else if (strcmp(action, "AcceptGameMessage") == 0) {
            KakaoResponseHandler::getInstance()->onAcceptGameMessageErrorComplete(status, error);
        } else if (strcmp(action, "AcceptAllGameMessages") == 0) {
            KakaoResponseHandler::getInstance()->onAcceptAllGameMessagesErrorComplete(status, error);
        } else if (strcmp(action, "BlockMessage") == 0) {
            KakaoResponseHandler::getInstance()->onBlockGameMessagesErrorComplete(status, error);
        } else if (strcmp(action, "DeleteUser") == 0) {
            KakaoResponseHandler::getInstance()->onDeleteUserInfoErrorComplete(status, error);
        } else if (strcmp(action, "InvitationEvent") == 0) {
            KakaoResponseHandler::getInstance()->onInvitationEventErrorComplete(status, error);
        } else if (strcmp(action, "InvitationStates") == 0) {
            KakaoResponseHandler::getInstance()->onInvitationStatesErrorComplete(status, error);
        } else if (strcmp(action, "InvitationHost") == 0) {
            KakaoResponseHandler::getInstance()->onInvitationHostErrorComplete(status, error);
        }
    }
}

void KakaoResponseHandler::kakaoClear() {
    KakaoLocalUser::getInstance()->clear();
    KakaoLeaderBoards::getInstance()->clear();
    KakaoGameMessages::getInstance()->clear();
    KakaoFriends::getInstance()->clear();
    GameUserInfo::getInstance()->clear();
    GameInfo::getInstance()->clear();
    GameFriends::getInstance()->clear();
}