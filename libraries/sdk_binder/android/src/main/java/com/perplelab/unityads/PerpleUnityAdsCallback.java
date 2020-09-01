package com.perplelab.unityads;

public interface PerpleUnityAdsCallback {
    public void onError(String error, String message);
    public void onFinish(String placementId, String result);
    public void onReady(String placementId);
    public void onStart(String placementId);
}
