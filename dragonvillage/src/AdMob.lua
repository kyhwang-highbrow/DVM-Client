-- @inherit IAdModule
local PARENT = IAdModule:getCloneTable()

-------------------------------------
---@class AdMob
-- @brief 보상형 동영상 광고
-------------------------------------
AdMob = class(PARENT, {
    m_unitID = 'string',     -- 기본 광고
    m_testUnitID = 'string', -- 테스트 광고 유닛 ID
})

local instance = nil

-------------------------------------
-- function init
-------------------------------------
function AdMob:init()
    self.m_moduleName = 'admob'

    if CppFunctions:isAndroid() then
        self.m_unitID = 'ca-app-pub-9497777061019569/6433744394'
        self.m_testUnitID = 'ca-app-pub-9497777061019569/7659560061'

    elseif CppFunctions:isIos() then
        self.m_unitID = 'ca-app-pub-9497777061019569/2042688805'
        self.m_testUnitID = 'ca-app-pub-9497777061019569/1610486021'
    else

    end
end

-------------------------------------
-- function getInstance
---@return AdMob
-------------------------------------
function AdMob:getInstance()
    if (instance == nil) then
        instance = AdMob()
    end
    return instance
end

-------------------------------------
-- function adModuleInitialize override
-- @brief AdMob SDK 초기화
-------------------------------------
function AdMob:adModuleInitialize(callback)
    do -- Firebase Crashlytics Log
        local log = 'AdMob:adModuleInitialize'
        --FirebaseCrashlytics:getInstance():crashlyticsSetLog(log)
        PerpleSdkManager.getCrashlytics():setLog(log)
    end

    local loading_ui = UI_Loading()

    -- PerpleSDK:adMobInitialize(function(ret, info) end)를 호출한 것과 같음
    local ret = PerpleSDK:adMobInitialize(function(ret, info)
        do -- Firebase Crashlytics Log
            local log = 'AdMob:adModuleInitialize return ' .. tostring(ret) ..  ' ' .. tostring(info)
            PerpleSdkManager.getCrashlytics():setLog(log)
            --FirebaseCrashlytics:getInstance():crashlyticsSetLog(log)
        end

        loading_ui:close()
        -- ret : "success"만 리턴하고 있음
        -- info : java상의 InitializationStatus클래스 인스턴스의 toString()

        if callback then
            callback(ret, info)
        end

        -- 광고 프리로드
        self:_adMobLoadRewardedAd(self.m_testUnitID)
        self:_adMobLoadRewardedAd(self.m_unitID)
    end)

    -- 빌드 버전에 따라 adMobInitialize함수가 없을 수 있다.
    if (ret == false) then
        if callback then
            callback('success', '')
        end
    end
end

-------------------------------------
-- function _adMobLoadRewardedAd
-- @brief AdMob 광고 로드
-- @param ad_unit_id(string)
-- @param callback(function)
-------------------------------------
function AdMob:_adMobLoadRewardedAd(ad_unit_id, callback)
    do -- Firebase Crashlytics Log
        local log = 'AdMob:_adMobLoadRewardedAd #' .. tostring(ad_unit_id)
        --FirebaseCrashlytics:getInstance():crashlyticsSetLog(log)
        PerpleSdkManager.getCrashlytics():setLog(log)
    end

    -- PerpleSDK:adMobLoadRewardAd(adUnitId, function(ret, info) end)를 호출한 것과 같음
    PerpleSDK:adMobLoadRewardAd(ad_unit_id, function(ret, info)
        do -- Firebase Crashlytics Log
            local log = 'AdMob:_adMobLoadRewardedAd return ' .. tostring(ret) ..  ' ' .. tostring(info)
            --FirebaseCrashlytics:getInstance():crashlyticsSetLog(log)
            PerpleSdkManager.getCrashlytics():setLog(log)
        end

        -- ret : "success", "loading", "fail", 

        if callback then
            callback(ret, info)
        end
    end)
end

-------------------------------------
-- function adMobShowRewardAd
-- @brief AdMob 광고 재생
-- @param ad_unit_id(string)
-- @param callback function(ret, ad_network, log)
-------------------------------------
function AdMob:_adMobShowRewardAd(ad_unit_id, callback)
    do -- Firebase Crashlytics Log
        local log = 'AdMob:_adMobShowRewardAd #' .. tostring(ad_unit_id)
        PerpleSdkManager.getCrashlytics():setLog(log)
        --FirebaseCrashlytics:getInstance():crashlyticsSetLog(log)
    end

    if (isWin32() or isMac()) then
        self:adModuleShowRewardAd_Highbrow(callback, 'emulator')
        return
    end

    local loading_ui = UI_Loading()

    local func_load
    local func_show
    local func_finish

    func_load = function()
        self:_adMobLoadRewardedAd(ad_unit_id, function(ret, info)
            if (ret == 'success') then
                -- @nextfunc
                func_show()
            elseif (ret == 'loading') then
                local msg = Str('광고를 불러오는 중입니다. 잠시 후에 다시 시도해주세요.')
                MakeSimplePopup(POPUP_TYPE.OK, msg)

                -- @escape
                loading_ui:close()
                callback('fail')
            else--if (ret == 'fail') then
                -- AdMob에서 광고를 받아오지 못하는 경우 테스트 광고로 전환
                if (ad_unit_id ~= self.m_testUnitID) then
                    local code = self:getCodeNumberFromInfoStr(info)
                    if (code == 0) then
                        -- 0: 'Internal error.'' (aos)
                        loading_ui:close()
                        self:adModuleShowRewardAd_Highbrow(callback, info)
                        return

                    elseif (code == 1) then
                        -- 1: 'Request Error: No ad to show' (ios)
                        loading_ui:close()
                        self:adModuleShowRewardAd_Highbrow(callback, info)
                        return

                    elseif (code == 3) then
                        -- 3: 'Ad failed to load' (aos)
                        loading_ui:close()
                        self:adModuleShowRewardAd_Highbrow(callback, info)
                        return
                    else
                        loading_ui:close()
                        self:adModuleShowRewardAd_Highbrow(callback, info)
                    end
                end

                local msg = Str('광고를 불러오는 과정에서 에러가 발생했습니다.')
                local sub_msg = self:parseAdMobErrorMessage(info)
                MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)

                -- @escape
                loading_ui:close()
                callback('fail')
            end
        end)
    end
    
    func_show = function()
        -- PerpleSDK:showRewardedAd(adUnitId, function(ret, info) end)를 호출한 것과 같음
        PerpleSDK:adMobShowRewardAd(ad_unit_id, function(ret, info)
            do -- Firebase Crashlytics Log
                local log = 'AdMob:_adMobShowRewardAd return ' .. tostring(ret) ..  ' ' .. tostring(info)
                --FirebaseCrashlytics:getInstance():crashlyticsSetLog(log)
                PerpleSdkManager.getCrashlytics():setLog(log)
            end

            -- ret : 'success', 'cancel', 'fail'
            if (ret == 'success') then
                do -- Firebase Crashlytics Value
                    --FirebaseCrashlytics:getInstance():crashlyticsSetKeyValue('did_view_ads', true)
                end

                -- @nextfunc
                func_finish(ret, info)
            else
                if (ret == 'cancel') then
                    local msg = Str('광고 시청 도중 취소하셨습니다.')
                    MakeSimplePopup(POPUP_TYPE.OK, msg)

                else --if(ret == 'fail') then
                    local msg = Str('광고 재생 과정에서 오류가 발생하였습니다. 잠시 후 다시 시도해 주세요.')
                    local sub_msg = self:parseAdMobErrorMessage(info)
                    MakeSimplePopup2(POPUP_TYPE.OK, msg, sub_msg)
                end
                -- @escape
                loading_ui:close()
                callback(ret, 'admob', tostring(info)) -- params: ret, ad_network, log
            end
        end)
    end

    func_finish = function(ret, info)
        -- @escape
        loading_ui:close()
        callback('success', 'admob') -- params: ret, ad_network, log

        -- 광고 프리로드
        self:_adMobLoadRewardedAd(ad_unit_id)
    end

    func_load()
end

-------------------------------------
-- function adModuleShowRewardAd_Common
-- @brief AdMob 보상형 광고 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function AdMob:adModuleShowRewardAd_Common(callback)
    self:_adMobShowRewardAd(self.m_unitID, callback)
end

-------------------------------------
-- function adModuleShowRewardAd_Test
-- @brief AdMob 보상형 광고 테스트 재생
-- @param callback function(ret, ad_network, log)
-------------------------------------
function AdMob:adModuleShowRewardAd_Test(callback)
    self:_adMobShowRewardAd(self.m_testUnitID, callback)
end

-------------------------------------
-- function parseAdMobErrorMessage
-- @brief 오류 메세지
-- @param info_str(string)
-------------------------------------
function AdMob:parseAdMobErrorMessage(info_str)
    if (type(info_str) ~= 'string') then
        return ''
    end

    local info_json = json_decode(info_str)
    if (type(info_json) ~= 'table') then
        return info_str
    end

    if (info_json['msg'] and info_json['code'] and info_json['subcode']) then
        return Str('({1} code:{2} subcode:{3})', info_json['msg'], info_json['code'], info_json['subcode'])
    end

    if (info_json['msg'] and info_json['code']) then
        return Str('({1} code:{2})', info_json['msg'], info_json['code'])
    end

    if (info_json['msg']) then
        return Str('({1})', info_json['msg'])
    end

    return info_str
end

-------------------------------------
-- function infoStrToTable
-- @brief
-- @param info_str(string)
-------------------------------------
function AdMob:infoStrToTable(info_str)
    if (type(info_str) ~= 'string') then
        return {}
    end

    local info_json = json_decode(info_str)
    if (type(info_json) ~= 'table') then
        return {}
    end

    return info_json
end

-------------------------------------
-- function getCodeNumberFromInfoStr
-- @brief
-- @param info_str(string)
-------------------------------------
function AdMob:getCodeNumberFromInfoStr(info_str)
    local info_json = self:infoStrToTable(info_str)
    local code = tonumber(info_json['code'])
    return code
end

-------------------------------------
-- virtual function adModuleShowInterstitialAd_Common override
-- @brief AdMob 전면 광고 재생 (지원 X)
-- @param callback function(ret, ad_network, log)
-------------------------------------
function AdMob:adModuleShowInterstitialAd_Common(callback)
    cclog('Admob 전면 광고 지원 X')
    SafeFuncCall(callback, 'fail')
end

-------------------------------------
-- virtual function adModuleShowInterstitialAd_Test override
-- @brief AdMob 전면 광고 테스트 재생 (지원 X)
-- @param callback function(ret, ad_network, log)
-------------------------------------
function AdMob:adModuleShowInterstitialAd_Test(callback)
    cclog('Admob 전면 광고 지원 X')
    SafeFuncCall(callback, 'fail')
end