local PARENT = Character

local TAMER_SKILL_ACTIVE = 1
local TAMER_SKILL_PASSIVE = 2

-------------------------------------
-- class Tamer
-------------------------------------
Tamer = class(Character, {
        -- 기본 정보
        m_tamerID = '',    -- 드래곤의 고유 ID

        m_barrier = '',

        m_afterimageMove = 'number',
        m_bUseSelfAfterImage = 'boolean',
        m_bWaitState = 'boolean',

        m_lSkill = '',
        m_lSkillCoolTimer = '',

        m_roamTimer = '',
        m_zPos = 'number',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Tamer:init(file_name, body, ...)
    self.m_charType = 'tamer'

    self.m_bWaitState = false
    self.m_bUseSelfAfterImage = false

    self.m_lSkill = {}
    self.m_lSkillCoolTimer = {}

    self.m_roamTimer = 0
    self.m_zPos = 0
end

-------------------------------------
-- function init_tamer
-------------------------------------
function Tamer:init_tamer(t_tamer, bLeftFormationend)
    self.m_charTable = t_tamer
    self.m_bLeftFormation = bLeftFormationend

    local t_tamer = self.m_charTable
	local table_tamer_skill = TableTamerSkill()

    self.m_lSkill[TAMER_SKILL_ACTIVE] = table_tamer_skill:getTamerSkill(t_tamer['skill_' .. TAMER_SKILL_ACTIVE])
    self.m_lSkill[TAMER_SKILL_PASSIVE] = table_tamer_skill:getTamerSkill(t_tamer['skill_' .. TAMER_SKILL_PASSIVE])

    self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] = 0
    self.m_lSkillCoolTimer[TAMER_SKILL_PASSIVE] = 0
end

-------------------------------------
-- function initAnimator
-------------------------------------
function Tamer:initAnimator(file_name)
    PARENT.initAnimator(self, file_name)

    -- 보호막
    self.m_barrier = MakeAnimator('res/effect/effect_tamer_shield/effect_tamer_shield.vrp')
    self.m_animator.m_node:addChild(self.m_barrier.m_node)
end

-------------------------------------
-- function initState
-------------------------------------
function Tamer:initState()
    --PARENT.initState(self)

    self:addState('idle', PARENT.st_idle, 'i_idle', true)
    self:addState('roam', Tamer.st_roam, 'i_idle', true)
    --self:addState('attack', PARENT.st_idle, 'i_idle', false)
    --self:addState('attackDelay', PARENT.st_idle, 'i_idle', true)
    --self:addState('charge', PARENT.st_idle, 'i_idle', true)
    --self:addState('casting', PARENT.st_idle, 'i_idle', true)

    self:addState('wait', Tamer.st_wait, 'i_idle', true)
    self:addState('move', PARENT.st_move, 'i_idle', true)

    self:addState('success_pose', Tamer.st_success_pose, 'i_idle', true)
    self:addState('success_move', Tamer.st_success_move, 'i_idle', true)

    self:addState('dying', Tamer.st_dying, 'i_dying', false, PRIORITY.DYING)
    self:addState('dead', PARENT.st_dead, nil, nil, PRIORITY.DEAD)

    self:addState('comeback', PARENT.st_comeback, 'i_idle', true)
end

-------------------------------------
-- function update
-------------------------------------
function Tamer:update(dt)
    if self.m_bUseSelfAfterImage then
        self:updateAfterImage(dt)
    end

    if (self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] > 0) then
        self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] = math_max(self.m_lSkillCoolTimer[TAMER_SKILL_ACTIVE] - dt, 0)
    end

    self:syncAniAndPhys()
        
    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_roam
-------------------------------------
function Tamer.st_roam(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_roamTimer = 0
    end

    if (owner.m_roamTimer <= 0) then
        -- 현재 위치가 몇사분면인지 계산
        local quadrant = getQuadrant(
            CRITERIA_RESOLUTION_X / 2,
            0,
            owner.pos.x,
            owner.pos.y
        )

        -- 다음 분면을 목표 지점으로 함
        quadrant = quadrant + 1
        if (quadrant > 4) then
            quadrant = quadrant - 4
        end
        
        local tar_x, tar_y, tar_z
        
        if (quadrant == 1) then
            tar_x = math_random(CRITERIA_RESOLUTION_X / 2, CRITERIA_RESOLUTION_X) - 300
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2 - 100)
        elseif (quadrant == 2) then
            tar_x = math_random(CRITERIA_RESOLUTION_X / 2, CRITERIA_RESOLUTION_X) - 300
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2) - (CRITERIA_RESOLUTION_Y / 2 - 100)
        elseif (quadrant == 3) then
            tar_x = math_random(50, CRITERIA_RESOLUTION_X / 2)
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2) - (CRITERIA_RESOLUTION_Y / 2 - 100)
        elseif (quadrant == 4) then
            tar_x = math_random(50, CRITERIA_RESOLUTION_X / 2)
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2)
        end
        tar_z = math_random(0, 150)

        local cameraHomePosX, cameraHomePosY = owner.m_world.m_gameCamera:getHomePos()
        tar_x = (tar_x + cameraHomePosX)
        tar_y = (tar_y + cameraHomePosY)

        local course = math_random(-1, 1)
        local time = math_random(15, 30) / 10
        local bezier = getBezier(tar_x, tar_y, owner.pos.x, owner.pos.y, course)
        local move_action = cc.BezierBy:create(time, bezier)
        local scale_action = cc.ScaleTo:create(time, 1 - (0.003 * tar_z))
        local tint_action = cc.TintTo:create(time, 255 - tar_z, 255 - tar_z, 255 - tar_z)
        
        owner.m_rootNode:stopAllActions()
        owner.m_rootNode:runAction(cc.Spawn:create(move_action, scale_action))

        owner.m_animator.m_node:stopAllActions()
        owner.m_animator.m_node:runAction(tint_action)
                
        owner.m_roamTimer = time * 0.9
    end

    owner.m_roamTimer = owner.m_roamTimer - dt
end

-------------------------------------
-- function st_dying
-------------------------------------
function Tamer.st_dying(owner, dt)
    PARENT.st_dying(owner, dt)

    if (owner.m_stateTimer == 0) then
		owner.m_barrier:changeAni('disappear', false)
        owner.m_barrier:addAniHandler(function()
            owner.m_barrier:setVisible(false)
        end)
    end
end

-------------------------------------
-- function st_wait
-------------------------------------
function Tamer.st_wait(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_rootNode:stopAllActions()
    end
end

-------------------------------------
-- function st_success_pose
-- @brief success 세레머니
-------------------------------------
function Tamer.st_success_pose(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:addAniHandler(function()
            owner.m_animator:changeAni('i_idle', true)
        end)

    elseif (owner.m_stateTimer >= 2.5) then
        owner:changeState('success_move')
    end
end

-------------------------------------
-- function st_success_move
-- @brief success 세레머니 후 오른쪽으로 퇴장
-------------------------------------
function Tamer.st_success_move(owner, dt)
    if (owner.m_stateTimer == 0) then
        --local add_speed = (owner.pos['y'] / -100) * 100
        local add_speed = math_random(-2, 2) * 100
        owner:setMove(owner.pos.x + 2000, owner.pos.y, 1500 + add_speed)

        owner.m_afterimageMove = 0

        owner:setAfterImage(true)
    end
end

-------------------------------------
-- function setWaitState
-------------------------------------
function Tamer:setWaitState(is_wait_state)
    self.m_bWaitState = is_wait_state

    if is_wait_state then
        if isExistValue(self.m_state, 'idle', 'roam') then
            self:changeState('wait')
        end
    else
        if (self.m_state == 'wait') then
            self:changeState('roam')
        end
    end
end

-------------------------------------
-- function setAfterImage
-------------------------------------
function Tamer:setAfterImage(b)
    Dragon.setAfterImage(self, b)
end

-------------------------------------
-- function updateAfterImage
-------------------------------------
function Tamer:updateAfterImage(dt)
    Dragon.updateAfterImage(self, dt)
end

-------------------------------------
-- function getTargetList
-------------------------------------
function Tamer:getTargetList(t_skill)
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
function Tamer:doSkill(skill_idx)
	local t_skill = self.m_lSkill[skill_idx]

	if (t_skill['skill_form'] == 'status_effect') then 
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
function Tamer:doSkillActive()
    --[[
    self.m_world:dispatch('tamer_skill', {}, function()
        self:showToolTipActive()
        self:doSkill(TAMER_SKILL_ACTIVE)
    end, idx)
    ]]--

    self.m_world:dispatch('tamer_skill')

    self:showToolTipActive()

    return self:doSkill(TAMER_SKILL_ACTIVE)
end

-------------------------------------
-- function doSkillPassive
-------------------------------------
function Tamer:doSkillPassive()
    return self:doSkill(TAMER_SKILL_PASSIVE)
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