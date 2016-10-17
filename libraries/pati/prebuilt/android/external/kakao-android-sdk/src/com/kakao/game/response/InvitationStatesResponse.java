package com.kakao.game.response;

import com.kakao.auth.network.response.JSONObjectResponse;
import com.kakao.game.StringSet;
import com.kakao.game.response.model.InvitationState;
import com.kakao.gameutil.helper.BodyParser;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;
import com.kakao.network.response.ResponseBodyArray;
import com.kakao.network.response.ResponseData;

import org.apache.http.HttpStatus;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.List;

/**
 * Created by house.dr on 16. 2. 13..
 */
public class InvitationStatesResponse extends JSONObjectResponse {
    private final Integer totalCount;
    private final List<InvitationState> invitationStates;

    public InvitationStatesResponse(ResponseData responseData) throws ResponseBodyException, ApiResponseStatusError {
        super(responseData);
        this.totalCount = BodyParser.optInteger(body, StringSet.total_count);
        ResponseBodyArray responseInvitationStates = body.getArray(StringSet.invitation_states);
        this.invitationStates = responseInvitationStates.getConvertedList(ARRAY_CONVERTER);
    }

    public Integer getTotalCount() {
        return totalCount;
    }

    public List<InvitationState> getInvitationStates() {
        return invitationStates;
    }

    public static final ResponseBodyArray.ArrayConverter<ResponseBody, InvitationState> ARRAY_CONVERTER = new ResponseBodyArray.ArrayConverter<ResponseBody, InvitationState>() {
        @Override
        public ResponseBody fromArray(JSONArray array, int i) throws ResponseBodyException {
            try {
                return new ResponseBody(HttpStatus.SC_OK, array.getJSONObject(i));
            } catch (JSONException e) {
                throw new ResponseBody.ResponseBodyException("");
            }
        }

        @Override
        public InvitationState convert(ResponseBody o) throws ResponseBodyException {
            return new InvitationState(o);
        }
    };
}
