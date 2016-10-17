package com.kakao.guild.response;

import com.kakao.auth.network.response.JSONArrayResponse;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;
import com.kakao.network.response.ResponseBodyArray.ArrayConverter;
import com.kakao.network.response.ResponseData;
import com.kakao.guild.response.model.GuildInfo;

import org.apache.http.HttpStatus;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.List;

/**
 * Created by house.dr on 15. 9. 10..
 */
public class MyGuildsResponse extends JSONArrayResponse {
    private final List<GuildInfo> guildInfoList;

    public MyGuildsResponse(ResponseData responseData) throws ResponseBodyException, ApiResponseStatusError {
        super(responseData);

        this.guildInfoList = bodyArray.getConvertedList(ARRAY_CONVERTER);
    }

    public List<GuildInfo> getGuildInfoList() {
        return guildInfoList;
    }

    public Boolean isJoinedGuild() {
        return getGuildInfoList().size() > 0;
    }

    public static final ArrayConverter<ResponseBody, GuildInfo> ARRAY_CONVERTER = new ArrayConverter<ResponseBody, GuildInfo>() {
        @Override
        public ResponseBody fromArray(JSONArray array, int i) throws ResponseBodyException {
            try {
                return new ResponseBody(HttpStatus.SC_OK, array.getJSONObject(i));
            } catch (JSONException e) {
                throw new ResponseBodyException("");
            }
        }

        @Override
        public GuildInfo convert(ResponseBody o) throws ResponseBodyException {
            return new GuildInfo(o);
        }
    };
}
