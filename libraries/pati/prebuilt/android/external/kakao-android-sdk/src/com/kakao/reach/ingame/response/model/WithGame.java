package com.kakao.reach.ingame.response.model;

import android.os.Bundle;

import com.kakao.auth.Session;
import com.kakao.network.response.ResponseBody;
import com.kakao.reach.StringSet;
import com.kakao.util.helper.SharedPreferencesCache;

/**
 * Created by seed on 15. 9. 16..
 */
public class WithGame {
    private static final String CACHE_SHOW_NEW_BADGE = "com.kakao.withgame.shownewbadge";
    private static final String CACHE_LAST_MODIFIED_AT = "com.kakao.withgame.lastmodifiedat";
    private static final String CACHE_HOME_URL = "com.kakao.withgame.homeurl";

    private boolean showNewBadge;
    private long lastModifiedAt;
    private String homeUrl;

    public WithGame(ResponseBody body) throws ResponseBody.ResponseBodyException {
        this.showNewBadge = body.getBoolean(StringSet.show_new_badge);
        this.lastModifiedAt = body.getLong(StringSet.last_modified_at);
        this.homeUrl = body.getString(StringSet.home_url);
    }

    public WithGame(SharedPreferencesCache cache) {
        this.showNewBadge = Boolean.parseBoolean(cache.getString(CACHE_SHOW_NEW_BADGE));
        this.lastModifiedAt = cache.getLong(CACHE_LAST_MODIFIED_AT);
        this.homeUrl = cache.getString(CACHE_HOME_URL);
    }

    public boolean isShowNewBadge() {
        return showNewBadge;
    }

    public long getLastModifiedAt() {
        return lastModifiedAt;
    }

    public String getHomeUrl() {
        return homeUrl;
    }

    public void saveToCache() {
        SharedPreferencesCache cache = Session.getAppCache();
        if (cache == null)
            return;

        Bundle bundle = new Bundle();
        bundle.putString(CACHE_SHOW_NEW_BADGE, String.valueOf(showNewBadge));
        bundle.putLong(CACHE_LAST_MODIFIED_AT, lastModifiedAt);
        bundle.putString(CACHE_HOME_URL, homeUrl);

        cache.save(bundle);
    }

    public static WithGame loadFromCache() {
        SharedPreferencesCache cache = Session.getAppCache();
        if (cache == null)
            return null;

        return new WithGame(cache);
    }

    @Override
    public String toString() {
        return "WithGame{" +
                "showNewBadge=" + showNewBadge +
                ", lastModifiedAt=" + lastModifiedAt +
                ", homeUrl='" + homeUrl + '\'' +
                '}';
    }
}
