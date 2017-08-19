-------------------------------------
-- table AdsManager
-- @brief 광고 SDK 매니져
-------------------------------------
AdsManager = {
    callback = function() end,
    mode = 'test',
}

-------------------------------------
-- function skip
-------------------------------------
local function skip()
    if (isWin32()) then 
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

    local function _result_cb(ret, info)
        if (ret == 'ready') and (info == placementId) then
            self:show(placementId, function(ret, info)
                result_cb(ret, info)
            end)
        end
    end

    self:start(placementId, _result_cb)
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