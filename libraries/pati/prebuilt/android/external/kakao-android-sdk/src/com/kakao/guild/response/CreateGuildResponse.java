package com.kakao.guild.response;

import com.kakao.auth.network.response.JSONObjectResponse;
import com.kakao.network.response.ResponseBody.ResponseBodyException;
import com.kakao.network.response.ResponseData;
import com.kakao.guild.StringSet;

/**
 * Created by house.dr on 15. 8. 22..
 */
public class CreateGuildResponse extends JSONObjectResponse {
    private String guildId;

    public CreateGuildResponse(ResponseData responseData) throws ResponseBodyException, ApiResponseStatusError {
        super(responseData);

        this.guildId = body.optString(StringSet.guild_id, null);
    }

    public String getGuildId() {
        return this.guildId;
    }
}
