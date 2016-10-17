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
package com.kakao.auth.authorization.accesstoken;

import android.os.Bundle;
import android.text.TextUtils;

import com.kakao.auth.StringSet;
import com.kakao.util.helper.SharedPreferencesCache;
import com.kakao.auth.network.response.AuthResponse;
import com.kakao.network.response.ResponseBody;
import com.kakao.network.response.ResponseBody.ResponseBodyException;
import com.kakao.util.helper.Utility;
import com.kakao.util.helper.log.Logger;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * refresh token에 대한 expires_at은 아직 내려오지 않는다.
 * @author MJ
 */
public class AccessToken extends AuthResponse {
    private static final String CACHE_ACCESS_TOKEN = "com.kakao.token.AccessToken";
    private static final String CACHE_ACCESS_TOKEN_EXPIRES_AT = "com.kakao.token.AccessToken.ExpiresAt";
    private static final String CACHE_REFRESH_TOKEN = "com.kakao.token.RefreshToken";
    private static final String CACHE_REFRESH_TOKEN_EXPIRES_AT = "com.kakao.token.RefreshToken.ExpiresAt";

    private static final Date MIN_DATE = new Date(Long.MIN_VALUE);
    private static final Date MAX_DATE = new Date(Long.MAX_VALUE);
    private static final Date DEFAULT_EXPIRATION_TIME = MAX_DATE;
    private static final Date ALREADY_EXPIRED_EXPIRATION_TIME = MIN_DATE;

    private String accessToken;
    private String refreshToken;
    private Date accessTokenExpiresAt;
    private Date refreshTokenExpiresAt;

    public static AccessToken createEmptyToken() {
        return new AccessToken("", "", ALREADY_EXPIRED_EXPIRATION_TIME, ALREADY_EXPIRED_EXPIRATION_TIME);
    }

    public static AccessToken createFromCache(final SharedPreferencesCache cache) {
        final String accessToken = cache.getString(CACHE_ACCESS_TOKEN);
        final String refreshToken = cache.getString(CACHE_REFRESH_TOKEN);
        final Date accessTokenExpiresAt = cache.getDate(CACHE_ACCESS_TOKEN_EXPIRES_AT);
        final Date refreshTokenExpiresAt = cache.getDate(CACHE_REFRESH_TOKEN_EXPIRES_AT);
        return new AccessToken(accessToken, refreshToken, accessTokenExpiresAt, refreshTokenExpiresAt);
    }

    public AccessToken(ResponseBody body) throws ResponseBodyException, AuthResponseStatusError {
        super(body);
        if (!body.has(StringSet.access_token)) {
            Logger.e("");
            throw new ResponseBody.ResponseBodyException("No Search Element : " + StringSet.access_token);
        }
        accessToken = body.getString(StringSet.access_token);
        if (body.has(StringSet.refresh_token)) {
            refreshToken = body.getString(StringSet.refresh_token);
        }
        long expiredAt = new Date().getTime() + body.getInt(StringSet.expires_in) * 1000;
        accessTokenExpiresAt = new Date(expiredAt);
        refreshTokenExpiresAt = MAX_DATE;
    }

    private AccessToken(final String accessToken, final String refreshToken, final Date accessTokenExpiresAt, final Date refreshTokenExpiresAt) {
        super();
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        this.accessTokenExpiresAt = accessTokenExpiresAt;
        this.refreshTokenExpiresAt = refreshTokenExpiresAt;
    }

    public void clearAccessToken(final SharedPreferencesCache cache) {
        this.accessToken = null;
        this.accessTokenExpiresAt = DEFAULT_EXPIRATION_TIME;
        final List<String> keysToRemove = new ArrayList<String>();
        keysToRemove.add(CACHE_ACCESS_TOKEN);
        keysToRemove.add(CACHE_ACCESS_TOKEN_EXPIRES_AT);
        cache.clear(keysToRemove);
    }

    public void clearRefreshToken(final SharedPreferencesCache cache) {
        this.refreshToken = null;
        this.refreshTokenExpiresAt = DEFAULT_EXPIRATION_TIME;
        final List<String> keysToRemove = new ArrayList<String>();
        keysToRemove.add(CACHE_REFRESH_TOKEN);
        keysToRemove.add(CACHE_REFRESH_TOKEN_EXPIRES_AT);
        cache.clear(keysToRemove);
    }

    public void removeAccessTokenToCache(final SharedPreferencesCache cache) {
        final List<String> keysToRemove = new ArrayList<String>();
        keysToRemove.add(CACHE_ACCESS_TOKEN);
        keysToRemove.add(CACHE_ACCESS_TOKEN_EXPIRES_AT);
        cache.clear(keysToRemove);
    }

    public void saveAccessTokenToCache(final SharedPreferencesCache cache) {
        Bundle bundle = new Bundle();

        bundle.putString(CACHE_ACCESS_TOKEN, accessToken);
        bundle.putString(CACHE_REFRESH_TOKEN, refreshToken);
        bundle.putLong(CACHE_ACCESS_TOKEN_EXPIRES_AT, accessTokenExpiresAt.getTime());
        bundle.putLong(CACHE_REFRESH_TOKEN_EXPIRES_AT, refreshTokenExpiresAt.getTime());
        cache.save(bundle);
    }

    // access token 갱신시에는 refresh token이 내려오지 않을 수도 있다.
    public void updateAccessToken(final AccessToken newAccessToken){
        String newRefreshToken = newAccessToken.refreshToken;
        if(TextUtils.isEmpty(newRefreshToken)){
            this.accessToken = newAccessToken.accessToken;
            this.accessTokenExpiresAt = newAccessToken.accessTokenExpiresAt;
        } else {
            this.accessToken = newAccessToken.accessToken;
            this.refreshToken = newAccessToken.refreshToken;
            this.accessTokenExpiresAt = newAccessToken.accessTokenExpiresAt;
            this.refreshTokenExpiresAt = newAccessToken.refreshTokenExpiresAt;
        }
    }

    public String getAccessToken() {
        return accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public boolean hasRefreshToken(){
        return !Utility.isNullOrEmpty(this.refreshToken);
    }

    public boolean hasValidAccessToken() {
        return !Utility.isNullOrEmpty(this.accessToken) && !new Date().after(this.accessTokenExpiresAt);
    }

    public int getRemainedExpiresInAccessTokenTime() {
        if (accessTokenExpiresAt == null || !hasValidAccessToken()) {
            return 0;
        }

        return (int) (accessTokenExpiresAt.getTime() - new Date().getTime());
    }
}
