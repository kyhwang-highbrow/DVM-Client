//
// Created by Harvey on 2013. 11. 8..
//


#include "cocos2d.h"
#include "Kakao/Plugins/KakaoNativeExtension.h"
#include "Kakao/Common/KakaoLocalUser.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include "document.h"

// @kakao
#define PACKAGE_NAME    "com/perplelab/hod/AppActivity"

using namespace rapidjson;
#endif

USING_NS_CC;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
jobject javaObj;
JniMethodInfo method;
#endif

KakaoNativeExtension *KakaoNativeExtension::instance = 0;

KakaoNativeExtension *KakaoNativeExtension::getInstance() {
    if (instance == 0) {
        instance = new KakaoNativeExtension();
    }

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

    // @kakao
    JniHelper::getMethodInfo(method, PACKAGE_NAME, "kakaoCocos2dxExtension", "(Ljava/lang/String;)V");

#endif

    return instance;
}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
extern "C" {

    // @kakao
	JNIEXPORT void JNICALL Java_com_perplelab_hod_AppActivity_initJNIBridge(JNIEnv *env, jobject jobj) {
        CCLog("initJNIBridge");
        javaObj = env->NewGlobalRef(jobj);
    }

    // @kakao
	JNIEXPORT void JNICALL Java_com_perplelab_hod_AppActivity_sendMessageBridge(JNIEnv *env, jobject jobj, jstring target, jstring method, jstring params) {
        const jbyte* methodV = (jbyte*)env->GetStringUTFChars(method, NULL);
        char* methodValue = (char *) methodV;
        const char* argv = env->GetStringUTFChars(params, NULL);
        CCLog("sendMessageBridge target: %s", methodValue);
        CCLog("sendMessageBridge : %s", argv);

        if (!std::strcmp(methodValue, "onKakaoResonseComplete")) {
            KakaoResponseHandler::onSuccessComplete(std::string(argv));
        } else {
            KakaoResponseHandler::onErrorComplete(std::string(argv));
        }
        return;
    }
}

void callVoidMethod(jstring stringArg) {
    method.env->CallVoidMethod(javaObj, method.methodID, stringArg);
    method.env->DeleteLocalRef(stringArg);
    method.env->DeleteLocalRef(method.classID);
}
#endif

void KakaoNativeExtension::runAction(char const *param) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    CCUserDefault::sharedUserDefault()->setStringForKey("kakaoCocos2dxExtension", param);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    jstring stringArg = method.env->NewStringUTF(param);
    callVoidMethod(stringArg);
#endif
}

void KakaoNativeExtension::init(std::function<void()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onInitComplete = _callback;
    KakaoResponseHandler::getInstance()->onInitErrorComplete = error_callback;
    std::string access_token = CCUserDefault::sharedUserDefault()->getStringForKey("access_token");
    std::string refresh_token = CCUserDefault::sharedUserDefault()->getStringForKey("refresh_token");
    CCLog("access_token : %s, refresh_token : %s", access_token.c_str(), refresh_token.c_str());
    const char *param;
    if (access_token.length()) {
        param = cocos2d::CCString::createWithFormat("{\"action\":\"Init\", \"access_token\":\"%s\", \"refresh_token\":\"%s\"}", access_token.c_str(), refresh_token.c_str())->getCString();
    } else {
        param = cocos2d::CCString::createWithFormat("{\"action\":\"Init\"}")->getCString();
    }

    runAction(param);
}

void KakaoNativeExtension::auth(std::function<void (bool)> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onAuthComplete = _callback;
    KakaoResponseHandler::getInstance()->onAuthErrorComplete = error_callback;

    const char *param;
    param = "{\"action\":\"Authorized\"}";

    runAction(param);
}

void KakaoNativeExtension::login(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onLoginComplete = _callback;
    KakaoResponseHandler::getInstance()->onLoginErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"Login\"}";

    runAction(param);
}

void KakaoNativeExtension::tokenListener(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onTokenComplete = _callback;
    KakaoResponseHandler::getInstance()->onTokenErrorComplete = error_callback;
}

void KakaoNativeExtension::logout(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onLogoutComplete = _callback;
    KakaoResponseHandler::getInstance()->onLogoutErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"Logout\"}";

    runAction(param);
}

void KakaoNativeExtension::localUser(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onLocalUserComplete = _callback;
    KakaoResponseHandler::getInstance()->onLocalUserErrorComplete = error_callback;
    const char *param;
    param = "{\"action\":\"LocalUser\"}";

    runAction(param);
}

void KakaoNativeExtension::unregister(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onUnregisterComplete = _callback;
    KakaoResponseHandler::getInstance()->onUnregisterErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"Unregister\"}";

    runAction(param);
}

void KakaoNativeExtension::friends(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onFriendsComplete = _callback;
    KakaoResponseHandler::getInstance()->onFriendsErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"Friends\"}";

    runAction(param);
}

void KakaoNativeExtension::sendLinkMessage(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::string templateId, std::string receiverId, std::string imageUrl, std::string executeUrl, std::string metaInfo) {
    KakaoResponseHandler::getInstance()->onSendLinkMessageComplete = _callback;
    KakaoResponseHandler::getInstance()->onSendLinkMessageErrorComplete = error_callback;
    const char *param;
    param = CCString::createWithFormat("{\"action\":\"SendLinkMessage\", \"templateId\":\"%s\", \"receiverId\":\"%s\", \"imageURL\":\"%s\", \"executeUrl\":\"%s\", \"metaInfo\":%s}", templateId.c_str(), receiverId.c_str(), imageUrl.c_str(), executeUrl.c_str(), metaInfo.c_str())->getCString();

    runAction(param);
}

void KakaoNativeExtension::showMessageBlockDialog(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onShowMessageBlockDialogComplete = _callback;
    KakaoResponseHandler::getInstance()->onShowMessageBlockDialogErrorComplete = error_callback;
    const char *param;
    param = "{\"action\":\"ShowMessageBlockDialog\"}";

    runAction(param);
}

void KakaoNativeExtension::postToKakaoStory(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::string message, std::string imageUrl, std::string executeUrl) {
    KakaoResponseHandler::getInstance()->onPostToKakaoStoryComplete = _callback;
    KakaoResponseHandler::getInstance()->onPostToKakaoStoryErrorComplete = error_callback;
    const char *param;
    param = CCString::createWithFormat("{\"action\":\"PostToKakaoStory\", \"message\":\"%s\", \"imageURL\":\"%s\", \"executeUrl\":\"%s\"}", message.c_str(), imageUrl.c_str(), executeUrl.c_str())->getCString();

    runAction(param);
}

void KakaoNativeExtension::loadGameInfo(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onLoadGameInfoComplete = _callback;
    KakaoResponseHandler::getInstance()->onLoadGameInfoErrorComplete = error_callback;
    const char *param;
    param = CCString::createWithFormat("{\"action\":\"LoadGameInfo\"}")->getCString();

    runAction(param);
}

void KakaoNativeExtension::loadGameUserInfo(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onLoadGameUserInfoComplete = _callback;
    KakaoResponseHandler::getInstance()->onLoadGameUserInfoErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"LoadGameUserInfo\"}";

    runAction(param);
}

void KakaoNativeExtension::updateUser(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, int addHeart, int currentHeart, std::string publicData, std::string privateData) {
    KakaoResponseHandler::getInstance()->onUpdateUserComplete = _callback;
    KakaoResponseHandler::getInstance()->onUpdateUserErrorComplete = error_callback;
    const char *param;
    param = CCString::createWithFormat("{\"action\":\"UpdateUser\", \"additionalHeart\":%d, \"currentHeart\":%d, \"public_data\":\"%s\", \"private_data\":\"%s\"}", addHeart, currentHeart, publicData.c_str(), privateData.c_str())->getCString();

    runAction(param);
}

void KakaoNativeExtension::useHeart(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, int heart_count) {
    KakaoResponseHandler::getInstance()->onUseHeartComplete = _callback;
    KakaoResponseHandler::getInstance()->onUseHeartErrorComplete = error_callback;
    const char *param;
    param = CCString::createWithFormat("{\"action\":\"UseHeart\", \"useHeart\":%d}", heart_count)->getCString();

    runAction(param);
}

void KakaoNativeExtension::updateResult(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::string leaderboardKey, long score, long exp, std::string publicData, std::string privateData) {
    KakaoResponseHandler::getInstance()->onUpdateResultComplete = _callback;
    KakaoResponseHandler::getInstance()->onUpdateResultErrorComplete = error_callback;
    const char *param;
    param = CCString::createWithFormat("{\"action\":\"UpdateResult\", \"leaderboardKey\":\"%s\", \"score\":%ld, \"exp\":%ld, \"public_data\":\"%s\", \"private_data\":\"%s\"}", leaderboardKey.c_str(), score, exp, publicData.c_str(), privateData.c_str())->getCString();

    runAction(param);
}

void KakaoNativeExtension::updateMultipleResults(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::map<std::string, long> leaderboards, long exp, std::string publicData, std::string privateData) {
    KakaoResponseHandler::getInstance()->onUpdateMultipleResultsComplete = _callback;
    KakaoResponseHandler::getInstance()->onUpdateMultipleResultsErrorComplete = error_callback;
    std::string params = "{";
    for (std::map<std::string, long>::iterator iter = leaderboards.begin(); iter != leaderboards.end(); ++iter) {
        std::string key = iter->first;
        long long value = iter->second;
        params.append("\"");
        params.append(key);
        params.append("\":");
        std::string number;
        std::stringstream strstream;
        strstream << value;
        strstream >> number;
        params.append(number);
        params.append(",");
    }
    params.pop_back();
    params.append("}");

    const char *param;
    param = CCString::createWithFormat("{\"action\":\"UpdateMultipleResults\", \"multipleLeaderboards\":%s, \"exp\":%ld, \"public_data\":\"%s\", \"private_data\":\"%s\"}", params.c_str(), exp, publicData.c_str(), privateData.c_str())->getCString();

    runAction(param);
}

void KakaoNativeExtension::loadLeaderBoard(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::string key) {
    KakaoResponseHandler::getInstance()->onLoadLeaderBoardComplete = _callback;
    KakaoResponseHandler::getInstance()->onLoadLeaderBoardErrorComplete = error_callback;
    const char *param;
    param = CCString::createWithFormat("{\"action\":\"LoadLeaderboard\", \"leaderboardKey\":\"%s\"}", key.c_str())->getCString();

    runAction(param);
}

void KakaoNativeExtension::loadGameFriends(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onLoadGameFriendsComplete = _callback;
    KakaoResponseHandler::getInstance()->onLoadGameFriendsErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"LoadGameFriends\"}";

    runAction(param);
}

void KakaoNativeExtension::sendLinkGameMessage(std::function<void()> _callback, std::function<void(char const *, char const *)> error_callback, std::string templateId, std::string receiverId, std::string gameMessage, int heart, std::string imageUrl, std::string executeUrl, std::string data, std::string metaInfo) {
    KakaoResponseHandler::getInstance()->onSendLinkGameMessageComplete = _callback;
    KakaoResponseHandler::getInstance()->onSendLinkGameMessageErrorComplete = error_callback;
    const char *param;
    param = CCString::createWithFormat("{\"action\":\"SendLinkGameMessage\", \"template_id\":\"%s\", \"receiver_id\":\"%s\", \"gameMessage\":\"%s\", \"heart\":\"%d\", \"imageURL\":\"%s\", \"executeUrl\":\"%s\", \"data\":\"%s\", \"metaInfo\":%s}", templateId.c_str(), receiverId.c_str(), gameMessage.c_str(), heart, imageUrl.c_str(), executeUrl.c_str(), data.c_str(), metaInfo.c_str())->getCString();

    runAction(param);
}

void KakaoNativeExtension::sendInviteLinkGameMessage(std::function<void()> _callback, std::function<void(char const *, char const *)> error_callback, std::string templateId, std::string receiverId, std::string executeUrl, std::string metaInfo) {
    KakaoResponseHandler::getInstance()->onSendInviteGameMessageComplete = _callback;
    KakaoResponseHandler::getInstance()->onSendInviteGameMessageErrorComplete = error_callback;
    const char *param;
    param = CCString::createWithFormat("{\"action\":\"SendInviteLinkGameMessage\", \"template_id\":\"%s\", \"receiver_id\":\"%s\", \"executeUrl\":\"%s\", \"metaInfo\":%s}", templateId.c_str(), receiverId.c_str(), executeUrl.c_str(), metaInfo.c_str())->getCString();

    runAction(param);
}

void KakaoNativeExtension::loadGameMessages(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onLoadGameMessagesComplete = _callback;
    KakaoResponseHandler::getInstance()->onLoadGameMessagesErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"LoadGameMessages\"}";

    runAction(param);
}

void KakaoNativeExtension::acceptGameMessage(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, std::string gameMessageId) {
    KakaoResponseHandler::getInstance()->onAcceptGameMessageComplete = _callback;
    KakaoResponseHandler::getInstance()->onAcceptGameMessageErrorComplete = error_callback;
    const char *param;
    param = CCString::createWithFormat("{\"action\":\"AcceptGameMessage\", \"message_id\":\"%s\"}", gameMessageId.c_str())->getCString();

    runAction(param);
}

void KakaoNativeExtension::acceptAllGameMessages(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onAcceptAllGameMessagesComplete = _callback;
    KakaoResponseHandler::getInstance()->onAcceptAllGameMessagesErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"AcceptAllGameMessages\"}";

    runAction(param);
}

void KakaoNativeExtension::blockGameMessage(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback, bool messageBlocked) {
    KakaoResponseHandler::getInstance()->onBlockGameMessagesComplete = _callback;
    KakaoResponseHandler::getInstance()->onBlockGameMessagesErrorComplete = error_callback;
    const char *param;
    param = CCString::createWithFormat("{\"action\":\"BlockMessage\", \"block\":\"%s\"}", messageBlocked ? "false" : "true")->getCString();

    runAction(param);
}

void KakaoNativeExtension::deleteUserInfo(std::function<void ()> _callback, std::function<void (char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onDeleteUserInfoComplete = _callback;
    KakaoResponseHandler::getInstance()->onDeleteUserInfoErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"DeleteUser\"}";

    runAction(param);
}

void KakaoNativeExtension::invitationEvent(std::function<void()> _callback, std::function<void(char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onInvitationEventComplete = _callback;
    KakaoResponseHandler::getInstance()->onInvitationEventErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"InvitationEvent\"}";

    runAction(param);
}

void KakaoNativeExtension::invitationStates(std::function<void()> _callback, std::function<void(char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onInvitationStatesComplete = _callback;
    KakaoResponseHandler::getInstance()->onInvitationStatesErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"InvitationStates\"}";

    runAction(param);
}

void KakaoNativeExtension::invitationHost(std::function<void()> _callback, std::function<void(char const*, char const*)> error_callback) {
    KakaoResponseHandler::getInstance()->onInvitationHostComplete = _callback;
    KakaoResponseHandler::getInstance()->onInvitationHostErrorComplete = error_callback;
    const char *param;
    param = "{\"action\": \"InvitationHost\"}";

    runAction(param);
}
