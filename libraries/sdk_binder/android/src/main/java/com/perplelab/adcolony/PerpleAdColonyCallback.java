package com.perplelab.adcolony;

public interface PerpleAdColonyCallback {
    public void onReward(String info);
    public void onReady(String zoneId);
    public void onError(String info);
}
