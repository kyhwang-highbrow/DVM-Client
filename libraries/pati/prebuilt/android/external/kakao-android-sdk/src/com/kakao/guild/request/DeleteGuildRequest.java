package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;

/**
 * Created by house.dr on 15. 8. 22..
 */
public class DeleteGuildRequest extends ApiRequest {
    private final String id;

    public DeleteGuildRequest(String id) {
        this.id = id;
    }

    @Override
    public String getMethod() {
        return DELETE;
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION + GameServerProtocol.GET_GUILDS_PATH;
        return baseUrl + "/" + id;
    }
}
