local PARENT = Character

-------------------------------------
-- function st_skillAppear
-------------------------------------
function Tamer.st_skillAppear(owner, dt)
    local world = owner.m_world

    if (owner.m_stateTimer == 0) then
        -- 스킬 사용 여부 저장
        owner.m_bActiveSKillUsable = false

        -- tamer action stop
		owner:stopAllActions()

        -- 애프터 이미지
		owner:setAfterImage(true)

        -- 이벤트
        world:dispatch('set_global_cool_time_active')
    end
end

-------------------------------------
-- function st_skillIdle
-------------------------------------
function Tamer.st_skillIdle(owner, dt)
    if (owner.m_stateTimer == 0) then
        -- 애프터 이미지 해제
		owner:setAfterImage(false)
        
        -- 테이머 애니메이션 종료 콜백
		owner.m_animator:addAniHandler(function()
            -- 간헐적으로 테이머의 스킬이 발동하지 않는 현상 
            -- 디바이스 성능 차이에 의한 프레임 변동으로 애니메이션 콜백이 호출되지 않을 가능성 존재한다고 추측됨
            -- 아래 2줄을 GameDragonSkill.st_playTamerSkill 쪽으로 옮김
            ----local active_skill_id = owner:getSkillID('active')
			----owner:doSkill(active_skill_id)
            owner.m_animator:changeAni('i_idle', true)
		end)
    end
end

-------------------------------------
-- function doSkill
-------------------------------------
function Tamer:doSkill(skill_id)
	local skill_indivisual_info = self:findSkillInfoByID(skill_id)
    if (not skill_indivisual_info) then return end

    local t_skill = skill_indivisual_info.m_tSkill
    local chance_type = t_skill['chance_type']

    -- 쿨타임 적용
    skill_indivisual_info:startCoolTime(true)

	-- 타겟 확인
	if (not self.m_targetChar) then
		self:checkTarget(t_skill)
	end
	
	-- [ACTIVE]
	if (chance_type == 'active') then
        -- 액티브 전역 쿨타임
        self:dispatch('set_global_cool_time_active')

		-- 상태효과 시전
		StatusEffectHelper:doStatusEffectByTable(self, t_skill)

	-- [PASSIVE]
	else
        PARENT.doSkillBySkillTable(self, t_skill)

	end

	return true
end

-------------------------------------
-- function resetActiveSkillCool
-------------------------------------
function Tamer:resetActiveSkillCool()
    local skill_indivisual_info = self:getSkillIndivisualInfo('active')
    if (not skill_indivisual_info) then return end

    skill_indivisual_info:resetCoolTime()

    self.m_bActiveSKillUsable = true
end

-------------------------------------
-- function isEndActiveSkillCool
-------------------------------------
function Tamer:isEndActiveSkillCool()
    local skill_indivisual_info = self:getSkillIndivisualInfo('active')
    if (not skill_indivisual_info) then return end

    return skill_indivisual_info:isEndCoolTime()
end

-------------------------------------
-- function isPossibleActiveSkill
-------------------------------------
function Tamer:isPossibleActiveSkill()
    -- 쿨타임 체크(테이머의 경우는 액티브를 한번만 사용 가능해서 의미 없음)
    --[[
    if (not self:isEndActiveSkillCool()) then
		return false
	end
    ]]--

    -- 이미 액티브 스킬을 사용한 경우
    if (not self.m_bActiveSKillUsable) then
        return false
    end

    -- 이미 스킬을 사용하기 위한 상태나 사용 중인 경우
    if (isExistValue(self.m_state, 'skillAppear', 'skillIdle')) then
        return false
    end

    return true, {}
end