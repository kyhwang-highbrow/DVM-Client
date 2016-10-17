package com.kakao.game.response;

import com.kakao.auth.network.response.JSONObjectResponse;
import com.kakao.network.response.ResponseBody.ResponseBodyException;
import com.kakao.network.response.ResponseData;
import com.kakao.game.StringSet;
import com.kakao.gameutil.helper.GameServerProtocol;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

/**
 * Created by house.dr on 15. 9. 5..
 */
public class GameImageResponse extends JSONObjectResponse {
    private String accessKey;
    private final String fileName;

    public GameImageResponse(ResponseData responseData) throws ResponseBodyException, ApiResponseStatusError, UnsupportedEncodingException {
        super(responseData);
        this.accessKey = URLEncoder.encode(body.optString(StringSet.access_key, null), "utf-8");
        this.fileName = body.getBody(StringSet.info).getBody(StringSet.original).optString(StringSet.file_name, null);
    }

    public String getImageUrl() {
        return GameServerProtocol.KAGE_CDN_AUTHORITY + accessKey  + "/" + fileName;
    }

}
