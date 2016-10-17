package com.kakao.guild.response.model;

import com.kakao.network.response.ResponseBodyArray;
import com.kakao.gameutil.helper.BodyParser;
import com.kakao.guild.StringSet;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;

import java.util.ArrayList;

/**
 * Created by house.dr on 15. 8. 21..
 */
public class GuildInfo {
    private final String id;
    private final String description;
    private final Integer joinType;
    private final GuildMember leader;
    private final String name;
    private final Integer privacy;
    private final Integer memberListAccessLevel;
    private final Boolean allowRejoin;
    private final Boolean denyExitChatRoom;
    private final Integer memberCount;
    private final String imageUrl;
    private final Integer updatedAt;
    private final Integer maxMemberCount;
    private final String chatLink;
    private final Integer createdAt;
    private final GuildMember me;
    private final ArrayList<GuildMember> subLeaders;

    public GuildInfo(ResponseBody body) throws ResponseBodyException {
        id = body.optString(StringSet.id, null);
        description = body.optString(StringSet.description, null);
        joinType = BodyParser.optInteger(body, StringSet.join_type);
        ResponseBody leaderBody = body.optBody(StringSet.leader, null);
        leader = (leaderBody == null) ? null : new GuildMember(leaderBody);
        name = body.optString(StringSet.name, null);
        privacy = BodyParser.optInteger(body, StringSet.privacy);
        memberListAccessLevel = BodyParser.optInteger(body, StringSet.member_list_access_level);
        allowRejoin = BodyParser.optBool(body, StringSet.allow_rejoin);
        denyExitChatRoom = BodyParser.optBool(body, StringSet.deny_exit_chat_room);
        memberCount = BodyParser.optInteger(body, StringSet.member_count);
        imageUrl = body.optString(StringSet.image_url, null);
        updatedAt = BodyParser.optInteger(body, StringSet.updated_at);
        maxMemberCount = BodyParser.optInteger(body, StringSet.max_member_count);
        chatLink = body.optString(StringSet.chat_link, null);
        createdAt = BodyParser.optInteger(body, StringSet.created_at);
        ResponseBody optBody = body.optBody(StringSet.me, null);
        me = (optBody == null) ? null : new GuildMember(optBody);
        if (body.has(StringSet.sub_leaders)) {
            ResponseBodyArray responseBodyArray = body.getArray(StringSet.sub_leaders);
            subLeaders = new ArrayList<GuildMember>();
            for (int i = 0; i < responseBodyArray.length(); i++) {
                subLeaders.add(new GuildMember(responseBodyArray.getBody(i)));
            }
        } else {
            subLeaders = null;
        }
    }

    public String getId() {
        return id;
    }

    public String getDescription() {
        return description;
    }

    public Integer getJoinType() {
        return joinType;
    }

    public GuildMember getLeader() {
        return leader;
    }

    public String getName() {
        return name;
    }

    public Integer getPrivacy() {
        return privacy;
    }

    public Integer getMemberListAccessLevel() {
        return memberListAccessLevel;
    }

    public Boolean isAllowRejoin() {
        return allowRejoin;
    }

    public Boolean isDenyExitChatRoom() {
        return denyExitChatRoom;
    }

    public Integer getMemberCount() {
        return memberCount;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public Integer getUpdatedAt() {
        return updatedAt;
    }

    public Integer getMaxMemberCount() {
        return maxMemberCount;
    }

    public String getChatLink() {
        String url;
        switch (com.kakao.util.helper.log.Logger.DeployPhase.current()) {
            case Release:
                url = chatLink;
                break;
            default:
                url = chatLink.replaceFirst("alphaopen", "kakaoopen");
                break;
        }
        return url;
    }

    public Integer getCreatedAt() {
        return createdAt;
    }

    public GuildMember getMe() {
        return me;
    }

    public ArrayList<GuildMember> getSubLeaders() {
        return subLeaders;
    }

    public boolean isAdmin() {
        return getMe() != null && (getMe().getRole() == GuildMember.LEADER || getMe().getRole() == GuildMember.SUB_LEADER);
    }

    public boolean isLeader() {
        return getMe() != null && getMe().getRole() == GuildMember.LEADER;
    }

    public boolean canJoin() {
        return getMe() == null || (isAllowRejoin() && getMe().getJoinStatus() == GuildMember.BAN);
    }

    public boolean isJoined() {
        return getMe() != null && getMe().getJoinStatus() == GuildMember.JOIN;
    }

    public boolean isPending() {
        return getMe() != null && getMe().getJoinStatus() == GuildMember.PENDING;
    }

    @Override
    public String toString() {
        return "++ id : " + id + ", name : " + name + ", description" + description +
                ", imageUrl : " + imageUrl + ", leaderId : " + leader.getUserId() +
                ", joinType : " + joinType + ", privacy : " + privacy +
                ", memberListAccessLevel" + memberListAccessLevel +
                ", allowRejoin : " + allowRejoin +
                ", denyExitChatRoom : " + denyExitChatRoom + ", memberCount : " + memberCount +
                ", updatedAt : " + updatedAt + ", maxMemberCount :" + maxMemberCount +
                ", chatLink : " + chatLink + ", createdAt : " + createdAt +
                ", me : " + me + ", subLeaderId : " + subLeaders.get(0).getUserId();
    }
}
