package com.perplelab.adjust;

import com.adjust.sdk.AdjustEvent;
import com.adjust.sdk.LogLevel;
import com.adjust.sdk.OnDeviceIdsRead;
import com.perplelab.PerpleSDK;
import com.perplelab.PerpleLog;

import com.adjust.sdk.Adjust;
import com.adjust.sdk.AdjustAttribution;
import com.adjust.sdk.AdjustConfig;
import com.adjust.sdk.AdjustEventFailure;
import com.adjust.sdk.AdjustEventSuccess;
import com.adjust.sdk.OnAttributionChangedListener;
import com.adjust.sdk.OnEventTrackingFailedListener;
import com.adjust.sdk.OnEventTrackingSucceededListener;
import com.adjust.sdk.OnSessionTrackingFailedListener;
import com.adjust.sdk.OnSessionTrackingSucceededListener;
import com.adjust.sdk.AdjustSessionFailure;
import com.adjust.sdk.AdjustSessionSuccess;

public class PerpleAdjust {
    private static final String LOG_TAG = "PerpleSDK Adjust";

    private boolean mIsInit;
    private String mAdid = "";

    public PerpleAdjust() {}

    public void init(String appToken, long[] secretKeyArray, boolean isDebug) {
        PerpleLog.d(LOG_TAG, "Initializing Adjust.");

        String environment;
        if( isDebug ) {
            environment = AdjustConfig.ENVIRONMENT_SANDBOX;
        }
        else {
            environment = AdjustConfig.ENVIRONMENT_PRODUCTION;
        }

        AdjustConfig config = new AdjustConfig(PerpleSDK.getInstance().getMainActivity(), appToken, environment);
        if( isDebug ) {
            config.setLogLevel(LogLevel.VERBOSE);
        }
        else {
            config.setLogLevel(LogLevel.WARN);
        }

        // Set attribution delegate.
        config.setOnAttributionChangedListener(new OnAttributionChangedListener() {
            @Override
            public void onAttributionChanged(AdjustAttribution attribution) {
                PerpleLog.d("example", "Attribution callback called!");
                PerpleLog.d("example", "Attribution: " + attribution.toString());
            }
        });

        // Set event success tracking delegate.
        config.setOnEventTrackingSucceededListener(new OnEventTrackingSucceededListener() {
            @Override
            public void onFinishedEventTrackingSucceeded(AdjustEventSuccess eventSuccessResponseData) {
                PerpleLog.d("example", "Event success callback called!");
                PerpleLog.d("example", "Event success data: " + eventSuccessResponseData.toString());
            }
        });

        // Set event failure tracking delegate.
        config.setOnEventTrackingFailedListener(new OnEventTrackingFailedListener() {
            @Override
            public void onFinishedEventTrackingFailed(AdjustEventFailure eventFailureResponseData) {
                PerpleLog.d("example", "Event failure callback called!");
                PerpleLog.d("example", "Event failure data: " + eventFailureResponseData.toString());
            }
        });

        // Set session success tracking delegate.
        config.setOnSessionTrackingSucceededListener(new OnSessionTrackingSucceededListener() {
            @Override
            public void onFinishedSessionTrackingSucceeded(AdjustSessionSuccess sessionSuccessResponseData) {
                PerpleLog.d("example", "Session success callback called!");
                PerpleLog.d("example", "Session success data: " + sessionSuccessResponseData.toString());
            }
        });

        // Set session failure tracking delegate.
        config.setOnSessionTrackingFailedListener(new OnSessionTrackingFailedListener() {
            @Override
            public void onFinishedSessionTrackingFailed(AdjustSessionFailure sessionFailureResponseData) {
                PerpleLog.d("example", "Session failure callback called!");
                PerpleLog.d("example", "Session failure data: " + sessionFailureResponseData.toString());
            }
        });

        // SDK Signature - App Secret setting
        config.setAppSecret(secretKeyArray[0], secretKeyArray[1], secretKeyArray[2], secretKeyArray[3], secretKeyArray[4]);

        Adjust.onCreate(config);

        PerpleLog.d(LOG_TAG, "call getGoogleAdId");
        Adjust.getGoogleAdId(PerpleSDK.getInstance().getMainActivity(), new OnDeviceIdsRead() {
            @Override
            public void onGoogleAdIdRead(String googleAdId) {
                mAdid = googleAdId;
                PerpleLog.d(LOG_TAG, "getGoogleAdId-ADID: " + googleAdId);
            }
        });

        mIsInit = true;
    }

    public void onResume() {
        if (mIsInit) {
            Adjust.onResume();
        }
    }

    public void onPause() {
        if (mIsInit) {
            Adjust.onPause();
        }
    }

    public void trackEvent(String eventToken) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Tapjoy is not initialized.");
            return;
        }

        PerpleLog.d(LOG_TAG, "Adjust trackEvent:" + eventToken);

        AdjustEvent event = new AdjustEvent(eventToken);
        Adjust.trackEvent(event);
    }
    public void trackPayment(String eventToken, String price, String currency) {
        if (!mIsInit) {
            PerpleLog.e(LOG_TAG, "Tapjoy is not initialized.");
            return;
        }
        double retPrice = Double.parseDouble(price);

        PerpleLog.d(LOG_TAG, "Adjust trackPayment:" + eventToken);
        PerpleLog.d(LOG_TAG, "price:" + retPrice);
        PerpleLog.d(LOG_TAG, "currency:" + currency);

        AdjustEvent event = new AdjustEvent(eventToken);
        event.setRevenue(retPrice, currency);
        Adjust.trackEvent(event);
    }

    public String getAdid() {
        return mAdid;
    }
}
