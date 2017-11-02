local PARENT = Structure

-------------------------------------
-- class StructClanMark
-------------------------------------
StructClanMark = class(PARENT, {
        m_bgIdx = 'number',
        m_symbolIdx = 'number',
        m_colorIdx1 = 'number',
        m_colorIdx2 = 'number',
    })

local THIS = StructClanMark

-------------------------------------
-- function init
-------------------------------------
function StructClanMark:init(data)
    self.m_bgIdx = 30
    self.m_symbolIdx = 1
    self.m_colorIdx1 = 5
    self.m_colorIdx2 = 6
end

-------------------------------------
-- function copy
-------------------------------------
function StructClanMark:copy()
    local struct_clan_mark = StructClanMark()

    for i,v in pairs(self) do
        struct_clan_mark[i] = v
    end

    return struct_clan_mark
end

-------------------------------------
-- function create
-------------------------------------
function StructClanMark:create(str)
    local struct_clan_mark = StructClanMark()
    local l_str = pl.stringx.split(str, ';')
    
    if (4 <= table.count(l_str)) then
        struct_clan_mark.m_bgIdx = tonumber(l_str[1])
        struct_clan_mark.m_symbolIdx = tonumber(l_str[2])
        struct_clan_mark.m_colorIdx1 = tonumber(l_str[3])
        struct_clan_mark.m_colorIdx2 = tonumber(l_str[4])
    end
    return struct_clan_mark
end

-------------------------------------
-- function getClassName
-------------------------------------
function StructClanMark:getClassName()
    return 'StructClanMark'
end

-------------------------------------
-- function getThis
-------------------------------------
function StructClanMark:getThis()
    return THIS
end

-------------------------------------
-- function makeClanMarkIcon
-------------------------------------
function StructClanMark:makeClanMarkIcon()
    local table_clan_mark = TableClanMark()

    local root

    -- 배경 지정
    local bg_res = table_clan_mark:getBgRes(self.m_bgIdx)
    local icon = IconHelper:getIcon(bg_res)
    root = icon

    -- 심볼 생성
    local res = table_clan_mark:getSymbolRes(self.m_symbolIdx, 1)
    local color = table_clan_mark:getColor(self.m_colorIdx1)
    local icon = IconHelper:getIcon(res)
    icon:setColor(color)
    root:addChild(icon)

    -- 심볼 생성
    local res = table_clan_mark:getSymbolRes(self.m_symbolIdx, 2)
    local color = table_clan_mark:getColor(self.m_colorIdx2)
    local icon = IconHelper:getIcon(res)
    icon:setColor(color)
    root:addChild(icon)
    
    return root
end

-------------------------------------
-- function tostring
-------------------------------------
function StructClanMark:tostring()
    local str = '' .. self.m_bgIdx .. ';' .. self.m_symbolIdx .. ';' .. self.m_colorIdx1 .. ';' .. self.m_colorIdx2
    return str
end
