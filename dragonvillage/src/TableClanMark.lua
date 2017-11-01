local PARENT = TableClass

-------------------------------------
-- class TableClanMark
-------------------------------------
TableClanMark = class(PARENT, {
        m_bgMap = 'table',
        m_symbolMap = 'table',
        m_colorMap = 'table',
    })

-------------------------------------
-- function init
-------------------------------------
function TableClanMark:init()
    self.m_tableName = 'table_clan_mark'
    self.m_orgTable = TABLE:get(self.m_tableName)

    self:initTableByType()
end

-------------------------------------
-- function initTableByType
-------------------------------------
function TableClanMark:initTableByType()
    -- 배경 정보
    local map = self:filterList('type', 'bg')
    self.m_bgMap = {}
    for i,v in pairs(map) do
        local idx = v['idx']
        self.m_bgMap[idx] = v
    end

    -- 문양(symbol) 정보
    local map = self:filterList('type', 'symbol')
    self.m_symbolMap = {}
    for i,v in pairs(map) do
        local idx = v['idx']
        self.m_symbolMap[idx] = v
    end


    -- 색상 정보
    local map = self:filterList('type', 'color')
    self.m_colorMap = {}
    for i,v in pairs(map) do
        local idx = v['idx']
        self.m_colorMap[idx] = v
    end
end

-------------------------------------
-- function getBgRes
-------------------------------------
function TableClanMark:getBgRes(idx)
    local t_data = self.m_bgMap[idx]
    if (not t_data) then
        return nil
    end

    local res = t_data['res_01']
    return res
end

-------------------------------------
-- function getSymbolRes
-------------------------------------
function TableClanMark:getSymbolRes(idx, sub_idx)
    local t_data = self.m_symbolMap[idx]
    if (not t_data) then
        return nil
    end

    local res = t_data['res_0' .. sub_idx]
    return res
end

-------------------------------------
-- function getColor
-------------------------------------
function TableClanMark:getColor(idx)
    local t_data = self.m_colorMap[idx]
    if (not t_data) then
        return nil
    end

    local color = cc.c3b(t_data['color_r'], t_data['color_g'], t_data['color_b'])
    return color
end