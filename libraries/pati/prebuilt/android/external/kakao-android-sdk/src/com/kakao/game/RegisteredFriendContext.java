package com.kakao.game;

import com.kakao.friends.FriendContext;
import com.kakao.friends.request.FriendsRequest.FriendFilter;
import com.kakao.friends.request.FriendsRequest.FriendOrder;
import com.kakao.friends.request.FriendsRequest.FriendType;

/**
 * Created by house.dr on 15. 9. 8..
 */
public class RegisteredFriendContext {
    private FriendContext friendContext;

    private RegisteredFriendContext(int offset, int limit) {
        friendContext = FriendContext.createContext(FriendType.KAKAO_TALK, FriendFilter.REGISTERED, FriendOrder.NICKNAME, false, offset, limit, "asc");
    }

    public static RegisteredFriendContext createContext(int offset, int limit) {
        return new RegisteredFriendContext(offset, limit);
    }

    public FriendContext getFriendContext() {
        return friendContext;
    }
}
