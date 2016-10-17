package com.kakao.game.response.model;

import com.kakao.game.StringSet;
import com.kakao.gameutil.helper.BodyParser;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;

/**
 * Created by house.dr on 16. 2. 2..
 */
public class InvitationEvent {
    private final Integer id;
    private final Boolean enabled;
    private final String startsAt;
    private final String endsAt;
    private final Integer maxSenderRewardsCount;
    private final String senderReward;
    private final String receiverReward;
    private String invitationUrl;
    private Integer totalReceiversCount;

    public InvitationEvent(ResponseBody body) throws ResponseBodyException {
        id = BodyParser.optInteger(body, StringSet.id);
        enabled = BodyParser.optBool(body, StringSet.enabled);
        startsAt = body.optString(StringSet.starts_at, null);
        endsAt = body.optString(StringSet.ends_at, null);
        maxSenderRewardsCount = BodyParser.optInteger(body, StringSet.max_sender_rewards_count);
        senderReward = body.optString(StringSet.sender_reward, null);
        receiverReward = body.optString(StringSet.receiver_reward, null);
        ResponseBody invitationSender = body.optBody(StringSet.invitation_sender, null);
        if (invitationSender != null) {
            invitationUrl = invitationSender.optString(StringSet.invitation_url, null);
            totalReceiversCount = BodyParser.optInteger(invitationSender, StringSet.total_receivers_count);
        }
    }

    public Integer getId() {
        return id;
    }

    public Boolean getEnabled() {
        return enabled;
    }

    public String getStartsAt() {
        return startsAt;
    }

    public String getEndsAt() {
        return endsAt;
    }

    public Integer getMaxSenderRewardsCount() {
        return maxSenderRewardsCount;
    }

    public String getSenderReward() {
        return senderReward;
    }

    public String getReceiverReward() {
        return receiverReward;
    }

    public String getInvitationUrl() {
        return invitationUrl;
    }

    public Integer getTotalReceiversCount() {
        return totalReceiversCount;
    }
}
