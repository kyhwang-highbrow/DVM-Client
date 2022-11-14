package com.perplelab.firebase;

import com.adjust.sdk.Util;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.perplelab.PerpleSDK;
import com.perplelab.PerpleLog;
import com.perplelab.R;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.media.MediaPlayer;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import java.net.URLDecoder;

public class PerpleFirebaseMessagingService extends FirebaseMessagingService {

    private static final String LOG_TAG = "PerpleSDK Firebase";

    private String id = "my_channel_02";
    private CharSequence name = "fcm_nt";
    private String description = "push";

    int importance = NotificationManager.IMPORTANCE_LOW;

    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        // TODO(developer): Handle FCM messages here.
        // If the application is in the foreground handle both data and notification messages here.
        // Also if you intend on generating your own notifications as a result of a received FCM
        // message, here is where that should be initiated. See sendNotification method below.
        Log.d(LOG_TAG, "onMessageReceived - from:" + remoteMessage.getFrom() + ", message:" + remoteMessage.getNotification().getBody());

        super.onMessageReceived(remoteMessage);
        if (remoteMessage.getNotification() != null){ // 포그라운드
            //sendNotification(remoteMessage.getNotification().getTitle(), remoteMessage.getNotification().getBody()); // 게임 중인 경우 푸시를 받지 않음
        }
        else if (remoteMessage.getData().size() > 0) { //백그라운드
            sendNotification(remoteMessage.getData().get("body"),remoteMessage.getData().get("title"));
        }
    }

    @Override
    public void onMessageSent(String msgId) {
        PerpleLog.d(LOG_TAG, "onMessageSent - msgId:" + msgId);
        PerpleSDK.onMessageSent(msgId);
    }

    @Override
    public void onSendError(String msgId, Exception exception) {
        PerpleLog.e(LOG_TAG, "onSendError - msgId:" + msgId + ", exception:" + exception.toString());
        PerpleSDK.onSendError(msgId, exception);
    }

    /**
     * Create and show a simple notification containing the received FCM message.
     *
     * @param messageBody FCM message body received.
     */
    private void sendNotification(String messageTitle, String messageBody) {
        Activity mainActivity = PerpleSDK.getInstance().getMainActivity();
        Intent intent = new Intent(this, mainActivity.getClass());
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

        int flag;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flag = PendingIntent.FLAG_IMMUTABLE;
        } else {
            flag = PendingIntent.FLAG_ONE_SHOT;
        }

        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent,
                flag);

        NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        NotificationChannel channel = new NotificationChannel(id, name, importance);

        //channel.setDescription(description);
        notificationManager.createNotificationChannel(channel);

        int notifyID = 0;
        int pushIcon = 0;
        String CHANNEL_ID = "dvm_push_channel";
        String appName = "";

        try{
            ApplicationInfo info = getPackageManager().getApplicationInfo(mainActivity.getPackageName(), PackageManager.GET_META_DATA);
            pushIcon = info.icon;
            appName = getString(info.labelRes);
            Bundle bundle = info.metaData;
            if (bundle != null) {
                int icon = bundle.getInt("push_icon");
                if (icon != 0) {
                    pushIcon = icon;
                }
            }

            messageTitle = URLDecoder.decode(messageTitle, "UTF-8");
            messageBody = URLDecoder.decode(messageBody, "UTF-8");
        }
        catch(Exception e){
            e.printStackTrace();
        }

        if (messageTitle == null || messageTitle.isEmpty()) {
            messageTitle = appName;
        }

        if (messageTitle != null && messageBody != null) {
            Notification notification = new Notification.Builder(this)
                    .setContentTitle(messageTitle)
                    .setContentText(messageBody)
                    .setSmallIcon(pushIcon)
                    .setChannelId(CHANNEL_ID)
                    .setContentIntent(pendingIntent)
                    .build();


            notificationManager.notify(notifyID, notification);
        }
    }

    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised. Note that this is called when the InstanceID token
     * is initially generated so this is where you would retrieve the token.
     */
    @Override
    public void onNewToken(String token) {
        super.onNewToken(token);

        PerpleLog.d(LOG_TAG, "onNewToken - token:" + token);

        // Implement this method to send any registration to your app's servers.
        sendRegistrationToServer(token);
    }

    /**
     * Persist token to third-party servers.
     *
     * Modify this method to associate the user's FCM InstanceID token with any server-side account
     * maintained by your application.
     *
     * @param token The new token.
     */
    private void sendRegistrationToServer(String token) {
        // Add custom implementation, as needed.
        PerpleSDK.onFCMTokenRefresh(token);
    }
}
