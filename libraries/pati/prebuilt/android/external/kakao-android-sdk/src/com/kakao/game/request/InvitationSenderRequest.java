package com.kakao.game.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;

/**
 * Created by house.dr on 16. 2. 13..
 */
public class InvitationSenderRequest extends ApiRequest {
    private final int id;

    public InvitationSenderRequest(int id) {
        this.id = id;
    }
    @Override
    public String getMethod() {
        return GET;
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_API_AUTHORITY + GameServerProtocol.GET_COMMON_PATH +
                GameServerProtocol.API_VERSION + GameServerProtocol.GET_INVITATION_EVENTS_PATH;
        return baseUrl + "/" + id + GameServerProtocol.GET_INVITATION_SENDER_PATH;
    }
}
