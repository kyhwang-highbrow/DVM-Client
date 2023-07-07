package com.perplelab;

import android.util.Log;
import org.json.JSONObject;
import com.perplelab.firebase.PerpleCrashlytics;
import com.perplelab.firebase.PerpleFirebase;
import com.perplelab.tapjoy.PerpleTapjoyPlacementCallback;
import com.perplelab.util.PerpleUtil;

public class PerpleSDKLua {
    private static final String LOG_TAG = "PerpleSDKLua";


    // 루아 스크립트 엔진 재시작시 프로세스 아이디를 변경시켜,
    // 이전 프로세스에서 넘어오는 콜백함수가 루아로 전달되지 않도록 한다.
    public static void resetLuaBinding(final int funcID) {
        PerpleSDK.ProcessId++;
        if (PerpleSDK.ProcessId > 65534) {
            PerpleSDK.ProcessId = 1;
        }
    }

    public static void setPlatformServerSecretKey(final int funcID, String secretKey, String algorithm) {
        PerpleSDK.PlatformServerEncryptSecretKey = secretKey;
        PerpleSDK.PlatformServerEncryptAlgorithm = algorithm;
    }

    // @firebase fcm
    public static void setFCMPushOnForeground(final int funcID, int isReceive) {
        PerpleSDK.IsReceivePushOnForeground = (isReceive != 0);
    }

    // @firebase fcm
    public static void setFCMTokenRefresh(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        PerpleSDK.setFCMTokenRefreshCallback(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "refresh", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "error", info);
            }
        });
    }

    // @firebase fcm
    public static void getFCMToken(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            String info = PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized.");
            PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            return;
        }

        PerpleSDK.getFirebase().getPushToken(
                new PerpleSDKCallback() {
                    @Override
                    public void onSuccess(String info) {
                        PerpleSDK.callSDKResult(pID, funcID, "success", info);
                    }
                    @Override
                    public void onFail(String info) {
                        PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                    }
                }
        );
    }

    // @firebase fcm
    public static void subscribeToTopic(final int funcID, final String topic) {
        if (PerpleSDK.getFirebase() != null) {
            PerpleSDK.getFirebase().subscribeToTopic(topic);
        }
    }

    // @firebase fcm
    public static void unsubscribeFromTopic(final int funcID, final String topic) {
        if (PerpleSDK.getFirebase() != null) {
            PerpleSDK.getFirebase().unsubscribeFromTopic(topic);
        }
    }

    // @firebase
    public static void logEvent(final int funcID, final String arg0, final String arg1) {
        if (PerpleSDK.getFirebase() != null) {
            PerpleSDK.getFirebase().logEvent(arg0, arg1);
        }
    }

    // @firebase
    public static void setUserProperty(final int funcID, final String arg0, final String arg1) {
        if (PerpleSDK.getFirebase() != null) {
            PerpleSDK.getFirebase().setUserProperty(arg0, arg1);
        }
    }

    // @firebase
    public static void autoLogin(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().autoLogin(
            new PerpleSDKCallback() {
                @Override
                public void onSuccess(String info) {
                    PerpleSDK.callSDKResult(pID, funcID, "success", info);
                }

                @Override
                public void onFail(String info) {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            });
    }

    // @firebase
    public static void loginAnonymously(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().loginAnonymously(
            new PerpleSDKCallback() {
                @Override
                public void onSuccess(String info) {
                    PerpleSDK.callSDKResult(pID, funcID, "success", info);
                }
                @Override
                public void onFail(String info) {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            });
    }

    // @firebase, @google
    public static void loginWithGoogle(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        if (PerpleSDK.getGoogle() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        PerpleSDK.getGoogle().login(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String idToken) {
                PerpleSDK.getFirebase().signInWithCredential(
                        "google.com",
                        PerpleFirebase.getGoogleCredential(idToken),
                        new PerpleSDKCallback() {
                            @Override
                            public void onSuccess(String info) {
                                PerpleSDK.callSDKResult(pID, funcID, "success", PerpleFirebase.addGoogleLoginInfo(info));
                            }
                            @Override
                            public void onFail(String info) {
                                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                            }
                        });
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", "");
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @firebase, @facebook
    public static void loginWithFacebook(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        if (PerpleSDK.getFacebook() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        PerpleSDK.getFacebook().login(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String token) {
                PerpleSDK.getFirebase().signInWithCredential(
                        "facebook.com",
                        PerpleFirebase.getFacebookCredential(token),
                        new PerpleSDKCallback() {
                            @Override
                            public void onSuccess(String info) {
                                PerpleSDK.callSDKResult(pID, funcID, "success", PerpleFirebase.addFacebookLoginInfo(info));
                            }
                            @Override
                            public void onFail(String info) {
                                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                            }
                        });
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", "");
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @firebase, @twitter
    public static void loginWithTwitter(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        if (PerpleSDK.getTwitter() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TWITTER_NOTINITIALIZED, "Twitter is not initialized."));
            return;
        }

        PerpleSDK.getTwitter().login(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                String[] data = info.split(";");
                String token = data[0];
                String secret = data[1];
                PerpleSDK.getFirebase().signInWithCredential(
                        "twitter.com",
                        PerpleFirebase.getTwitterCredential(token, secret),
                        new PerpleSDKCallback() {
                            @Override
                            public void onSuccess(String info) {
                                PerpleSDK.callSDKResult(pID, funcID, "success", PerpleFirebase.addTwitterLoginInfo(info));
                            }
                            @Override
                            public void onFail(String info) {
                                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                            }
                        });
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", "");
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @firebase, @gamecenter
    public static void loginWithGameCenter(final int funcID, String param1) {
        // do nothing
    }

    // @firebase, @apple
    public static void loginWithApple(final int funcID) { }

    // @firebase
    public static void loginWithEmail(final int funcID, String email, String password) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().loginEmail(
            email,
            password,
            new PerpleSDKCallback() {
                @Override
                public void onSuccess(String info) {
                    PerpleSDK.callSDKResult(pID, funcID, "success", info);
                }
                @Override
                public void onFail(String info) {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            });
    }
	
	// @firebase
    public static void loginWithCustomToken(final int funcID, String customToken) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().signInWithCustomToken(
            customToken,
            new PerpleSDKCallback() {
                @Override
                public void onSuccess(String info) {
                    PerpleSDK.callSDKResult(pID, funcID, "success", info);
                }
                @Override
                public void onFail(String info) {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            });
    }

    // @firebase, @google
    public static void linkWithGoogle(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        if (PerpleSDK.getGoogle() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        PerpleSDK.getGoogle().login(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String idToken) {
                PerpleSDK.getFirebase().linkWithCredential(
                        "google.com",
                        PerpleFirebase.getGoogleCredential(idToken),
                        new PerpleSDKCallback() {
                            @Override
                            public void onSuccess(String info) {
                                PerpleSDK.callSDKResult(pID, funcID, "success", PerpleFirebase.addGoogleLoginInfo(info));
                            }
                            @Override
                            public void onFail(String info) {

                                String code = PerpleSDK.getItemFromInfo(info, "code");
                                String subcode = PerpleSDK.getItemFromInfo(info, "subcode");
                                if (code.equals(PerpleSDK.ERROR_FIREBASE_LOGIN) && subcode.equals("ERROR_CREDENTIAL_ALREADY_IN_USE")) {
                                    PerpleSDK.callSDKResult(pID, funcID, "already_in_use", PerpleFirebase.addGoogleLoginInfo(info));
                                } else {
                                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                                }

                            }
                        });
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", "");
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @firebase, @facebook
    public static void linkWithFacebook(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        if (PerpleSDK.getFacebook() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        PerpleSDK.getFacebook().login(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String token) {
                PerpleSDK.getFirebase().linkWithCredential(
                        "facebook.com",
                        PerpleFirebase.getFacebookCredential(token),
                        new PerpleSDKCallback() {
                            @Override
                            public void onSuccess(String info) {
                                PerpleSDK.callSDKResult(pID, funcID, "success", PerpleFirebase.addFacebookLoginInfo(info));
                            }
                            @Override
                            public void onFail(String info) {
                                String code = PerpleSDK.getItemFromInfo(info, "code");
                                String subcode = PerpleSDK.getItemFromInfo(info, "subcode");
                                if (code.equals(PerpleSDK.ERROR_FIREBASE_LOGIN) && subcode.equals("ERROR_CREDENTIAL_ALREADY_IN_USE")) {
                                    PerpleSDK.callSDKResult(pID, funcID, "already_in_use", PerpleFirebase.addFacebookLoginInfo(info));
                                } else {
                                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                                }
                            }
                        });
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", "");
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @firebase, @twitter
    public static void linkWithTwitter(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        if (PerpleSDK.getTwitter() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TWITTER_NOTINITIALIZED, "Twitter is not initialized."));
            return;
        }

        PerpleSDK.getTwitter().login(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                String[] data = info.split(";");
                String token = data[0];
                String secret = data[1];

                PerpleSDK.getFirebase().linkWithCredential(
                        "twitter.com",
                        PerpleFirebase.getTwitterCredential(token, secret),
                        new PerpleSDKCallback() {
                            @Override
                            public void onSuccess(String info) {
                                PerpleSDK.callSDKResult(pID, funcID, "success", PerpleFirebase.addTwitterLoginInfo(info));
                            }
                            @Override
                            public void onFail(String info) {
                                String code = PerpleSDK.getItemFromInfo(info, "code");
                                String subcode = PerpleSDK.getItemFromInfo(info, "subcode");
                                if (code.equals(PerpleSDK.ERROR_FIREBASE_LOGIN) && subcode.equals("ERROR_CREDENTIAL_ALREADY_IN_USE")) {
                                    PerpleSDK.callSDKResult(pID, funcID, "already_in_use", PerpleFirebase.addTwitterLoginInfo(info));
                                } else {
                                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                                }
                            }
                        });
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", "");
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @firebase, @apple
    public static void linkWithApple(final int funcID) { }

    // @firebase
    public static void linkWithEmail(final int funcID, String email, String password) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().linkWithCredential(
                "email",
                PerpleFirebase.getEmailCredential(email, password),
                new PerpleSDKCallback() {
                    @Override
                    public void onSuccess(String info) {
                        PerpleSDK.callSDKResult(pID, funcID, "success", info);
                    }
                    @Override
                    public void onFail(String info) {
                        PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                    }
                });
    }

    // @firebase, @google
    public static void unlinkWithGoogle(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().unlink("google.com", new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @firebase, @facebook
    public static void unlinkWithFacebook(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().unlink("facebook.com", new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @firebase, @twitter
    public static void unlinkWithTwitter(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().unlink("twitter.com", new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @firebase, @apple
    public static void unlinkWithApple(final int funcID) { }

    // @firebase
    public static void unlinkWithEmail(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().unlink("email", new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @firebase
    public static void logout(final int funcID) {
        if (PerpleSDK.getFirebase() != null) {
            PerpleSDK.getFirebase().logout();
        }
    }

    // @firebase
    public static void deleteUser(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().deleteUser(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @firebase
    public static void createUserWithEmail(final int funcID, String email, String password) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().createUserWithEmail(email, password, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @firebase
    public static void sendPasswordResetEmail(final int funcID, String email) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFirebase() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FIREBASE_NOTINITIALIZED, "Firebase is not initialized."));
            return;
        }

        PerpleSDK.getFirebase().sendPasswordResetEmail(email, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @facebook
    public static void facebookLogin(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFacebook() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        PerpleSDK.getFacebook().login(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String token) {
                String info = "";
                JSONObject obj = PerpleSDK.getFacebook().getProfileData();
                if (obj != null) {
                    info = obj.toString();
                }
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", info);
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @facebook
    public static void facebookLogout(final int funcID) {
        if (PerpleSDK.getFacebook() != null) {
            PerpleSDK.getFacebook().logout();
        }
    }

    // @facebook
    public static void facebookSendRequest(final int funcID, String data) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFacebook() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        PerpleSDK.getFacebook().sendGameRequest(data, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", "");
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @facebook
    public static void facebookSendSharing(final int funcID, String data) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFacebook() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        PerpleSDK.getFacebook().sendGameSharing(data, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", "");
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @facebook
    public static void facebookGetFriends(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFacebook() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        PerpleSDK.getFacebook().getFriends(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @facebook
    public static void facebookGetInvitableFriends(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFacebook() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        PerpleSDK.getFacebook().getInvitableFriends(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @facebook
    public static void facebookNotifications(final int funcID, String receiverId, String message) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFacebook() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        PerpleSDK.getFacebook().notifications(receiverId, message, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @facebook
    public static boolean facebookIsGrantedPermission(final int funcID, String permission) {
        boolean ret = false;
        if (PerpleSDK.getFacebook() != null) {
            ret = PerpleSDK.getFacebook().isGrantedPermission(permission);
        }
        return ret;
    }

    // @facebook
    public static void facebookAskPermission(final int funcID, String permission) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getFacebook() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_FACEBOOK_NOTINITIALIZED, "Facebook is not initialized."));
            return;
        }

        PerpleSDK.getFacebook().askPermission(permission, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @twitter
    public static void twitterLogin(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getTwitter() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TWITTER_NOTINITIALIZED, "Twitter is not initialized."));
            return;
        }

        PerpleSDK.getTwitter().login(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String token) {
                String info = "";
                JSONObject obj = PerpleSDK.getTwitter().getProfileData();
                if (obj != null) {
                    info = obj.toString();
                }
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", info);
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @twitter
    public static void twitterLogout(final int funcID) {
        if (PerpleSDK.getTwitter() != null) {
            PerpleSDK.getTwitter().logout();
        }
    }

    // @twitter
    public static void twitterComposeTweet(final int funcID, String imageUrl) {
         final int pID = PerpleSDK.ProcessId;
         if (PerpleSDK.getTwitter() == null) {
             PerpleSDK.callSDKResult(pID, funcID, "fail",
                     PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TWITTER_NOTINITIALIZED, "Twitter is not initialized."));
             return;
         }

         PerpleSDK.getTwitter().composeTweet(imageUrl, new PerpleSDKCallback() {
             @Override
             public void onSuccess(String info) {
                 PerpleSDK.callSDKResult(pID, funcID, "success", info);
             }
             @Override
             public void onFail(String info) {
                 if (info.equals("cancel"))
                     PerpleSDK.callSDKResult(pID, funcID, "cancel", info);
                 else
                     PerpleSDK.callSDKResult(pID, funcID, "fail", info);
             }
         });
        Log.d("twitterComposeTweet", "disable");
    }

    // @twitter
    public static void twitterFollow(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getTwitter() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TWITTER_NOTINITIALIZED, "Twitter is not initialized."));
            return;
        }

        PerpleSDK.getTwitter().follow(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String token) {
                PerpleSDK.callSDKResult(pID, funcID, "success", "");
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @tapjoy
    public static void tapjoyEvent(final int funcID, String cmd, String arg0, String arg1) {
        if (PerpleSDK.getTapjoy() != null) {
             PerpleSDK.getTapjoy().setEvent(cmd, arg0, arg1);
        }
    }

    // @tapjoy
    public static void tapjoySetTrackPurchase(final int funcID, int flag) {
        if (PerpleSDK.getTapjoy() != null) {
            PerpleSDK.getTapjoy().setTrackPurchase(flag == 1);
        }
    }

    // @tapjoy
    public static void tapjoySetPlacement(final int funcID, String placementName) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getTapjoy() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TAPJOY_NOTINITIALIZED, "Tapjoy is not initialized."));
            return;
        }

        PerpleSDK.getTapjoy().setPlacement(placementName, new PerpleTapjoyPlacementCallback() {
            @Override
            public void onRequestSuccess() {
                PerpleSDK.callSDKResult(pID, funcID, "success", "");
            }
            @Override
            public void onRequestFailure(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
            @Override
            public void onContentReady() {
                PerpleSDK.callSDKResult(pID, funcID, "ready", "");
            }
            @Override
            public void onPurchaseRequest(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "purchase", info);
            }
            @Override
            public void onRewardRequest(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "reward", info);
            }
            @Override
            public void onError(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "error", info);
            }
            @Override
            public void onShow() {}
            @Override
            public void onWait() {}
            @Override
            public void onDismiss() {}
        });
    }

    // @tapjoy
    public static void tapjoyShowPlacement(final int funcID, String placementName) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getTapjoy() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TAPJOY_NOTINITIALIZED, "Tapjoy is not initialized."));
            return;
        }

        PerpleSDK.getTapjoy().showPlacement(placementName, new PerpleTapjoyPlacementCallback() {
            @Override
            public void onShow() {
                PerpleSDK.callSDKResult(pID, funcID, "show", "");
            }
            @Override
            public void onWait() {
                PerpleSDK.callSDKResult(pID, funcID, "wait", "");
            }
            @Override
            public void onDismiss() {
                PerpleSDK.callSDKResult(pID, funcID, "dismiss", "");
            }
            @Override
            public void onError(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "error", info);
            }
            @Override
            public void onRequestSuccess() {}
            @Override
            public void onRequestFailure(String info) {}
            @Override
            public void onContentReady() {}
            @Override
            public void onPurchaseRequest(String info) {}
            @Override
            public void onRewardRequest(String info) {}
        });
    }

    // @tapjoy
    public static void tapjoyGetCurrency(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getTapjoy() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TAPJOY_NOTINITIALIZED, "Tapjoy is not initialized."));
            return;
        }

        PerpleSDK.getTapjoy().getCurrency(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @tapjoy
    public static void tapjoySetEarnedCurrencyCallback(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getTapjoy() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TAPJOY_NOTINITIALIZED, "Tapjoy is not initialized."));
            return;
        }

        PerpleSDK.getTapjoy().setEarnedCurrencyCallback(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "earn", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "error", info);
            }
        });
    }

    // @tapjoy
    public static void tapjoySpendCurrency(final int funcID, int amount) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getTapjoy() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TAPJOY_NOTINITIALIZED, "Tapjoy is not initialized."));
            return;
        }

        PerpleSDK.getTapjoy().spendCurrency(amount, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @tapjoy
    public static void tapjoyAwardCurrency(final int funcID, int amount) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getTapjoy() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_TAPJOY_NOTINITIALIZED, "Tapjoy is not initialized."));
            return;
        }

        PerpleSDK.getTapjoy().awardCurrency(amount, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @google - not assigned
    public static void googleLogin(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getGoogle() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        PerpleSDK.getGoogle().login(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", info);
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @google - use for auto login
    public static void googleSilentLogin(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getGoogle() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        PerpleSDK.getGoogle().loginSilently(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @google - use for auto login
    public static void googlePlayServiceLogin(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getGoogle() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        PerpleSDK.getGoogle().loginPlayServices(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", "");
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @google
    public static void googleLogout(final int funcID) {
        if (PerpleSDK.getGoogle() != null) {
            PerpleSDK.getGoogle().logout();
        }
    }

    // @google
    public static void googleRevokeAccess(final int funcID) {
        if (PerpleSDK.getGoogle() != null) {
            PerpleSDK.getGoogle().revokeAccess();
        }
    }

    // @google
    public static void googleShowAchievements(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getGoogle() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        PerpleSDK.getGoogle().showAchievements(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @google
    public static void googleShowLeaderboards(final int funcID, String leaderBoardId) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getGoogle() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        PerpleSDK.getGoogle().showLeaderboards(leaderBoardId, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @google
    public static void googleUpdateAchievements(final int funcID, String id, String steps) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getGoogle() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        PerpleSDK.getGoogle().updateAchievements(id, Integer.parseInt(steps), new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @google
    public static void googleUpdateLeaderboards(final int funcID, String id, String score) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getGoogle() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_GOOGLE_NOTINITIALIZED, "Google is not initialized."));
            return;
        }

        PerpleSDK.getGoogle().updateLeaderboards(id, Integer.parseInt(score), new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @game center
    public static void gameCenterLogin(final int funcID) {
        // do nothing
    }

    // @apple
    public static void appleLogin(final int funcID) { }
    public static void appleLogout(final int funcID) { }

    // @billing
    public static void billingSetup(final int funcID, String checkReceiptServerUrl, String saveTransactionIdUrl) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getBilling() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_NOTINITIALIZED, "Billing is not initialized."));
            return;
        }

        String receipt_url = "";
        if (checkReceiptServerUrl != null)
            receipt_url = checkReceiptServerUrl;

        String save_transaction_url = "";
        if (saveTransactionIdUrl != null)
            save_transaction_url = saveTransactionIdUrl;

        PerpleSDK.getBilling().startSetup(receipt_url, save_transaction_url, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
                Log.d("In-App Billing", info);
            }

            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "error", info);
                Log.d("In-App Billing", info);
            }
        });
    }

    // @billing
    public static void billingConfirm(final int funcID, String orderId) {
        if (PerpleSDK.getBilling() != null) {
            PerpleSDK.getBilling().consume(orderId);
        }
    }

    // @billing
    public static void billingPurchase(final int funcID, String productId, String payload) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getBilling() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_NOTINITIALIZED, "Billing is not initialized."));
            return;
        }

        PerpleSDK.getBilling().purchase(productId, payload, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                Log.d(LOG_TAG, "billingPurchase success : " + info);
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                Log.d(LOG_TAG, "billingPurchase fail : " + info);
                PerpleSDK.callSDKResult(pID, funcID, "cancel", info);
            }
        });
    }

    // @billing
    public static void billingGetItemList(final int funcID, String productIdList ) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getBilling() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_NOTINITIALIZED, "Billing is not initialized."));
            return;
        }

        PerpleSDK.getBilling().getItemList(productIdList, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @billing
    public static void billingGetIncompletePurchaseList(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getBilling() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_NOTINITIALIZED, "Billing is not initialized."));
            return;
        }

        PerpleSDK.getBilling().getIncompletePurchaseList(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @billing
    public static void billingSubscription(final int funcID, String sku, String payload) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getBilling() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "fail",
                    PerpleSDK.getErrorInfo(PerpleSDK.ERROR_BILLING_NOTINITIALIZED, "Billing is not initialized."));
            return;
        }



        /* @ochoi 2021.03.19 구글 결제 라이브러리 4로 업그레이드 하면서 일단 제거
        PerpleSDK.getBilling().subscription(sku, payload, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", "");
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });*/
    }

    //@Adjust
    public static void adjustTrackEvent( int funcID, String eventKey ) {
        PerpleSDK.getAdjust().trackEvent(eventKey);
    }

    public static void adjustTrackPayment( int funcID, String eventKey, String price, String currency ) {
        PerpleSDK.getAdjust().trackPayment(eventKey, price, currency);
    }

    public static String adjustGetAdid(int funcID) {
        return PerpleSDK.getAdjust().getAdid();
    }

    // @AdMob
    public static void adMobInitialize(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getAdMob() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error", PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ADMOB_NOTINITIALIZED, "Admob is not initialized."));
            return;
        }

        PerpleSDK.getAdMob().initialize(new SdkBinderCallback() {
            @Override
            public void onFinish(String result, String info) {
                // @sgkim 2021.05.25 현재 result는 "success"만 리턴함. 초기화 완료 시점만 콜백으로 확인
                PerpleSDK.callSDKResult(pID, funcID, result, info);
            }
        });
    }

    // 광고 로드
    public static void adMobLoadRewardAd(final int funcID, String adUnitId) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getAdMob() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error", PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ADMOB_NOTINITIALIZED, "Admob is not initialized."));
            return;
        }

        PerpleSDK.getAdMob().loadRewardedAd(adUnitId, new SdkBinderCallback() {
            @Override
            public void onFinish(String result, String info) {
                // result값 "success", "fail"
                PerpleSDK.callSDKResult(pID, funcID, result, info);
            }
        });
    }

    // 광고 재생
    public static void adMobShowRewardAd(final int funcID, String adUnitId) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getAdMob() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error", PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ADMOB_NOTINITIALIZED, "Admob is not initialized."));
            return;
        }

        PerpleSDK.getAdMob().showRewardedAd(adUnitId, new SdkBinderCallback() {
            @Override
            public void onFinish(String result, String info) {
                // result값 "success", "fail", "cancel"
                PerpleSDK.callSDKResult(pID, funcID, result, info);
            }
        });
    }





    // @xsolla
    public static boolean xsollaIsAvailable(final int funcID) {
        return (PerpleSDK.getXsolla() != null);
    }

    public static void xsollaSetPaymentInfoUrl(final int funcID, String paymentInfoUrl) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getXsolla() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error", PerpleSDK.getErrorInfo(PerpleSDK.ERROR_XSOLLA_NOTINITIALIZED, "Xsolla is not initialized."));
            return;
        }

        PerpleSDK.getXsolla().setPaymentInfoUrl(paymentInfoUrl);
    }

    public static void xsollaOpenPaymentUI(final int funcID, String payloadString) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getXsolla() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error", PerpleSDK.getErrorInfo(PerpleSDK.ERROR_XSOLLA_NOTINITIALIZED, "Xsolla is not initialized."));
            return;
        }

        PerpleSDK.getXsolla().openPaymentUI(payloadString, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                if (info.equals("cancel")) {
                    PerpleSDK.callSDKResult(pID, funcID, "cancel", "");
                } else {
                    PerpleSDK.callSDKResult(pID, funcID, "fail", info);
                }
            }
        });
    }

    // @util
    public static String getABI(int funcID) {
        return PerpleUtil.Companion.getABI();
    }

    // @crashlytics
    public static void crashlyticsForceCrash(int funcID) {
        PerpleCrashlytics.Companion.forceCrash();
    }

    public static void crashlyticsSetUid(int funcID, String uid) {
        PerpleCrashlytics.Companion.setUid(uid);
    }

    public static void crashlyticsSetLog(int funcID, String message) {
        PerpleCrashlytics.Companion.setLog(message);
    }

    public static void crashlyticsSetExceptionLog(int funcID, String message) {
        PerpleCrashlytics.Companion.setExceptionLog(message);
    }

    public static void crashlyticsSetKeyString(int funcID, String key, String value) {
        PerpleCrashlytics.Companion.setKeyString(key, value);
    }

    public static void crashlyticsSetKeyInt(int funcID, String key, int value) {
        PerpleCrashlytics.Companion.setKeyInt(key, value);
    }

    public static void crashlyticsSetKeyBool(int funcID, String key, boolean value) {
        PerpleCrashlytics.Companion.setKeyBool(key, value);
    }

    // @onestore
    public static void billingPurchaseForOnestore(final int funcID, final String productId, final String payload) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getOnestore() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error", PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ONESTORE_NOTINITIALIZED, "Onestore is not initialized."));
            return;
        }

        // 구매가능한 상태인지 확인 후 구매 진행
        PerpleSDK.getOnestore().getMPerpleOnestoreBilling().isOnestorePurchaseAvailable(new PerpleSDKCallback() {

            // 구매 가능한 상태 여부
            @Override
            public void onSuccess(String info) {
                PerpleLog.d(LOG_TAG, String.format("isOnestorePurchaseAvailable : %s",info));


                PerpleSDK.getOnestore().getMPerpleOnestoreBilling().buyProduct(productId, payload, new PerpleSDKCallback() {
                    // 구매 성공 여부
                    @Override
                    public void onSuccess(String info) {
                        PerpleSDK.callSDKResult(pID, funcID, "success", info);
                        PerpleLog.d(LOG_TAG, String.format("buyProduct  sku : %s | payload : %s | info : %s",productId , payload, info));
                    }
                    @Override
                    public void onFail(String info) {
                        PerpleSDK.callSDKResult(pID, funcID, "cancel", info);
                        PerpleLog.d(LOG_TAG, String.format("buyProduct  sku : %s | payload : %s | info : %s",productId , payload, info));
                    }
                });
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "cancel", info);
            }
        });
    }

    // @onestore
    public static void onestoreSetUid(int funcID, String uid) {
        PerpleSDK.getOnestore().getMPerpleOnestoreBilling().setUid(uid);
    }

    // @onestore
    public static boolean onestoreIsAvailable(final int funcID) {
        return (PerpleSDK.getOnestore() != null);
    }

    // @onestore
    public static void onestoreConsumeByOrderid(final int funcID, final String orderid) {
        final int pID = PerpleSDK.ProcessId;
        PerpleSDK.getOnestore().getMPerpleOnestoreBilling().consumeByOrderid(orderid, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }

            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @onestore
    public static void onestoreRequestPurchases(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        PerpleSDK.getOnestore().getMPerpleOnestoreBilling().requestPurchases(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }

            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @onestore
    public static void onestoreGetPurchases(final int funcID) {
        final int pID = PerpleSDK.ProcessId;
        PerpleSDK.getOnestore().getMPerpleOnestoreBilling().getPurchases(new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }

            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @onestore
    public static void billingGetItemListForOnestore(final int funcID, String skuList) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getOnestore() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error", PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ONESTORE_NOTINITIALIZED, "Onestore is not initialized."));
            return;
        }

        PerpleSDK.getOnestore().getMPerpleOnestoreBilling().getItemList(skuList, new PerpleSDKCallback() {
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "fail", info);
            }
        });
    }

    // @onestore
    public static void billingPurchaseSubscriptionForOnestore(final int funcID, final String sku, final String payload) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getOnestore() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error", PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ONESTORE_NOTINITIALIZED, "Onestore is not initialized."));
            return;
        }

        // 구매가능한 상태인지 확인 후 구매 진행
        PerpleSDK.getOnestore().getMPerpleOnestoreBilling().isOnestorePurchaseAvailable(new PerpleSDKCallback() {

            // 구매 가능한 상태 여부
            @Override
            public void onSuccess(String info) {
                PerpleSDK.getOnestore().getMPerpleOnestoreBilling().buySubscriptionProduct(sku, payload, new PerpleSDKCallback() {

                    // 구매 성공 여부
                    @Override
                    public void onSuccess(String info) {
                        PerpleSDK.callSDKResult(pID, funcID, "success", info);
                    }
                    @Override
                    public void onFail(String info) {
                        PerpleSDK.callSDKResult(pID, funcID, "cancel", info);
                    }
                });
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "cancel", info);
            }
        });
    }

    // @onestore
	// @Warning 20200116 @jhakim 구독 취소 후 소비 처리까지는 안되어 있는 상태
    // @Warning 구독 취소 후 consumeItem 처리를 해야 재구매 가능
    public static void cancelSubscriptionForOnestore(final int funcID, final String sku) {
        final int pID = PerpleSDK.ProcessId;
        if (PerpleSDK.getOnestore() == null) {
            PerpleSDK.callSDKResult(pID, funcID, "error", PerpleSDK.getErrorInfo(PerpleSDK.ERROR_ONESTORE_NOTINITIALIZED, "Onestore is not initialized."));
            return;
        }

        // 구매가능한 상태인지 확인 후 구독 취소
        PerpleSDK.getOnestore().getMPerpleOnestoreBilling().cancelSubscriptPurchaseForOnestore(sku, new PerpleSDKCallback() {
            // 구매 가능한 상태 여부
            @Override
            public void onSuccess(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "success", info);
            }
            @Override
            public void onFail(String info) {
                PerpleSDK.callSDKResult(pID, funcID, "cancel", info);
            }
        });
    }

}

