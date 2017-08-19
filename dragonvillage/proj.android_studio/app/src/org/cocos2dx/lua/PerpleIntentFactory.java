package org.cocos2dx.lua;

import java.util.ArrayList;

import android.content.Context;
import android.content.Intent;

public class PerpleIntentFactory {
    public static ArrayList<String> mType = new ArrayList<String>();
    public static ArrayList<Long> mNotiTime = new ArrayList<Long>();
    public static ArrayList<String> mNotiMsg = new ArrayList<String>();
    public static ArrayList<String> mAlert = new ArrayList<String>();

    public static String mLinkTitle = null;
    public static String mLinkUrl = null;
    public static String mCafeUrl = null;

    public static String mBGColor = null;
    public static String mTitleColor = null;
    public static String mMessageColor = null;

    public static void addNoti(String type, int sec, String msg, boolean bAlert) {
        mType.add(type);
        mNotiTime.add(System.currentTimeMillis() + (sec * 1000));
        mNotiMsg.add(msg);
        mAlert.add(bAlert ? "t" : "f");
    }

    public static void setLinkUrlInfo(String linkTitle, String linkUrl, String cafeUrl) {
        mLinkTitle = linkTitle;
        mLinkUrl = linkUrl;
        mCafeUrl = cafeUrl;
    }

    public static void setColor(String bgColor, String titleColor, String messageColor) {
        mBGColor = bgColor;
        mTitleColor = titleColor;
        mMessageColor = messageColor;
    }

    public static void clear() {
        mType.clear();
        mNotiTime.clear();
        mNotiMsg.clear();
        mAlert.clear();
        mLinkTitle = null;
        mLinkUrl = null;
        mCafeUrl = null;
        mBGColor = null;
        mTitleColor = null;
        mMessageColor = null;
    }

    public static Intent makeIntentService(Context context) {
        Intent intent = new Intent(context, PerpleIntentService.class);

        // Intent에서 Extra로 LongArrayList를 지원하지 않기 때문에 long[]로 변환하여 사용
        Long[] longArr = mNotiTime.toArray(new Long[mNotiTime.size()]);
        long[] primitives = new long[longArr.length];
        for (int i = 0; i < longArr.length; i++) {
            primitives[i] = longArr[i];
        }

        // primitives는 long[]으로 변환된 mNotiTime
        intent.putExtra("noti_type", mType);
        intent.putExtra("noti_time", primitives);
        intent.putExtra("noti_msg", mNotiMsg);
        intent.putExtra("noti_alert", mAlert);
        intent.putExtra("link_title", mLinkTitle);
        intent.putExtra("link_url", mLinkUrl);
        intent.putExtra("cafe_url", mCafeUrl);
        intent.putExtra("noti_color_bg", mBGColor);
        intent.putExtra("noti_color_title", mTitleColor);
        intent.putExtra("noti_color_message", mMessageColor);

        return intent;
    }
}
