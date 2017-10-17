local PARENT = TableClass

-------------------------------------
-- class TableColosseumBuff
-------------------------------------
TableColosseumBuff = class(PARENT, {
    })

local THIS = TableColosseumBuff

-------------------------------------
-- function init
-------------------------------------
function TableColosseumBuff:init()
    self.m_tableName = 'table_colosseum_buff'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getStraightBuffData
-------------------------------------
function TableColosseumBuff:getStraightBuffData(wins)
    if (self == THIS) then
        self = THIS()
    end

    local skip_error_msg = true
    local t_table = self:get(wins, skip_error_msg)

    -- 낮은 연승의 버프를 검색 (10연승 이후에는 버프가 없고 시간만 초기화됨)
    if (not t_table) then
        for i=wins, 1, -1 do
            t_table = self:get(i, skip_error_msg)
            if t_table then
                break
            end
        end
    end
    
	-- 버프 값이 비어있을 경우 버프 없음 (1연승)
    local buff_str = nil
    if t_table then
        if (t_table['buff'] ~= '') then
            buff_str = t_table['buff']
        end
    end

    if (not buff_str) then
        return {}
    else
        return TableOption:parseOptionContentStr(buff_str)
    end
end