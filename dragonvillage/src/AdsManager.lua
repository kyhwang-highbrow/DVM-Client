-------------------------------------
-- table AdsManager
-- @brief 광고 SDK 매니져
-------------------------------------
AdsManager = {
    callback = function() end,
    mode = '',
}

-------------------------------------
-- function skip
-------------------------------------
local function skip()
    if (isWin32()) then 
        return true
    end

    -- 0.3.4 버전 미만에서는 skip
    local app_ver_num = getAppVerNum()
    if (app_ver_num < AppVer_strToNum('0.3.4')) then
        return true
    end

    return false
end

-------------------------------------
-- function prepare
-------------------------------------
function AdsManager:prepare()
    if (skip()) then 
        return
    end

    self:start('', nil)
end

-------------------------------------
-- function start
-------------------------------------
function AdsManager:start(placementId, result_cb)
    if (skip()) then 
        return
    end

    self.callback = result_cb or function() end

    local function _result_cb(ret, info)
        cclog('UnityAds Callback - ret:' .. ret .. ',info:' .. info)
        self.callback(ret, info)
    end

    if (IS_TEST_MODE()) then
        self.mode = 'test'
    end

    PerpleSDK:unityAdsStart(self.mode, '', _result_cb)
end

-------------------------------------
-- function show
-------------------------------------
function AdsManager:show(placementId, result_cb)
    if (skip()) then 
        return
    end

    self.callback = result_cb or function() end

    PerpleSDK:unityAdsShow(placementId, '')
end

-------------------------------------
-- function showPlacement
-------------------------------------
function AdsManager:showPlacement(placementId, result_cb)
    if (skip()) then 
        return
    end

    local function __result_cb(ret, info)
        if (ret == 'error') then
            self:showErrorPopup(info, function()
                result_cb(ret, info)
            end)
        else
            result_cb(ret, info)
        end
    end

    local function _result_cb(ret, info)
        if (ret == 'ready') then
            if (info == placementId) then
                self:show(placementId, function(ret, info)
                    __result_cb(ret, info)
                end)
            end
        else
            __result_cb(ret, info)
        end
    end

    self:start(placementId, _result_cb)
end

-------------------------------------
-- function showErrorPopup
-------------------------------------
function AdsManager:showErrorPopup(errorCode, result_cb)
    local msg = ''

    if (errorCode == 'INITIALIZE_FAILED') then
        msg = Str('광고 모듈 초기화에 실패하였습니다.')
    elseif (errorCode == 'NOT_INITIALIZED') then
        msg = Str('광고 모듈이 아직 초기화되지 않았습니다. 잠시 후 다시 시도해 주세요.')
    elseif (errorCode == 'VIDEO_PLAYER_ERROR') then
        msg = Str('광고를 재생하는 비디오 플레이어에서 오류가 발생하였습니다.')
    elseif (errorCode == 'AD_BLOCKER_DETECTED') then
        msg = Str('광고가 차단되었습니다. 광고를 보시려면 광고 차단기를 해제하고 다시 시도해 주세요.')
    elseif (errorCode == 'FILE_IO_ERROR') then
        msg = Str('저장공간이 부족하여 광고를 다운로드받지 못했습니다. 불필요한 앱이나 파일을 삭제 후 다시 시도해 주세요.')
    elseif (errorCode == 'DEVICE_ID_ERROR') then
        msg = Str('디바이스 설정에 문제가 있어 광고를 보실 수 없습니다.')
    elseif (errorCode == 'INIT_SANITY_CHECK_FAIL') then
        msg = Str('디바이스 환경 설정에 문제가 있어 광고를 보실 수 없습니다.')
    elseif (errorCode == 'INVALID_ARGUMENT') then
        msg = Str('광고 API 호출시 잘못된 인자를 전달하였습니다.')
    elseif (errorCode == 'SHOW_ERROR') then
        msg = Str('광고 재생 과정에서 오류가 발생하였습니다. 잠시 후 다시 시도해 주세요.')
    else
        -- 'INTERNAL_ERROR'
        msg = Str('광고 모듈에 오류가 발생하였습니다. 잠시 후 다시 시도해 주세요.')
    end

    MakeSimplePopup(POPUP_TYPE.OK, msg, result_cb)
end

-- 호출 방법
--[[
    AdsManager:showPlacement('rewardedVideo', function(ret, info)
        if ret == 'finish' then
            local t_info = dkjson.decode(info)
            ccdump(t_info)
            if t_info.placementId == 'rewardedVideo' then
                if t_info.result ~= 'SKIPPED' then
                    -- 보상 처리
                    MakeSimplePopup(POPUP_TYPE.OK, Str('광고 시청 완료!'))
                end
            end
        elseif ret == 'error' then
            if info == 'NOT_READY' then
                -- 광고가 없는 경우 또는 못 가져오는 경우
                MakeSimplePopup(POPUP_TYPE.OK, Str('광고 없음!'))
            end
        end
    end)
--]]