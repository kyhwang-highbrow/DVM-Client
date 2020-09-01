package com.perplelab.naver;

import com.perplelab.PerpleSDK;
import com.perplelab.PerpleLog;

import org.json.JSONException;
import org.json.JSONObject;

import com.naver.glink.android.sdk.Glink;
import android.app.Activity;
import android.graphics.Bitmap;
import android.os.Environment;
import android.view.View;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class PerpleNaver {
    private static final String LOG_TAG = "PerpleSDK Naver";

//    public static final int CAFE_HOME = 0;
//    public static final int CAFE_NOTICE = 1;
//    public static final int CAFE_EVENT = 2;
//    public static final int CAFE_MENU = 3;
//    public static final int CAFE_PROFILE = 4;

    private boolean mUseCafe;

    public PerpleNaver() {}

    public void initCafe(String clientId, String clientSecret, int cafeId, String neoIdConsumerKey, int communityId) {
        if (cafeId > 0) {
            PerpleLog.d(LOG_TAG, "Initializing Naver CafeSDK.");

            // "네아로 개발자 센터"에서 받은 정보로 SDK를 초기화 합니다.
            // Glink의 다른 메소드를 호출하기 전에 반드시 초기화를 먼저해야 합니다.
            // 개발자 센터 주소: https://nid.naver.com/devcenter/main.nhn
            Glink.init(PerpleSDK.getInstance().getMainActivity(), clientId, clientSecret, cafeId);
        }

        if (communityId > 0) {
            PerpleLog.d(LOG_TAG, "Initializing Naver CafeSDKGlobal.");

            // 글로벌 카페 초기화, 국내 카페만 사용할 경우 initGlobal을 하지 않아도 됩니다.
            Glink.initGlobal(PerpleSDK.getInstance().getMainActivity(), neoIdConsumerKey, communityId);
        }

//        mAppHandler = new Handler();
        mUseCafe = true;
    }

    public void cafeShowWidgetWhenUnloadSdk(boolean isShowWidget) {
        if (mUseCafe) {
            Glink.showWidgetWhenUnloadSdk(PerpleSDK.getInstance().getMainActivity(), isShowWidget);
        }
    }

    public void cafeSetWidgetStartPosition(boolean isLeft, int heightPercentage) {
        if (mUseCafe) {
            Glink.setWidgetStartPosition(PerpleSDK.getInstance().getMainActivity(), isLeft, heightPercentage);
        }
    }

    public void cafeStartWidget() {
        if (mUseCafe) {
            Glink.startWidget(PerpleSDK.getInstance().getMainActivity());
        }
    }

    public void cafeStopWidget() {
        if (mUseCafe) {
            Glink.stopWidget(PerpleSDK.getInstance().getMainActivity());
        }
    }

    public boolean cafeIsShowGlink() {
        boolean ret = false;
        if (mUseCafe) {
            // 네이버 카페 SDK 화면이 열려 있는지 확인한다.
            // 반환값이 true이면 열려 있는 상태고, 반환값이 false이면 열려 있지 않은 상태다.
            ret = Glink.isShowGlink(PerpleSDK.getInstance().getMainActivity());
        }
        return ret;
    }

    public void cafeStart(int tapIndex) {
        if (mUseCafe) {
            //3.1.0버전 부터 startHome만 된다.
            Glink.startHome(PerpleSDK.getInstance().getMainActivity());
            /*
            switch (tapIndex) {
            case CAFE_NOTICE:
                // 공지 사항 탭으로 네이버 카페 SDK 화면을 연다.
                Glink.startNotice(sMainActivity);
                break;
            case CAFE_EVENT:
                // 이벤트 탭으로 네이버 카페 SDK를 시작한다.
                Glink.startEvent(sMainActivity);
                break;
            case CAFE_MENU:
                // 게시판 탭으로 네이버 카페 SDK 화면을 연다.
                Glink.startMenu(sMainActivity);
                break;
            case CAFE_PROFILE:
                // 프로필 탭으로 네이버 카페 SDK 화면을 연다.
                Glink.startProfile(sMainActivity);
                break;
            default:
                // 홈 탭으로 네이버 카페 SDK 화면을 연다.
                Glink.startHome(sMainActivity);
                break;
            }
            */
        }
    }

    public void cafeStop() {
        if (mUseCafe) {
            // 종료하기
            Glink.stop(PerpleSDK.getInstance().getMainActivity());
        }
    }

    public void cafeStartWrite() {
        if (mUseCafe) {
            Glink.startWrite(PerpleSDK.getInstance().getMainActivity());
        }
    }

    public void cafeStartImageWrite(String imageUri) {
        if (mUseCafe) {
            // imageUri : 이미지 경로는 URI 형식으로 넣어주시면 됩니다.
            String retUri = addFileScheme(imageUri);
            if(PerpleSDK.IsDebug){
                PerpleLog.d(LOG_TAG, imageUri + " -> " + retUri);
            }

            Glink.startImageWrite(PerpleSDK.getInstance().getMainActivity(), retUri);
        }
    }

    public void cafeStartVideoWrite(String videoUri) {
        if (mUseCafe) {
            // videoUri : 동영상 파일의 경로는 URI 형식으로 넣어주시면 됩니다.
            Glink.startVideoWrite(PerpleSDK.getInstance().getMainActivity(), videoUri);
        }
    }

    public void cafeSyncGameUserId(String gameUserId) {
        if (mUseCafe) {
            // 게임 아이디와 카페 아이디를 매핑합니다.
            Glink.syncGameUserId(PerpleSDK.getInstance().getMainActivity(), gameUserId);
        }
    }

    public void cafeSetUseVideoRecord(boolean isSetUseVideoRecord) {
        if (mUseCafe) {
            Glink.setUseVideoRecord(PerpleSDK.getInstance().getMainActivity(), isSetUseVideoRecord);
        }
    }

    public void cafeSetUseScreenshot(boolean isSetUseScreenshot) {
        if (mUseCafe) {
            Glink.setUseScreenshot(PerpleSDK.getInstance().getMainActivity(), isSetUseScreenshot);
        }
    }

    public void cafeScreenshot() {
        if (mUseCafe) {
            String path = screenshot(PerpleSDK.getInstance().getMainActivity());
            Glink.startImageWrite(PerpleSDK.getInstance().getMainActivity(), path);
        }
    }

    public void cafeSetCallback(final PerpleNaverCafeCallback callback) {
        if (mUseCafe) {
            // SDK 시작 리스너 설정.
            Glink.setOnSdkStartedListener(new Glink.OnSdkStartedListener() {
                @Override
                public void onSdkStarted() {
                    PerpleLog.d(LOG_TAG, "Naver CafeSDK, onSdkStarted");
                    callback.onSdkStarted();
                }
            });
            // SDK 종료 리스너 설정.
            Glink.setOnSdkStoppedListener(new Glink.OnSdkStoppedListener() {
                @Override
                public void onSdkStopped() {
                    PerpleLog.d(LOG_TAG, "Naver CafeSDK, onSdkStopped");
                    callback.onSdkStopped();
                }
            });
            // 앱스킴 터치 리스너 설정.
            Glink.setOnClickAppSchemeBannerListener(new Glink.OnClickAppSchemeBannerListener() {
                @Override
                public void onClickAppSchemeBanner(String appScheme) {
                    PerpleLog.d(LOG_TAG, "Naver CafeSDK, onClickAppSchemeBanner - appScheme:" + appScheme);

                    // 카페 관리에서 설정한 appScheme 문자열을 SDK에서 넘겨줍니다.
                    // 각 appScheme 처리를 이곳에서 하시면 됩니다.
                    callback.onClickAppSchemeBanner(appScheme);
                }
            });
            // 카페 가입 리스너를 설정.
            Glink.setOnJoinedListener(new Glink.OnJoinedListener() {
                @Override
                public void onJoined() {
                    PerpleLog.d(LOG_TAG, "Naver CafeSDK, onJoined");
                    callback.onJoined();
                }
            });
            // 게시글 등록 리스너를 설정
            // @param menuId 게시글이 등록된 menuId
            // @param imageCount 첨부한 image 개수
            // @param videoCount 첨부한 video 개수
            Glink.setOnPostedArticleListener(new Glink.OnPostedArticleListener() {
                @Override public void onPostedArticle(int menuId, int imageCount, int videoCount) {
                    PerpleLog.d(LOG_TAG, "Naver CafeSDK, onPostedArticle - menuId:" + String.valueOf(menuId) +
                            ", imageCount:" + String.valueOf(imageCount) +
                            ", videoCount:" + String.valueOf(videoCount));

                    try {
                        JSONObject info = new JSONObject();
                        info.put("menuId", menuId);
                        info.put("imageCount", imageCount);
                        info.put("videoCount", videoCount);
                        callback.onPostedArticle(info.toString());
                    } catch (JSONException e) {
                        e.printStackTrace();
                        callback.onError(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_NAVER_ONPOSTEDARTICLE, PerpleSDK.ERROR_JSONEXCEPTION, e.toString()));
                    }
                }
            });
            // 댓글 등록 리스너를 설정.
            Glink.setOnPostedCommentListener(new Glink.OnPostedCommentListener() {
                @Override
                public void onPostedComment(int articleId) {
                    PerpleLog.d(LOG_TAG, "Naver CafeSDK, onPostedComment - articleId:" + String.valueOf(articleId));
                    callback.onPostedComment(articleId);
                }
            });
            // 투표 완료 리스너를 설정.
            Glink.setOnVotedListener(new Glink.OnVotedListener() {
                @Override
                public void onVoted(int articleId) {
                    PerpleLog.d(LOG_TAG, "Naver CafeSDK, onVoted - articleId:" + String.valueOf(articleId));
                    callback.onVoted(articleId);
                }
            });
            // 스크린샷 요청 버튼 클릭 리스너 설정.
            Glink.setOnWidgetScreenshotClickListener(new Glink.OnWidgetScreenshotClickListener() {
                @Override
                public void onScreenshotClick() {
                    PerpleLog.d(LOG_TAG, "Naver CafeSDK, onScreenshotClick");
                    callback.onScreenshotClick();
                }
            });
            //동영상 녹화 완료 리스너 설정.
            Glink.setOnRecordFinishListener(new Glink.OnRecordFinishListener() {
                @Override
                public void onRecordFinished(String uri) {
                    PerpleLog.d(LOG_TAG, "Naver CafeSDK, onRecordFinished - uri:" + uri);
                    cafeStartVideoWrite(uri);
                    callback.onRecordFinished(uri);
                }
            });
        } else {
            callback.onError(PerpleSDK.getErrorInfo(PerpleSDK.ERROR_NAVER_CAFENOTINITIALIZED, "Naver CafeSDK is not initialized."));
        }
    }

    public void naverCafeInitGlobalPlug(String neoIdConsumerKey, int communityId, int channelID ) {
        if( channelID > 0 )
        {
            Glink.initGlobal(PerpleSDK.getInstance().getMainActivity(), neoIdConsumerKey, communityId, channelID);
        }
        else
        {
            Glink.initGlobal(PerpleSDK.getInstance().getMainActivity(), neoIdConsumerKey, communityId);
        }

    }

    public void naverCafeSetChannelCode(String channelCde) {
        Glink.setChannelCode( channelCde );
    }

    public String naverCafeGetChannelCode() {
        if (!mUseCafe) {
            PerpleLog.e(LOG_TAG, "Naver is not initialized.");
            return "";
        }
        return Glink.getChannelCode();
    }

    public void naverCafeStartWithArticle( int articleID ) {
        Glink.startArticle(PerpleSDK.getInstance().getMainActivity(), articleID);
    }

    public String screenshot(Activity activity) {
        View view = activity.getWindow().getDecorView().findViewById(android.R.id.content).getRootView();

        view.setDrawingCacheEnabled(true);
        //view.buildDrawingCache(true);

        Bitmap screenshot = Bitmap.createBitmap( view.getDrawingCache(true) );

        view.setDrawingCacheEnabled(false);

        String path = Environment.getExternalStorageDirectory().toString();
        String filename = "screenshot" + System.currentTimeMillis() + ".png";
        String fileUri = null;
        try {
            File f = new File( path + "/" + filename );

            f.createNewFile();
            fileUri = f.toURI().toString();

            OutputStream outStream = new FileOutputStream(f);
            screenshot.compress(Bitmap.CompressFormat.PNG, 100, outStream);
            outStream.flush();
            outStream.close();

            PerpleLog.d(LOG_TAG, "Naver CafeSDK, screenshot - uri:" + fileUri);

        } catch (IOException e) {
            e.printStackTrace();
        }

        return fileUri;
    }

    private String addFileScheme(String filePath) {
        final String scheme = "file://";

        if (filePath != null && !filePath.startsWith(scheme)) {
            return scheme + filePath;
        } else {
            return filePath;
        }
    }
}
