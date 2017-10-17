//
// Created by Harvey on 2013. 12. 12..
//


#include "Kakao/Common/KakaoGameMessages.h"

KakaoGameMessages *KakaoGameMessages::instance = 0;

KakaoGameMessages *KakaoGameMessages::getInstance() {
    if ( instance == 0 ) instance = new KakaoGameMessages();
    return instance;
}

void KakaoGameMessages::setGameMessagesFromJSON(const rapidjson::Value &json) {
    gameMessages->removeAllObjects();

    const rapidjson::Value& messages = json["messages"];
    for (rapidjson::SizeType i = 0; i < messages.Size(); i++) {
        const rapidjson::Value& message = messages[i];
        GameMessage *gameMessage = new GameMessage(message);
        gameMessages->setObject(gameMessage, gameMessage->messageId);
    }
}
