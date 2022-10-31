-------------------------------------
-- class IAdModule
-- @brief 광고 모듈 Interface
-------------------------------------
IAdModule = class({
    m_moduleName = 'string'
})

-------------------------------------
-- function init
-------------------------------------
function IAdModule:init()
    self.m_moduleName = ''
end

-------------------------------------
-- function adModuleInitialize
-- @brief 광고 모듈 초기화
-------------------------------------
function IAdModule:adModuleInitialize(callback)
end

-------------------------------------
-- function isAdModuleUsable
-- @brief 광고 모듈 사용 가능 여부
-------------------------------------
function IAdModule:isAdModuleUsable()
    return true
end

-------------------------------------
-- function getModuleName
-- @brief 광고 모듈 이름
-------------------------------------
function IAdModule:getModuleName()
    return self.m_moduleName
end

-------------------------------------
-- function adModuleShowRewardAd_Common
-- @brief 광고 모듈 보상형 광고 일반 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function IAdModule:adModuleShowRewardAd_Common(callback)
    error('IAdModule:adModuleShowRewardAd_Common not override')
end

-------------------------------------
-- function adModuleShowRewardAd_Test
-- @brief 광고 모듈 보상형 광고 테스트 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function IAdModule:adModuleShowRewardAd_Test(callback)
    error('IAdModule:adModuleShowRewardAd_Test not override')
end

-------------------------------------
-- function showRewardAd_Highbrow
-- @brief highbrow 자체 보상형 광고 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function IAdModule:adModuleShowRewardAd_Highbrow(callback, log)
    do -- Firebase Crashlytics Log
        local log = 'IAdModule:adModuleShowRewardAd_Highbrow'
        --PerpleSdkManager.getCrashlytics():setLog(log)
    end

    require('UI_HighbrowAds')

    local function success_cb()
        callback('success', 'highbrow', log) -- params: ret, ad_network, log
    end

    local function cancel_cb()
        callback('cancel', 'highbrow', log) -- params: ret, ad_network, log
    end

    UI_HighbrowAds(success_cb, cancel_cb)
end

-------------------------------------
-- function adModuleShowInterstitialAd_Common
-- @brief 광고 모듈 전면 광고 일반 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function IAdModule:adModuleShowInterstitialAd_Common(callback)
    error('IAdModule:adModuleShowInterstitialAd_Common not override')
end

-------------------------------------
-- function adModuleShowInterstitialAd_Test
-- @brief 광고 모듈 전면 광고 테스트 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function IAdModule:adModuleShowInterstitialAd_Test(callback)
    error('IAdModule:adModuleShowInterstitialAd_Test not override')
end

-------------------------------------
-- function getCloneTable
-------------------------------------
function IAdModule:getCloneTable()
	return clone(IAdModule)
end
