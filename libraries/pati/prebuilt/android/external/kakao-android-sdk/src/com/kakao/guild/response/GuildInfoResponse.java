package com.kakao.guild.response;

import com.kakao.auth.network.response.JSONObjectResponse;
import com.kakao.network.response.ResponseBody.ResponseBodyException;
import com.kakao.network.response.ResponseData;
import com.kakao.guild.response.model.GuildInfo;

/**
 * Created by house.dr on 15. 8. 22..
 */
public class GuildInfoResponse extends JSONObjectResponse {
    private final GuildInfo guildInfo;

    public GuildInfoResponse(ResponseData responseData) throws ResponseBodyException, ApiResponseStatusError {
        super(responseData);
        this.guildInfo = new GuildInfo(body);
    }

    public GuildInfo getGuildInfo() {
        return guildInfo;
    }
}
