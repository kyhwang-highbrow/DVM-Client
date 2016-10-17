package com.kakao.game.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.game.response.model.ExtendedFriendInfo;
import com.kakao.gameutil.helper.GameServerProtocol;
import com.kakao.kakaotalk.StringSet;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by house.dr on 16. 3. 8..
 */
public class SendRecommendedInviteMessageRequest extends ApiRequest {
    private final String receiverId;
    private final String receiverIdType;
    private final String impressionId;
    private final String templateId;
    private final JSONObject args;

    public SendRecommendedInviteMessageRequest(ExtendedFriendInfo receiverInfo, String templateId, Map<String, String> args) {
        this.receiverId = receiverInfo.getTargetId();
        this.receiverIdType = receiverInfo.getType();
        this.impressionId = receiverInfo.getImpressionId();
        this.templateId = templateId;
        this.args = args != null ? new JSONObject(args) : null;
    }

    @Override
    public String getMethod() {
        return POST;
    }

    @Override
    public String getUrl() {
        String baseUrl = ApiRequest.createBaseURL(GameServerProtocol.GAME_API_AUTHORITY, GameServerProtocol.GET_PLAY_GAME_PATH);
        return baseUrl + GameServerProtocol.API_VERSION_2 + GameServerProtocol.GET_MESSAGE_SEND_PATH;
    }

    @Override
    public Map<String, String> getParams() {
        Map<String, String> params = new HashMap<String, String>();
        params.put(StringSet.receiver_id, receiverId);
        params.put(StringSet.receiver_id_type, receiverIdType);
        params.put(StringSet.impression_id, impressionId);
        params.put(StringSet.template_id, templateId);

        if (args != null && args.length() > 0) {
            params.put(StringSet.args, args.toString());
        }
        return params;
    }
}
