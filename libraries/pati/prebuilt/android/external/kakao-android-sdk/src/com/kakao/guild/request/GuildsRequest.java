package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.guild.StringSet;
import com.kakao.network.helper.QueryString;

/**
 * Created by house.dr on 15. 8. 21..
 */
public class GuildsRequest extends ApiRequest {
    private final int offset;
    private final int limit;

    public GuildsRequest(int offset, int limit) {
        this.offset = offset;
        this.limit = limit;
    }

    @Override
    public String getMethod() {
        return GET;
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION + GameServerProtocol.GET_GUILDS_PATH;
        QueryString qs = new QueryString();
        qs.add(StringSet.offset, String.valueOf(offset));
        qs.add(StringSet.limit, String.valueOf(limit));
        return baseUrl + "?" + qs.toString();
    }
}
