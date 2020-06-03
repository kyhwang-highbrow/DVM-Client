local PARENT = TableClass

-------------------------------------
-- class TableFormation
-------------------------------------
TableFormation = class(PARENT, {
    })

local THIS = TableFormation

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
function TableFormation:getFormationPositionList(formation, min_x, max_x, min_y, max_y, is_right)
    if (self == TableFormation) then
        self = TableFormation()
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
function TableFormation:getFormationPositionListNew(formation, interval)
    if (self == TableFormation) then
        self = TableFormation()
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
function TableFormation:getBuffStrList(formation)
	-- @TODO
	local formation = self:temp(formation)

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

-------------------------------------
-- function getBuffList
-- @breif 특정 포메이션 특정 슬롯이 가지는 버프 리스트 리턴
-------------------------------------
function TableFormation:getBuffList(formation, formation_lv, slot_idx)
    if (formation == '') or (formation == 'default') then
        formation = 'attack'
    end

    if (self == TableFormation) then
        self = TableFormation()
    end

    -- @TODO
	local formation = self:temp(formation)
    if (not formation_lv) then
        formation_lv = g_formationData:getFormationInfo(formation)['formation_lv']
    end

    local t_formation = self:get(formation)

    local slot_idx = tonumber(slot_idx)

    local l_buff = {}

    for i=1, 10 do
        local buff_targets = t_formation[string.format('buff_targets_%.2d', i)]
        if (buff_targets and (buff_targets ~= '')) then
            local l_targets = seperate(buff_targets, ',')

            -- l_targets가 nil일 경우 리스트가 1개이므로 테이블을 생성해준다
            if (not l_targets) then
                l_targets = {buff_targets}
            end

            -- 타겟 대상에 포함되어 있을 경우
            for _,target_idx in ipairs(l_targets) do
                if (tonumber(target_idx) == slot_idx) then
                    local buff_type = t_formation[string.format('buff_type_%.2d', i)]
                    local status, action = TableOption:parseOptionKey(buff_type)
                    local value = t_formation[string.format('buff_value_%.2d', i)]
					local max_value = t_formation[string.format('buff_value_%.2d_max', i)]
					value = TableOption:getLevelingValue(value, max_value, formation_lv)

                    -- 버프 리스트에 추가
                    table.insert(l_buff, {['status']=status, ['action']=action, ['value']=value})
                end
            end
        end
    end

    return l_buff
end

-------------------------------------
-- function getLocationInfo
-------------------------------------
function TableFormation:getLocationInfo(formation)
    if (self == TableFormation) then
        self = TableFormation()
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
function TableFormation:getFormationName(formation)
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
function TableFormation:getFormatioDesc(formation, formation_lv)
    if (self == THIS) then
        self = THIS()
    end
    	
	-- @TODO
	local formation = self:temp(formation)
	local formation_lv = formation_lv or g_formationData:getFormationInfo(formation)['formation_lv']

    local t_table = self:get(formation)

    local desc = ''

    for i=1, 10 do
        local buff_type = t_table[string.format('buff_type_%.2d', i)]
        local buff_value = t_table[string.format('buff_value_%.2d', i)]
		local buff_max_value = t_table[string.format('buff_value_%.2d_max', i)]

        if (not buff_type) or (not buff_value) then
        elseif (buff_type == '') or (buff_value == '') then
        else
			buff_value = TableOption:getLevelingValue(buff_value, buff_max_value, formation_lv)
			buff_value = math_floor(buff_value * 100) / 100
            local str = TableOption:getOptionDesc(buff_type, buff_value)
            if (desc ~= '') then
                desc = desc .. ', '
            end
            desc = desc .. str
        end
    end

    return desc
end

-------------------------------------
-- function getFormationNameAndDesc
-- @breif UI에서 사용되는 진형 이름, 버프 내용
-------------------------------------
function TableFormation:getFormationNameAndDesc(formation)
    if (self == THIS) then
        self = THIS()
    end
    	
	-- @TODO
	local formation = self:temp(formation)

    local t_table = self:get(formation)

    local name = Str(t_table['t_name'])
    local desc = ''

    for i=1, 10 do
        local buff_type = t_table[string.format('buff_type_%.2d', i)]
        local buff_value = t_table[string.format('buff_value_%.2d', i)]

        if (not buff_type) or (not buff_value) then
        elseif (buff_type == '') or (buff_value == '') then
        else
            local str = TableOption:getOptionDesc(buff_type, buff_value)
            if (desc ~= '') then
                desc = desc .. ', '
            end
            desc = desc .. str
        end
    end

    return name, desc
end

-------------------------------------
-- function temp
-- @TODO
-------------------------------------
function TableFormation:temp(formation)
    if (formation == 'default') then
        formation = 'attack'

	elseif (formation == 'protect') then
		formation = 'critical'
		ccdisplay('임시 처리 코드 통과 - formation_type ')
	end
	return formation
end