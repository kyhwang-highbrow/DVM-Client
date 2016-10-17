package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.guild.StringSet;
import com.kakao.network.helper.QueryString;

/**
 * Created by house.dr on 15. 9. 19..
 */
public class SearchGuildRequest extends ApiRequest {
    private String query;
    private int offset;
    private int limit;

    public SearchGuildRequest(String query, int offset, int limit) {
        this.query = query;
        this.offset = offset;
        this.limit = limit;
    }

    @Override
    public String getMethod() {
        return GET;
    }

    @Override
    public String getUrl() {
        String baseUrl = "https://" + GameServerProtocol.GAME_GUILD_API_AUTHORITY + GameServerProtocol.API_VERSION +
                GameServerProtocol.GET_GUILDS_PATH + GameServerProtocol.GET_GUILDS_SEARCH_PATH;
        QueryString qs = new QueryString();
        qs.add(StringSet.query, query);
        qs.add(StringSet.offset, String.valueOf(offset));
        qs.add(StringSet.limit, String.valueOf(limit));
        return baseUrl  + "?" + qs.toString();
    }
}
