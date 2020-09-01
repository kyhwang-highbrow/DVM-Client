package com.perplelab.twitter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;

import com.perplelab.PerpleSDKCallback;
import com.twitter.sdk.android.tweetcomposer.TweetUploadService;

public class PerpleTwitterReceiver extends BroadcastReceiver{
    private PerpleSDKCallback mCallback;

    public PerpleTwitterReceiver(PerpleSDKCallback callback) {
        this.mCallback = callback;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if (TweetUploadService.UPLOAD_SUCCESS.equals(intent.getAction())) {
            // success
            //Toast.makeText(context, "receive action : " + "Success tweet" , Toast.LENGTH_SHORT).show();
            this.mCallback.onSuccess("success");

        } else if (TweetUploadService.UPLOAD_FAILURE.equals(intent.getAction())) {
            // failure
            //Toast.makeText(context, "receive action : " + "Fail tweet" , Toast.LENGTH_SHORT).show();
            this.mCallback.onFail("fail");

        } else if (TweetUploadService.TWEET_COMPOSE_CANCEL.equals(intent.getAction())) {
            // cancel
            //Toast.makeText(context, "receive action : " + "Cancel tweet" , Toast.LENGTH_SHORT).show();
            this.mCallback.onFail("cancel");
        }
    }
}
