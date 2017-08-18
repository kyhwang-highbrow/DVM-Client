AdsManager = {
    callback = function() end,
    placements = {},
    mode = 'test',
    initialized = false,
}

function AdsManager:start(placementId, result_cb)

    if self.initialized == true then
        if self.placements[placementId] then
            result_cb(self.placements[placementId], placementId)
        else
            result_cb('error', 'NOT_READY')
        end
        return
    end

    self.callback = result_cb or function() end

    PerpleSDK:unityAdsStart(self.mode, '', function(ret, info)
        if self.initialized == false then
            if ret ~= 'error' then
                self.initialized = true
            end
        end

        if ret == 'ready' then
            -- info : placementId
            self.placements[info] = 'ready'
        end

        self.callback(ret, info)
    end)
end

function AdsManager:show(placementId, result_cb)
    self.callback = result_cb
    PerpleSDK:unityAdsShow(placementId, '')
end

function AdsManager:showPlacement(placementId, result_cb)
    self:start(placementId, function(ret, info)
        if ret == 'ready' then
            if placementId == info then
                self:show(placementId, function(ret, info)
                    result_cb(ret, info)
                end)
            end
        end
    end)
end
