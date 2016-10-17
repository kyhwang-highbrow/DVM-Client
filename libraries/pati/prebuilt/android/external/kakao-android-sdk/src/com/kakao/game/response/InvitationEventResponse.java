package com.kakao.game.response;

import com.kakao.auth.network.response.JSONObjectResponse;
import com.kakao.game.StringSet;
import com.kakao.game.response.model.InvitationEvent;
import com.kakao.network.response.ResponseBody.ResponseBodyException;
import com.kakao.network.response.ResponseData;

/**
 * Created by house.dr on 16. 2. 12..
 */
public class InvitationEventResponse extends JSONObjectResponse {
    private final InvitationEvent invitationEvent;

    public InvitationEventResponse(ResponseData responseData) throws ResponseBodyException, ApiResponseStatusError {
        super(responseData);
        this.invitationEvent = new InvitationEvent(body.optBody(StringSet.invitation_event, null));
    }

    public InvitationEvent getInvitationEvent() {
        return invitationEvent;
    }
}
