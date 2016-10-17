package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;

import java.util.Map;

/**
 * Created by house.dr on 15. 8. 22..
 */
public class CreateGuildRequest extends ApiRequest {
    private final Map<String, String> properties;

    public CreateGuildRequest(Map<String, String> properties) {
        this.properties = properties;
    }

    @Override
    public String getMethod() {
        return POST;
    }

    @Override
    public String getUrl() {
        return "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION + GameServerProtocol.GET_GUILDS_PATH;
    }

    @Override
    public Map<String, String> getParams() {
        return properties;
    }
}
