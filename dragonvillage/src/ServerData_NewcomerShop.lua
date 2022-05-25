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
    if false then
        ret['newcomer_shop_end_info'] = {}
        ret['newcomer_shop_end_info']['10001'] = ((ServerTime:getInstance():getCurrentTimestampSeconds() + 1209600) * 1000)
        ret['newcomer_shop_end_info']['10002'] = ((ServerTime:getInstance():getCurrentTimestampSeconds() + 60) * 1000)
        ret['newcomer_shop_end_info']['10003'] = ((ServerTime:getInstance():getCurrentTimestampSeconds() + 8640) * 1000)
    end

    if (ret['newcomer_shop_end_info'] == nil) then
        return
    end

    if (ret['newcomer_shop_end_info'] == false) then
        return
    end

    -- 초보자 선물은 2020년 5월 19일에 추가된 상점.
    -- 업데이트 후 생성된 신규계정에만 노출되는 것이 혜택으로 볼 수 있었다.
    -- 기존 유저들에게도 일정 기간동안은 구매를 할 수 있게 하기 위해 하드코딩함.
    if (ret['newcomer_shop_end_info']['10001'] == nil) then
        local date_format = 'yyyy-mm-dd HH:MM:SS'
        local parser = pl.Date.Format(date_format)

        -- 단말기(local)의 타임존 (단위 : 초)
        local timezone_local = ServerTime:getInstance():getLocalUTCOffset()

        -- 서버(server)의 타임존 (단위 : 초)
        local timezone_server = ServerTime:getInstance():getServerUTCOffset()
        local offset = (timezone_local - timezone_server)

        local parse_start_date = parser:parse('2020-06-07 23:59:59')
        if (parse_start_date and parse_start_date['time']) then
            local end_timestamp = parse_start_date['time'] + offset
            ret['newcomer_shop_end_info']['10001'] = (end_timestamp * 1000)
        end
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

    local curr_time = ServerTime:getInstance():getCurrentTimestampSeconds()
    local end_time = (timestamp / 1000)

    if (curr_time < end_time) then
        return true
    else
        return false
    end
end


-------------------------------------
-- function openNewcomerShop
-- @brief
-- @return ui UI
-------------------------------------
function ServerData_NewcomerShop:openNewcomerShop()
    for ncm_id,v in pairs(self.m_tNewcomerShopEndInfo) do
        if (self:isActiveNewcomerShop(ncm_id) == true) then
            require('UI_NewcomerShop')
            local ui = UI_NewcomerShop(ncm_id)
            return ui
        end
    end
    
    return nil
end