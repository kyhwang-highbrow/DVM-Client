//
// Created by Harvey on 2013. 11. 8..
//



#ifndef __KakaoResponseHandler_H_
#define __KakaoResponseHandler_H_


class KakaoResponseHandler {
private:
    KakaoResponseHandler();
    ~KakaoResponseHandler() {};

    static KakaoResponseHandler* instance;

public:
    static KakaoResponseHandler* getInstance();
    std::function<void()> onInitComplete;
    std::function<void(char const*, char const*)> onInitErrorComplete;
    std::function<void(bool)> onAuthComplete;
    std::function<void(char const*, char const*)> onAuthErrorComplete;
    std::function<void()> onLoginComplete;
    std::function<void(char const*, char const*)> onLoginErrorComplete;
    std::function<void()> onTokenComplete;
    std::function<void(char const*, char const*)> onTokenErrorComplete;
    std::function<void()> onLogoutComplete;
    std::function<void(char const*, char const*)> onLogoutErrorComplete;
    std::function<void()> onLocalUserComplete;
    std::function<void(char const*, char const*)> onLocalUserErrorComplete;
    std::function<void()> onUnregisterComplete;
    std::function<void(char const*, char const*)> onUnregisterErrorComplete;
    std::function<void()> onFriendsComplete;
    std::function<void(char const*, char const*)> onFriendsErrorComplete;
    std::function<void()> onSendLinkMessageComplete;
    std::function<void(char const*, char const*)> onSendLinkMessageErrorComplete;
    std::function<void()> onShowMessageBlockDialogComplete;
    std::function<void(char const*, char const*)> onShowMessageBlockDialogErrorComplete;
    std::function<void()> onPostToKakaoStoryComplete;
    std::function<void(char const*, char const*)> onPostToKakaoStoryErrorComplete;
    std::function<void()> onLoadGameInfoComplete;
    std::function<void(char const*, char const*)> onLoadGameInfoErrorComplete;
    std::function<void()> onLoadGameUserInfoComplete;
    std::function<void(char const*, char const*)> onLoadGameUserInfoErrorComplete;
    std::function<void()> onUpdateUserComplete;
    std::function<void(char const*, char const*)> onUpdateUserErrorComplete;
    std::function<void()> onUseHeartComplete;
    std::function<void(char const*, char const*)> onUseHeartErrorComplete;
    std::function<void()> onUpdateResultComplete;
    std::function<void(char const*, char const*)> onUpdateResultErrorComplete;
    std::function<void()> onUpdateMultipleResultsComplete;
    std::function<void(char const*, char const*)> onUpdateMultipleResultsErrorComplete;
    std::function<void()> onLoadLeaderBoardComplete;
    std::function<void(char const*, char const*)> onLoadLeaderBoardErrorComplete;
    std::function<void()> onLoadGameFriendsComplete;
    std::function<void(char const*, char const*)> onLoadGameFriendsErrorComplete;
    std::function<void()> onSendLinkGameMessageComplete;
    std::function<void(char const*, char const*)> onSendLinkGameMessageErrorComplete;
    std::function<void()> onSendInviteGameMessageComplete;
    std::function<void(char const*, char const*)> onSendInviteGameMessageErrorComplete;
    std::function<void()> onLoadGameMessagesComplete;
    std::function<void(char const*, char const*)> onLoadGameMessagesErrorComplete;
    std::function<void()> onAcceptGameMessageComplete;
    std::function<void(char const*, char const*)> onAcceptGameMessageErrorComplete;
    std::function<void()> onAcceptAllGameMessagesComplete;
    std::function<void(char const*, char const*)> onAcceptAllGameMessagesErrorComplete;
    std::function<void()> onBlockGameMessagesComplete;
    std::function<void(char const*, char const*)> onBlockGameMessagesErrorComplete;
    std::function<void()> onDeleteUserInfoComplete;
    std::function<void(char const*, char const*)> onDeleteUserInfoErrorComplete;
    std::function<void()> onInvitationEventComplete;
    std::function<void(char const*, char const*)> onInvitationEventErrorComplete;
    std::function<void()> onInvitationStatesComplete;
    std::function<void(char const*, char const*)> onInvitationStatesErrorComplete;
    std::function<void()> onInvitationHostComplete;
    std::function<void(char const*, char const*)> onInvitationHostErrorComplete;
    static void onSuccessComplete(const std::string &param);
    static void onErrorComplete(const std::string &param);

    void kakaoClear();
};


#endif //__KakaoResponseHandler_H_
