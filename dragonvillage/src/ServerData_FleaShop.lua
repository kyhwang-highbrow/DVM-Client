-------------------------------------
-- class ServerData_FleaShop
-- @instance g_FleaShop
-- @brief 벼룩시장(신규 유저 전용 상점)
-------------------------------------
ServerData_FleaShop = class({
        m_serverData = 'ServerData',
        m_tFleaShopStartInfo = 'map',
        m_tFleaShopEndInfo = 'map', -- 활성화된 flea_shop의 종료 타임스탬프들 ex) {"10001":1590728992552, "10002":1590728992552}
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_FleaShop:init(server_data)
    self.m_serverData = server_data
    self.m_tFleaShopEndInfo = {}
end

-------------------------------------
-- function applyFleaShopInfo_fromRet
-- @brief
-- @used_at users/title
-------------------------------------
function ServerData_FleaShop:applyFleaShopInfo_fromRet(ret)
    if (ret == nil) then
        return
    end

    -- -- 개발용 테스트 코드
    -- if false then
    --     ret['flea_shop_end_info'] = {}
    --     ret['flea_shop_end_info']['10001'] = ((ServerTime:getInstance():getCurrentTimestampSeconds() + 1209600) * 1000)
    -- end

    -- if (ret['flea_shop_end_info'] == nil) then
    --     return
    -- end

    -- if (ret['flea_shop_end_info'] == false) then
    --     return
    -- end
    self:applyFleaShopStartInfo(ret)
    self:applyFleaShopEndInfo(ret)
end

-------------------------------------
-- function applyFleaShopStartInfo
-- @brief
-------------------------------------
function ServerData_FleaShop:applyFleaShopStartInfo(t_data)
    self.m_tFleaShopStartInfo = {}
    
    for i,v in pairs(t_data) do
        local ncm_id = tonumber(v['ncm_id'])
        self.m_tFleaShopStartInfo[ncm_id] = ServerTime:getInstance():datestrToTimestampMillisec(v['start_date'])
    end
end

-------------------------------------
-- function applyFleaShopEndInfo
-- @brief
-------------------------------------
function ServerData_FleaShop:applyFleaShopEndInfo(t_data)
    self.m_tFleaShopEndInfo = {}
    
    for i,v in pairs(t_data) do
        local ncm_id = tonumber(v['ncm_id'])
        self.m_tFleaShopEndInfo[ncm_id] = ServerTime:getInstance():datestrToTimestampMillisec(v['end_date'])
    end
end

-------------------------------------
-- function getFleaShopList
-- @brief 벼룩시장
-- @return table
-------------------------------------
function ServerData_FleaShop:getFleaShopList()
    return self.m_tFleaShopEndInfo -- key: ncm_id, value: timestamp
end

-------------------------------------
-- function getFleaShopStartTimestamp
-- @brief 벼룩시장 ID를 통해 시작 시간 얻어옴
-- @param ncm_id number
-------------------------------------
function ServerData_FleaShop:getFleaShopStartTimestamp(ncm_id)
    if (not self.m_tFleaShopStartInfo) then
        return 0
    end

    local ret = self.m_tFleaShopStartInfo[ncm_id]
    return ret
end

-------------------------------------
-- function getFleaShopEndTimestamp
-- @brief 벼룩시장 ID를 통해 종료 시간 얻어옴
-- @param ncm_id number
-------------------------------------
function ServerData_FleaShop:getFleaShopEndTimestamp(ncm_id)
    if (not self.m_tFleaShopEndInfo) then
        return 0
    end

    local ret = self.m_tFleaShopEndInfo[ncm_id]
    return ret
end

-------------------------------------
-- function isActiveFleaShop
-- @brief
-- @return boolean
-------------------------------------
function ServerData_FleaShop:isActiveFleaShop(ncm_id)
    local start_timestamp = self:getFleaShopStartTimestamp(ncm_id)
    local end_timestamp = self:getFleaShopEndTimestamp(ncm_id)
    if (timestamp == nil) then
        return false
    end

    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local start_time = (start_timestamp / 1000)
    local end_time = (end_timestamp / 1000)

    if (curr_time >= start_time and curr_time < end_time) then
        return true
    else
        return false
    end
end


-------------------------------------
-- function openFleaShop
-- @brief
-- @return ui UI
-------------------------------------
function ServerData_FleaShop:openFleaShop()
    for ncm_id,v in pairs(self.m_tFleaShopEndInfo) do
        if (self:isActiveFleaShop(ncm_id) == true) then
            require('UI_FleaShop')
            local ui = UI_FleaShop(ncm_id)
            return ui
        end
    end
    
    return nil
end