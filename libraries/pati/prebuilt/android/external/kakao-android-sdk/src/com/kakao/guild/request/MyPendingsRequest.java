package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;

/**
 * Created by house.dr on 15. 10. 19..
 */
public class MyPendingsRequest extends ApiRequest {
    @Override
    public String getMethod() {
        return GET;
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION + GameServerProtocol.GET_GUILDS_ME_PATH;
        return baseUrl + GameServerProtocol.GET_GUILDS_PATH + GameServerProtocol.GET_GUILDS_PENDING_PATH;
    }
}
