local PARENT = TableClass

-------------------------------------
-- class TableStatusEffect
-------------------------------------
TableStatusEffect = class(PARENT, {
    })

-------------------------------------
-- function init
-------------------------------------
function TableStatusEffect:init()
    self.m_tableName = 'status_effect'
    self.m_orgTable = TABLE:get(self.m_tableName)
end

-------------------------------------
-- function get
-------------------------------------
function TableStatusEffect:get(key, skip_error_msg)
    local t = PARENT.get(self, key, skip_error_msg)

    if (not t) then
        -- add_dmg_%s 이름의 타입은 add_dmg 타입과 일치시킨다
        if (string.find(key, 'add_dmg_')) then
            t = PARENT.get(self, 'add_dmg', skip_error_msg)
        end
    end

    return t
end

-------------------------------------
-- function getRes
-------------------------------------
function TableStatusEffect:getRes(key, attr)
    local t_table = self:get(key)
    if (not t_table) then return end

    -- res attr parsing
    local res = t_table['res']
	if (res and attr) then 
		res = string.gsub(res, '@', attr)
	end

	-- nil 처리
	if (res == '') then 
		res = nil 
	end

    return res
end