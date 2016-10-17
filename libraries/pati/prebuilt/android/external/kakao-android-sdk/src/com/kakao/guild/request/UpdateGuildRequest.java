package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;

import java.util.Map;

/**
 * Created by house.dr on 15. 8. 22..
 */
public class UpdateGuildRequest extends ApiRequest {
    private final Map<String, String> properties;
    private final String id;

    public UpdateGuildRequest(String id, Map<String, String> properties) {
        this.id = id;
        this.properties = properties;
    }

    @Override
    public String getMethod() {
        return "PUT";
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION + GameServerProtocol.GET_GUILDS_PATH;
        return baseUrl + "/" + id;
    }

    @Override
    public Map<String, String> getParams() {
        return properties;
    }
}
