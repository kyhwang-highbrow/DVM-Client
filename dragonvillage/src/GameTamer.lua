local TAMER_SKILL_ACTIVE = 1
local TAMER_SKILL_PASSIVE = 2

-------------------------------------
-- class GameTamer
-------------------------------------
GameTamer = class({
		m_world = 'GameWorld',
		m_charType = 'tamer',
		m_charTable = 'table',

		m_lSkill = '',
        m_lSkillCoolTimer = '',
     })

-------------------------------------
-- function init
-------------------------------------
function GameTamer:init(world, t_tamer)
    self.m_world = world
	self.m_charType = 'tamer'
	self.m_charTable = t_tamer
    self.m_lSkill = {}
    self.m_lSkillCoolTimer = {}

    self:init_skill()
end

-------------------------------------
-- function init_skill
-------------------------------------
function GameTamer:init_skill()
	local t_tamer = self.m_charTable
	local table_tamer_skill = TableTamerSkill()

    -- 아군 테이머만 처리하도록 함
    self.m_lSkill[TAMER_SKILL_ACTIVE] = table_tamer_skill:getTamerSkill(t_tamer['skill_' .. TAMER_SKILL_ACTIVE])
    self.m_lSkill[TAMER_SKILL_PASSIVE] = table_tamer_skill:getTamerSkill(t_tamer['skill_' .. TAMER_SKILL_PASSIVE])

    self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] = 0
    self.m_lSkillCoolTimer[TAMER_SKILL_PASSIVE] = 0
end

-------------------------------------
-- function update
-------------------------------------
function GameTamer:update(dt)
    if (self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] > 0) then
        self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] = math_max(self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] - dt, 0)
    end
end

--[[
-------------------------------------
-- function checkSkill
-------------------------------------
function GameTamer:checkSkillActive()
    local t_skill = self.m_lSkill[TAMER_SKILL_ACTIVE]

    local world = self.m_world
    if (not world:isPossibleControl()) then return end
    if (world.m_gameState:isWaitingGlobalCoolTime()) then return end
    if (not self:isEndActiveSkillCoolTime()) then return end

    -- TODO : 스킬 타입별 고유한 조건으로 체크되어야함
    if (t_skill['type'] == 'tamer_skill_haeal') then

    end

    return true
end
]]--

-------------------------------------
-- function getTargetList
-------------------------------------
function GameTamer:getTargetList(t_skill)
    local target_type = t_skill['target_type']
    if (target_type == 'x') then 
		error('타겟 타입이 x인데요? 테이블 수정해주세요')
	end

    local table_skill_target = TABLE:get('skill_target')
    local t_skill_target = table_skill_target[target_type]

    local target_team = t_skill_target['fof']
    local target_formation = 'front'
    local target_rule = t_skill_target['rule']

    local t_ret = self.m_world:getTargetList(nil, 0, 0, target_team, target_formation, target_rule)
    return t_ret
end


-------------------------------------
-- function doSkill
-------------------------------------
function GameTamer:doSkill(skill_idx)
	local t_skill = self.m_lSkill[skill_idx]

	if (t_skill['skill_form'] == 'status_effect') then 
        cclog('doSkill type = ' .. t_skill['type'])

		-- 1. target 설정
		local l_target = self:getTargetList(t_skill)
        if (not l_target) then return end

        -- 2. 타겟 대상에 상태효과생성
		local idx = 1
		local effect_str = nil
		local t_effect = nil
		local type = nil
        local target_type = nil
        local start_con = nil
		local duration = nil
		local value_1 = nil
		local value_2 = nil
		local rate = 100

		while true do 
			-- 1. 파싱할 구문 가져오고 탈출 체크
			effect_str = t_skill['status_effect_' .. idx]
			if (not effect_str) or (effect_str == 'x') then 
				break 
			end

			-- 2. 파싱하여 규칙에 맞게 분배
            t_effect = StatusEffectHelper:parsingStr(effect_str)
            
		    type = t_effect['type']
		    target_type = t_effect['target_type']
            start_con = t_effect['start_con']
		    duration = t_effect['duration']
		    rate = t_effect['rate'] 
		    value_1 = t_effect['value_1']

            -- 3. 타겟 리스트 순회하며 상태효과 걸어준다.
			for _,target in ipairs(l_target) do
                StatusEffectHelper:invokeStatusEffect(target, type, value_1, rate, duration)
			end

			-- 4. 인덱스 증가
			idx = idx + 1
		end

	else
		cclog('미구현 테이머 스킬 : ' .. t_skill['sid'] .. ' / ' .. t_skill['t_name'])
		return false
	end

    self.m_lSkillCoolTimer[skill_idx] = t_skill['cooldown']

	return true
end

-------------------------------------
-- function doSkillActive
-------------------------------------
function GameTamer:doSkillActive()
    
    self.m_world:dispatch('tamer_skill', {}, function()
        self:showToolTipActive()
        self:doSkill(TAMER_SKILL_ACTIVE)
    end, idx)

    return self:doSkill(TAMER_SKILL_ACTIVE)
end

-------------------------------------
-- function doSkillPassive
-------------------------------------
function GameTamer:doSkillPassive()
    return self:doSkill(TAMER_SKILL_PASSIVE)
end

-------------------------------------
-- function showToolTipActive
-------------------------------------
function GameTamer:showToolTipActive()
    local t_skill = self.m_lSkill[TAMER_SKILL_ACTIVE]
    local str = UI_Tooltip_Skill:getSkillDescStr('tamer', t_skill['sid'])

    local tool_tip = UI_Tooltip_Skill(320, -220, str, true)
    tool_tip:autoRelease()
end

-------------------------------------
-- function resetActiveSkillCoolTime
-------------------------------------
function GameTamer:resetActiveSkillCoolTime()
    self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] = 0
end

-------------------------------------
-- function isEndActiveSkillCoolTime
-------------------------------------
function GameTamer:isEndActiveSkillCoolTime()
    return (self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] == 0)
end

-------------------------------------
-- function isPossibleSkill
-------------------------------------
function GameTamer:isPossibleSkill()
    if (not self:isEndActiveSkillCoolTime()) then
		return false
	end

    return true
end

-------------------------------------
-- function getActiveSkillTable
-------------------------------------
function GameTamer:getActiveSkillTable()
    local t_skill = self.m_lSkill[TAMER_SKILL_ACTIVE]
    return t_skill
end