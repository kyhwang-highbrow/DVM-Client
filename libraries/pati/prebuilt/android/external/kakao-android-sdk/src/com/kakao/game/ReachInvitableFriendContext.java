package com.kakao.game;

import com.kakao.friends.FriendContext;
import com.kakao.friends.request.FriendsRequest;

/**
 * Created by house.dr on 16. 4. 22..
 */
public class ReachInvitableFriendContext {
    private FriendContext friendContext;

    private ReachInvitableFriendContext(int offset, int limit) {
        friendContext = FriendContext.createContext(FriendsRequest.FriendType.KAKAO_TALK, FriendsRequest.FriendFilter.INVITABLE, FriendsRequest.FriendOrder.AGE, false, offset, limit, "asc");
    }

    public static ReachInvitableFriendContext createContext(int offset, int limit) {
        return new ReachInvitableFriendContext(offset, limit);
    }

    public FriendContext getFriendContext() {
        return friendContext;
    }
}
