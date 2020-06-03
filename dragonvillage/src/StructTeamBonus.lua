-------------------------------------
-- class StructTeamBonus
-------------------------------------
StructTeamBonus = class({
		m_id = 'number',

        m_type = 'string',

        m_lSkill = 'table',     -- 보너스 효과 기능 리스트(스킬 아이디 or 옵션 타입명)
        m_lValue = 'table',     -- 보너스 효과 수치 리스트(옵션 적용값)

        m_bSatisfy = 'boolean', -- 조건 만족 여부
        m_lSatisfied = 'table', -- 조건을 만족시킨 대상 리스트
        m_lAllDragonData = 'table', -- 모든 드래곤 리스트 (활성화/비활성화 모두 포함)

        m_priority = 'number', -- 우선순위
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
-- @brief 파라미터의 드래곤들을 대상으로 해당하는 팀보너스 정보를 설정
-------------------------------------
function StructTeamBonus:setFromDragonObjectList(l_dragon_data)
    local t_teambonus = TableTeamBonus():get(self.m_id)
    self.m_bSatisfy, self.m_lSatisfied, self.m_lAllDragonData = TeamBonusHelper:checkCondition(t_teambonus, l_dragon_data)
end

-------------------------------------
-- function findDidFromSatisfiedList
-- @brief 파라미터의 드래곤이 팀보너스를 만족시킨 대상에 들어가는지 확인
-------------------------------------
function StructTeamBonus:findDidFromSatisfiedList(did)
    -- 만족시킨 대상에 포함되는지 확인
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
-- @brief 해당 팀보너스의 조건이 충족되었는지 여부
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