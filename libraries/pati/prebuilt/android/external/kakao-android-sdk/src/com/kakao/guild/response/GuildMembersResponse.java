package com.kakao.guild.response;

import com.kakao.auth.network.response.JSONArrayResponse;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBodyArray;
import com.kakao.network.response.ResponseData;
import com.kakao.guild.response.model.GuildMember;

import org.apache.http.HttpStatus;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.List;

/**
 * Created by house.dr on 15. 8. 22..
 */
public class GuildMembersResponse extends JSONArrayResponse {
    private final List<GuildMember> guildMemberList;

    public GuildMembersResponse(ResponseData responseData) throws ResponseBody.ResponseBodyException, ApiResponseStatusError {
        super(responseData);
        this.guildMemberList = bodyArray.getConvertedList(ARRAY_CONVERTER);
    }

    public List<GuildMember> getGuildMemberList() {
        return guildMemberList;
    }

    public static final ResponseBodyArray.ArrayConverter<ResponseBody, GuildMember> ARRAY_CONVERTER = new ResponseBodyArray.ArrayConverter<ResponseBody, GuildMember>() {

        @Override
        public ResponseBody fromArray(JSONArray array, int i) throws ResponseBody.ResponseBodyException {
            try {
                return new ResponseBody(HttpStatus.SC_OK, array.getJSONObject(i));
            } catch (JSONException e) {
                throw new ResponseBody.ResponseBodyException("");
            }
        }

        @Override
        public GuildMember convert(ResponseBody o) throws ResponseBody.ResponseBodyException {
            return new GuildMember(o);
        }
    };
}
