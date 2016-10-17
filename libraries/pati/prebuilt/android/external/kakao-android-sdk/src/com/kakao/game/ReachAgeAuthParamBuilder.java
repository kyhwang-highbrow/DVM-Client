package com.kakao.game;

import com.kakao.auth.AgeAuthParamBuilder;
import com.kakao.auth.AuthService;

/**
 * Created by house.dr on 16. 4. 21..
 */
public class ReachAgeAuthParamBuilder extends AgeAuthParamBuilder {

    /**
     * 리치 보드 게임을 위한 연령인증 프리셋
     */
    public ReachAgeAuthParamBuilder() {
        setAuthLevel(AuthService.AgeAuthLevel.LEVEL_2);
        setAgeLimit(AuthService.AgeLimit.LIMIT_19);
        setSkipTerm(false);
        setIsWesternAge(false);
    }
}
