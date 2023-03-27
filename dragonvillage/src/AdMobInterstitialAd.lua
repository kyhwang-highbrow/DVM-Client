-------------------------------------
-- table AdMobInterstitialAd
-- @brief AdMob 전면 광고 관리
-------------------------------------
AdMobInterstitialAd = {
    mIsInit = false,
    mCallback = nil,
    mOneTimeCallback = nil,
}

-- 광고 키
local ADMOB_INTERSTITIAL_AD_ID

if (CppFunctions:isAndroid()) then
    -- Admob에서 제공하는 Android test id
    ADMOB_INTERSTITIAL_AD_ID = 'ca-app-pub-4135263923809648/4640022311'

elseif (CppFunctions:isIos()) then
    -- Admob에서 제공하는 iOS test id
    ADMOB_INTERSTITIAL_AD_ID = 'ca-app-pub-4135263923809648/3870436946'

end

-------------------------------------
-- function initInterstitialAd
-------------------------------------
function AdMobInterstitialAd:initInterstitialAd()
    -- @ AdManager
    PerpleSDK:adMobInitInterstitialAd()
    self.mIsInit = true

    self:setResultCallback(function(ret, info) 
        self:result(ret, info)
        if (self.mCallback) then
            self.mCallback(ret, info)
        end

        -- 한 번만 호출되는 콜백
        if (self.mOneTimeCallback) then
            self.mOneTimeCallback(ret, info)
            self.mOneTimeCallback = nil
        end
    end)
    self:setAdUnitId(ADMOB_INTERSTITIAL_AD_ID)
    self:loadRequest()
end

-------------------------------------
-- function setAdUnitId
-------------------------------------
function AdMobInterstitialAd:setAdUnitId(ad_unit_id)
    if (not self.mIsInit) then
        return
    end
    PerpleSDK:itAdSetAdUnitId(ad_unit_id)
end

-------------------------------------
-- function loadRequest
-------------------------------------
function AdMobInterstitialAd:loadRequest()
    if (not self.mIsInit) then
        return
    end
    PerpleSDK:itAdLoadRequest()
end

-------------------------------------
-- function setResultCallback
-------------------------------------
function AdMobInterstitialAd:setResultCallback(cb_func)
    if (not self.mIsInit) then
        return
    end
    PerpleSDK:itAdSetResultCallback(cb_func)
end

-------------------------------------
-- function show
-------------------------------------
function AdMobInterstitialAd:show(result_cb)
    if (not self.mIsInit) then
        return
    end
    
    self.mCallback = function(ret, info)
        if (result_cb) then
            result_cb(ret, info)
        end
    end

    PerpleSDK:itAdShow()
end

-------------------------------------
-- function result
-- @brief 공용 callback 처리
-------------------------------------
function AdMobInterstitialAd:result(ret, info)
    cclog('AdMobInterstitialAd Callback - ret:' .. tostring(ret) .. ', info:' .. tostring(info))

    -- 광고 load 완료
    if (ret == 'receive') then

    -- 광고 load 실패
    elseif (ret == 'fail') then

	-- 광고 open <-> finish
	elseif (ret == 'open') then
        SoundMgr:stopBGM()

	-- 각각 opne, finish와 큰 차이는 없음
	elseif (ret == 'start') then	
	elseif (ret == 'complete') then

    -- 광고 show 완료
    elseif (ret == 'finish') then
        SoundMgr:playPrevBGM()

    -- 광고 show 중단
    elseif (ret == 'cancel') then
        SoundMgr:playPrevBGM()

    -- 에러
    elseif (ret == 'error') then
        SoundMgr:playPrevBGM()
    end
end

-------------------------------------
-- function setOneTimeCallback
-- @brief 한 번만 호출되는 콜백 등록
-- @param one_time_callback(ret, info)
-------------------------------------
function AdMobInterstitialAd:setOneTimeCallback(one_time_callback)
    self.mOneTimeCallback = one_time_callback
end