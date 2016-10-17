package com.kakao.cocos2dx.plugin;

public interface KakaoAndroidInterface {
	abstract void sendMessage(final String target, final String method, final String params);
	abstract void kakaoCocos2dxExtension(final String params);
}
