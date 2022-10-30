-------------------------------------
-- table AdSDKSelector
-- @brief 광고 SDK 선택자
-------------------------------------
AdSDKSelector = {
        m_isInit = false,
        m_sdkName = 'string', -- 'admob' or 'unityads' or 'ad_without_play'
    }

-------------------------------------
-- function initAdSDKSelector
-- @brief 광고 SDK 선택자 초기화
-- @param skip_ad_play(boolean) 광고 재생 생략 여부
-- @param skip_ad_aos_7_later(boolean) 안드로이드 7 이상에서 광고 재생 스킵 여부
-------------------------------------
function AdSDKSelector:initAdSDKSelector(skip_ad_play, skip_ad_aos_7_later, skip_facebook_ad_play)
    cclog('# skip_ad_play : ' .. tostring(skip_ad_play))
    cclog('# skip_ad_aos_7_later : ' .. tostring(skip_ad_aos_7_later))
    cclog('# skip_facebook_ad_play : ' .. tostring(skip_facebook_ad_play))
    
    -- 앱 버전별로 처리할 필요가 있을 경우에 사용하는 코드
    --local appver_str = CppFunctionsClass:getAppVer()
    --isExistValue(appver_str, '1.1.7', '0.6.3', '0.6.4')
    
    -- 모든 광고 재생 스킵
    if (skip_ad_play == true) then
        
        self.m_sdkName = 'ad_without_play'

    else
        
        -- 라이브 서버인가?
        if IS_LIVE_SERVER() or IS_QA_SERVER() then
             -- 라이브 1.2.8 버전부터 안드로이드에서만 페북 광고를 쓴다.
             if (getAppVerNum() >= 1002008 and CppFunctionsClass:isAndroid() == true) then
                -- facebook 광고 on off
                if (skip_facebook_ad_play == true) then 
                    self.m_sdkName = 'ad_without_play'
                else
                    self.m_sdkName = 'facebookAudienceNetwork'
                end
             else
                self.m_sdkName = 'admob'

                -- 안드로이드 7 이상에서 skip일 경우
                if (CppFunctionsClass:isAndroid() == true) then
                    if (skip_ad_aos_7_later == true) then
                        -- Android 버전 체크
                        local version_sdk_int = tonumber(g_userData:getDeviceInfoByKey('VERSION_SDK_INT'))
                        -- https://developer.android.com/about/dashboards
                        -- API      Version Codename
                        -- 29       10.0    10
                        -- 28       9.0     Pie
                        -- 27       8.1     Oreo
                        -- 26       8.0     Oreo
                        -- 25       7.1     Nougat
                        -- 24       7.0     Nougat      <-- 7.0이상부터 오류가 발생하고 있음
                        -- 23       6.0     Marshmallow
                        if (version_sdk_int and (24 <= version_sdk_int)) then
                            self.m_sdkName = 'ad_without_play'
                        end
                    end
                end
             end
        else
            -- QA 0.7.9 부터 들어가는 기능
            if (getAppVerNum() >= 7009 and CppFunctionsClass:isAndroid() == true) then
                self.m_sdkName = 'facebookAudienceNetwork'
            else
                self.m_sdkName = 'admob'

                -- 안드로이드 7 이상에서 skip일 경우
                if (CppFunctionsClass:isAndroid() == true) then
                    if (skip_ad_aos_7_later == true) then
                        -- Android 버전 체크
                        local version_sdk_int = tonumber(g_userData:getDeviceInfoByKey('VERSION_SDK_INT'))
                        -- https://developer.android.com/about/dashboards
                        -- API      Version Codename
                        -- 29       10.0    10
                        -- 28       9.0     Pie
                        -- 27       8.1     Oreo
                        -- 26       8.0     Oreo
                        -- 25       7.1     Nougat
                        -- 24       7.0     Nougat      <-- 7.0이상부터 오류가 발생하고 있음
                        -- 23       6.0     Marshmallow
                        if (version_sdk_int and (24 <= version_sdk_int)) then
                            self.m_sdkName = 'ad_without_play'
                        end
                    end
                end
            end
        end
    end

    self:log('call initAdSDKSelector() ' .. tostring(self.m_sdkName))
end

function AdSDKSelector:getSDKName()
    return self.m_sdkName
end

-------------------------------------
-- function initRewardedVideoAd
-- @brief 보상형 광고 초기화
-------------------------------------
function AdSDKSelector:initRewardedVideoAd()
    self:log('call initRewardedVideoAd()')

    if (CppFunctions:isWin32()) or (self:isAdInactive()) then
        return
    end

    self.m_isInit = true

    if (self.m_sdkName == 'facebookAudienceNetwork') then
        return FacebookAudienceNetworkManager:initRewardedVideoAd()

    elseif (self.m_sdkName == 'admob') then
        return AdMobManager:initRewardedVideoAd()

    elseif (self.m_sdkName == 'unityads') then
        return UnityAdsManager:initRewardedVideoAd()

    elseif (self.m_sdkName == 'ad_without_play') then
        -- 아무것도 진행하지 않음
        return

    end
end

-------------------------------------
-- function adPreload
-- @brief
-------------------------------------
function AdSDKSelector:adPreload(ad_type)
    self:log('call adPreload() ad_type : ' .. tostring(ad_type))

    if (not self.m_isInit) then
        return
    end

    if (self.m_sdkName == 'facebookAudienceNetwork') then
        return FacebookAudienceNetworkManager:getRewardedVideoAd():adPreload(ad_type)

    elseif (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():adPreload(ad_type)

    elseif (self.m_sdkName == 'unityads') then
        return UnityAdsManager:adPreload(ad_type)

    elseif (self.m_sdkName == 'ad_without_play') then
        -- 아무것도 진행하지 않음
        return

    end
end

-------------------------------------
-- function showByAdType
-- @brief
-------------------------------------
function AdSDKSelector:showByAdType(ad_type, result_cb)
    self:log('call showByAdType() ad_type : ' .. tostring(ad_type))

    if (not self.m_isInit) then
        return
    end

    if (self.m_sdkName == 'facebookAudienceNetwork') then
        return FacebookAudienceNetworkManager:getRewardedVideoAd():showByAdType(ad_type, result_cb)

    elseif (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():showByAdType(ad_type, result_cb)

    elseif (self.m_sdkName == 'unityads') then
        return UnityAdsManager:showByAdType(ad_type, result_cb)

    elseif (self.m_sdkName == 'ad_without_play') then
        return AdWithoutPlayManager:showByAdType(ad_type, result_cb)

    end
end

-------------------------------------
-- function showDailyAd
-- @brief
-------------------------------------
function AdSDKSelector:showDailyAd(ad_type, result_cb)
    self:log('call showByAdType() showDailyAd : ' .. tostring(ad_type))

    if (not self.m_isInit) then
        return
    end

    if (CppFunctions:isWin32()) then
        result_cb('finish')
        return
    end

    if (self.m_sdkName == 'facebookAudienceNetwork') then
        return FacebookAudienceNetworkManager:getRewardedVideoAd():showDailyAd(ad_type, result_cb)

    elseif (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():showDailyAd(ad_type, result_cb)

    elseif (self.m_sdkName == 'unityads') then
        return UnityAdsManager:showDailyAd(ad_type, result_cb)

    elseif (self.m_sdkName == 'ad_without_play') then
        return AdWithoutPlayManager:showDailyAd(ad_type, result_cb)
    end
end


-------------------------------------
-- function isAdInactive
-------------------------------------
function AdSDKSelector:isAdInactive()
    return g_localData:isAdInactive()
end

-------------------------------------
-- function makePopupAdInactive
-------------------------------------
function AdSDKSelector:makePopupAdInactive()
	local msg, sub_msg
	local lang = Translate:getGameLang()
	
	if (lang == 'ko') then
		msg = '동영상 광고 일시 중지 안내'
		sub_msg = '동영상 광고 송출에 장애가 있어 문제를 처리 중입니다.\n여러분의 양해를 부탁드립니다.'

	elseif (lang == 'zh') then
		msg = '影片廣告暫時終止公告'
		sub_msg = '正在處理影片廣告輸出時所發生的問題。如造成不便，敬請見諒。'

	elseif (lang == 'ja') then
		msg = '動画広告の一時中止のお知らせ'
		sub_msg = 'ただいま動画広告に関する不具合を処理中です。\n皆様のご了承をお願い致します。'

	else
		msg = 'Ad Viewing Temporarily Unavailable'
		sub_msg = 'Ad viewing is currently not available due to technical problems.\nThank you for your understanding.'

	end

	MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)
end

-------------------------------------
-- function log
-------------------------------------
function AdSDKSelector:log(msg)
    local active = true
    if (not active) then
        return
    end

    cclog('##AdSDKSelector log## : ' .. tostring(msg))
end