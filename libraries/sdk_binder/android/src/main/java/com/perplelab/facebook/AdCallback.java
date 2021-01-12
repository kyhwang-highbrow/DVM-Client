package com.perplelab.facebook;

public interface AdCallback {
    // ad load
    void onReceive(String info);
    void onFail(String info);

    // ad show
    void onOpen(String info);
    void onStart(String info);
    void onFinish(String info);
    void onCancel(String info);

    // error
    void onError(String info);
}
