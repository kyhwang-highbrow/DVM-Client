AdsManager = {
    callback = function() end,
    mode = 'test',
    initialized = false,
}

function AdsManager:start(placementId, result_cb)
    self.callback = result_cb or function() end

    if self.initialized == true then
        self.callback('ready', placementId)
        return
    end

    PerpleSDK:unityAdsStart(self.mode, '', function(ret, info)
        if self.initialized == false then
            if ret ~= 'error' then
                self.initialized = true
            end
        end

        cclog('UnityAds Callback - ret:' .. ret .. ',info:' .. info)
        self.callback(ret, info)
    end)
end

function AdsManager:show(placementId, result_cb)
    self.callback = result_cb
    PerpleSDK:unityAdsShow(placementId, '')
end

function AdsManager:showPlacement(placementId, result_cb)
    self:start(placementId, function(ret, info)
        if ret == 'ready' and info == placementId then
            self:show(placementId, function(ret, info)
                result_cb(ret, info)
            end)
        end
    end)
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