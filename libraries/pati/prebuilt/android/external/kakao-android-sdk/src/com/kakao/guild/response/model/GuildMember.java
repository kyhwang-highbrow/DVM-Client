package com.kakao.guild.response.model;

import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;
import com.kakao.gameutil.helper.BodyParser;
import com.kakao.guild.StringSet;

/**
 * Created by house.dr on 15. 8. 22..
 */
public class GuildMember {
    public static int MEMBER = 0;
    public static int LEADER = 1;
    public static int SUB_LEADER = 2;

    public static int PENDING = 0;
    public static int JOIN = 1;
    public static int BAN = 2;

    private final Integer userId;
    private final Integer role;
    private final Integer guildId;
    private final Integer joinStatus;
    private final Integer updatedAt;
    private final Integer lastAccessAt;
    private final Integer createdAt;
    private final String nickName;
    private final String profileImage;

    public GuildMember(ResponseBody body) throws ResponseBodyException {
        userId = BodyParser.optInteger(body, StringSet.user_id);
        role = BodyParser.optInteger(body, StringSet.role);
        guildId = BodyParser.optInteger(body, StringSet.guild_id);
        joinStatus = BodyParser.optInteger(body, StringSet.join_status);
        updatedAt = BodyParser.optInteger(body, StringSet.updated_at);
        lastAccessAt = BodyParser.optInteger(body, StringSet.last_access_at);
        createdAt = BodyParser.optInteger(body, StringSet.created_at);
        nickName = body.optString(StringSet.nick_name, null);
        profileImage = body.optString(StringSet.profile_image, null);
    }

    public Integer getUserId() {
        return userId;
    }

    public Integer getRole() {
        return role;
    }

    public Integer getGuildId() {
        return guildId;
    }

    public Integer getJoinStatus() {
        return joinStatus;
    }

    public Integer getUpdatedAt() {
        return updatedAt;
    }

    public Integer getLastAccessAt() {
        return lastAccessAt;
    }

    public Integer getCreatedAt() {
        return createdAt;
    }

    public String getNickName() {
        return nickName;
    }

    public String getProfileImage() {
        return profileImage;
    }

    @Override
    public String toString() {
        return "++ userId : " + userId + ", role : " + role + ", guildId : " + guildId +
                ", joinStatus : " + joinStatus + ", updatedAt : " + updatedAt +
                ", lastAccessAt : " + lastAccessAt + ", createdAt : " + createdAt +
                ", nickName : " + nickName;
    }
}
