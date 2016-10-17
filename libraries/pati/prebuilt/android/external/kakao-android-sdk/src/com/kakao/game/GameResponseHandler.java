package com.kakao.game;

import android.content.Context;
import android.os.Handler;
import android.os.Message;

import org.json.JSONObject;

/**
 * Created by housedr on 15. 11. 10..
 */
public abstract class GameResponseHandler extends Handler {
    public static final int START = 0;
    public static final int COMPLETE = 1;
    public static final int ERROR = 2;

    private Context context;

    /**
     * <pre>
     * KakaoResponseHandler Constructor.
     * </pre>
     */
    public GameResponseHandler(Context context) {
        super();
        this.context = context;
    }

    public Context getContext() {
        return context;
    }

    /* (non-Javadoc)
     * @see android.os.Handler#handleMessage(android.os.Message)
     */
    @Override
    public void handleMessage(Message msg) {

        switch (msg.what) {
            case START:
                onStart();
                break;
            case COMPLETE:
                onComplete(msg.arg1, msg.arg2, (JSONObject)msg.obj);
                break;
            case ERROR:
                onError(msg.arg1, msg.arg2, (JSONObject) msg.obj);
                break;
        }
    }

    /**
     * Request start
     */
    protected void onStart() {
        // do nothing, not yet.
    }

    protected abstract void onComplete(int httpStatus, int kakaoStatus, JSONObject result);

    protected abstract void onError(int httpStatus, int kakaoStatus, JSONObject result);

}
