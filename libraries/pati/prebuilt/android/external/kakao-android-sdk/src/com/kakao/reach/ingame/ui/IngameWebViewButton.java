package com.kakao.reach.ingame.ui;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

import com.kakao.network.ErrorResult;
import com.kakao.network.callback.ResponseCallback;
import com.kakao.reach.ingame.IngameService;
import com.kakao.android.sdk.R;
import com.kakao.util.helper.log.Logger;

/**
 * Created by seed on 15. 9. 7..
 */
public class IngameWebViewButton extends FrameLayout implements View.OnClickListener {
    public IngameWebViewButton(Context context) {
        super(context);
    }

    public IngameWebViewButton(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public IngameWebViewButton(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        inflate(getContext(), R.layout.kakao_reach_ingame_webview_button, this);
        setNewBadge();
        setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        findViewById(R.id.kakao_reach_ingame_webview_new_badge).setVisibility(View.INVISIBLE);

        IngameService.showIngameWebView(new ResponseCallback<Integer>() {

            @Override
            public void onFailure(ErrorResult errorResult) {
                Logger.e(errorResult.getErrorMessage());
            }

            @Override
            public void onSuccess(Integer result) {

            }
        });
    }

    private void setNewBadge() {
        final View badge = findViewById(R.id.kakao_reach_ingame_webview_new_badge);
        badge.setVisibility(View.GONE);

        IngameService.isEnableNewBadge(new ResponseCallback<Boolean>() {

            @Override
            public void onFailure(ErrorResult errorResult) {
                badge.setVisibility(View.GONE);
            }

            @Override
            public void onSuccess(Boolean result) {
                if (result)
                    badge.setVisibility(View.VISIBLE);
                else
                    badge.setVisibility(View.GONE);
            }
        });

    }
}