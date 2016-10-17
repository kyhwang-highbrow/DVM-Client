package com.kakao.guild.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.guild.StringSet;
import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.network.helper.QueryString;

/**
 * Created by house.dr on 15. 8. 22..
 */
public class GuildMembersRequest extends ApiRequest {
    private final String id;
    private final int offset;
    private final int limit;
    private final int joinStatus;

    public GuildMembersRequest(String id, int offset, int limit, int joinStatus) {
        this.id = id;
        this.offset = offset;
        this.limit = limit;
        this.joinStatus = joinStatus;
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
        qs.add(StringSet.join_status, String.valueOf(joinStatus));
        return baseUrl + "/" + id + GameServerProtocol.GET_GUILDS_MEMBERS_PATH + "?" + qs.toString();
    }
}
