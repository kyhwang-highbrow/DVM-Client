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

    return self:getValue(tamer_id, 'type')
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
	local val_1, val_2
	if string.find(condition, 'clear_adventure_') then
		local raw_str = string.gsub(condition, 'clear_adventure_', '')
		raw_str = seperate(raw_str, '_')
		val_1 = raw_str[1]
		val_2 = raw_str[2]
	end

	return Str(t_tamer['t_obtain_desc'], val_1, val_2)
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