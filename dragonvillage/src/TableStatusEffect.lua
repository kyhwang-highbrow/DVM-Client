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
        -- add_dmg_%s �̸��� Ÿ���� add_dmg Ÿ�԰� ��ġ��Ų��
        if (string.find(key, 'add_dmg_')) then
            t = PARENT.get(self, 'add_dmg', skip_error_msg)
        end
    end

    if (not t) then
        error('invalid status_effect name = ' .. key)
    end

    return t
end