package com.kakao.reach.ingame.response.model;

import android.os.Bundle;

import com.kakao.auth.Session;
import com.kakao.network.response.ResponseBody;
import com.kakao.reach.StringSet;
import com.kakao.util.helper.SharedPreferencesCache;

/**
 * Created by seed on 15. 9. 16..
 */
public class IngameStatus {
    private static final String CACHE_ENABLE_PLUSFRIEND_PAGE = "com.kakao.ingamestatus.enableplusfriendpage";
    private static final String CACHE_NEW_AGREEMENT_TALK_VERSION = "com.kakao.ingamestatus.newagreementtalkversion";

    private WithGame withGame;
    private boolean enablePlusFriendPage;
    private String newAgreementTalkVersion;

    public IngameStatus(ResponseBody body) throws ResponseBody.ResponseBodyException {
        this.withGame = new WithGame(body.getBody(StringSet.with_game));

        // plusfriend agreement
        enablePlusFriendPage = body.optBoolean(StringSet.enable_plus_friend_page, false);
        newAgreementTalkVersion = body.optString(StringSet.new_agreement_talk_version, null);
    }

    public IngameStatus(SharedPreferencesCache cache) {
        this.withGame = WithGame.loadFromCache();

        this.enablePlusFriendPage = Boolean.parseBoolean(cache.getString(CACHE_ENABLE_PLUSFRIEND_PAGE));
        this.newAgreementTalkVersion = cache.getString(CACHE_NEW_AGREEMENT_TALK_VERSION);
    }

    public WithGame getWithGame() {
        return withGame;
    }

    public String getNewAgreementTalkVersion() {
        return newAgreementTalkVersion;
    }

    public boolean isEnablePlusFriendPage() {
        return enablePlusFriendPage;
    }

    public void saveToCache() {
        SharedPreferencesCache cache = Session.getAppCache();
        if (cache == null)
            return;

        if (withGame != null)
            withGame.saveToCache();

        Bundle bundle = new Bundle();
        bundle.putString(CACHE_ENABLE_PLUSFRIEND_PAGE, String.valueOf(enablePlusFriendPage));
        bundle.putString(CACHE_NEW_AGREEMENT_TALK_VERSION, newAgreementTalkVersion);

        cache.save(bundle);
    }

    public static IngameStatus loadFromCache() {
        SharedPreferencesCache cache = Session.getAppCache();
        if (cache == null)
            return null;

        return new IngameStatus(cache);
    }

    @Override
    public String toString() {
        return "IngameStatus{" +
                "withGame=" + withGame.toString() +
                ", enablePlusFriendPage=" + enablePlusFriendPage +
                ", newAgreementTalkVersion='" + newAgreementTalkVersion + '\'' +
                '}';
    }
}
