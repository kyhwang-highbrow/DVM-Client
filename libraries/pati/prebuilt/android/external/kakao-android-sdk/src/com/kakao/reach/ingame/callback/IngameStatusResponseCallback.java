package com.kakao.reach.ingame.callback;

/**
 * Created by seed on 2015. 11. 9..
 */

import com.kakao.auth.ApiResponseCallback;
import com.kakao.reach.ingame.response.model.IngameStatus;

public abstract class IngameStatusResponseCallback extends ApiResponseCallback<IngameStatus> {

    @Override
    public void onSuccessForUiThread(IngameStatus result) {
        result.saveToCache();
        super.onSuccessForUiThread(result);
    }
}
