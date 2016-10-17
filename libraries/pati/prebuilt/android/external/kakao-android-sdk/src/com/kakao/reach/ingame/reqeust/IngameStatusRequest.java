package com.kakao.reach.ingame.reqeust;

import com.kakao.auth.network.request.ApiRequest;
import com.kakao.gameutil.helper.GameServerProtocol;

/**
 * Created by seed on 15. 9. 14..
 */
public class IngameStatusRequest extends ApiRequest {
    @Override
    public String getMethod() {
        return GET;
    }

    @Override
    public String getUrl() {
        return createBaseURL(GameServerProtocol.API_PROXY_AUTHORITY, GameServerProtocol.INGAME_STATUS);
    }
}
