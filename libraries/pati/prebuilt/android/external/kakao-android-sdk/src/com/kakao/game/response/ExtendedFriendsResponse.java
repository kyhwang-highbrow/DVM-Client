package com.kakao.game.response;

import com.kakao.friends.response.FriendsResponse;
import com.kakao.game.StringSet;
import com.kakao.game.response.model.ExtendedFriendInfo;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseData;

import java.util.Collections;
import java.util.List;

/**
 * Created by house.dr on 16. 3. 4..
 */
public class ExtendedFriendsResponse extends FriendsResponse {
    final private List<ExtendedFriendInfo> friendInfoList;
    final private int totalCount;
    final private String id;
    private String beforeUrl;
    private String afterUrl;

    public ExtendedFriendsResponse(ResponseData responseData) throws ResponseBody.ResponseBodyException, ApiResponseStatusError {
        super(responseData);
        this.friendInfoList = body.optConvertedList(com.kakao.friends.StringSet.elements, ExtendedFriendInfo.CONVERTER, Collections.<ExtendedFriendInfo>emptyList());
        this.totalCount = body.optInt(com.kakao.friends.StringSet.total_count, 0);
        this.beforeUrl = body.optString(com.kakao.friends.StringSet.before_url, null);
        this.afterUrl = body.optString(com.kakao.friends.StringSet.after_url, null);
        this.id = body.optString(com.kakao.friends.StringSet.id, null);
    }

    public int getTotalCount() {
        return totalCount;
    }

    public String getBeforeUrl() {
        return beforeUrl;
    }

    public String getAfterUrl() {
        return afterUrl;
    }

    public String getId() {
        return id;
    }

    public List<ExtendedFriendInfo> getExtendedFriendInfoList() {
        return friendInfoList;
    }
}
