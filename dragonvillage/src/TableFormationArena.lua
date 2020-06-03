local PARENT = TableClass

-------------------------------------
-- class TableFormationArena
-------------------------------------
TableFormationArena = class(PARENT, {
    })

local THIS = TableFormationArena

-------------------------------------
-- function init
-------------------------------------
function TableFormationArena:init()
    self.m_tableName = 'formation_arena'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getFormationPositionList
-------------------------------------
function TableFormationArena:getFormationPositionList(formation, min_x, max_x, min_y, max_y, is_right)
    if (self == TableFormationArena) then
        self = TableFormationArena()
    end

	-- @TODO
	local formation = self:temp(formation)

    local t_table = self:get(formation)

    local gap_x = (max_x - min_x)
    local gap_y = (max_y - min_y)

    local l_pos_list = {}

    for i = 1, 5 do
        local pos_str = t_table[string.format('pos_%.2d', i)]
        local l_pos = seperate(pos_str, ',')

        local rate_x = (l_pos[1] / 100)
        local rate_y = (l_pos[2] / 100)

        if (is_right) then
            rate_x = 1 - rate_x
        end

        local pos = {}
        pos['x'] = min_x + (gap_x * rate_x)
        pos['y'] = min_y + (gap_y * rate_y)
        
        l_pos_list[i] = pos
    end
    
    return l_pos_list
end

-------------------------------------
-- function getFormationPositionListNew
-------------------------------------
function TableFormationArena:getFormationPositionListNew(formation, interval)
    if (self == TableFormationArena) then
        self = TableFormationArena()
    end

	-- @TODO
	local formation = self:temp(formation)
    local t_table = self:get(formation)

    local l_pos_list = {}
    local interval = interval or 120

    for i = 1, 5 do
        local pos_str = t_table[string.format('ui_pos_%.2d', i)]
        local l_pos = seperate(pos_str, ',')
        
        -- 최대, 최소 비율없이 2D 포지션 바로 계산
        local pos = {}
        pos['x'] = l_pos[1] * interval
        pos['y'] = l_pos[2] * interval
        
        l_pos_list[i] = pos
    end
    
    return l_pos_list
end

-------------------------------------
-- function getBuffStrList
-------------------------------------
function TableFormationArena:getBuffStrList(formation)
	return ''
end

-------------------------------------
-- function getBuffList
-- @breif 특정 포메이션 특정 슬롯이 가지는 버프 리스트 리턴
-------------------------------------
function TableFormationArena:getBuffList(formation, formation_lv, slot_idx)
    return {}
end

-------------------------------------
-- function getLocationInfo
-------------------------------------
function TableFormationArena:getLocationInfo(formation)
    if (self == TableFormationArena) then
        self = TableFormationArena()
    end

	-- @TODO
	local formation = self:temp(formation)

    local t_ret = {}
    t_ret['front'] = self:getCommaSeparatedValues(formation, 'front')
    t_ret['middle'] = self:getCommaSeparatedValues(formation, 'middle')
    t_ret['rear'] = self:getCommaSeparatedValues(formation, 'rear')
    
    return t_ret
end

-------------------------------------
-- function getFormationName
-- @breif UI에서 사용되는 진형 이름
-------------------------------------
function TableFormationArena:getFormationName(formation)
	if (self == THIS) then
        self = THIS()
    end
    
	-- @TODO
	local formation = self:temp(formation)

    local t_table = self:get(formation)
    local name = Str(t_table['t_name'])

	return name
end

-------------------------------------
-- function getFormatioDesc
-- @breif UI에서 사용되는 진형 이름, 버프 내용
-------------------------------------
function TableFormationArena:getFormatioDesc(formation, formation_lv)
    return ''
end

-------------------------------------
-- function getFormationNameAndDesc
-- @breif UI에서 사용되는 진형 이름, 버프 내용
-------------------------------------
function TableFormationArena:getFormationNameAndDesc(formation)
    if (self == THIS) then
        self = THIS()
    end
    	
	-- @TODO
	local formation = self:temp(formation)

    local t_table = self:get(formation)

    local name = Str(t_table['t_name'])
    local desc = ''

    return name, desc
end

-------------------------------------
-- function temp
-- @TODO
-------------------------------------
function TableFormationArena:temp(formation)
    if (formation == 'default') then
        formation = 'attack'

	elseif (formation == 'protect') then
		formation = 'critical'
		ccdisplay('임시 처리 코드 통과 - formation_type ')
	end
	return formation
end