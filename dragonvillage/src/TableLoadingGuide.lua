local PARENT = TableClass

-------------------------------------
-- class TableLoadingGuide
-------------------------------------
TableLoadingGuide = class(PARENT, {
    })

local THIS = TableLoadingGuide

-------------------------------------
-- function init
-------------------------------------
function TableLoadingGuide:init()
    self.m_tableName = 'loading_guide'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function init
-------------------------------------
function TableLoadingGuide:getLoadingImg(gid)
	local t_loading = self:get(gid)
	local tip_icon = IconHelper:getIcon(t_loading['res'])

	return tip_icon
end

-------------------------------------
-- function init
-------------------------------------
function TableLoadingGuide:getLoadingDesc(gid)
	local t_loading = self:get(gid)
	local tip_str = Str(t_loading['t_desc'])

	return tip_str
end