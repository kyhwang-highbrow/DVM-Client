package com.kakao.game.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.friends.StringSet;
import com.kakao.friends.request.FriendsRequest;
import com.kakao.game.InvitableFriendContext;
import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.network.helper.QueryString;

/**
 * Created by house.dr on 16. 3. 3..
 */
public class RecommendedInvitableFriendsRequest extends FriendsRequest {

    private final int offset;
    private final int limit;
    private final String url;

    public RecommendedInvitableFriendsRequest(InvitableFriendContext context) {
        super(context.getFriendContext());
        this.offset = context.getFriendContext().getOffset();
        this.limit = context.getFriendContext().getLimit();
        this.url = context.getFriendContext().getAfterUrl();
    }

    @Override
    public String getMethod() {
        return GET;
    }

    @Override
    public String getUrl() {
        if (url != null && url.length() > 0) {
            return url;
        }
        String baseUrl = ApiRequest.createBaseURL(GameServerProtocol.GAME_API_AUTHORITY, GameServerProtocol.GET_PLAY_GAME_PATH);
        baseUrl = baseUrl + GameServerProtocol.API_VERSION_2 + GameServerProtocol.GET_FRIENDS_RECOMMEND_PATH;
        QueryString qs = new QueryString();
        qs.add(StringSet.offset, String.valueOf(offset));
        qs.add(StringSet.limit, String.valueOf(limit));
        return baseUrl + "?" + qs.toString();
    }
}
