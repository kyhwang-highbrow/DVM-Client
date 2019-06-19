-------------------------------------
-- table AdSDKSelector
-- @brief 광고 SDK 선택자
-------------------------------------
AdSDKSelector = {
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
    if (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():initRewardedVideoAd()
    end
end

-------------------------------------
-- function adPreload
-- @brief
-------------------------------------
function AdSDKSelector:adPreload(ad_id)
    if (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():adPreload(ad_id)
    end
end

-------------------------------------
-- function showByAdType
-- @brief
-------------------------------------
function AdSDKSelector:showByAdType(ad_type, result_cb)
    if (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():showByAdType(ad_type, result_cb)
    end
end

-------------------------------------
-- function showDailyAd
-- @brief
-------------------------------------
function AdSDKSelector:showDailyAd(ad_id, result_cb)
    if (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():showDailyAd(ad_id, result_cb)
    end
end


-------------------------------------
-- function isAdInactive
-------------------------------------
function AdSDKSelector:isAdInactive()
    if (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():isAdInactive()
    end
end

-------------------------------------
-- function makePopupAdInactive
-------------------------------------
function AdSDKSelector:makePopupAdInactive()
    if (self.m_sdkName == 'admob') then
        return AdMobManager:getRewardedVideoAd():makePopupAdInactive()
    end
end