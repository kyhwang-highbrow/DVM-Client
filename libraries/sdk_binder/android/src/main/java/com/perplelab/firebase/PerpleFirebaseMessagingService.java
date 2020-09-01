package com.perplelab.firebase;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.perplelab.PerpleSDK;
import com.perplelab.PerpleLog;

import android.app.Activity;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import androidx.core.app.NotificationCompat;

public class PerpleFirebaseMessagingService extends FirebaseMessagingService {

    private static final String LOG_TAG = "PerpleSDK Firebase";

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
        PerpleLog.d(LOG_TAG, "onMessageReceived - from:" + remoteMessage.getFrom() + ", message:" + remoteMessage.getNotification().getBody());
        if (PerpleSDK.IsReceivePushOnForeground) {
            sendNotification(remoteMessage.getNotification().getTitle(), remoteMessage.getNotification().getBody());
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

        if (mainActivity == null) {
            PerpleLog.e(LOG_TAG, "MainActivity for FCM notification is null.");
            return;
        }

        int pushIcon = 0;
        String appName = "";
        try {
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
        } catch (NameNotFoundException e) {
            e.printStackTrace();
        }

        if (messageTitle == null || messageTitle.isEmpty()) {
            messageTitle = appName;
        }

        Intent intent = new Intent(this, mainActivity.getClass());
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

        PendingIntent pendingIntent = PendingIntent.getActivity(this, PerpleSDK.RC_FIREBASE_MESSAGING, intent,
                PendingIntent.FLAG_ONE_SHOT);

        Uri defaultSoundUri= RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(pushIcon)
                .setContentTitle(messageTitle)
                .setContentText(messageBody)
                .setTicker(messageBody)
                .setDefaults(NotificationCompat.DEFAULT_VIBRATE |
                             NotificationCompat.DEFAULT_LIGHTS |
                             NotificationCompat.DEFAULT_SOUND)
                .setAutoCancel(true)
                .setOnlyAlertOnce(true)
                .setSound(defaultSoundUri)
                .setContentIntent(pendingIntent);

        NotificationManager notificationManager =
                (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);

        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());
    }

    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised. Note that this is called when the InstanceID token
     * is initially generated so this is where you would retrieve the token.
     */
    @Override
    public void onNewToken(String token) {
        // Get updated InstanceID token.
        String instanceId = FirebaseInstanceId.getInstance().getId();

        // getToken()함수가 deprecated 되었다.
        //String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        String refreshedToken = token;

        PerpleLog.d(LOG_TAG, "onTokenRefresh - iid: " + instanceId + ", token:" + refreshedToken);

        // Implement this method to send any registration to your app's servers.
        sendRegistrationToServer(instanceId, refreshedToken);
    }

    /**
     * Persist token to third-party servers.
     *
     * Modify this method to associate the user's FCM InstanceID token with any server-side account
     * maintained by your application.
     *
     * @param token The new token.
     */
    private void sendRegistrationToServer(String iid, String token) {
        // Add custom implementation, as needed.
        PerpleSDK.onFCMTokenRefresh(token);
    }
}
