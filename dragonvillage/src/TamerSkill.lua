local PARENT = Character

-------------------------------------
-- function st_active
-------------------------------------
function Tamer.st_active(owner, dt)
	if (owner:getStep() == 0) then
        if (owner:isBeginningStep()) then
		    local world = owner.m_world
		    local l_dragon = owner:getFellowList()
		
		    local cameraHomePosX, cameraHomePosY = world.m_gameCamera:getHomePos()
		    local move_pos_x = cameraHomePosX + CRITERIA_RESOLUTION_X/2
		    local move_pos_y = cameraHomePosY + 200

            -- 스킬 사용 여부 저장
            owner.m_bActiveSKillUsable = false
		
		    -- tamer action stop
		    owner:stopAllActions()

		    -- world 일시 정지
		    world:setTemporaryPause(true, owner, INGAME_PAUSE__ACTIVE_SKILL)

		    -- 스킬 이름 말풍선
            local skill_indivisual_info = owner:getLevelingSkillByType('active')
            local t_skill = skill_indivisual_info.m_tSkill
		    local skill_name = Str(t_skill['t_name'])
		    SkillHelper:makePassiveSkillSpeech(owner, skill_name)

		    -- 연출 이동
		    owner:setHomePos(owner.pos.x, owner.pos.y)
		    owner:setMove(move_pos_x, move_pos_y, 2000)
		    owner:runAction_MoveZ(0.1, 0)
			
		    -- 애프터 이미지
		    owner:setAfterImage(true)

            -- 이벤트
            world:dispatch('set_global_cool_time_active')
        
        elseif (owner.m_isOnTheMove == false) then
            owner:nextStep()

        end

	elseif (owner:getStep() == 1) then
        if (owner:isBeginningStep()) then
            local skill_indivisual_info = owner:getLevelingSkillByType('active')
            local t_skill = skill_indivisual_info.m_tSkill
		    local res_1 = t_skill['res_1']	-- 전화면 컷씬 리소스
		    local res_2 = t_skill['res_2']	-- 스킬 발동 리소스

		    -- 전화면 컷씬 종료 콜백
		    local function cb_function()

			    -- 2. 테이머 스킬 시전 애니 & 스킬 발동 연출
			    owner.m_animator:changeAni('skill_2', false)
			    SkillHelper:makeEffectOnView(res_2, 'idle')

			    -- 테이머 애니메이션 종료 콜백
			    owner.m_animator:addAniHandler(function()
				    -- 3. 스킬 발동
				    local cb_func_action_1 = cc.CallFunc:create(function()
                        local active_skill_id = owner:getSkillID('active')
					    owner:doSkill(active_skill_id)
				    end)

				    -- 4. 딜레이
				    local delay_action = cc.DelayTime:create(0.1)

				    -- 5. 스킬 종료
				    local cb_func_action_2 = cc.CallFunc:create(function()
					    -- 일시정지 해제
					    owner.m_world:setTemporaryPause(false, owner, INGAME_PAUSE__ACTIVE_SKILL)
					    -- roam상태로 변경
					    owner:changeStateWithCheckHomePos('roam')
					    -- 애프터 이미지 해제
					    owner:setAfterImage(false)
				    end)

				    local sequence_action = cc.Sequence:create(cb_func_action_1, delay_action, cb_func_action_2)

				    owner.m_rootNode:runAction(sequence_action)
			    end)
		    end

		    -- 1. 전화면 컷씬 연출 부터 시작
		    SkillHelper:makeEffectOnView(res_1, 'idle', cb_function)
        end
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
    skill_indivisual_info:startCoolTime()

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
    local skill_indivisual_info = self:getLevelingSkillByType('active')
    if (not skill_indivisual_info) then return end

    skill_indivisual_info:resetCoolTime()

    self.m_bActiveSKillUsable = true
end

-------------------------------------
-- function isEndActiveSkillCool
-------------------------------------
function Tamer:isEndActiveSkillCool()
    local skill_indivisual_info = self:getLevelingSkillByType('active')
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
    if (isExistValue(self.m_state, 'active')) then
        return false
    end

    return true, {}
end