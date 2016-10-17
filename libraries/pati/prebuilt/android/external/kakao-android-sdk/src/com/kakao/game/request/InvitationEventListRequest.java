package com.kakao.game.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;

/**
 * Created by house.dr on 16. 2. 12..
 */
public class InvitationEventListRequest extends ApiRequest {
    @Override
    public String getMethod() {
        return GET;
    }

    @Override
    public String getUrl() {
        return "https://" + GameServerProtocol.GAME_API_AUTHORITY + GameServerProtocol.GET_COMMON_PATH +
                GameServerProtocol.API_VERSION + GameServerProtocol.GET_INVITATION_EVENTS_PATH;
    }
}
