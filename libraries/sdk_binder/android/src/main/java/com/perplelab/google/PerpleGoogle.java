package com.perplelab.google;

import com.perplelab.PerpleSDK;
import com.perplelab.PerpleSDKCallback;
import com.perplelab.PerpleLog;

import org.json.JSONException;
import org.json.JSONObject;

import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.GoogleSignInStatusCodes;
import com.google.android.gms.auth.api.signin.GoogleSignInResult;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.games.Games;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnCompleteListener;

import android.app.Activity;
import android.content.Intent;
import androidx.annotation.NonNull;
import android.view.View;

public class PerpleGoogle {
    private static final String LOG_TAG = "PerpleSDK Google";

    private boolean mIsInit;

    private GoogleSignInClient mGoogleSignInClient;
    private GoogleSignInClient mPlayServicesTemporarySignInClient;
    private GoogleSignInAccount mAccount;

    private PerpleSDKCallback mLoginCallback;
    private PerpleSDKCallback mPlayServicesCallback;

    private boolean mPlayServicesConnected;

    public PerpleGoogle() {}

    public boolean init(String webClientId) {
        PerpleLog.d(LOG_TAG, "Initializing Google with web client id : " +  webClientId);

        // Configure sign-in options to request the user's ID, basic profile, ID token, and email address.
        // User's ID and basic profile are included in DEFAULT_SIGN_IN.
        // DEFAULT_GAME_SIGN_IN show Play Services UI.
        GoogleSignInOptions gso = new GoogleSignInOptions
                .Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken(webClientId)
                .requestEmail()
                .build();

        // Build a GoogleSignInClient with the options specified by gso.
        mGoogleSignInClient = GoogleSignIn.getClient(PerpleSDK.getInstance().getMainActivity(), gso);

        mIsInit = true;
        mPlayServicesTemporarySignInClient = null;
        mPlayServicesConnected = false;

        return true;
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (!mIsInit) {
            return;
        }

        if (requestCode == PerpleSDK.RC_GOOGLE_SIGN_IN) {
            PerpleLog.d(LOG_TAG, "sign in google");

            // Result returned from launching the Intent from GoogleSignInApi.getSignInIntent(...);
            Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
            try {
                PerpleLog.d(LOG_TAG, "Google sign in success");

                // google sign in success
                GoogleSignInAccount account = task.getResult(ApiException.class);
                mLoginCallback.onSuccess(account.getIdToken());
                onConnected(account);

            } catch (ApiException e) {
                PerpleLog.w(LOG_TAG, "Google sign in failed", e);

                // Google sign-in status code
                //---------------------------
                // GoogleSignInStatusCodes.SERVICE_DISABLED (3)
                // GoogleSignInStatusCodes.SIGN_IN_REQUIRED (4)
                // GoogleSignInStatusCodes.INVALID_ACCOUNT (5)
                // GoogleSignInStatusCodes.RESOLUTION_REQUIRED (6)
                // GoogleSignInStatusCodes.NETWORK_ERROR (7)
                // GoogleSignInStatusCodes.INTERNAL_ERROR (8)
                // GoogleSignInStatusCodes.DEVELOPER_ERROR (10)
                // GoogleSignInStatusCodes.ERROR (13)
                // GoogleSignInStatusCodes.INTERRUPTED (14)
                // GoogleSignInStatusCodes.TIMEOUT (15)
                // GoogleSignInStatusCodes.CANCELED (16)
                // GoogleSignInStatusCodes.API_NOT_CONNECTED (17) // Google Play services was not updated.
                // GoogleSignInStatusCodes.DEAD_CLIENT (18)
                // GoogleSignInStatusCodes.SIGN_IN_FAILED (12500)
                // GoogleSignInStatusCodes.SIGN_IN_CANCELED (12501)

                // Google Sign In failed
                int statusCode = e.getStatusCode(); // CommonStatusCode

                if (resultCode == Activity.RESULT_CANCELED) {
                    mLoginCallback.onFail("cancel");
                }else if (statusCode == GoogleSignInStatusCodes.SIGN_IN_REQUIRED) {
                    // retry to sign in.
                    startSignInIntent();
                } else {
                    String codeString = GoogleSignInStatusCodes.getStatusCodeString(statusCode);
                    mLoginCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_LOGIN, String.valueOf(statusCode), codeString));
                }
            }

        } else if (requestCode == PerpleSDK.RC_GOOGLE_PLAYSERVICES_SIGN_IN) {
            GoogleSignInResult result = Auth.GoogleSignInApi.getSignInResultFromIntent(data);

            if (result.isSuccess()) {
                // The signed in account is stored in the result.
                GoogleSignInAccount account = result.getSignInAccount();
                mPlayServicesCallback.onSuccess("");
                mAccount = account; // Important point
                onConnectedPlayServices(account);

            } else {
                if (resultCode == Activity.RESULT_CANCELED) {
                    mPlayServicesCallback.onFail("cancel");
                } else {
                    int statusCode = result.getStatus().getStatusCode();
                    String statusMsg = result.getStatus().getStatusMessage();
                    mPlayServicesCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_PLAYSERVICESLOGIN, String.valueOf(statusCode), statusMsg));
                }
            }

        } else if (requestCode == PerpleSDK.RC_GOOGLE_ACHIEVEMENTS) {
            if (resultCode == Activity.RESULT_OK || resultCode == Activity.RESULT_CANCELED) {
                if (mPlayServicesCallback != null) {
                    mPlayServicesCallback.onSuccess("");
                } else {
                    PerpleLog.e(LOG_TAG, "Play services callback is not set.");
                }
            } else {
                if (mPlayServicesCallback != null) {
                    if (resultCode == 10001) {
                        mPlayServicesCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_LOGOUT, String.valueOf(resultCode), "User logout in the play services UI."));
                    } else {
                        mPlayServicesCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_ACHIEVEMENTS, String.valueOf(resultCode), ""));
                    }
                } else {
                    PerpleLog.e(LOG_TAG, "Play services callback is not set.");
                }
            }
        } else if (requestCode == PerpleSDK.RC_GOOGLE_LEADERBOARDS) {
            if (resultCode == Activity.RESULT_OK || resultCode == Activity.RESULT_CANCELED) {
                if (mPlayServicesCallback != null) {
                    mPlayServicesCallback.onSuccess("");
                } else {
                    PerpleLog.e(LOG_TAG, "Play services callback is not set.");
                }
            } else {
                if (mPlayServicesCallback != null) {
                    if (resultCode == 10001) {
                        mPlayServicesCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_LOGOUT, String.valueOf(resultCode), "User logout in the play services UI."));
                    } else {
                        mPlayServicesCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_LEADERBOARDS, String.valueOf(resultCode), ""));
                    }
                } else {
                    PerpleLog.e(LOG_TAG, "Play services callback is not set.");
                }
            }
        }
    }

    public void login(PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Google is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        if (isSignedIn())
            PerpleLog.d(LOG_TAG, "Already signed in.. with " + getGoogleAccount().getDisplayName());

        mLoginCallback = callback;
        startSignInIntent();
    }

    public void loginSilently(PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Google is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        if (isSignedIn())
            PerpleLog.d(LOG_TAG, "Silent signed in.. with " + getGoogleAccount().getDisplayName());

        mLoginCallback = callback;
        mGoogleSignInClient.silentSignIn().addOnCompleteListener(new OnCompleteListener<GoogleSignInAccount>() {
            @Override
            public void onComplete(@NonNull Task<GoogleSignInAccount> task) {
                if (task.isSuccessful()) {
                    PerpleLog.d(LOG_TAG, "signInSilently(): success");
                    GoogleSignInAccount account = task.getResult();
                    mLoginCallback.onSuccess(account.getIdToken());
                    onConnected(account);
                } else {
                    PerpleLog.d(LOG_TAG, "signInSilently(): failure");
                    Exception exception = task.getException();
                    String msg = "";
                    if (exception != null)
                        msg = exception.getMessage();
                    mLoginCallback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_SILENTLOGIN, msg));
                    onDisconnected();
                }
            }
        });
    }

    // google play services login : It will be called at once, when account have not connected gps.
    public void loginPlayServices(PerpleSDKCallback callback) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Google is not initialized.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        mPlayServicesCallback = callback;
        startPlayServicesSignInIntent();
    }

    public void logout() {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Google is not initialized.");
            return;
        }
        mGoogleSignInClient.signOut();
        onDisconnected();

        // use case : pure google login -> play services login -> logout
        if (mPlayServicesTemporarySignInClient != null)
            mPlayServicesTemporarySignInClient.signOut();
    }

    public void revokeAccess() {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Google is not initialized.");
            return;
        }
        mGoogleSignInClient.revokeAccess();
        onDisconnected();
    }

    private void startSignInIntent() {
        Intent signInIntent = mGoogleSignInClient.getSignInIntent();
        PerpleSDK.getInstance().getMainActivity().startActivityForResult(signInIntent, PerpleSDK.RC_GOOGLE_SIGN_IN);
    }

    private void startPlayServicesSignInIntent() {
        GoogleSignInOptions gso = new GoogleSignInOptions
                .Builder(GoogleSignInOptions.DEFAULT_GAMES_SIGN_IN)
                .build();

        // Build a GoogleSignInClient for Google Play Service.
        mPlayServicesTemporarySignInClient = GoogleSignIn.getClient(PerpleSDK.getInstance().getMainActivity(), gso);
        Intent signInIntent = mPlayServicesTemporarySignInClient.getSignInIntent();
        PerpleSDK.getInstance().getMainActivity().startActivityForResult(signInIntent, PerpleSDK.RC_GOOGLE_PLAYSERVICES_SIGN_IN);
    }

    // call if sign in is success.
    private void onConnected(GoogleSignInAccount account) {
        PerpleLog.d(LOG_TAG, "onConnected(): connected to Google APIs");

        // set account
        if (mAccount != account) {
            mAccount = account;
        }

        // check if account connected to game play services automatically
//        if (isPlayServicesConnectedAccount(account))
//            onConnectedPlayServices(account);
    }

    // call if sign in is success and account have GAME_LITE scope.
    private void onConnectedPlayServices(GoogleSignInAccount account) {
        mPlayServicesConnected = true;

        // set view for popup
        View view = PerpleSDK.getInstance().getMainActivity().getCurrentFocus();
        if (view != null)
            Games.getGamesClient(PerpleSDK.getInstance().getMainActivity(), account)
                    .setViewForPopups(view);

        // set Player
//        Games.getPlayersClient(PerpleSDK.getInstance().getMainActivity(), account)
//                .getCurrentPlayer()
//                .addOnSuccessListener(new OnSuccessListener<Player>() {
//                    @Override
//                    public void onSuccess(Player player) {
//                        mPlayer = player;
//                    }
//                });
    }

    private void onDisconnected() {
        PerpleLog.d(LOG_TAG, "onDisconnected()");
        mAccount = null;
        mLoginCallback = null;
        mPlayServicesCallback = null;
        mPlayServicesConnected = false;
    }

    private GoogleSignInAccount getGoogleAccount() {
        if (mAccount == null)
            mAccount = GoogleSignIn.getLastSignedInAccount(PerpleSDK.getInstance().getMainActivity());

        return mAccount;
    }

    private boolean isSignedIn() {
        return (getGoogleAccount() != null);
    }

    private boolean isPlayServicesConnectedAccount(GoogleSignInAccount account) {
        if (account == null)
            return false;

        if (GoogleSignIn.hasPermissions(account, Games.SCOPE_GAMES_LITE)) {
            PerpleLog.d(LOG_TAG, "Account permission : Games.SCOPE_GAMES_LITE");
            return true;

        }else if (GoogleSignIn.hasPermissions(account, Games.SCOPE_GAMES)) {
            PerpleLog.d(LOG_TAG, "Account permission : Games.SCOPE_GAMES");
            return true;
        }

        return false;
    }

    // @ ref : https://developers.google.com/games/services/android/achievements
    public void showAchievements(final PerpleSDKCallback callback) {
        GoogleSignInAccount account = getGoogleAccount();
        if(account == null) {
            PerpleLog.e(LOG_TAG, "Google sign-in is not available.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTSIGNEDIN, "Google sign-in is not available."));
            return;
        }

        mPlayServicesCallback = callback;

        Games.getAchievementsClient(PerpleSDK.getInstance().getMainActivity(), account)
                .getAchievementsIntent()
                .addOnSuccessListener(new OnSuccessListener<Intent>() {
                    @Override
                    public void onSuccess(Intent intent) {
                        PerpleSDK.getInstance().getMainActivity().startActivityForResult(intent, PerpleSDK.RC_GOOGLE_ACHIEVEMENTS);
                    }
                })
                .addOnFailureListener(new OnFailureListener(){
                    @Override
                    public void onFailure(@NonNull Exception e){
                        callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_ACHIEVEMENTS, e.getMessage()));
                    }
                });
    }
    public void updateAchievements(String achievementId, int numSteps, PerpleSDKCallback callback) {
        GoogleSignInAccount account = getGoogleAccount();
        if (account == null) {
            PerpleLog.e(LOG_TAG, "Google sign-in is not available.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTSIGNEDIN, "Google sign-in is not available."));
            return;
        }

        if (numSteps > 0) {
            Games.getAchievementsClient(PerpleSDK.getInstance().getMainActivity(), account).increment(achievementId, 1);
            callback.onSuccess("");
        } else if (numSteps == 0) {
            Games.getAchievementsClient(PerpleSDK.getInstance().getMainActivity(), account).unlock(achievementId);
            callback.onSuccess("");
        }
    }

    // @ref : https://developers.google.com/games/services/android/leaderboards
    public void showLeaderboards(String leaderBoardId, final PerpleSDKCallback callback) {
        GoogleSignInAccount account = getGoogleAccount();
        if (account == null) {
            PerpleLog.e(LOG_TAG, "Google sign-in is not available.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTSIGNEDIN, "Google sign-in is not available."));
            return;
        }

        mPlayServicesCallback = callback;

        Games.getLeaderboardsClient(PerpleSDK.getInstance().getMainActivity(), account)
                .getLeaderboardIntent(leaderBoardId)
                .addOnSuccessListener(new OnSuccessListener<Intent>() {
                    @Override
                    public void onSuccess(Intent intent) {
                        PerpleSDK.getInstance().getMainActivity().startActivityForResult(intent, PerpleSDK.RC_GOOGLE_LEADERBOARDS);
                    }
                })
                .addOnFailureListener(new OnFailureListener(){
                    @Override
                    public void onFailure(@NonNull Exception e){
                        callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_LEADERBOARDS, e.getMessage()));
                    }
                });
    }
    public void updateLeaderboards(String leaderBoardId, int finalScore, PerpleSDKCallback callback) {
        GoogleSignInAccount account = getGoogleAccount();
        if (account == null) {
            PerpleLog.e(LOG_TAG, "Google sign-in is not available.");
            callback.onFail(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTSIGNEDIN, "Google sign-in is not available."));
            return;
        }

        Games.getLeaderboardsClient(PerpleSDK.getInstance().getMainActivity(), account).submitScore(leaderBoardId, finalScore);
        callback.onSuccess("");
    }

    // id and name are not used anywhere..
    // playServicesConnected use to check whether play service login need or not.
    public JSONObject getProfileData() {
        if (!isSignedIn())
            return null;

        try {
            return new JSONObject()
                    .put("id", mAccount.getId())
                    .put("name", mAccount.getDisplayName())
                    .put("playServicesConnected", mPlayServicesConnected);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return null;
    }

}
