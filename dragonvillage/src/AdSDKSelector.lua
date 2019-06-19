AD_TYPE = {
    NONE = 0,               -- 광고 없음(에러코드 처리) : 보상은 존재
    AUTO_ITEM_PICK = 1,     -- 광고 보기 보상 : 자동획득
    RANDOM_BOX_LOBBY = 2,   -- 광고 보기 보상 : 랜덤박스 (로비 진입)
    FOREST = 3,
    EXPLORE = 4,
    FSUMMON = 5,
}

-------------------------------------
-- table AdSDKSelector
-- @brief 광고 SDK 선택자
-------------------------------------
AdSDKSelector = {
        m_isInit = false,
        m_sdkName = 'string', -- 'admob' or 'unityads'
    }

-------------------------------------
-- function initAdSDKSelector
-- @brief 광고 SDK 선택자 초기화
-------------------------------------
function AdSDKSelector:initAdSDKSelector()
    self.m_sdkName = 'admob'
end

-------------------------------------
-- function initRewardedVideoAd
-- @brief 보상형 광고 초기화
-------------------------------------
function AdSDKSelector:initRewardedVideoAd()
    if (CppFunctions:isWin32()) or (self:isAdInactive()) then
        return
    end

    self.m_isInit = true

    if (self.m_sdkName == 'admob') then
        return AdMobManager:initRewardedVideoAd()

    elseif (self.m_sdkName == 'unityads') then
        return UnityAdsManager:initRewardedVideoAd()
    end
end

-------------------------------------
-- function adPreload
-- @brief
-------------------------------------
function AdSDKSelector:adPreload(ad_type)
    if (not self.m_isInit) then
        return
    end

    if (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():adPreload(ad_type)

    elseif (self.m_sdkName == 'unityads') then
        return UnityAdsManager:adPreload(ad_type)
    end
end

-------------------------------------
-- function showByAdType
-- @brief
-------------------------------------
function AdSDKSelector:showByAdType(ad_type, result_cb)
    if (not self.m_isInit) then
        return
    end

    if (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():showByAdType(ad_type, result_cb)

    elseif (self.m_sdkName == 'unityads') then
        return UnityAdsManager:showByAdType(ad_type, result_cb)
    end
end

-------------------------------------
-- function showDailyAd
-- @brief
-------------------------------------
function AdSDKSelector:showDailyAd(ad_type, result_cb)
    if (not self.m_isInit) then
        return
    end

    if (CppFunctions:isWin32()) then
        result_cb('finish')
        return
    end

    if (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():showDailyAd(ad_type, result_cb)

    elseif (self.m_sdkName == 'unityads') then
        return UnityAdsManager:showDailyAd(ad_type, result_cb)
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