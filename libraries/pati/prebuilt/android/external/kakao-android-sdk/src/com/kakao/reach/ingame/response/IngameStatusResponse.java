package com.kakao.reach.ingame.response;

import com.kakao.auth.network.response.JSONObjectResponse;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseData;
import com.kakao.reach.ingame.response.model.IngameStatus;

/**
 * Created by seed on 15. 9. 14..
 */
public class IngameStatusResponse extends JSONObjectResponse {
    private final IngameStatus ingameStatus;

    public IngameStatusResponse(ResponseData responseData) throws ResponseBody.ResponseBodyException, ApiResponseStatusError {
        super(responseData);
        this.ingameStatus = new IngameStatus(body);
    }

    public IngameStatus getIngameStatus() {
        return ingameStatus;
    }
}
