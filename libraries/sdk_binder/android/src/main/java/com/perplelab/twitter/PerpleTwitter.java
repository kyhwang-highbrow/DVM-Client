package com.perplelab.twitter;

import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.util.Log;

import com.perplelab.PerpleSDK;
import com.perplelab.PerpleSDKCallback;
import com.perplelab.PerpleLog;

import com.twitter.sdk.android.core.Callback;
import com.twitter.sdk.android.core.DefaultLogger;
import com.twitter.sdk.android.core.Result;
import com.twitter.sdk.android.core.Twitter;
import com.twitter.sdk.android.core.TwitterAuthConfig;
import com.twitter.sdk.android.core.TwitterAuthToken;
import com.twitter.sdk.android.core.TwitterConfig;
import com.twitter.sdk.android.core.TwitterCore;
import com.twitter.sdk.android.core.TwitterException;
import com.twitter.sdk.android.core.TwitterSession;
import com.twitter.sdk.android.core.identity.TwitterAuthClient;
import com.twitter.sdk.android.tweetcomposer.ComposerActivity;
import com.twitter.sdk.android.tweetcomposer.TweetUploadService;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by mskim on 2018-02-28.
 */

public class PerpleTwitter {
    private static final String LOG_TAG = "PerpleSDK Twitter";

    private boolean mIsInit;

    private TwitterAuthClient mAuthClient;
    private PerpleTwitterReceiver mReceiver = null;

    public PerpleTwitter() {}

    public void init(String consumerKey, String consumerSecret) {
        PerpleLog.d(LOG_TAG, "Initializing Twitter.");

        TwitterConfig config = new TwitterConfig.Builder(PerpleSDK.getInstance().getMainActivity())
                .logger(new DefaultLogger(Log.DEBUG))
                .twitterAuthConfig(new TwitterAuthConfig(consumerKey, consumerSecret))
                .debug(true)
                .build();
        Twitter.initialize(config);

        mIsInit = true;
    }

    public void login(final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Twitter is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TWITTER_NOTINITIALIZED, "Twitter is not initialized."));
            return;
        }

        getAuthClient().authorize(PerpleSDK.getInstance().getMainActivity(), new Callback<TwitterSession>() {
            @Override
            public void success(Result<TwitterSession> result) {
                PerpleLog.d(LOG_TAG, "Twitter_login is success.");

                TwitterAuthToken token = result.data.getAuthToken();
                String info = token.token + ";" + token.secret;

                callback.onSuccess(info);
            }

            @Override
            public void failure(TwitterException exception) {
                PerpleLog.d(LOG_TAG, "Twitter_login is failed");

                if (exception.getMessage().contains("cancel"))
                    callback.onFail("cancel");
                else
                    callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TWITTER_LOGIN, ""));
            }
        });

    }

    public void logout() {
        // Can not log out of Twitter, Because the session with Twitter is defined by cookie owned by Twitter.
        PerpleLog.d(LOG_TAG, "Twitter logout but nothing to do. session will be live");
    }

    private String addFileScheme(String filePath) {
        final String scheme = "file://";

        if (filePath != null && !filePath.startsWith(scheme)) {
            return scheme + filePath;
        } else {
            return filePath;
        }
    }

    // Tweet 날리기
    public void composeTweet(final String imageUri, final PerpleSDKCallback callback) {
        if (mReceiver == null) {
            this.registerReceiver(callback);
        }

        TwitterSession session = TwitterCore.getInstance().getSessionManager().getActiveSession();
        if (session == null) {
            getAuthClient().authorize(PerpleSDK.getInstance().getMainActivity(), new Callback<TwitterSession>() {
                @Override
                public void success(Result<TwitterSession> result) {
                    PerpleLog.d(LOG_TAG, "Twitter_login is success.");
                    _composeTweet(imageUri, result.data);
                }

                @Override
                public void failure(TwitterException exception) {
                    PerpleLog.e(LOG_TAG, "Twitter_login is failed");
                    callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TWITTER_LOGIN, ""));
                }
            });
            return;
        }

        _composeTweet(imageUri, session);
    }
    private void _composeTweet(String imageUri, TwitterSession session) {
        Uri uri = Uri.parse(addFileScheme(imageUri));
        PerpleLog.d(LOG_TAG, "uri : " + imageUri);
        PerpleLog.d(LOG_TAG, "final uri : " + uri.toString());

        final Intent intent = new ComposerActivity.Builder(PerpleSDK.getInstance().getMainActivity())
                .session(session)
                .image(uri)
                //.text("compose tweet test.")
                //.hashtags("#dragonvillagem")
                .createIntent();

        PerpleSDK.getInstance().getMainActivity().startActivity(intent);
        PerpleSDK.getInstance().getMainActivity().sendBroadcast(intent);
    }

    // Tweet follow - 콜백 작업 후에 바인딩
    public void follow(final PerpleSDKCallback callback) {
        String userId = "955608372073586688";
        String webIntentUrl = "https://twitter.com/intent/follow?user_id=" + userId;
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(webIntentUrl));

        PerpleSDK.getInstance().getMainActivity().startActivity(browserIntent);
    }

    // Receiver 등록
    private void registerReceiver(final PerpleSDKCallback callback){
        if(mReceiver != null) return;

        final IntentFilter theFilter = new IntentFilter();
        theFilter.addAction(TweetUploadService.UPLOAD_SUCCESS);
        theFilter.addAction(TweetUploadService.UPLOAD_FAILURE);
        theFilter.addAction(TweetUploadService.TWEET_COMPOSE_CANCEL);

        // Receiver 익명 클래스 생성
        this.mReceiver = new PerpleTwitterReceiver(callback);

        // Receiver 등록
        PerpleSDK.getInstance().getMainActivity().registerReceiver(this.mReceiver, theFilter);
    }

    // Receiver 해제
    private void unregisterReceiver() {
        if(mReceiver != null){
            PerpleSDK.getInstance().getMainActivity().unregisterReceiver(mReceiver);
            mReceiver = null;
        }
    }

    public JSONObject getProfileData() {
        TwitterSession twitterSession = TwitterCore.getInstance().getSessionManager().getActiveSession();
        if (twitterSession != null) {
            try {
                JSONObject obj = new JSONObject();
                obj.put("id", twitterSession.getUserId());
                obj.put("name", twitterSession.getUserName());
                return obj;
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == getAuthClient().getRequestCode()) {
            getAuthClient().onActivityResult(requestCode, resultCode, data);
        }
    }

    private TwitterAuthClient getAuthClient() {
        if (mAuthClient == null) {
            mAuthClient = new TwitterAuthClient();
        }
        return mAuthClient;
    }
}
