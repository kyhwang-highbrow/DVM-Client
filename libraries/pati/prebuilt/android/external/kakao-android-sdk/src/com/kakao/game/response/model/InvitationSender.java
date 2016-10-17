package com.kakao.game.response.model;

import com.kakao.game.StringSet;
import com.kakao.gameutil.helper.BodyParser;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;

/**
 * Created by house.dr on 16. 2. 12..
 */
public class InvitationSender {
    private final Integer invitationEventId;
    private final String invitationUrl;
    private final Long userId;
    private final String profileImageUrl;
    private final String nickname;
    private final Integer totalReceiversCount;

    public InvitationSender(ResponseBody body) throws ResponseBodyException {
        ResponseBody invitationEvent = body.optBody(StringSet.invitation_event, null);
        invitationEventId = BodyParser.optInteger(invitationEvent, StringSet.id);
        invitationUrl = body.optString(StringSet.invitation_url, null);
        userId = BodyParser.optLong(body, StringSet.user_id);
        profileImageUrl = body.optString(StringSet.profile_image_url, null);
        nickname = body.optString(StringSet.nickname, null);
        totalReceiversCount = BodyParser.optInteger(body, StringSet.total_receivers_count);
    }

    public Integer getInvitationEventId() {
        return invitationEventId;
    }

    public String getInvitationUrl() {
        return invitationUrl;
    }

    public Long getUserId() {
        return userId;
    }

    public String getProfileImageUrl() {
        return profileImageUrl;
    }

    public String getNickname() {
        return nickname;
    }

    public Integer getTotalReceiversCount() {
        return totalReceiversCount;
    }
}
