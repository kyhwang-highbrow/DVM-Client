-------------------------------------
-- class ServerData_NewcomerShop
-- @instance g_newcomerShop
-- @brief 초보자 선물(신규 유저 전용 상점)
-------------------------------------
ServerData_NewcomerShop = class({
        m_serverData = 'ServerData',
        m_tNewcomerShopEndInfo = 'map', -- 활성화된 newcomer_shop의 종료 타임스탬프들 ex) {"10001":1590728992552, "10002":1590728992552}
    })

-------------------------------------
-- function init
-------------------------------------
function ServerData_NewcomerShop:init(server_data)
    self.m_serverData = server_data
    self.m_tNewcomerShopEndInfo = {}
end

-------------------------------------
-- function applyNewcomderShopEndInfo_fromRet
-- @brief
-- @used_at users/title
-------------------------------------
function ServerData_NewcomerShop:applyNewcomderShopEndInfo_fromRet(ret)
    if (ret == nil) then
        return
    end

    -- 개발용 테스트 코드
    if true then
        ret['newcomer_shop_end_info'] = {}
        ret['newcomer_shop_end_info']['10001'] = ((Timer:getServerTime() + 2409) * 1000)
        ret['newcomer_shop_end_info']['10002'] = ((Timer:getServerTime() + 10) * 1000)
    end

    if (ret['newcomer_shop_end_info'] == nil) then
        return
    end

    if (ret['newcomer_shop_end_info'] == false) then
        return
    end

    self:applyNewcomderShopEndInfo(ret['newcomer_shop_end_info'])
end

-------------------------------------
-- function applyNewcomderShopEndInfo
-- @brief
-------------------------------------
function ServerData_NewcomerShop:applyNewcomderShopEndInfo(t_data)
    self.m_tNewcomerShopEndInfo = {}
    
    for i,v in pairs(t_data) do
        local ncm_id = tonumber(i)
        self.m_tNewcomerShopEndInfo[ncm_id] = v
    end
end

-------------------------------------
-- function getNewcomerShopList
-- @brief 초보자 선물(신규 유저 전용 상점)
-- @return table
-------------------------------------
function ServerData_NewcomerShop:getNewcomerShopList()
    return self.m_tNewcomerShopEndInfo -- key: ncm_id, value: timestamp
end

-------------------------------------
-- function getNewcomerShopEndTimestamp
-- @brief 초보자 선물(신규 유저 전용 상점) ID를 통해 종료 시간 얻어옴
-- @param ncm_id number
-------------------------------------
function ServerData_NewcomerShop:getNewcomerShopEndTimestamp(ncm_id)
    if (not self.m_tNewcomerShopEndInfo) then
        return 0
    end

    local ret = self.m_tNewcomerShopEndInfo[ncm_id]
    return ret
end

-------------------------------------
-- function isActiveNewcomerShop
-- @brief
-- @return boolean
-------------------------------------
function ServerData_NewcomerShop:isActiveNewcomerShop(ncm_id)
    local timestamp = self:getNewcomerShopEndTimestamp(ncm_id)
    if (timestamp == nil) then
        return false
    end

    local curr_time = Timer:getServerTime()
    local end_time = (timestamp / 1000)

    if (curr_time < end_time) then
        return true
    else
        return false
    end
end