local PARENT = TableClass

-------------------------------------
-- class TableClanMarkCustom
-------------------------------------
TableClanMarkCustom = class(PARENT, {
        m_bgMap = 'table',
        m_symbolMap = 'table',
        m_colorMap = 'table',
    })

local THIS = TableClanMarkCustom

-------------------------------------
-- function init
-------------------------------------
function TableClanMarkCustom:init()
    self.m_tableName = 'table_clan_mark_custom'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function findCustomMarkRes
-------------------------------------
function TableClanMarkCustom:findCustomMarkRes(custom_mark)
	if (self == THIS) then
        self = THIS()
    end

	-- custom_mark : server_clan 이므로 분리한다
	local l_word = plSplit(custom_mark, '_')
	local server = l_word[1]
	local clan_name = l_word[2]
	if (not server) or (not clan_name) then
		return
	end

	-- 찾는다
	local l_list = self:filterList('server', server)
	for i, v in ipairs(l_list) do
		if (v['clan_name'] == clan_name) then
			return v['res']
		end
	end

	return nil
end
