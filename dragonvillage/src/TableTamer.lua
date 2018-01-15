local PARENT = TableClass

-------------------------------------
-- class TableTamer
-------------------------------------
TableTamer = class(PARENT, {
    })

local THIS = TableTamer

-------------------------------------
-- function init
-------------------------------------
function TableTamer:init()
    self.m_tableName = 'tamer'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function getTamerType
-------------------------------------
function TableTamer:getTamerType(tamer_id)
    if (self == THIS) then
        self = THIS()
    end

    local skip_error_msg = true
    local t_table = self:get(tamer_id, skip_error_msg)
    if (not t_table) then
        return nil
    end

    return t_table['type']
end

-------------------------------------
-- function getCurrTamerTable
-------------------------------------
function TableTamer:getCurrTamerTable()
    if (self == THIS) then
        self = THIS()
    end
	local tamer_id = g_tamerData:getCurrTamerTable('tid')
    return self:get(tamer_id)
end

-------------------------------------
-- function getTamerObtainDesc
-------------------------------------
function TableTamer:getTamerObtainDesc(t_tamer)
	if (not t_tamer) then
		return ''
	end

	local condition = t_tamer['obtain_condition']
	local diff, chap, stage
	if string.find(condition, 'clr_adv_') then
		local raw_str = string.gsub(condition, 'clr_adv_', '')
		raw_str = seperate(raw_str, '_')
		diff = (raw_str[1] == 'normal') and Str('보통') or Str('어려움')
		chap = raw_str[2]
        stage = raw_str[3]
	end

	return Str(t_tamer['t_obtain_desc'], diff, chap, stage)
end

-------------------------------------
-- function getTamerFace
-------------------------------------
function TableTamer:getTamerFace(tamer_type, is_win)
	local t_ani = g_constant:get('TAMER', 'FACE', tamer_type)
	local ani_list
	if (is_win) then
		ani_list = t_ani['win']
	else
		ani_list = t_ani['lose']
	end

	return table.getRandom(ani_list)
end

-------------------------------------
-- function getTamerSDImage
-------------------------------------
function TableTamer:getTamerSDImage(tamer_id)
    if (self == THIS) then
        self = THIS()
    end

    local tamer_type = self:getValue(tamer_id, 'type')
    local path = string.format('res/ui/icons/tamer/costume_%s.png', tamer_type)
    local image = cc.Sprite:create(path) or nil

    return image
end

-------------------------------------
-- function getTamerName
-------------------------------------
function TableTamer:getTamerName(tamer_id)
    if (self == THIS) then
        self = THIS()
    end
    return Str(self:getValue(tamer_id, 't_name'))
end

-------------------------------------
-- function getTamerResSD
-------------------------------------
function TableTamer:getTamerResSD(tamer_id)
    if (self == THIS) then
        self = THIS()
    end
    return self:getValue(tamer_id, 'res_sd')
end
