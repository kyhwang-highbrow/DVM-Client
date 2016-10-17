package com.kakao.guild.response;

import com.kakao.auth.network.response.JSONObjectResponse;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;
import com.kakao.network.response.ResponseBodyArray;
import com.kakao.network.response.ResponseBodyArray.ArrayConverter;
import com.kakao.network.response.ResponseData;
import com.kakao.guild.StringSet;
import com.kakao.guild.response.model.GuildInfo;

import org.apache.http.HttpStatus;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.List;

/**
 * Created by house.dr on 15. 8. 21..
 */
public class GuildsResponse extends JSONObjectResponse {
    private final int totalCount;
    private final List<GuildInfo> guildInfoList;

    public GuildsResponse(ResponseData responseData) throws ResponseBodyException, ApiResponseStatusError {
        super(responseData);

        this.totalCount = body.getInt(StringSet.total_count);
        ResponseBodyArray responseGroups = body.getArray(StringSet.groups);
        this.guildInfoList = responseGroups.getConvertedList(ARRAY_CONVERTER);
    }

    public int getTotalCount() {
        return totalCount;
    }

    public List<GuildInfo> getGuildInfoList() {
        return guildInfoList;
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
