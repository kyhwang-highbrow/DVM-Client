package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.guild.StringSet;
import com.kakao.network.helper.QueryString;

/**
 * Created by house.dr on 15. 9. 19..
 */
public class PrivateSearchGuildRequest extends ApiRequest {
    String name;

    public PrivateSearchGuildRequest(String name) {
        this.name = name;
    }

    @Override
    public String getMethod() {
        return GET;
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION +
                GameServerProtocol.GET_GUILDS_PATH + GameServerProtocol.GET_GUILDS_PRIVATE + GameServerProtocol.GET_GUILDS_SEARCH_PATH;
        QueryString qs = new QueryString();
        qs.add(StringSet.name, name);
        return baseUrl + "?" + qs.toString();
    }
}
