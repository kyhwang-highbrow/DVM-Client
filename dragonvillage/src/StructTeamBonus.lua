-------------------------------------
-- class StructTeamBonus
-------------------------------------
StructTeamBonus = class({
		m_id = 'number',

        m_type = 'string',

        m_lSkill = 'table',     -- ���ʽ� ȿ�� ��� ����Ʈ(��ų ���̵� or �ɼ� Ÿ�Ը�)
        m_lValue = 'table',     -- ���ʽ� ȿ�� ��ġ ����Ʈ(�ɼ� ���밪)

        m_bSatisfy = 'boolean', -- ���� ���� ����
        m_lSatisfied = 'table', -- ������ ������Ų ��� ����Ʈ
        m_lAllDragonData = 'table', -- ��� �巡�� ����Ʈ (Ȱ��ȭ/��Ȱ��ȭ ��� ����)

        m_priority = 'number', -- �켱����
	})

-------------------------------------
-- function init
-------------------------------------
function StructTeamBonus:init(data)
    self.m_id = data['id']
    self.m_type = data['skill_type']

    self.m_lSkill = {}
    self.m_lValue = {}

    for i = 1, 3 do
        local type = data['skill_' .. i]
        if (type and type ~= '') then
            self.m_lSkill[i] = data['skill_' .. i]
            self.m_lValue[i] = data['value_' .. i]
        end
    end
    
    self.m_bSatisfy = false
    self.m_lSatisfied = {}
    self.m_lAllDragonData = {}
    if (TableTeamBonus():exists(self.m_id)) then
        local t_teambonus = TableTeamBonus():get(self.m_id)
        self.m_priority = t_teambonus['ui_priority'] or 0
    end
end

-------------------------------------
-- function setFromDragonObjectList
-- @brief �Ķ������ �巡����� ������� �ش��ϴ� �����ʽ� ������ ����
-------------------------------------
function StructTeamBonus:setFromDragonObjectList(l_dragon_data)
    local t_teambonus = TableTeamBonus():get(self.m_id)
    self.m_bSatisfy, self.m_lSatisfied, self.m_lAllDragonData = TeamBonusHelper:checkCondition(t_teambonus, l_dragon_data)
end

-------------------------------------
-- function findFromSatisfiedList
-- @brief �Ķ������ �巡���� �����ʽ��� ������Ų ��� ������ Ȯ��
-------------------------------------
function StructTeamBonus:findDidFromSatisfiedList(did)
    -- ������Ų ��� ���ԵǴ��� Ȯ��
    local is_exist = false

    for _, v in ipairs(self.m_lSatisfied) do
        if (did == v['did']) then
            is_exist = true
            break
        end
    end

    return is_exist
end

-------------------------------------
-- function isSatisfied
-- @brief �ش� �����ʽ��� ������ �����Ǿ����� ����
-------------------------------------
function StructTeamBonus:isSatisfied()
    return self.m_bSatisfy
end

-------------------------------------
-- function getType
-------------------------------------
function StructTeamBonus:getType()
    return self.m_type
end

-------------------------------------
-- function getName
-------------------------------------
function StructTeamBonus:getName()
    return TableTeamBonus():getName(self.m_id)
end

-------------------------------------
-- function getID
-------------------------------------
function StructTeamBonus:getID()
    return self.m_id
end