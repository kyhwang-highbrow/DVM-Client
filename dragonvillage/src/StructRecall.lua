--@inherit Structure
local PARENT = Structure

-------------------------------------
---@class StructRecall
-------------------------------------
StructRecall = class(PARENT, {
    did = 'number',
    start_time_millisec = 'timestamp',
    end_time_millisec = 'timestamp',
    is_recalled = 'boolean',
})

local THIS = StructRecall


-------------------------------------
-- function init
-------------------------------------
function StructRecall:init(data)

end

-------------------------------------
-- function getClassName
---@return string
-------------------------------------
function StructRecall:getClassName()
    return 'StructRecall'
end

-------------------------------------
-- function getThis
---@return StructRecall
-------------------------------------
function StructRecall:getThis()
    return THIS
end

-------------------------------------
-- function isAvailable
---@return boolean
-------------------------------------
function StructRecall:isAvailable()
    local result = self.is_recalled

    -- 이미 해당 did의 드래곤을 리콜을 한 경우
    if (result == true) then
        return false
    end

    -- 시간 체크
    local curr_time_millisec = ServerTime:getInstance():getCurrentTimestampMilliseconds()

    local start_time_millisec = self.start_time_millisec
    local end_time_millisec = self.end_time_millisec

    -- 서버에서 전달받은 시작 시간이 있고, 시작 시간 전인 경우
    if (start_time_millisec > 0) and (curr_time_millisec < start_time_millisec) then
        return false
    end

    -- 서버에서 전달받은 종료 시간이 있고, 종료 시간 후인 경우
    if (end_time_millisec > 0) and (curr_time_millisec > end_time_millisec) then
        return false
    end
    
    return true
end

-------------------------------------
-- function getTargetDragonList
---@return table
-------------------------------------
function StructRecall:getTargetDragonList()
    return g_dragonsData:getDragonsList_specificDid(tonumber(self.did))
end

-------------------------------------
-- function getTargetDid
---@return number
-------------------------------------
function StructRecall:getTargetDid()
    return self.did
end

-------------------------------------
-- function getRemainingTimeStr
---@return string
-------------------------------------
function StructRecall:getRemainingTimeStr()
    local time_str = ServerTime:getInstance():getRemainTimeDesc(self.end_time_millisec)
    return Str('종료까지 {1} 남음', time_str)
end
