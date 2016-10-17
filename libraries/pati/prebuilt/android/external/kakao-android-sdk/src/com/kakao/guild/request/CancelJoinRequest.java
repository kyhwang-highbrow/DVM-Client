package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;

/**
 * Created by house.dr on 15. 9. 20..
 */
public class CancelJoinRequest extends ApiRequest {
    private final String id;

    public CancelJoinRequest(String id) {
        this.id = id;
    }

    @Override
    public String getMethod() {
        return DELETE;
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION
                + GameServerProtocol.GET_GUILDS_ME_PATH + GameServerProtocol.GET_GUILDS_PATH + GameServerProtocol.GET_GUILDS_PENDING_PATH;
        return baseUrl + "/" + id;
    }
}
