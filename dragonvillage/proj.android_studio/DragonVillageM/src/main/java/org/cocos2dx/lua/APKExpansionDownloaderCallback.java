package org.cocos2dx.lua;

public interface APKExpansionDownloaderCallback {
    void onInit();
    void onCompleted();
    void onUpdateStatus(boolean isPaused, boolean isIndeterminate, boolean isInterruptable, int code, String statusText);
    void onUpdateProgress(long current, long total, String progress, String percent);
}
