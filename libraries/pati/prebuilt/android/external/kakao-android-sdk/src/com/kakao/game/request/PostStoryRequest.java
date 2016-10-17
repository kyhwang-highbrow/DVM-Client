package com.kakao.game.request;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by house.dr on 15. 10. 7..
 */
public class PostStoryRequest extends ApiRequest {
    private final String templateId;
    private final String content;

    public PostStoryRequest(String templateId, String content) {
        this.templateId = templateId;
        this.content = content;
    }

    @Override
    public String getMethod() {
        return POST;
    }

    @Override
    public String getUrl() {
        String url = ApiRequest.createBaseURL(GameServerProtocol.GAME_API_AUTHORITY, GameServerProtocol.GET_PLAY_GAME_PATH);
        return url + GameServerProtocol.API_VERSION_2 + GameServerProtocol.GET_STORY_FEED_PATH + GameServerProtocol.GET_TEMPLATE_PATH +
                "/" + templateId + GameServerProtocol.GET_APP_POST_PATH;
    }

    @Override
    public Map<String, String> getParams() {
        Map<String, String> params = new HashMap<String, String>();
        params.put("content", content);
        return params;
    }
}
