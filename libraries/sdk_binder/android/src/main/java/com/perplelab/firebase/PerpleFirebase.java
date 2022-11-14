package com.perplelab.firebase;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Scanner;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseException;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.google.firebase.auth.AdditionalUserInfo;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.EmailAuthProvider;
import com.google.firebase.auth.FacebookAuthProvider;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.auth.TwitterAuthProvider;
import com.google.firebase.auth.UserInfo;
import com.google.firebase.auth.UserProfileChangeRequest;
import com.google.firebase.messaging.FirebaseMessaging;

import com.perplelab.PerpleSDK;
import com.perplelab.PerpleSDKCallback;
import com.perplelab.PerpleLog;

import android.net.Uri;
import android.os.Bundle;
import androidx.annotation.NonNull;
import android.util.Log;
import android.widget.Toast;

public class PerpleFirebase {
    private static final String LOG_TAG = "PerpleSDK Firebase";

    private boolean mIsInit;

    private FirebaseAuth.AuthStateListener mAuthListener;
    private boolean mSignedIn;

    private FirebaseAnalytics mFirebaseAnalytics;
    private FirebaseAuth mAuth;

    public PerpleFirebase() {}

    public void init() {
        PerpleLog.d(LOG_TAG, "Initializing Firebase.");

        mAuthListener = new FirebaseAuth.AuthStateListener() {
            @Override
            public void onAuthStateChanged(@NonNull FirebaseAuth firebaseAuth) {
                FirebaseUser user = firebaseAuth.getCurrentUser();
                if (user != null) {
                    // User is signed in
                    mSignedIn = true;
                    PerpleLog.d(LOG_TAG, "Firebase onAuthStateChanged(signed in) - user:" + getLoginInfo(null, user));

                } else {
                    // User is signed out
                    mSignedIn = false;
                    PerpleLog.d(LOG_TAG, "Firebase onAuthStateChanged(signed out)");

                }
            }
        };

        mFirebaseAnalytics = FirebaseAnalytics.getInstance(PerpleSDK.getInstance().getMainActivity());

        // Crashlytics 에 있는 collect_analytics 는 영향을 받지 아니함
        mFirebaseAnalytics.setAnalyticsCollectionEnabled(true);
        mAuth = FirebaseAuth.getInstance();

        mIsInit = true;
    }

    public void onStart() {
        if (mIsInit) {
            mAuth.addAuthStateListener(mAuthListener);
        }
    }

    public void onStop() {
        if (mIsInit) {
            mAuth.removeAuthStateListener(mAuthListener);
        }
    }

    public void logEvent(final String arg0, final String arg1) {
        Bundle params = new Bundle();

        if (!arg1.isEmpty()) {
            try {
                JSONObject jobj = new JSONObject(arg1);
                Iterator<?> keys = jobj.keys();
                while (keys.hasNext()) {
                    String key = (String)keys.next();
                    params.putString(key, (String)jobj.get(key));
                }
            } catch (JSONException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }

        mFirebaseAnalytics.logEvent(arg0, params);
    }

    public void setUserProperty(final String arg0, final String arg1) {
        mFirebaseAnalytics.setUserProperty(arg0, arg1);
    }

    public void autoLogin(final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        if (mSignedIn) {
            String info = getLoginInfo(null, mAuth.getCurrentUser());

            PerpleLog.d(LOG_TAG, "Firebase autoLogin success - info:" + info);

            if (info.isEmpty()) {
                callback.onFail("");
            } else {
                callback.onSuccess(info);
            }
        } else {
            PerpleLog.d(LOG_TAG, "Firebase autoLogin fail");
            callback.onFail("");
        }
    }

    public void loginAnonymously(final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        mAuth.signInAnonymously()
            .addOnCompleteListener(PerpleSDK.getInstance().getMainActivity(), new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    // If sign in fails, display a message to the user. If sign in succeeds
                    // the auth state listener will be notified and logic to handle the
                    // signed in user can be handled in the listener.
                    if (!task.isSuccessful()) {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase loginAnonymously fail - info:" + info);
                        callback.onFail(info);
                    } else {
                        FirebaseUser user = mAuth.getCurrentUser();
                        String info = getLoginInfo(null, user);
                        PerpleLog.d(LOG_TAG, "Firebase loginAnonymously success - info:" + info);
                        callback.onSuccess(info);
                    }
                }
            });
    }

    public void loginEmail(String email, String password, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        mAuth.signInWithEmailAndPassword(email, password)
            .addOnCompleteListener(PerpleSDK.getInstance().getMainActivity(), new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    // If sign in fails, display a message to the user. If sign in succeeds
                    // the auth state listener will be notified and logic to handle the
                    // signed in user can be handled in the listener.
                    if (!task.isSuccessful()) {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase loginEmail fail - info:" + info);
                        callback.onFail(info);
                    } else {
                        FirebaseUser user = mAuth.getCurrentUser();
                        String info = getLoginInfo("password", user);
                        PerpleLog.d(LOG_TAG, "Firebase loginEmail success - info:" + info);
                        callback.onSuccess(info);
                    }
                }
            });
    }
	
	public void signInWithCustomToken(String customToken, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        mAuth.signInWithCustomToken(customToken)
            .addOnCompleteListener(PerpleSDK.getInstance().getMainActivity(), new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    // If sign in fails, display a message to the user. If sign in succeeds
                    // the auth state listener will be notified and logic to handle the
                    // signed in user can be handled in the listener.
                    if (!task.isSuccessful()) {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase signInWithCustomToken fail - info:" + info);
                        callback.onFail(info);
                    } else {
                        FirebaseUser user = mAuth.getCurrentUser();
                        String info = getLoginInfo("customToken", user);
                        PerpleLog.d(LOG_TAG, "Firebase signInWithCustomToken success - info:" + info);
                        callback.onSuccess(info);
                    }
                }
            });
    }

    public void logout() {
        if (!mIsInit) {
            return;
        }

        mAuth.signOut();
    }

    public void deleteUser(final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        // Important: To delete a user, the user must have signed in recently. See Re-authenticate a user.
        mAuth.getCurrentUser().delete()
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    if (task.isSuccessful()) {
                        PerpleLog.d(LOG_TAG, "Firebase deleteUser success");
                        callback.onSuccess("");
                    } else {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase deleteUser fail - info:" + info);
                        callback.onFail(info);
                    }
                }
            });
    }

    public void createUserWithEmail(String email, String password, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        mAuth.createUserWithEmailAndPassword(email, password)
            .addOnCompleteListener(PerpleSDK.getInstance().getMainActivity(), new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    // If sign in fails, display a message to the user. If sign in succeeds
                    // the auth state listener will be notified and logic to handle the
                    // signed in user can be handled in the listener.
                    if (!task.isSuccessful()) {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase createUserWithEmail fail - info:" + info);
                        callback.onFail(info);
                    } else {
                        FirebaseUser user = mAuth.getCurrentUser();
                        String info = getLoginInfo("password", user);
                        PerpleLog.d(LOG_TAG, "Firebase createUserWithEmail success - info:" + info);
                        callback.onSuccess(info);
                    }
                }
            });
    }

    public void sendPasswordResetEmail(String emailAddress, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        mAuth.sendPasswordResetEmail(emailAddress)
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    if (task.isSuccessful()) {
                        PerpleLog.d(LOG_TAG, "Firebase sendPasswordResetEmail success");
                        callback.onSuccess("");
                    } else {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase sendPasswordResetEmail fail - info:" + info);
                        callback.onFail(info);
                    }
                }
            });
    }

    public void signInWithCredential(final String providerId, AuthCredential credential, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        mAuth.signInWithCredential(credential)
            .addOnCompleteListener(PerpleSDK.getInstance().getMainActivity(), new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    // If sign in fails, display a message to the user. If sign in succeeds
                    // the auth state listener will be notified and logic to handle the
                    // signed in user can be handled in the listener.
                    if (!task.isSuccessful()) {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase signInWithCredential fail - info:" + info);
                        callback.onFail(info);
                    } else {
                        AdditionalUserInfo userInfo = task.getResult().getAdditionalUserInfo();
                        String info = getLoginInfo(providerId, userInfo);
                        PerpleLog.d(LOG_TAG, "Firebase signInWithCredential success - info:" + info);
                        callback.onSuccess(info);
                    }
                }
            });
    }

    public void linkWithCredential(final String providerId, AuthCredential credential, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        mAuth.getCurrentUser().linkWithCredential(credential)
            .addOnCompleteListener(PerpleSDK.getInstance().getMainActivity(), new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    // If sign in fails, display a message to the user. If sign in succeeds
                    // the auth state listener will be notified and logic to handle the
                    // signed in user can be handled in the listener.
                    if (!task.isSuccessful()) {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase linkWithCredential fail - info:" + info);
                        callback.onFail(info);
                    } else {
                        AdditionalUserInfo userInfo = task.getResult().getAdditionalUserInfo();
                        String info = getLoginInfo(providerId, userInfo);
                        PerpleLog.d(LOG_TAG, "Firebase linkWithCredential success - info:" + info);
                        callback.onSuccess(info);
                    }
                }
            });
    }

    public void unlink(String providerId, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        mAuth.getCurrentUser().unlink(providerId)
            .addOnCompleteListener(PerpleSDK.getInstance().getMainActivity(), new OnCompleteListener<AuthResult>() {
                @Override
                public void onComplete(@NonNull Task<AuthResult> task) {
                    if (!task.isSuccessful()) {
                        // Auth provider unlinked from account
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase unlink fail - info:" + info);
                        callback.onFail(info);
                    } else {
                        FirebaseUser user = mAuth.getCurrentUser();
                        String info = getLoginInfo(null, user);
                        PerpleLog.d(LOG_TAG, "Firebase unlink success - info:" + info);
                        callback.onSuccess(info);
                    }
                }
            });
    }

    public void reauthenticate(AuthCredential credential, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        // Prompt the user to re-provide their sign-in credentials
        mAuth.getCurrentUser().reauthenticate(credential)
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    if (task.isSuccessful()) {
                        PerpleLog.d(LOG_TAG, "Firebase reauthenticate success");
                        callback.onSuccess("");
                    } else {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase reauthenticate fail - info:" + info);
                        callback.onFail(info);
                    }
                }
            });
    }

    public void updateProfile(String displayName, String photoUri, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        UserProfileChangeRequest profileUpdates = new UserProfileChangeRequest.Builder()
            .setDisplayName(displayName)
            .setPhotoUri(Uri.parse(photoUri))
            .build();

        mAuth.getCurrentUser().updateProfile(profileUpdates)
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    if (task.isSuccessful()) {
                        PerpleLog.d(LOG_TAG, "Firebase updateProfile success");
                        callback.onSuccess("");
                    } else {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase updateProfile fail - info:" + info);
                        callback.onFail(info);
                    }
                }
            });
    }

    public void updateEmail(String newEmail, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        // Important: To set a user's email address, the user must have signed in recently. See Re-authenticate a user.
        mAuth.getCurrentUser().updateEmail("user@example.com")
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    if (task.isSuccessful()) {
                        PerpleLog.d(LOG_TAG, "Firebase updateEmail success");
                        callback.onSuccess("");
                    } else {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase updateEmail fail - info:" + info);
                        callback.onFail(info);
                    }
                }
            });
    }

    public void updatePassword(String newPassword, final PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Firebase is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        // Important: To set a user's password, the user must have signed in recently. See Re-authenticate a user.
        mAuth.getCurrentUser().updatePassword(newPassword)
            .addOnCompleteListener(new OnCompleteListener<Void>() {
                @Override
                public void onComplete(@NonNull Task<Void> task) {
                    if (task.isSuccessful()) {
                        PerpleLog.d(LOG_TAG, "Firebase updatePassword success");
                        callback.onSuccess("");
                    } else {
                        String info = getErrorInfoFromFirebaseException(task.getException());
                        PerpleLog.e(LOG_TAG, "Firebase updatePassword fail - info:" + info);
                        callback.onFail(info);
                    }
                }
            });
    }

    public static AuthCredential getGoogleCredential(String idToken) {
        return GoogleAuthProvider.getCredential(idToken, null);
    }

    public static AuthCredential getFacebookCredential(String token) {
        return FacebookAuthProvider.getCredential(token);
    }

    public static AuthCredential getTwitterCredential(String token, String secret) {
        return TwitterAuthProvider.getCredential(token, secret);
    }

    public static AuthCredential getEmailCredential(String email, String password) {
        return EmailAuthProvider.getCredential(email, password);
    }

    public void subscribeToTopic(String topic) {
        PerpleLog.d(LOG_TAG, "Firebase, Subscribe to news topic: " + topic);
        FirebaseMessaging.getInstance().subscribeToTopic(topic);
    }

    public void unsubscribeFromTopic(String topic) {
        PerpleLog.d(LOG_TAG, "Firebase, Unsubscribe to news topic: " + topic);
        FirebaseMessaging.getInstance().unsubscribeFromTopic(topic);
    }

    private String getLoginInfo(String providerId, FirebaseUser user) {
        if (user != null) {
            try {
                JSONObject obj = new JSONObject();
                obj.put("fuid", user.getUid());
                obj.put("name", getDisplayName(user));
                obj.put("providerId", getProviderId(providerId, user));
                obj.put("providerData", getProviderData(user));
                return obj.toString();
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return "";
    }

    private String getLoginInfo(String providerId, AdditionalUserInfo userInfo) {
        FirebaseUser user = mAuth.getCurrentUser();

        if (user == null) {
            return "";
        }

        String displayName = getDisplayName(user);

        if (userInfo != null) {
            String name = "";
            Object nameObj = userInfo.getProfile().get("name");
            if (nameObj != null) {
                name = nameObj.toString();
            }

            String email = "";
            Object emailObj = userInfo.getProfile().get("email");
            if (emailObj != null) {
                email = emailObj.toString();
            }

            String newDisplayName = name;
            if (!email.isEmpty()) {
                //newDisplayName += "(" + email + ")";
                newDisplayName = email;
            }

            if (!displayName.equals(newDisplayName)) {
                displayName = newDisplayName;
                UserProfileChangeRequest profileUpdates = new UserProfileChangeRequest.Builder()
                        .setDisplayName(displayName)
                        .build();
                user.updateProfile(profileUpdates);
            }
        }

        try {
            JSONObject obj = new JSONObject();
            obj.put("fuid", user.getUid());
            obj.put("name", displayName);
            obj.put("providerId", getProviderId(providerId, user));
            obj.put("providerData", getProviderData(user));
            return obj.toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return "";
    }

    /*
    private static JSONObject getUserProfile(FirebaseUser user) {
        JSONObject obj = new JSONObject();
        if (user != null) {
            try {
                // The user's ID, unique to the Firebase project. Do NOT use this value to
                // authenticate with your backend server, if you have one. Use
                // FirebaseUser.getToken() instead.
                obj.put("fuid", user.getUid());
                obj.put("name", user.getDisplayName());
                obj.put("email", user.getEmail());
                obj.put("photoUrl", user.getPhotoUrl());
                obj.put("providerId", user.getProviderId());

            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return obj;
    }
    */

    private static String getDisplayName(FirebaseUser user) {
        if (user == null) {
            return "";
        }

        if (user.isAnonymous()) {
            return "Guest";
        }

        // user.getDisplayName() 은 null일 수 있음.
        String name = user.getDisplayName();
        if (name == null) {
            name = "";
        }
        return name;
    }

    private static String getProviderId(String providerId, FirebaseUser user) {
        if (providerId != null) {
            return providerId;
        }

        if (user == null) {
            return "";
        }

        if (!user.isAnonymous()) {
            if (user.getProviderData().size() > 0) {
                int lastIdx = user.getProviderData().size() - 1;
                return user.getProviderData().get(lastIdx).getProviderId();
            }
        }

        // user.getProviderId() 는 link된 플랫폼과 상관없이 무조건 상수값으로 "firebase" 임
        return user.getProviderId();
    }

    private static JSONArray getProviderData(FirebaseUser user) {
        JSONArray array = new JSONArray();

        if (user != null) {
            try {
                for (UserInfo profile : user.getProviderData()) {
                    JSONObject obj = new JSONObject();

                    // Id of the provider (ex: google.com, facebook.com, firebase, password)
                    obj.put("providerId", profile.getProviderId());
                    //obj.put("uid", profile.getUid());
                    //obj.put("name", profile.getDisplayName());
                    //obj.put("email", profile.getEmail());
                    //obj.put("photoUrl", profile.getPhotoUrl());

                    array.put(obj);
                };
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        return array;
    }

    public static boolean isLinkedSpecificProvider(String info, String provider) {
        try {
            JSONObject obj = new JSONObject(info);
            JSONArray array = (JSONArray)obj.get("providerData");
            if (array != null) {
                for (int i = 0; i < array.length(); i++) {
                    JSONObject profile = (JSONObject)array.get(i);
                    if (profile != null && provider.equals(profile.getString("providerId"))) {
                        return true;
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static String addGoogleLoginInfo(String loginInfo) {
        try {
            JSONObject obj = new JSONObject(loginInfo);
            if (obj.has("google")) {
                obj.remove("google");
            }
            obj.put("google", PerpleSDK.getGoogle().getProfileData());
            return obj.toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return loginInfo;
    }

    public static String addFacebookLoginInfo(String loginInfo) {
        try {
            JSONObject obj = new JSONObject(loginInfo);
            if (!obj.has("facebook")) {
                obj.put("facebook", PerpleSDK.getFacebook().getProfileData());
                return obj.toString();
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return loginInfo;
    }

    public static String addTwitterLoginInfo(String loginInfo) {
        try {
            JSONObject obj = new JSONObject(loginInfo);
            if (!obj.has("twitter")) {
                obj.put("twitter", PerpleSDK.getTwitter().getProfileData());
                return obj.toString();
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return loginInfo;
    }

    public void getPushToken(final PerpleSDKCallback callback) {
        FirebaseMessaging.getInstance().getToken()
                .addOnCompleteListener(new OnCompleteListener<String>() {
                    @Override
                    public void onComplete(@NonNull Task<String> task) {
                        if (!task.isSuccessful()) {
                            String msg = "Fetching FCM registration token failed";
                            Log.w(LOG_TAG, msg, task.getException());
                            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_FCMTOKENNOTREADY, msg));
                            return;
                        }

                        // Get new FCM registration token
                        String token = task.getResult();

                        // Log and toast
                        //String msg = getString(R.string.msg_token_fmt, token);
                        String msg = "Fetching FCM registration token success";
                        Log.d(LOG_TAG, msg);
                        //Toast.makeText(PerpleSDK.getInstance().getMainActivity(), msg, Toast.LENGTH_SHORT).show();
                        callback.onSuccess(token);
                    }
                });
    }

    public String addNotificationKey(
            String senderId, String userEmail, String registrationId, String idToken)
            throws IOException, JSONException {
        URL url = new URL("https://android.googleapis.com/gcm/googlenotification");
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setDoOutput(true);

        // HTTP request header
        con.setRequestProperty("project_id", senderId);
        con.setRequestProperty("Content-Type", "application/json");
        con.setRequestProperty("Accept", "application/json");
        con.setRequestMethod("POST");
        con.connect();

        // HTTP request
        JSONObject data = new JSONObject();
        data.put("operation", "add");
        data.put("notification_key_name", userEmail);
        data.put("registration_ids", new JSONArray(Arrays.asList(registrationId)));
        data.put("id_token", idToken);

        OutputStream os = con.getOutputStream();
        os.write(data.toString().getBytes("UTF-8"));
        os.close();

        // Read the response into a string
        InputStream is = con.getInputStream();
        @SuppressWarnings("resource")
        String responseString = new Scanner(is, "UTF-8").useDelimiter("\\A").next();
        is.close();

        // Parse the JSON string and return the notification key
        JSONObject response = new JSONObject(responseString);
        return response.getString("notification_key");
    }

    public String removeNotificationKey(
            String senderId, String userEmail, String registrationId, String idToken)
            throws IOException, JSONException {
        URL url = new URL("https://android.googleapis.com/gcm/googlenotification");
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setDoOutput(true);

        // HTTP request header
        con.setRequestProperty("project_id", senderId);
        con.setRequestProperty("Content-Type", "application/json");
        con.setRequestProperty("Accept", "application/json");
        con.setRequestMethod("POST");
        con.connect();

        // HTTP request
        JSONObject data = new JSONObject();
        data.put("operation", "remove");
        data.put("notification_key_name", userEmail);
        data.put("registration_ids", new JSONArray(Arrays.asList(registrationId)));
        data.put("id_token", idToken);

        OutputStream os = con.getOutputStream();
        os.write(data.toString().getBytes("UTF-8"));
        os.close();

        // Read the response into a string
        InputStream is = con.getInputStream();
        @SuppressWarnings("resource")
        String responseString = new Scanner(is, "UTF-8").useDelimiter("\\A").next();
        is.close();

        // Parse the JSON string and return the notification key
        JSONObject response = new JSONObject(responseString);
        return response.getString("notification_key");
    }

    private static String getErrorInfoFromFirebaseException(Exception error) {
        try {
            throw error;
        } catch (FirebaseAuthException e) {
            return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_LOGIN, e.getErrorCode(), e.getMessage());
        } catch (FirebaseException e) {
            return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_LOGIN, e.getMessage());
        } catch (Exception e) {
            return PerpleSDK.getErrorInfo(PerpleSDK.ERROR_UNKNOWN, error.toString());
        }
    }

}