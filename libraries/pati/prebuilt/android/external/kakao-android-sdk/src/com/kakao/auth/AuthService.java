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

import com.kakao.auth.api.AuthApi;
import com.kakao.auth.callback.AccountResponseCallback;
import com.kakao.network.callback.ResponseCallback;
import com.kakao.network.tasks.KakaoResultTask;
import com.kakao.network.tasks.KakaoTaskQueue;

import java.util.concurrent.Future;

/**
 * @author leoshin
 */
public class AuthService {
    /**
     * 연령인증 레벨을 설정한다.
     */
    public enum AgeAuthLevel {
        /**
         * 본인인증
         */
        LEVEL_1("10", "AUTH_LEVEL1"),

        /**
         * 연령인증
         */
        LEVEL_2("20", "AUTH_LEVEL2");

        final private String value;
        final private String name;
        AgeAuthLevel(String value, String name) {
            this.value = value;
            this.name = name;
        }

        public static AgeAuthLevel convertByName(String name) {
            for (AgeAuthLevel value : values()) {
                if (value.getName().equals(name)) {
                    return value;
                }
            }

            return null;
        }

        public String getValue() {
            return value;
        }

        public String getName() {
            return name;
        }
    }

    /**
     * 연령제한, 일반적으로 12세, 15세, 19세
     */
    public enum AgeLimit {
        /**
         * 12세 인증
         */
        LIMIT_12("12"),

        /**
         * 15세 인증
         */
        LIMIT_15("15"),

        /**
         * 19세 인증
         */
        LIMIT_19("19");

        final private String value;
        AgeLimit(String value) {
            this.value = value;
        }

        public String getValue() {
            return value;
        }
    }

    /**
     * 연령인증시 응답받을 수 있는 StatusCode.
     */
    public enum AgeAuthStatus {
        /**
         * 성공 code = 0
         */
        SUCCESS(0),
        /**
         * 성공 code = 0
         */
        CLIENT_ERROR(-777),
        /**
         * 인증되지 않은 사용자 일 경우 code = -401
         */
        UNAUTHORIZED(-401),
        /**
         * 클라이언트 정보 호환 안됨, 업체에서 온 데이터가 비어있을경우, 앱에도 연령인증 정보가 없고 실제 입력도 없는경우. code = -440
         */
        BAD_PARAMETERS(-440),
        /**
         * 연령인증이 되지 않아서 연령인증이 필요한 상황(기본적으로는 정상인 상황) code = -450
         */
        NOT_AUTHORIZED_AGE(-450),
        /**
         * 현재 앱의 연령제한보다 사용자의 연령이 낮은 경우 code = -451
         */
        LOWER_AGE_LIMIT(-451),
        /**
         * 이미 연령인증을 마친상황. code = -452
         */
        ALREADY_AGE_AUTHORIZED(-452),
        /**
         * 연령인증 횟수 초과 code = -453
         */
        EXCEED_AGE_CHECK_LIMIT(-453),
        /**
         * 이전에 인정했던 정보와 불일치 (생일). code = -480
         */
        AGE_AUTH_RESULT_MISMATCH(-480),
        /**
         * CI 정보가 불일치 할 경우. code = -481
         */
        CI_RESULT_MISMATCH(-481),
        /**
         * 사용자 찾기 실패, 받아온 생일이 불일치할 경우, 예기치 못한 에러 발생시  code = -500
         */
        ERROR(-500),
        /**
         * 알수 없는 type의 status
         */
        UNKOWN(-999);

        final private int value;
        AgeAuthStatus(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }

        public static AgeAuthStatus valueOf(int i) {
            for (AgeAuthStatus value : values()) {
                if (value.getValue() == i) {
                    return value;
                }
            }
            return UNKOWN;
        }
    }

    /**
     * 연령인증이 필요한 경우에 동의창을 띄우기 위한 용도로 사용된다.
     * UI Thead에서 동작해야하며, 기본적으로 SDK내부에서 필요한 경우 자동으로 띄우기 때문에
     * 수동을 콘텐츠 연령인증이 필요한경우 띄우기 동의창을 띄우기 위한 용도로 사용한다.
     * (제휴를 통해 권한이 부여된 특정 앱에서만 호출이 가능합니다.)
     * @param callback 요청 결과에 대한 callback
     * @param builder {@link AgeAuthParamBuilder}
     * @param useSmsReceiver 인증 sms를 후킹할것이냐의 여부.
     * @return
     */
    public static Future<Integer> requestShowAgeAuthDialog(final AccountResponseCallback callback, final AgeAuthParamBuilder builder, final boolean useSmsReceiver) {
        return KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Integer>(callback) {
            @Override
            public Integer call() throws Exception {
                return AuthApi.requestShowAgeAuthDialog(builder, useSmsReceiver);
            }
        });
    }

    static void requestAccessTokenInfo(final ResponseCallback<Integer> callback) {
        KakaoTaskQueue.getInstance().addTask(new KakaoResultTask<Integer>(callback) {
            @Override
            public Integer call() throws Exception {
                return AuthApi.requestAccessTokenInfo();
            }
        });
    }
}
