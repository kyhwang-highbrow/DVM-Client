/**
 * Copyright 2014 Daum Kakao Corp.
 *
 * Redistribution and modification in source or binary forms are not permitted without specific prior written permission. 
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.kakao.auth;

import android.content.Context;

import com.kakao.util.exception.KakaoException;
import com.kakao.util.exception.KakaoException.ErrorType;

/**
 * Application에서 구현을 해줘야 하며 Application에서 init method를 {@link KakaoAdapter}와 연결한다.
 * @author leoshin, created at 15. 7. 20..
 */
public class KakaoSDK {
    private static volatile KakaoAdapter adapter = null;

    public synchronized static void init(KakaoAdapter adapter) {
        if (KakaoSDK.adapter != null) {
            throw new AlreadyInitializedException();
        }

        if (adapter == null) {
            throw new KakaoException(ErrorType.MISS_CONFIGURATION, "adapter is null");
        }

        KakaoSDK.adapter = adapter;

        // Sessino initailize.
        Context context = adapter.getApplicationConfig().getApplicationContext();
        ApprovalType approvalType = adapter.getSessionConfig().getApprovalType();
        AuthType[] authtypes = adapter.getSessionConfig().getAuthTypes();
        Session.initialize(context, approvalType, authtypes);
    }

    public static KakaoAdapter getAdapter() {
        return adapter;
    }

    /**
     * 3rd party Application과 Kakao SDK를 연결하는 과정중 adapter를 중복으로 세팅하게 되었을경우 발생할 수 있다.
     */
    public static class AlreadyInitializedException extends RuntimeException {
        private static final long serialVersionUID = 1L;
    }
}
