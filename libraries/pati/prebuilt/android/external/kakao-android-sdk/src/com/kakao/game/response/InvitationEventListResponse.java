package com.kakao.game.response;

import com.kakao.auth.network.response.JSONObjectResponse;
import com.kakao.game.StringSet;
import com.kakao.game.response.model.InvitationEvent;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;
import com.kakao.network.response.ResponseBodyArray;
import com.kakao.network.response.ResponseBodyArray.ArrayConverter;
import com.kakao.network.response.ResponseData;

import org.apache.http.HttpStatus;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.List;

/**
 * Created by house.dr on 16. 2. 2..
 */
public class InvitationEventListResponse extends JSONObjectResponse {
    private final List<InvitationEvent> invitationEventList;

    public InvitationEventListResponse(ResponseData responseData) throws ResponseBodyException, ApiResponseStatusError {
        super(responseData);
        ResponseBodyArray responseInvitationEvents = body.getArray(StringSet.invitation_events);
        this.invitationEventList = responseInvitationEvents.getConvertedList(ARRAY_CONVERTER);
    }

    public List<InvitationEvent> getInvitationEventList() {
        return invitationEventList;
    }

    public static final ArrayConverter<ResponseBody, InvitationEvent> ARRAY_CONVERTER = new ArrayConverter<ResponseBody, InvitationEvent>() {
        @Override
        public ResponseBody fromArray(JSONArray array, int i) throws ResponseBodyException {
            try {
                return new ResponseBody(HttpStatus.SC_OK, array.getJSONObject(i));
            } catch (JSONException e) {
                throw new ResponseBodyException("");
            }
        }

        @Override
        public InvitationEvent convert(ResponseBody o) throws ResponseBodyException {
            return new InvitationEvent(o);
        }
    };
}
