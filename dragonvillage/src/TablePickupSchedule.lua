local PARENT = TableClass

-------------------------------------
-- class TablePickupSchedule
-------------------------------------
TablePickupSchedule = class(PARENT, {
    m_cacheTimeStampMap = 'Map<number, timestamp>',
    })


local instance = nil
-------------------------------------
-- function init
-------------------------------------
function TablePickupSchedule:init()
    self.m_tableName = 'table_pickup_schedule'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getInstance
-------------------------------------
function TablePickupSchedule:getInstance()
    if instance == nil then
        instance = TablePickupSchedule()
    end
    return instance
end

-------------------------------------
-- function getDragonMythReturnDidList
-- @brief   신화 드래곤 소환 복각 풀 팝업 자동화
--          처음으로 부화소에 편입되는 신화 드래곤 리스트
-------------------------------------
function TablePickupSchedule:getDragonMythReturnDidList()
    local curr_time_millisec = ServerTime:getInstance():getCurrentTimestampSeconds()
    local secs_7days = 7*(60*60*24) -- 노출 기간 7일
    local did_list = {}
    self.m_cacheTimeStampMap = {}

    for _, v in pairs(self.m_orgTable) do
        local return_date = v['return_date']
        if return_date ~= '' then
            local start_timestamp_sec = ServerTime:getInstance():datestrToTimestampSec(return_date)
            local secs = curr_time_millisec - start_timestamp_sec
            if secs > 0 and secs < secs_7days then
                table.insert(did_list, v['did'])
                self.m_cacheTimeStampMap[v['did']] = start_timestamp_sec
            end
        end
    end

    return did_list
end

-------------------------------------
-- function getReturnTimeStampByDid
-- @brief   신화 드래곤 소환 복각 날짜
-------------------------------------
function TablePickupSchedule:getReturnTimeStampByDid(did)
    return self.m_cacheTimeStampMap[did]
end
