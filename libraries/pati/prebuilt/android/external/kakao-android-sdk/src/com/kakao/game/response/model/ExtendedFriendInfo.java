package com.kakao.game.response.model;

import com.kakao.friends.request.FriendsRequest;
import com.kakao.friends.response.model.FriendInfo;
import com.kakao.game.StringSet;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;

/**
 * Created by house.dr on 16. 3. 8..
 */
public class ExtendedFriendInfo extends FriendInfo {
    final private String impressionId;
    /**
     * @param body {@link FriendsRequest}를 통해서 응답받은 결과.
     * @param impressionId
     * @throws ResponseBodyException 프로토콜과 맞지 않는 응답이 왔을때 던지는 에러.
     */
    public ExtendedFriendInfo(ResponseBody body) throws ResponseBodyException {
        super(body);
        this.impressionId = body.optString(StringSet.impression_id, null);
    }

    public String getImpressionId() {
        return impressionId;
    }

    public static final ResponseBody.BodyConverter<ExtendedFriendInfo> CONVERTER = new ResponseBody.BodyConverter<ExtendedFriendInfo>() {
        @Override
        public ExtendedFriendInfo convert(ResponseBody body) throws ResponseBodyException {
            return new ExtendedFriendInfo(body);
        }
    };
}
