package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.guild.StringSet;
import com.kakao.gameutil.helper.GameServerProtocol;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by house.dr on 15. 10. 21..
 */
public class ChangeLeaderRequest extends ApiRequest {
    private final String id;
    private final String memberId;

    public ChangeLeaderRequest(String id, String memberId) {
        this.id = id;
        this.memberId = memberId;
    }

    @Override
    public String getMethod() {
        return "PUT";
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION + GameServerProtocol.GET_GUILDS_PATH;
        return baseUrl + "/" + id + GameServerProtocol.GET_LEADER_PATH;
    }

    @Override
    public Map<String, String> getParams() {
        Map<String, String> params = new HashMap<String, String>();
        params.put(StringSet.user_id, memberId);
        return params;
    }
}
