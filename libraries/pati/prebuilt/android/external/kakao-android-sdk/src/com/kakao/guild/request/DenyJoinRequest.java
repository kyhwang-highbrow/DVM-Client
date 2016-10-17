package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;

/**
 * Created by house.dr on 15. 9. 20..
 */
public class DenyJoinRequest extends ApiRequest {
    private final String id;
    private final String memberId;

    public DenyJoinRequest(String id, String memberId) {
        this.id = id;
        this.memberId = memberId;
    }

    @Override
    public String getMethod() {
        return POST;
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION + GameServerProtocol.GET_GUILDS_PATH;
        return baseUrl + "/" + id + GameServerProtocol.GET_GUILDS_MEMBERS_PATH + "/" + memberId + GameServerProtocol.GET_GUILDS_DENY_PATH;
    }
}
