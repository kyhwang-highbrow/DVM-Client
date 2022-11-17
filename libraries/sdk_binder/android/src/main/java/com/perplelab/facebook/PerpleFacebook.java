package com.perplelab.facebook;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookAuthorizationException;
import com.facebook.FacebookCallback;
import com.facebook.FacebookDialogException;
import com.facebook.FacebookException;
import com.facebook.FacebookGraphResponseException;
import com.facebook.FacebookOperationCanceledException;
import com.facebook.FacebookRequestError;
import com.facebook.FacebookSdk;
import com.facebook.FacebookSdkNotInitializedException;
import com.facebook.FacebookServiceException;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;
import com.facebook.LoggingBehavior;
import com.facebook.Profile;
import com.facebook.ProfileTracker;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginBehavior;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.Sharer;
import com.facebook.share.model.GameRequestContent;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.GameRequestDialog;
import com.facebook.share.widget.GameRequestDialog.Result;
import com.facebook.share.widget.ShareDialog;
import com.perplelab.PerpleSDK;
import com.perplelab.PerpleSDKCallback;
import com.perplelab.PerpleLog;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

public class PerpleFacebook {
    private static final String LOG_TAG = "PerpleSDK Facebook";

    private boolean mIsInit;

    private CallbackManager mCallbackManager;
    private ProfileTracker mProfileTracker;

    private String mAccessToken;

    public PerpleFacebook() {}

    public void init() {
        PerpleLog.d(LOG_TAG, "Initializing Facebook.");

        //FacebookSdk.sdkInitialize(PerpleSDK.getInstance().getMainActivity().getApplicationContext()); // @yjkil 22.11.07 deprecated from 4.19.0
        AppEventsLogger.activateApp(PerpleSDK.getInstance().getMainActivity().getApplication());

        mCallbackManager = CallbackManager.Factory.create();

        mAccessToken = "";

        mIsInit = true;

        // 광고 식별자, 자동 앱 이벤트 활성화
        FacebookSdk.setAutoLogAppEventsEnabled(true);
        FacebookSdk.setAdvertiserIDCollectionEnabled(true);

        // 디버그 로그 사용 설정
        //FacebookSdk.setIsDebugEnabled(true);
        //FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS);
    }

    public void onResume() {
        if (mIsInit) {
            AppEventsLogger.activateApp(PerpleSDK.getInstance().getMainActivity().getApplication());
        }
    }

    public void onPause() {
        if (mIsInit) {
			
        }
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (mIsInit) {
            if (mCallbackManager != null) {
                mCallbackManager.onActivityResult(requestCode, resultCode, data);
            }
        }
    }

    public AccessToken getAccessToken() {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Facebook is not initialized.");
            return null;
        }

        return AccessToken.getCurrentAccessToken();
    }

    public Profile getProfile() {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Facebook is not initialized.");
            return null;
        }

        return Profile.getCurrentProfile();
    }

    public void login(final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Facebook is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        if (!mAccessToken.isEmpty()) {
            callback.onSuccess(mAccessToken);
            return;
        }

        LoginManager.getInstance().registerCallback(mCallbackManager,
                new FacebookCallback<LoginResult>() {
                    @Override
                    public void onCancel() {
                        mAccessToken = "";
                        callback.onFail("cancel");
                    }
                    @Override
                    public void onError(FacebookException error) {
                        PerpleLog.e(LOG_TAG, "Facebook login error - desc:" + error.toString());
                        mAccessToken = "";
                        callback.onFail(getErrorInfoFromFacebookException(error));
                    }
                    @Override
                    public void onSuccess(LoginResult result) {
                        final String token = result.getAccessToken().getToken();
                        mAccessToken = token;
                        if (Profile.getCurrentProfile() == null) {
                            mProfileTracker = new ProfileTracker() {
                                @Override
                                protected void onCurrentProfileChanged(Profile oldProfile, Profile newProfile) {
                                    mProfileTracker.stopTracking();
                                    callback.onSuccess(token);
                                }
                            };
                        } else {
                            callback.onSuccess(token);
                        }
                    }
        });

        LoginManager.getInstance().logInWithReadPermissions(
                PerpleSDK.getInstance().getMainActivity(),
                Arrays.asList("public_profile", "email")
        );
    }

    public void logout() {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Facebook is not initialized.");
            return;
        }

        LoginManager.getInstance().logOut();
        mAccessToken = "";
    }

    public void sendGameRequest(String info, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Facebook is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        try {

            JSONObject obj = new JSONObject(info);
            String title = obj.getString("title");
            String message = obj.getString("message");
            String to = obj.getString("to");
            List<String> recipients = new ArrayList<String>();
            recipients.add(to);

            GameRequestContent content = new GameRequestContent.Builder()
                .setTitle(title)
                .setMessage(message)
                .setRecipients(recipients)
                .build();

            GameRequestDialog dialog = new GameRequestDialog(PerpleSDK.getInstance().getMainActivity());
            dialog.registerCallback(mCallbackManager, new FacebookCallback<GameRequestDialog.Result>() {
                @Override
                public void onCancel() {
                    callback.onFail("cancel");
                }
                @Override
                public void onError(FacebookException error) {
                    callback.onFail(getErrorInfoFromFacebookException(error));
                }
                @Override
                public void onSuccess(Result result) {
                    callback.onSuccess(result.getRequestId());
                }
            });

            dialog.show(content);

        } catch (JSONException e) {
            e.printStackTrace();
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_REQUEST, PerpleSDK.ERROR_JSONEXCEPTION, e.toString()));
        }
    }

    public void sendGameSharing(String info, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Facebook is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        ShareDialog dialog = new ShareDialog(PerpleSDK.getInstance().getMainActivity());
        dialog.registerCallback(mCallbackManager, new FacebookCallback<Sharer.Result>() {
            @Override
            public void onCancel() {
                callback.onFail("cancel");
            }
            @Override
            public void onError(FacebookException error) {
                callback.onFail(getErrorInfoFromFacebookException(error));
            }
            @Override
            public void onSuccess(Sharer.Result result) {
                callback.onSuccess(result.getPostId());
            }
        });

        if (ShareDialog.canShow(ShareLinkContent.class)) {
            JSONObject obj;
            try {
                obj = new JSONObject(info);
                String title = obj.getString("title");
                String message = obj.getString("message");
                String url = obj.getString("url");
                String to = obj.getString("to");
                List<String> peopleIds = new ArrayList<String>();
                peopleIds.add(to);

                ShareLinkContent content = new ShareLinkContent.Builder()
                    .setQuote(message)
                    .setContentUrl(Uri.parse(url))
                    .setPeopleIds(peopleIds)
                    .build();

                dialog.show(content);
            } catch (JSONException e) {
                e.printStackTrace();
                callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_SHARE, PerpleSDK.ERROR_JSONEXCEPTION, e.toString()));
            }
        } else {
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_SHARE, "Cannot show ShareDialog."));
        }
    }

    public boolean isGrantedPermission(String permission) {
        boolean status = false;
        AccessToken accessToken = AccessToken.getCurrentAccessToken();
        if (accessToken != null) {
            Set<String> Permissions = accessToken.getPermissions();
            status = Permissions.contains(permission);
        }
        return status;
    }

    public void askPermission(String permission, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Facebook is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        LoginManager.getInstance().registerCallback(mCallbackManager,
                new FacebookCallback<LoginResult>() {
                    @Override
                    public void onCancel() {
                        callback.onFail("cancel");
                    }
                    @Override
                    public void onError(FacebookException error) {
                        PerpleLog.e(LOG_TAG, "Facebook askPermission error - desc:" + error.toString());
                        callback.onFail(getErrorInfoFromFacebookException(error));
                    }
                    @Override
                    public void onSuccess(LoginResult result) {
                        mAccessToken = result.getAccessToken().getToken();
                        callback.onSuccess(mAccessToken);
                    }
        });

        LoginManager.getInstance().logInWithReadPermissions(
                PerpleSDK.getInstance().getMainActivity(),
                Arrays.asList(permission)
        );
    }

    public void getFriends(final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Facebook is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        Bundle args = new Bundle();
        args.putInt("limit", 5000);

        new GraphRequest(
            AccessToken.getCurrentAccessToken(),
            "/me/friends",
            args,
            HttpMethod.GET,
            new GraphRequest.Callback() {
                public void onCompleted(GraphResponse response) {
                    PerpleLog.d(LOG_TAG, "Facebook friends - response:" + response.toString());

                    FacebookRequestError error = response.getError();
                    if (error != null) {
                        callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_GRAPHAPI, error.getRequestResultBody().toString()));
                    } else {
                        callback.onSuccess(convertFriendsListFormat(response.getJSONObject()));
                    }
                }
            }
        ).executeAsync();
    }

    public void getInvitableFriends(final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Facebook is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        Bundle args = new Bundle();
        args.putInt("limit", 5000);

        new GraphRequest(
            AccessToken.getCurrentAccessToken(),
            "/me/invitable_friends",
            args,
            HttpMethod.GET,
            new GraphRequest.Callback() {
                public void onCompleted(GraphResponse response) {
                    PerpleLog.d(LOG_TAG, "Facebook invitable_friends - response:" + response.toString());

                    FacebookRequestError error = response.getError();
                    if (error != null) {
                        callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_GRAPHAPI, error.getRequestResultBody().toString()));
                    } else {
                        callback.onSuccess(convertInvitableFriendsListFormat(response.getJSONObject()));
                    }
                }
            }
        ).executeAsync();
    }

    public void notifications(String receiverId, String message, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Facebook is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        String userId = "/" + receiverId + "/";
        Bundle args = new Bundle();
        args.putString("template", message);

        new GraphRequest(
            AccessToken.getCurrentAccessToken(),
            userId + "notifications",
            args,
            HttpMethod.POST,
            new GraphRequest.Callback() {
                public void onCompleted(GraphResponse response) {
                    PerpleLog.d(LOG_TAG, "Facebook notifications - response:" + response.toString());

                    FacebookRequestError error = response.getError();
                    if (error != null) {
                        callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_GRAPHAPI, error.getRequestResultBody().toString()));
                    } else {
                        callback.onSuccess("");
                    }
                }
            }
        ).executeAsync();
    }

    public JSONObject getProfileData() {
        Profile profile = getProfile();
        if (profile != null) {
            try {
                JSONObject obj = new JSONObject();
                obj.put("id", profile.getId());
                obj.put("name", profile.getName());
                //obj.put("photoUrl", profile.getProfilePictureUri(64, 64));
                return obj;
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    private static String convertFriendsListFormat(JSONObject obj) {
        try {
            JSONArray outArray = new JSONArray();
            JSONArray inArray = obj.getJSONArray("data");
            for (int i = 0; i < inArray.length(); i++) {
                // parsing original json
                JSONObject friendObj = (JSONObject)inArray.get(i);
                String id = friendObj.getString("id");
                String name = friendObj.getString("name");

                // make new json
                JSONObject outObj = new JSONObject();
                outObj.put("id", id);
                outObj.put("name", name);
                outArray.put(outObj);
            }
            return outArray.toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return "";
    }

    private static String convertInvitableFriendsListFormat(JSONObject obj) {
        try {
            JSONArray outArray = new JSONArray();
            JSONArray inArray = obj.getJSONArray("data");
            for (int i = 0; i < inArray.length(); i++) {
                // parsing original json
                JSONObject friendObj = (JSONObject)inArray.get(i);
                String id = friendObj.getString("id");
                String name = friendObj.getString("name");
                JSONObject pictureObj = (JSONObject)friendObj.get("picture");
                JSONObject pictureDataObj = (JSONObject)pictureObj.get("data");
                String photoUrl = pictureDataObj.getString("url");

                // make new json
                JSONObject outObj = new JSONObject();
                outObj.put("id", id);
                outObj.put("name", name);
                outObj.put("photoUrl", photoUrl);
                outArray.put(outObj);
            }
            return outArray.toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return "";
    }

    public static String getErrorInfoFromFacebookException(Exception error) {
        if (error instanceof FacebookException) {
            if (error instanceof FacebookAuthorizationException) {
                FacebookAuthorizationException e = (FacebookAuthorizationException)error;
                return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_AUTHORIZATIONEXCEPTION, e.toString());
            } else if (error instanceof FacebookDialogException) {
                FacebookDialogException e = (FacebookDialogException)error;
                return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_DIALOGEXCEPTION, String.valueOf(e.getErrorCode()), e.toString());
            } else if (error instanceof FacebookGraphResponseException) {
                FacebookGraphResponseException e = (FacebookGraphResponseException)error;
                FacebookRequestError requestError = (e.getGraphResponse() != null ? e.getGraphResponse().getError() : null);
                if (requestError != null) {
                    return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_GRAPHRESPONSEEXCEPTION, String.valueOf(requestError.getErrorCode()), requestError.getErrorMessage());
                } else {
                    return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_GRAPHRESPONSEEXCEPTION, e.toString());
                }
            } else if (error instanceof FacebookOperationCanceledException) {
                FacebookOperationCanceledException e = (FacebookOperationCanceledException)error;
                return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_OPERATIONCANCELEDEXCEPTION, e.toString());
            } else if (error instanceof FacebookSdkNotInitializedException) {
                FacebookSdkNotInitializedException e = (FacebookSdkNotInitializedException)error;
                return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_SDKNOTINITIALIZEDEXCEPTION, e.toString());
            } else if (error instanceof FacebookServiceException) {
                FacebookServiceException e = (FacebookServiceException)error;
                FacebookRequestError requestError = e.getRequestError();
                if (requestError != null) {
                    return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_SERVICEEXCEPTION, String.valueOf(requestError.getErrorCode()), requestError.getErrorMessage());
                } else {
                    return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_SERVICEEXCEPTION, e.toString());
                }
            } else {
                FacebookException e = (FacebookException)error;
                return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_FACEBOOKEXCEPTION, e.toString());
            }
        } else {
            return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_UNKNOWN, error.toString());
        }
    }
}
