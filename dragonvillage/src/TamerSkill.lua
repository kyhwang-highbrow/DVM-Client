local PARENT = Character

local TAMER_SKILL_ACTIVE = 1
local TAMER_SKILL_EVENT = 2
local TAMER_SKILL_PASSIVE = 3

local MAX_TAMER_SKILL = 3

-------------------------------------
-- function initSkill
-------------------------------------
function Tamer:initSkill()
    local t_tamer = self.m_charTable
	local table_tamer_skill = TableTamerSkill()
	local t_tamer_data = g_tamerData:getTamerServerInfo(t_tamer['tid'])

	self:setDragonSkillLevelList(0, t_tamer_data['skill_lv1'], t_tamer_data['skill_lv2'], t_tamer_data['skill_lv3'])
	self:initDragonSkillManager('tamer', t_tamer['tid'])

	for i = 1, MAX_TAMER_SKILL do
		local skill_id = t_tamer['skill_' .. i]
		local skill_info = self:getSkillInfoByID(skill_id)
		if (skill_info) then
			local t_skill = skill_info.m_tSkill

			self.m_lSkill[i] = t_skill
			self.m_lSkillCoolTimer[i] = t_skill['cooldown']
		end
	end
end

-------------------------------------
-- function setTamerEventSkill
-- @breif 드래곤이 등장한 후 테이머의 스킬 이벤트를 등록한다.
-------------------------------------
function Tamer:setTamerEventSkill()
	local t_skill = self.m_lSkill[TAMER_SKILL_EVENT]
	local trigger_type = t_skill['chance_value']
	if (trigger_type ~= '') then
        for i, dragon in pairs(self:getFellowList()) do
			dragon:addListener(trigger_type, self)
		end
	end
end

-------------------------------------
-- function st_active
-------------------------------------
function Tamer.st_active(owner, dt)
	if (owner.m_stateTimer == 0) then
		local world = owner.m_world
		local l_dragon = owner:getFellowList()
		
		local cameraHomePosX, cameraHomePosY = world.m_gameCamera:getHomePos()
		local move_pos_x = cameraHomePosX + CRITERIA_RESOLUTION_X/2
		local move_pos_y = cameraHomePosY + 200

		
		-- tamer action stop
		owner:stopAllActions()

		-- world 일시 정지
		world:setTemporaryPause(true, owner)

		-- 스킬 이름 말풍선
		local skill_name = Str(owner.m_lSkill[1]['t_name'])
		SkillHelper:makePassiveSkillSpeech(owner, skill_name)

		-- 연출 이동
		owner:setHomePos(owner.pos.x, owner.pos.y)
		owner:setMove(move_pos_x, move_pos_y, 2000)
		owner:runAction_MoveZ(0.1, 0)
			
		-- 애프터 이미지
		owner:setAfterImage(true)

        -- 이벤트
        world:dispatch('set_global_cool_time_active')

	elseif (owner.m_isOnTheMove == false) and (owner.m_bActiveSKillUsable) then
		owner.m_bActiveSKillUsable = false

		local t_skill = owner.m_lSkill[TAMER_SKILL_ACTIVE]
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
					owner:doSkillActive()
				end)

				-- 4. 딜레이
				local delay_action = cc.DelayTime:create(0.1)

				-- 5. 스킬 종료
				local cb_func_action_2 = cc.CallFunc:create(function()
					-- 일시정지 해제
					owner.m_world:setTemporaryPause(false, owner)
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

-------------------------------------
-- function st_event
-------------------------------------
function Tamer.st_event(owner, dt)
    if (owner.m_stateTimer == 0) then
		owner.m_bEventSKillUsable = false

		local function cb_func()
			-- 발동형 스킬 발동
			owner:doSkillEvent()
			owner.m_bEventSKillUsable = true
		end

		-- 연출 세팅
		local cameraHomePosX, cameraHomePosY = owner.m_world.m_gameCamera:getHomePos()

        local pos_x = CRITERIA_RESOLUTION_X / 4
        if (not owner.m_bLeftFormation) then
            pos_x = CRITERIA_RESOLUTION_X - pos_x
        end

		owner:setTamerSkillDirecting(cameraHomePosX + pos_x, cameraHomePosY + 200, TAMER_SKILL_EVENT, cb_func)

		-- 효과음
        SoundMgr:playEffect('UI', 'ui_passive')

        -- 이벤트
        owner.m_world:dispatch('set_global_cool_time_passive')
    end
end

-------------------------------------
-- function doSkill
-------------------------------------
function Tamer:doSkill(skill_idx)
	local t_skill = self.m_lSkill[skill_idx]
	local skill_type = t_skill['skill_type']
	
	-- 타겟 확인
	if (not self.m_targetChar) then
		self:checkTarget(t_skill)
	end
	
	-- [ACTIVE]
	if string.find(skill_type, 'tamer_skill_active') then
		-- 상태효과 시전
		StatusEffectHelper:doStatusEffectByTable(self, t_skill)
		
		-- 스킬별 추가 효과
		if (skill_type == 'tamer_skill_active_kesath') then
			-- 케사스 액티브 : 아군 중 피가 제일 많은 녀석의 체력을 깎는다.
			local hp_rate = (1 - (t_skill['val_1']/100))
			local l_target = self:getTargetListByTable(t_skill)

			for i, char in pairs(l_target) do
				local after_hp = (char.m_hp * hp_rate)
				local damage = char.m_hp - after_hp
				char:setHp(after_hp)
				char:makeDamageFont(damage, char.pos.x, char.pos.y)
			end
		end

	-- [EVENT]
	elseif string.find(skill_type, 'tamer_skill_event') then
		-- 1. 타겟리스트 생성
		local l_target = {self.m_targetChar}
			
		-- 2. 상태효과 구조체
		local l_status_effect_struct = SkillHelper:makeStructStatusEffectList(t_skill)
			
		-- 3. 타겟에 상태효과생성
		StatusEffectHelper:doStatusEffectByStruct(self, l_target, l_status_effect_struct, nil, t_skill['sid'])

	-- [PASSIVE]
	else
		PARENT.doSkillBySkillTable(self, t_skill, nil)
	end

	-- 쿨타임 갱신
    self.m_lSkillCoolTimer[skill_idx] = t_skill['cooldown'] 

	return true
end

-------------------------------------
-- function doSkillActive
-------------------------------------
function Tamer:doSkillActive()
    return self:doSkill(TAMER_SKILL_ACTIVE)
end

-------------------------------------
-- function doSkillEvent
-------------------------------------
function Tamer:doSkillEvent()
    return self:doSkill(TAMER_SKILL_EVENT)
end

-------------------------------------
-- function doSkillPassive
-------------------------------------
function Tamer:doSkillPassive()
    return self:doSkill(TAMER_SKILL_PASSIVE)
end

-------------------------------------
-- function checkEventSkill
-------------------------------------
function Tamer:checkEventSkill(skill_idx, event_name)
	-- 이미 실행중인지 체크
	if (not self.m_bEventSKillUsable) then
		return false
	end

	local t_skill = self.m_lSkill[skill_idx]
	
	-- 적합한 이벤트 타입인지 체크
	if (event_name ~= t_skill['chance_value']) then
		return false
	end

	-- 글로벌 쿨타임 체크
	if (self.m_world.m_gameCoolTime:isWaiting(GLOBAL_COOL_TIME.PASSIVE_SKILL)) then
		return false
	end

	-- 쿨타임 체크
	if (self.m_lSkillCoolTimer[skill_idx] > 0) then
		return false
	end

	-- 발동 확률 체크 (100단위 사용 심플)
	local chance_value = t_skill['chance_value_2']
	local random_100 = math_random(1, 100)
	if (chance_value < random_100) then
		return false
	end

	return true
end

-------------------------------------
-- function getTargetOnEvent
-------------------------------------
function Tamer:getTargetOnEvent(event_name, t_event)
	local target_char
	if string.find(event_name, 'under_atk') then
		target_char = t_event['defender']
	elseif string.find(event_name, 'hit') then
		target_char = t_event['attacker']
	else
		target_char = t_event['char']
	end
			
	self.m_targetChar = target_char
end

-------------------------------------
-- function showToolTipActive
-------------------------------------
function Tamer:showToolTipActive()
    local t_skill = self.m_lSkill[TAMER_SKILL_ACTIVE]
    local str = UI_Tooltip_Skill:getSkillDescStr('tamer', t_skill['sid'])

    local tool_tip = UI_Tooltip_Skill(320, -220, str, true)
    tool_tip:autoRelease()
end

-------------------------------------
-- function increaseActiveSkillCool
-------------------------------------
function Tamer:increaseActiveSkillCool(percentage)
    local t_skill = self.m_lSkill[TAMER_SKILL_ACTIVE]

    self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] = t_skill['cooldown'] 
    
    self.m_bActiveSKillUsable = true
end

-------------------------------------
-- function resetActiveSkillCool
-------------------------------------
function Tamer:resetActiveSkillCool()
    self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] = 0
end

-------------------------------------
-- function isEndActiveSkillCool
-------------------------------------
function Tamer:isEndActiveSkillCool()
    return (self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] == 0)
end

-------------------------------------
-- function isPossibleSkill
-------------------------------------
function Tamer:isPossibleSkill()
    if (not self:isEndActiveSkillCool()) then
		return false
	end

    return true
end

-------------------------------------
-- function getActiveSkillTable
-------------------------------------
function Tamer:getActiveSkillTable()
    local t_skill = self.m_lSkill[TAMER_SKILL_ACTIVE]
    return t_skill
end