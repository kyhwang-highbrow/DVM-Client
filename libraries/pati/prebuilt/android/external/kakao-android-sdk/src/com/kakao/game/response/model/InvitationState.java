package com.kakao.game.response.model;

import com.kakao.game.StringSet;
import com.kakao.gameutil.helper.BodyParser;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;

/**
 * Created by house.dr on 16. 2. 13..
 */
public class InvitationState {
    private final Long userId;
    private final String profileImageUrl;
    private final String nickname;
    private final String senderReward;
    private final String senderRewardState;
    private final String receiverReward;
    private final String receiverRewardState;
    private final String createdAt;

    public InvitationState(ResponseBody body) throws ResponseBodyException {
        userId = BodyParser.optLong(body, StringSet.user_id);
        profileImageUrl = body.optString(StringSet.profile_image_url, null);
        nickname = body.optString(StringSet.nickname, null);
        senderReward = body.optString(StringSet.sender_reward, null);
        senderRewardState = body.optString(StringSet.sender_reward_state, null);
        receiverReward = body.optString(StringSet.receiver_reward, null);
        receiverRewardState = body.optString(StringSet.receiver_reward_state, null);
        createdAt = body.optString(StringSet.created_at, null);
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

    public String getSenderReward() {
        return senderReward;
    }

    public String getSenderRewardState() {
        return senderRewardState;
    }

    public String getReceiverReward() {
        return receiverReward;
    }

    public String getReceiverRewardState() {
        return receiverRewardState;
    }

    public String getCreatedAt() {
        return createdAt;
    }
}
