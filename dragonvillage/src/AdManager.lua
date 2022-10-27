-------------------------------------
---@class AdManager
-- @brief 보상형 동영상 광고
-------------------------------------
AdManager = class({
    m_adModule = 'IAdModule', -- 광고 모듈
})

local instance = nil

-------------------------------------
-- function init
-------------------------------------
function AdManager:init()
    -- 기본 광고 모듈은 AdMob 사용
    local ad_module = AdMob:getInstance()

    -- -- Hive AdKit(ADOP) 사용 가능한지 검사
    -- if (HiveAdKit:getInstance():isAdModuleUsable() == true) then
    --     ad_module = HiveAdKit:getInstance()
    -- end

    -- 사용할 광고 모듈 
    self.m_adModule = ad_module
end

-------------------------------------
-- function getInstance
---@return AdManager
-------------------------------------
function AdManager:getInstance()
    if (instance == nil) then
        instance = AdManager()
    end

    return instance
end

-------------------------------------
-- function adManagerInitialize
-- @brief AdManager SDK 초기화
-------------------------------------
function AdManager:adManagerInitialize(callback)
    if (self.m_adModule == nil) then
        cclog('AdManager init failed.')
        return
    end
    self.m_adModule:adModuleInitialize(callback)
end

-------------------------------------
-- function showRewardAd_Common
-- @brief AdManager 보상형 광고 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function AdManager:showRewardAd_Common(callback)
    if (self.m_adModule == nil) then
        cclog('AdManager init failed.')
        return
    end
    self.m_adModule:adModuleShowRewardAd_Common(callback)
end

-------------------------------------
-- function showRewardAd_Test
-- @brief AdManager 보상형 광고 테스트 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function AdManager:showRewardAd_Test(callback)
    if (self.m_adModule == nil) then
        cclog('AdManager init failed.')
        return
    end
    self.m_adModule:adModuleShowRewardAd_Test(callback)
end

-------------------------------------
-- function showRewardAd_Highbrow
-- @brief highbrow 자체 보상형 광고 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function AdManager:showRewardAd_Highbrow(callback, log)
    if (self.m_adModule == nil) then
        cclog('AdManager init failed.')
        return
    end
    self.m_adModule:adModuleShowRewardAd_Highbrow(callback)
end

-------------------------------------
-- function showInterstitialAd_Common
-- @brief AdManager 전면 광고 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function AdManager:showInterstitialAd_Common(callback)
    if (self.m_adModule == nil) then
        cclog('AdManager init failed.')
        return
    end
    self.m_adModule:adModuleShowInterstitialAd_Common(callback)
end

-------------------------------------
-- function showInterstitialAd_Test
-- @brief AdManager 전면 광고 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function AdManager:showInterstitialAd_Test(callback)
    if (self.m_adModule == nil) then
        cclog('AdManager init failed.')
        return
    end
    self.m_adModule:adModuleShowInterstitialAd_Test(callback)
end

-------------------------------------
-- function getAdModuleName
-- @brief 광고 모듈 이름 (ex: admob)
---@return string
-------------------------------------
function AdManager:getAdModuleName()
    return self.m_adModule:getModuleName()
end