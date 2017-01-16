local PARENT = TableClass

-------------------------------------
-- class TableFormation
-------------------------------------
TableFormation = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableFormation:init()
    self.m_tableName = 'formation'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getFormationPositionList
-------------------------------------
function TableFormation:getFormationPositionList(formation, min_x, max_x, min_y, max_y)
    if (self == TableFormation) then
        self = TableFormation()
    end

    local t_table = self:get(formation)

    local gap_x = (max_x - min_x)
    local gap_y = (max_y - min_y)

    local l_pos_list = {}
    for i=1, 5 do
        local pos_str = t_table[string.format('pos_%.2d', i)]
        local l_pos = seperate(pos_str, ',')

        local rate_x = (l_pos[1] / 100)
        local rate_y = (l_pos[2] / 100)

        local pos = {}
        pos['x'] = min_x + (gap_x * rate_x)
        pos['y'] = min_y + (gap_y * rate_y)
        l_pos_list[i] = pos
    end
    
    return l_pos_list
end

-------------------------------------
-- function makeFormationIcon
-------------------------------------
function TableFormation:makeFormationIcon(formation)
    local res = 'res/ui/icon/fomation/fomation_' .. formation .. '.png'
    local icon = cc.Sprite:create(res)

    if (not icon) then
        icon = cc.Sprite:create('res/ui/icon/skill/developing.png')
    end

    icon:setDockPoint(cc.p(0.5, 0.5))
    icon:setAnchorPoint(cc.p(0.5, 0.5))

    return icon
end

-------------------------------------
-- function getBuffStrList
-------------------------------------
function TableFormation:getBuffStrList(formation)
    local t_formation = self:get(formation)

    local l_buff_str = {}

    for i=1, 10 do
        local buff_type = t_formation[string.format('buff_type_%.2d', i)]
        local buff_value = t_formation[string.format('buff_value_%.2d', i)]
        if buff_type and (buff_type ~= '') then
            local t_data = {}

            -- 이름 (설명)
            local str = self:getValue('buff_' .. buff_type, 't_name')
            t_data['str'] = Str(str, buff_value)
            
            -- 색상
            t_data['color'] = self:getValue('buff_' .. buff_type, 'font_color')
            table.insert(l_buff_str, t_data)
        end
    end
    
    return l_buff_str
end