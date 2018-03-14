-------------------------------------
-- class StructTeamBonus
-------------------------------------
StructTeamBonus = class({
		m_id = 'number',

        m_type = 'string',

        m_skill_1 = '',
        m_value_1 = '',
        m_skill_2 = '',
        m_value_2 = '',
        m_skill_3 = '',
        m_value_3 = '',
		
        m_bSatisfy = 'boolean', -- ���� ���� ����
        m_lSatisfied = 'table', -- ������ ������Ų ��� ����Ʈ
	})

-------------------------------------
-- function init
-------------------------------------
function StructTeamBonus:init(data)
    self.m_id = data['id']
    self.m_type = data['skill_type']
    
    self.m_skill_1 = data['skill_1']
    self.m_value_1 = data['value_1']
    self.m_skill_2 = data['skill_2']
    self.m_value_2 = data['value_2']
    self.m_skill_3 = data['skill_3']
    self.m_value_3 = data['value_3']

    self.m_bSatisfy = false
    self.m_lSatisfied = {}
end

-------------------------------------
-- function setFromDragonObjectList
-- @brief �Ķ������ �巡����� ������� �ش��ϴ� �����ʽ� ������ ����
-------------------------------------
function StructTeamBonus:setFromDragonObjectList(l_dragon_data)
    local t_teambonus = TableTeamBonus():get(self.m_id)

    self.m_bSatisfy, self.m_lSatisfied = TeamBonusHelper:checkCondition(t_teambonus, l_dragon_data)

    if (self.m_bSatisfy) then
        cclog('ID :  ' .. self.m_id)
        cclog('NAME : ' .. Str(t_teambonus['t_name']))
        cclog('DRAGONS : ')

        for i, dragon_data in ipairs(self.m_lSatisfied) do
            cclog(dragon_data:getDragonNameWithEclv())
        end
    end
end