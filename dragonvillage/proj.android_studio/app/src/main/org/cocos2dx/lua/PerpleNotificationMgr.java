package org.cocos2dx.lua;

import com.perplelab.dragonvillagem.kr.R;

import android.app.Activity;
import android.app.PendingIntent.CanceledException;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Build;
//import android.support.v4.app.NotificationCompat;
import androidx.core.app.NotificationCompat;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.widget.Button;
import android.widget.RemoteViews;
import android.widget.TextView;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.PowerManager;

public class PerpleNotificationMgr extends Activity {
    public static Context mContext = null;
    private static final Boolean DEBUG = false;
    private static final String TAG = "PerpleNotificationMgr";
    private static final int COLOR_BG           = Color.parseColor("#a71197");
    private static final int COLOR_TITLE_TEXT   = Color.parseColor("#fcff29");
    private static final int COLOR_MESSAGE_TEXT = Color.parseColor("#ffffff");

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
        Intent intent = getIntent();
        String msg = intent.getStringExtra("message");
        alert(msg);
    }

    public void alert(String message) {
        if(DEBUG) Log.d(TAG, "popup alert");
        // layout popupMessage.xml을 view로 사용
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.popup);
        TextView popupMessage = (TextView)findViewById(R.id.popupMessage);
        popupMessage.setText(message);
        Button popupButton = (Button)findViewById(R.id.popupButton);
        popupButton.setOnClickListener(new SubmitOnClickListener());
    }

    private class SubmitOnClickListener implements OnClickListener {
        @Override
        public void onClick(View v) {
            // TODO Auto-generated method stub
            finish();
        }
    }

    /*
     * context : activity일 필요 없음. 독립적으로 동작하기 때문에 service 객체를 넣어줘도 무방
     * message : notify를 확인했을 때 나오는 내용
     * bAlert : 팝업을 띄울지의 여부.
     */
    public static void doNotify(Context context, String type, String message, boolean bAlert) {
        doNotify(context, type, message, bAlert, null, null, null, null, null, null);
    }

    public static void doNotify(Context context, String type, String message, boolean bAlert, String linkTitle, String linkUrl, String cafeUrl, String bgColor, String titleColor, String messageColor) {
        PowerManager pm = (PowerManager)context.getSystemService(Context.POWER_SERVICE);

        if (bAlert) {
            // 스크린이 꺼져있는 상태에서만
            boolean isScreenOn = false;

            if (Build.VERSION.SDK_INT < 20) {
                isScreenOn = pm.isScreenOn();
            } else {
                isScreenOn = pm.isInteractive();
            }

            if (!isScreenOn) {
                Intent noticeIntent = new Intent(context, PerpleNotificationMgr.class);
                noticeIntent.putExtra("message", message);

                int flag;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    flag = PendingIntent.FLAG_IMMUTABLE;
                } else {
                    flag = PendingIntent.FLAG_ONE_SHOT;
                }
                PendingIntent pie = PendingIntent.getActivity(context.getApplicationContext(), AppActivity.RC_LOCAL_PUSH, noticeIntent, flag);

                try {
                    pie.send();
                } catch (CanceledException e) {
                    e.printStackTrace();
                }
            }
        }

        PowerManager.WakeLock wl = pm.newWakeLock(PowerManager.FULL_WAKE_LOCK | PowerManager.ACQUIRE_CAUSES_WAKEUP | PowerManager.ON_AFTER_RELEASE, "INFO");
        wl.acquire(5000);

        PerpleNotificationMgr.notifyMessage(context, context.getString(R.string.app_name), type, message, cafeUrl, linkTitle, linkUrl, bgColor, titleColor, messageColor);

        // badge
        AppActivity.setBadgeCount(context, 1);
    }

    public static void notifyMessage(Context context, String title, String type, String message, String cafeUrl, String linkTitle, String linkUrl, String bgColor, String titleColor, String messageColor) {
        if (type == "type3") {
            notifyMessageStyle3(context, title, message, bgColor, titleColor, messageColor);
        } else if (type == "type2") {
            notifyMessageStyle2(context, title, message, cafeUrl, linkTitle, linkUrl, bgColor, titleColor, messageColor);
        } else {
            notifyMessageStyle1(context, title, message);
        }
    }

    public static void notifyMessageStyle1(Context context, String title, String message) {
        NotificationManager mgr = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
        int flag;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flag = PendingIntent.FLAG_IMMUTABLE;
        } else {
            flag = 0;
        }

        Intent intent = new Intent(context, AppActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, AppActivity.RC_LOCAL_PUSH, intent, flag);

        Notification.Builder builder = new Notification.Builder(context)
                .setContentIntent(pendingIntent)
                .setSmallIcon(R.drawable.push_icon)
                .setContentTitle(title)
                .setContentText(message)
                .setDefaults(Notification.DEFAULT_SOUND | Notification.DEFAULT_VIBRATE | Notification.DEFAULT_LIGHTS)
                .setOnlyAlertOnce(true)
                .setAutoCancel(true)
                .setTicker(message);

        Notification noti = builder.build();
        mgr.notify(0, noti);
    }

    public static void notifyMessageStyle2(Context context, String title, String message, String cafeUrl, String linkTitle, String linkUrl, String bgColor, String titleColor, String messageColor) {
        Bitmap largeIcon = BitmapFactory.decodeResource(context.getResources(), R.drawable.push_icon);   // 아이콘
        Bitmap banner = BitmapFactory.decodeResource(context.getResources(), R.raw.noti_banner_kr); // 배너

        // notification에 배경, 글자색 변경한 layout 지정
        RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.push);
        remoteViews.setTextViewText(R.id.push_title, title);
        remoteViews.setTextViewText(R.id.push_message, message);

        int colorBG = COLOR_BG;
        int colorTitle = COLOR_TITLE_TEXT;
        int colorMessage = COLOR_MESSAGE_TEXT;

        if (bgColor != null) {
            colorBG = Color.parseColor(bgColor);
        }
        if (titleColor != null) {
            colorTitle = Color.parseColor(titleColor);
        }
        if (messageColor != null) {
            colorMessage = Color.parseColor(messageColor);
        }

        remoteViews.setInt(R.id.relativeLayout1, "setBackgroundColor", colorBG);
        remoteViews.setTextColor(R.id.push_title, colorTitle);
        remoteViews.setTextColor(R.id.push_message, colorMessage);

        // 알림음 지정
        Uri soundUri;
        try {
            soundUri = Uri.parse("android.resource://" + context.getPackageName() + "/"
                    + R.raw.notification);
        } catch (Exception e) {
            soundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        }
        if(DEBUG) Log.d(TAG, soundUri.toString());
        int flag;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flag = PendingIntent.FLAG_IMMUTABLE;
        } else {
            flag = PendingIntent.FLAG_UPDATE_CURRENT;
        }

        // 앱을 실행하는 PendingIntent 생성(notification을 터치했을 경우에 사용됨)
        Intent intent = new Intent(context, AppActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, AppActivity.RC_LOCAL_PUSH, intent, flag);

        // 공식카페로 이동하는 PendingIntent 생성("공식카페 바로가기"아이콘을 터치했을 경우에 사용됨)
        PendingIntent cafeIntent = PendingIntent.getActivity(context, AppActivity.RC_LOCAL_PUSH, new Intent(Intent.ACTION_VIEW).setData(Uri.parse(cafeUrl)), 0);

        // notification 생성
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context)
                .setAutoCancel(true)
                .setSmallIcon(R.drawable.push_icon)
                .setLargeIcon(largeIcon)
                .setTicker(message)
                .setContentTitle(title)
                .setContentText(message)
                .setContentIntent(pendingIntent)
                .setContent(remoteViews)
                .setDefaults(Notification.DEFAULT_VIBRATE | Notification.DEFAULT_LIGHTS | Notification.DEFAULT_SOUND)
                .setSound(soundUri)
                .setOnlyAlertOnce(true)
                .addAction(R.drawable.push_icon, context.getString(R.string.link_cafe).toString(), cafeIntent);

        // link 버튼 추가
        if(linkUrl != null)
        {
            if (linkTitle == null) linkTitle = "Link";
            PendingIntent linkIntent = PendingIntent.getActivity(context, AppActivity.RC_LOCAL_PUSH, new Intent(Intent.ACTION_VIEW).setData(Uri.parse(linkUrl)), 0);
            builder.addAction(R.drawable.push_icon, linkTitle, linkIntent);
        }

        // Notification에 BigPictureStyle 지정
        NotificationCompat.BigPictureStyle style = new NotificationCompat.BigPictureStyle(builder)
                .setBigContentTitle(title)
                .setSummaryText(message)
                .bigPicture(banner);

        // Notify
        NotificationManager notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.notify(0, style.build());
    }

    public static void notifyMessageStyle3(Context context, String title, String message, String bgColor, String titleColor, String messageColor) {
        Bitmap largeIcon = BitmapFactory.decodeResource(context.getResources(), R.drawable.push_icon);   // 아이콘

        // notification에 배경, 글자색 변경한 layout 지정
        RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.push);
        remoteViews.setTextViewText(R.id.push_title, title);
        remoteViews.setTextViewText(R.id.push_message, message);

        int colorBG = COLOR_BG;
        int colorTitle = COLOR_TITLE_TEXT;
        int colorMessage = COLOR_MESSAGE_TEXT;

        if (bgColor != null) {
            colorBG = Color.parseColor(bgColor);
        }
        if (titleColor != null) {
            colorTitle = Color.parseColor(titleColor);
        }
        if (messageColor != null) {
            colorMessage = Color.parseColor(messageColor);
        }

        remoteViews.setInt(R.id.relativeLayout1, "setBackgroundColor", colorBG);
        remoteViews.setTextColor(R.id.push_title, colorTitle);
        remoteViews.setTextColor(R.id.push_message, colorMessage);
        int flag;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flag = PendingIntent.FLAG_IMMUTABLE;
        } else {
            flag = PendingIntent.FLAG_UPDATE_CURRENT;
        }

        // 앱을 실행하는 PendingIntent 생성(notification을 터치했을 경우에 사용됨)
        Intent intent = new Intent(context, AppActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, AppActivity.RC_LOCAL_PUSH, intent, flag);

        Notification builder = new NotificationCompat.Builder(context)
                .setAutoCancel(true)
                .setContentTitle(title)
                .setContentText(message)
                .setSmallIcon(R.drawable.push_icon)
                .setLargeIcon(largeIcon)
                .setContentIntent(pendingIntent)
                .setContent(remoteViews)
                .setTicker(message)
                .setDefaults(Notification.DEFAULT_VIBRATE | Notification.DEFAULT_LIGHTS | Notification.DEFAULT_SOUND)
                .setOnlyAlertOnce(true)
                .build();

        // Notify
        NotificationManager notificationManager = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.notify(0, builder);
    }
}
