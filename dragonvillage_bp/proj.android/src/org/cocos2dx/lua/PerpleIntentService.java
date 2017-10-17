package org.cocos2dx.lua;

import java.util.ArrayList;

import android.app.IntentService;
import android.content.Intent;
import android.util.Log;

public class PerpleIntentService extends IntentService {

    private static long mUpdatePeriod = 1000 * 1;
    private static final Boolean DEBUG = false;
    private static final String TAG = "PerpleIntentService";

    private boolean mActive = false;

    private ArrayList<String>   mType       = null;
    private ArrayList<Long>     mNotiTime   = null;
    private ArrayList<String>   mNotiMsg    = null;
    private ArrayList<Boolean>  mNotiState  = null;
    private ArrayList<String>   mAlert      = null;

    private String mLinkTitle       = null;
    private String mLinkUrl         = null;
    private String mCafeUrl         = null;

    private String mBGColor         = null;
    private String mTitleColor      = null;
    private String mMessageColor    = null;

    private int mPastNotiCnt = 0;   // 처리된 Noti의 갯수(최초 실행 시 시간이 지났거나, Noti를 보낼 때마다 증가)

    public PerpleIntentService() {
        super("PerpleIntentService");
        if(DEBUG) Log.d(TAG, "PerpleIntentService()");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if(DEBUG) Log.d(TAG, "onStartCommand()");

        if (intent == null) {
            return super.onStartCommand(intent, flags, startId);
        }

        mType = intent.getStringArrayListExtra("noti_type");
        long[] timeArr = intent.getLongArrayExtra("noti_time");
        mNotiTime = new ArrayList<Long>();
        mNotiState = new ArrayList<Boolean>();
        for( int i=0; i<timeArr.length; i++)
        {
            mNotiTime.add(timeArr[i]);
            mNotiState.add(true);
        }
        mNotiMsg = intent.getStringArrayListExtra("noti_msg");
        mAlert = intent.getStringArrayListExtra("noti_alert");

        mLinkTitle  = intent.getStringExtra("link_title");
        mLinkUrl    = intent.getStringExtra("link_url");
        mCafeUrl    = intent.getStringExtra("cafe_url");

        mBGColor      = intent.getStringExtra("noti_color_bg");
        mTitleColor   = intent.getStringExtra("noti_color_title");
        mMessageColor = intent.getStringExtra("noti_color_message");

        //super클래스의 onStartCommand에서 onHandleIntent를 연결시킨
        //스레드를 생성하는 것으로 추측됨.
        //그러므로 onHandleIntent를 위한 각종 환경 설정이 모두 끝난 후에
        //super클래스의 onStartCommand를 호출해야함!
        super.onStartCommand(intent, flags, startId);
        return START_REDELIVER_INTENT;
    }

    @Override
    public void onCreate()
    {
        super.onCreate();
        if(DEBUG) Log.d(TAG, "onCreate()");

        mActive = true;
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        if(DEBUG) Log.d(TAG, "onHandleIntent() start");

        if (intent == null) {
            return;
        }

        invalidate();

        while(isNeedToRunService()) {
            // Update loop
            synchronized (this) {
                try {
                    wait(mUpdatePeriod);
                } catch (InterruptedException e) {
                }
            }

            // 서비스가 stop되었을 경우
            if(mActive == false)
            {
                if(DEBUG) Log.d(TAG, "onHandleIntent() Service was destroyed.");
                break;
            }

            // Update
            updateNotice();
        }
        if(DEBUG) Log.d(TAG, "onHandleIntent() end");
    }

    @Override
    public void onDestroy() {
        //Log.d(TAG, "onDestroy()");

        // onHandleIntent()에서 wait()중일 경우
        // onDestroy()함수 호출 후에
        // onHandleIntent()함수 wait()이후 부분이 실행 될 수 있기 때문에
        // mActive변수로 확인한다.
        mActive = false;
    }

    private boolean isNeedToRunService() {
        // mNotiTime이 비어있지 않으면 업데이트 해야하는 상태
        if(mNotiTime != null && mNotiTime.size() > mPastNotiCnt) {
            return true;
        } else {
            return false;
        }
    }

    private void invalidate()
    {
        mPastNotiCnt = 0;
        long curTime = System.currentTimeMillis();

        int size = mNotiTime.size();
        for(int i = 0; i < size; i++) {
            long t = mNotiTime.get(i);
            if(t <= curTime) {
                mNotiState.set(i, false);
                mPastNotiCnt++;
            }
            else {
                mNotiState.set(i, true);
            }
        }
    }

    private void updateNotice() {

        long curTime = System.currentTimeMillis();
        int size = mNotiTime.size();

        if(DEBUG) Log.d(TAG, "updateNotice() update service! " + mPastNotiCnt + "/" + size);

        for(int i = 0; i < size; i++) {

            if(mNotiState.get(i) == false)
            {
                continue;
            }

            long t = mNotiTime.get(i);
            if(t <= curTime) {
                String type = mType.get(i);
                String message = mNotiMsg.get(i);
                String alert = mAlert.get(i);
                if(!AppActivity.sIsRun) {
                    PerpleNotificationMgr.doNotify(this, type, message, alert.equals("t"), mLinkTitle, mLinkUrl, mCafeUrl, mBGColor, mTitleColor, mMessageColor);
                }

                if(DEBUG) Log.d(TAG, "updateNotice() " + message);

                mNotiState.set(i, false);
                mPastNotiCnt++;
                break;
            }
        }
    }

}
