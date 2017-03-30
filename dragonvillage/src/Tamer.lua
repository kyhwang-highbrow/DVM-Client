local PARENT = Character

local TAMER_SKILL_ACTIVE = 1
local TAMER_SKILL_EVENT = 2
local TAMER_SKILL_PASSIVE = 3

local MAX_TAMER_SKILL = 3
local TAMER_Z_POS = 100

local TAMER_ACTION_TAG__MOVE_Z = 10

-------------------------------------
-- class Tamer
-------------------------------------
Tamer = class(PARENT, {
        -- 기본 정보
        m_tamerID = '',    -- 드래곤의 고유 ID

        m_barrier = '',

        m_afterimageMove = 'number',
        m_bUseSelfAfterImage = 'boolean',
        m_bWaitState = 'boolean',

        m_lSkill = 'list',
        m_lSkillCoolTimer = 'list',
		m_bActiveSKillUsable = 'boolean',
		m_bEventSKillUsable = 'boolean',

        m_roamTimer = '',
        m_baseAnimatorScale = '',

        m_targetItem = 'DropItem',
        m_targetItemStack = '',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Tamer:init(file_name, body, ...)
    self.m_charType = 'tamer'
	self.m_attribute = 'earth'

    self.m_bWaitState = false
    self.m_bUseSelfAfterImage = false

    self.m_lSkill = {}
    self.m_lSkillCoolTimer = {}
	self.m_bActiveSKillUsable = true
	self.m_bEventSKillUsable = true

    self.m_roamTimer = 0
    self.m_baseAnimatorScale = 0.5

    self.m_targetItem = nil
    self.m_targetItemStack = {}
end

-------------------------------------
-- function init_tamer
-------------------------------------
function Tamer:init_tamer(t_tamer, bLeftFormationend)
    self.m_charTable = t_tamer
    self.m_bLeftFormation = bLeftFormationend

	-- Tamer Skill 설정
	self:initSkill()

	-- TAMER UI 생성
	self.m_world.m_inGameUI:initTamerUI(self)

	self.m_world:addListener('dragon_summon', self)
end

-------------------------------------
-- function initSkill
-------------------------------------
function Tamer:initSkill(file_name)
    local t_tamer = self.m_charTable
	local table_tamer_skill = TableTamerSkill()
	
	for i = 1, MAX_TAMER_SKILL do
		local skill_id = t_tamer['skill_' .. i]
		local t_skill = table_tamer_skill:getTamerSkill(skill_id)

		self.m_lSkill[i] = t_skill
		self.m_lSkillCoolTimer[i] = t_skill['cooldown']
	end
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
    self:addState('appear', Tamer.st_appear, 'i_idle', true)
    self:addState('idle', PARENT.st_idle, 'i_idle', true)
    self:addState('roam', Tamer.st_roam, 'i_idle', true)
    self:addState('bring', Tamer.st_bring, 'i_idle', true)

	self:addState('active', Tamer.st_active, 'i_idle', false)
	self:addState('event', Tamer.st_event, 'skill_2', false)

    self:addState('wait', Tamer.st_wait, 'i_idle', true)
    self:addState('move', PARENT.st_move, 'i_idle', true)

    self:addState('success_pose', Tamer.st_success_pose, 'i_idle', true)
    self:addState('success_move', Tamer.st_success_move, 'i_idle', true)

    self:addState('dying', Tamer.st_dying, 'i_dying', false, PRIORITY.DYING)
    self:addState('dead', PARENT.st_dead, nil, nil, PRIORITY.DEAD)

    self:addState('comeback', PARENT.st_comeback, 'i_idle', true)
end

-------------------------------------
-- function onEvent
-------------------------------------
function Tamer:onEvent(event_name, t_event, ...)
	if (event_name == 'dragon_summon') then
		self:setTamerEventSkill()

	elseif (event_name == 'hit_basic') then
		if (self:checkEventSkill(TAMER_SKILL_EVENT)) then
			self:changeState('event')
		end
	end
end

-------------------------------------
-- function setTamerEventSkill
-- @breif 드래곤이 등장한 후 테이머의 스킬 이벤트를 등록한다.
-------------------------------------
function Tamer:setTamerEventSkill()
	for i, t_skill in pairs(self.m_lSkill) do
		if (t_skill['chance_type'] == 'basic') then
			for i, dragon in pairs(self.m_world:getDragonList()) do
				dragon:addListener('hit_basic', self)
			end
		end
	end
end

-------------------------------------
-- function update
-------------------------------------
function Tamer:update(dt)
    if self.m_bUseSelfAfterImage then
        self:updateAfterImage(dt)
    end

    if (not self.m_bDead and self.m_world:isPossibleControl()) then
        if (self.m_lSkillCoolTimer[TAMER_SKILL_EVENT] > 0) then
            self.m_lSkillCoolTimer[TAMER_SKILL_EVENT] = math_max(self.m_lSkillCoolTimer[TAMER_SKILL_EVENT] - dt, 0)
        end
    end

    self:syncAniAndPhys()
        
    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_appear
-- @brief 테이머 배회
-------------------------------------
function Tamer.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
        if (owner.m_bLeftFormation) then
            owner:setPosition(-300, 0)
            owner:setMove(CRITERIA_RESOLUTION_X / 2 - 80, 0, 700)
        end
    end
end

--[[
-------------------------------------
-- function st_roam
-- @brief 테이머 배회
-------------------------------------
function Tamer.st_roam(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner.m_roamTimer = 0

        owner:setAfterImage(false)
    end

    if (owner.m_roamTimer <= 0) then
        -- 현재 위치가 몇사분면인지 계산
        local quadrant = getQuadrant(
            CRITERIA_RESOLUTION_X / 4,
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
            tar_x = math_random(CRITERIA_RESOLUTION_X / 4, CRITERIA_RESOLUTION_X / 2)
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2 - 100)
        elseif (quadrant == 2) then
            tar_x = math_random(CRITERIA_RESOLUTION_X / 4, CRITERIA_RESOLUTION_X / 2)
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2) - (CRITERIA_RESOLUTION_Y / 2 - 150)
        elseif (quadrant == 3) then
            tar_x = math_random(100, CRITERIA_RESOLUTION_X / 4)
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2) - (CRITERIA_RESOLUTION_Y / 2 - 150)
        elseif (quadrant == 4) then
            tar_x = math_random(100, CRITERIA_RESOLUTION_X / 4)
            tar_y = math_random(0, CRITERIA_RESOLUTION_Y / 2 - 100)
        end
        tar_z = TAMER_Z_POS
        
        local cameraHomePosX, cameraHomePosY = owner.m_world.m_gameCamera:getHomePos()
        tar_x = (tar_x + cameraHomePosX)
        tar_y = (tar_y + cameraHomePosY)

        local course = math_random(-1, 1)
        local time = math_random(15, 30) / 10
        local bezier = getBezier(tar_x, tar_y, owner.pos.x, owner.pos.y, course)
        local move_action = cc.BezierBy:create(time, bezier)
                
        owner.m_rootNode:stopAllActions()
        owner.m_rootNode:runAction(move_action)

        owner:runAction_MoveZ(time, tar_z)
                        
        owner.m_roamTimer = time + (math_random(0, 10) * 0.1)    -- 0 ~ 1초 사이로 잠시 멈추도록
    end

    owner.m_roamTimer = owner.m_roamTimer - dt
end
]]--
-------------------------------------
-- function st_roam
-- @brief 테이머 배회
-------------------------------------
function Tamer.st_roam(owner, dt)
    if owner:checkItemStack() then
        return
    end

    if (owner.m_stateTimer == 0) then
        owner.m_roamTimer = 0
        owner:setAfterImage(false)
    end

    if (owner.m_roamTimer <= 0) then
        local tar_x, tar_y, tar_z, course = owner:getRoamPos()

        local time = math_random(15, 30) / 10
        local bezier = getBezier(tar_x, tar_y, owner.pos.x, owner.pos.y, course)
        local move_action = cc.BezierBy:create(time, bezier)
                
        owner.m_rootNode:stopAllActions()
        owner.m_rootNode:runAction(move_action)

        owner:runAction_MoveZ(time, tar_z)
                        
        owner.m_roamTimer = time + (math_random(0, 10) * 0.1)    -- 0 ~ 1초 사이로 잠시 멈추도록
    end

    owner.m_roamTimer = owner.m_roamTimer - dt
end

-------------------------------------
-- function getRoamPos
-- @brief 테이머 배회
-------------------------------------
function Tamer:getRoamPos()
    local t_random = {}
    local t_temp = {}

    for y = 1, 7 do
        for x = 1, 7 do
            if (not t_temp[tostring(x) .. tostring(y)]) then
                local b = false
                if (y == 1 or y == 7) then      b = true
                elseif (x == 1 or x == 7) then  b = true
                end

                if (b) then
                    table.insert(t_random, { x = x, y = y })
                    t_temp[tostring(x) .. tostring(y)] = true
                end
            end
        end
    end

    t_random = randomShuffle(t_random)

    local random = t_random[1]
    local tar_x = random['x'] * 70
    local tar_y = random['y'] * 80 - 280
    local tar_z = TAMER_Z_POS
    local cameraHomePosX, cameraHomePosY = self.m_world.m_gameCamera:getHomePos()
    tar_x = (tar_x + cameraHomePosX)
    tar_y = (tar_y + cameraHomePosY)

    local course = math_random(-1, 1)

    -- 화면 좌측일 경우 곡선이동이 화면 밖으로 나가지 않도록 임시 처리...a
    if (random['x'] == 1 or random['y'] == 1 or random['x'] == 7) then
        course = 0
    end

    return tar_x, tar_y, tar_z, course
end

-------------------------------------
-- function checkItemStack
-- @brief
-------------------------------------
function Tamer:checkItemStack()
    if self.m_targetItemStack[1] then

        if self.m_targetItem then
            self.m_targetItem:makeObtainEffect()
            self.m_targetItem:changeState('dying')
        end

        self.m_targetItem = self.m_targetItemStack[1]
        table.remove(self.m_targetItemStack, 1)
        self:changeState('bring', true)
        return true
    end

    return false
end

-------------------------------------
-- function st_bring
-- @brief 드랍아이템을 가져오는 연출
-------------------------------------
function Tamer.st_bring(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:resetMove()
        local prevPosX = owner.pos.x
        local prevPosY = owner.pos.y
        local prevScale = owner.m_rootNode:getScale()

        owner.m_targetItem:stopAllActions()
        local distance = getDistance(owner.m_targetItem.pos.x, owner.m_targetItem.pos.y, owner.pos.x, owner.pos.y)
        local speed = 1000
        local time1 = (distance / speed)
        --local move_action1 = cc.MoveTo:create(time1, cc.p(owner.m_targetItem.pos.x, owner.m_targetItem.pos.y))
        local bezier1 = getBezier(owner.m_targetItem.pos.x, owner.m_targetItem.pos.y, owner.pos.x, owner.pos.y, 1)
        local move_action1 = cc.BezierBy:create(time1, bezier1)
        move_action1 = cc.EaseInOut:create(move_action1, 2)
        local callFunc_action1 = cc.CallFunc:create(function()
            owner:runAction_MoveZ(time1, 0)
            owner:setAfterImage(false)
        end)

        local callFunc_checkItemStack = cc.CallFunc:create(function()
            owner.m_targetItem:makeObtainEffect()
            owner.m_targetItem:changeState('dying')
            owner.m_targetItem = nil
            owner:checkItemStack()
        end)
        
        owner.m_rootNode:stopAllActions()
        owner.m_rootNode:runAction(cc.Sequence:create(
            cc.Spawn:create(move_action1, callFunc_action1),
            callFunc_checkItemStack,
            cc.DelayTime:create(0.6),
            cc.CallFunc:create(function()
                owner:changeState('roam')
            end)
        ))

        owner.m_animator:changeAni('i_summon', false)
        owner.m_animator:addAniHandler(function()
            owner.m_animator:changeAni('i_idle', true)
        end)

        owner.m_afterimageMove = 0
        owner:setAfterImage(true)
            
    else
        owner:updateAfterImage(dt)
    end
end

-------------------------------------
-- function st_active
-------------------------------------
function Tamer.st_active(owner, dt)
	if (owner.m_stateTimer == 0) then
		local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
		local move_pos_x = CRITERIA_RESOLUTION_X/2
		local move_pos_y = cameraHomePosY + 200

		local world = owner.m_world
		local game_highlight = world.m_gameHighlight
		local l_dragon = world:getDragonList()
		
		-- tamer action stop
		owner:stopAllActions()

		-- 하이라이트 활성화
		--game_highlight:setActive(true)

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
		owner.m_afterimageMove = 0
		owner:setAfterImage(true)

	elseif (owner.m_isOnTheMove == false) and (owner.m_bActiveSKillUsable) then
		owner.m_bActiveSKillUsable = false
		local world = owner.m_world
		local game_highlight = world.m_gameHighlight
		local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()

		local function cb_function()
			owner.m_animator:changeAni('skill_1', false)

			-- 애니메이션 종료시
			owner:addAniHandler(function()
			
				local time = 0.4
				local target = owner.m_targetChar
				local move_action = cc.MoveTo:create(time, cc.p(target.pos.x, target.pos.y))

				owner.m_rootNode:runAction(cc.Sequence:create(
					move_action,
					cc.DelayTime:create(0.1),
					cc.CallFunc:create(function() owner:doSkillActive() end),
					cc.DelayTime:create(0.4),
					cc.CallFunc:create(function()
						-- 일시정지 해제
						owner.m_world:setTemporaryPause(false, owner)
						-- roam상태로 변경
						owner:changeStateWithCheckHomePos('roam')
						-- 하이라이트 비활성화
						--game_highlight:setActive(false)
						-- 애프터 이미지 해제
						owner:setAfterImage(false)
					end)
				))

			end)
		end

		local res = 'res/effect/cutscene_tamer_a_type/cutscene_tamer_a_type.vrp'
		SkillHelper:makeEffect(world, res, CRITERIA_RESOLUTION_X/2, cameraHomePosY, 'idle', cb_function)
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
		local cameraHomePosX, cameraHomePosY = g_gameScene.m_gameWorld.m_gameCamera:getHomePos()
		owner:setTamerSkillDirecting(CRITERIA_RESOLUTION_X/4, cameraHomePosY + 200, TAMER_SKILL_EVENT, cb_func)
    end
end

-------------------------------------
-- function st_dying
-------------------------------------
function Tamer.st_dying(owner, dt)
    if (owner.m_stateTimer == 0) then
        if (owner.m_bDead == false) then
            owner:setDead()
        end
        owner.m_rootNode:stopAllActions()

		owner.m_barrier:changeAni('disappear', false)
        owner.m_barrier:addAniHandler(function()
            owner.m_barrier:setVisible(false)

            local action = cc.Sequence:create(
                cc.MoveBy:create(3, cc.p(0, -2000)),
                cc.CallFunc:create(function()
                    owner:changeState('dead')
                end)
            )
            owner:runAction(action)            
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

    owner:checkItemStack()
end

-------------------------------------
-- function st_success_pose
-- @brief success 세레머니
-------------------------------------
function Tamer.st_success_pose(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:stopAllActions()
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
        owner:stopAllActions()
        --local add_speed = (owner.pos['y'] / -100) * 100
        local add_speed = math_random(-2, 2) * 100
        owner:setMove(owner.pos.x + 2000, owner.pos.y, 1500 + add_speed)

        owner.m_afterimageMove = 0

        owner:setAfterImage(true)
    end
end

-------------------------------------
-- function setTamerSkillDirecting
-------------------------------------
function Tamer:setTamerSkillDirecting(move_pos_x, move_pos_y, skill_idx, cb_func)
	local world = self.m_world
	local game_highlight = world.m_gameHighlight
	local l_dragon = world:getDragonList()

	-- tamer action stop
	self:stopAllActions()

	-- 하이라이트 활성화
    --game_highlight:setActive(true)

	-- 스킬 이름 말풍선
	local skill_name = Str(self.m_lSkill[skill_idx]['t_name'])
	SkillHelper:makePassiveSkillSpeech(self, skill_name)

	-- 연출 이동
    self:setHomePos(self.pos.x, self.pos.y)
    self:setMove(move_pos_x, move_pos_y, 2000)
	self:runAction_MoveZ(0.1, 0)

	-- 애니메이션 종료시
	self:addAniHandler(function()

		-- 애프터 이미지
		self.m_afterimageMove = 0
		self:setAfterImage(true)

		local time = 0.4
		local target = self.m_targetChar
		local move_action = cc.MoveTo:create(time, cc.p(target.pos.x, target.pos.y))
		local cb_func_action = cc.CallFunc:create(function() end)

		self.m_rootNode:runAction(cc.Sequence:create(
            move_action,
			cc.DelayTime:create(0.1),
			cb_func_action,
			cc.DelayTime:create(0.4),
            cc.CallFunc:create(function()
				-- 스킬 실행
				if (cb_func) then
					cb_func()
				end

                -- roam상태로 변경
				self:changeStateWithCheckHomePos('roam')
				-- 하이라이트 비활성화
				--game_highlight:setActive(false)
				-- 애프터 이미지 해제
				self:setAfterImage(false)
            end)
        ))

    end)
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
-- function runAction_Floating
-- @brief 캐릭터 부유중 효과
-------------------------------------
function Tamer:runAction_Floating()
end

-------------------------------------
-- function runAction_MoveZ
-- @brief 테이머 z축 이동
-------------------------------------
function Tamer:runAction_MoveZ(time, tar_z)
    local target_node = self.m_animator.m_node
    if (not target_node) then
        return
    end

    local tar_z = tar_z or TAMER_Z_POS

    local scale_action = cc.ScaleTo:create(time, self.m_baseAnimatorScale * (1 - (0.003 * tar_z)))
    local tint_action = cc.TintTo:create(time, 255 - tar_z, 255 - tar_z, 255 - tar_z)
    local action = cc.Spawn:create(scale_action, tint_action)

    cca.runAction(target_node, action, TAMER_ACTION_TAG__MOVE_Z)
end

-------------------------------------
-- function setAnimatorScale
-------------------------------------
function Tamer:setAnimatorScale(scale)
    self.m_animator:setScale(scale)

    self.m_baseAnimatorScale = scale
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
-- function changeHomePosByTime
-------------------------------------
function Tamer:changeHomePosByTime(x, y, time)
    if (self.m_state == 'bring') then
        self:setHomePos(x, y)
    else
        PARENT.changeHomePosByTime(self, x, y, time)
        --self:runAction_MoveZ(time, 0)
    end
end

-------------------------------------
-- function doSkill
-------------------------------------
function Tamer:doSkill(skill_idx)
	local t_skill = self.m_lSkill[skill_idx]
	
	self:checkTarget(t_skill)
	PARENT.doSkillBySkillTable(self, t_skill, nil)

    self.m_lSkillCoolTimer[skill_idx] = t_skill['cooldown'] 

	return true
end

-------------------------------------
-- function doSkillActive
-------------------------------------
function Tamer:doSkillActive()
	cclog('############ Tamer:doSkillActive()')
    self.m_world:dispatch('tamer_skill')
    return self:doSkill(TAMER_SKILL_ACTIVE)
end

-------------------------------------
-- function doSkillEvent
-------------------------------------
function Tamer:doSkillEvent()
	cclog('############ Tamer:doSkillEvent()')
    return self:doSkill(TAMER_SKILL_EVENT)
end

-------------------------------------
-- function doSkillPassive
-------------------------------------
function Tamer:doSkillPassive()
	cclog('############ Tamer:doSkillPassive()')
    return self:doSkill(TAMER_SKILL_PASSIVE)
end

-------------------------------------
-- function checkEventSkill
-------------------------------------
function Tamer:checkEventSkill(skill_idx)
	-- 0. 이미 실행중인지 체크
	if (not self.m_bEventSKillUsable) then
		return 
	end

	-- 1. 쿨타임 체크
	if (self.m_lSkillCoolTimer[skill_idx] > 0) then
		return false
	end

	-- 2. 발동 확률 체크 (100단위 사용 심플)
	local t_skill = self.m_lSkill[skill_idx]
	local chance_value = t_skill['chance_value']
	local random_100 = math_random(1, 100)
	if (chance_value < random_100) then
		return false
	end

	return true
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

-------------------------------------
-- function doBringItem
-------------------------------------
function Tamer:doBringItem(item)
    table.insert(self.m_targetItemStack, item)
    item:changeState('idle', true)

    --[[
    self.m_targetItem = item
    self:changeState('bring')
    --]]

    if (self.m_state == 'bring') then
        return
    end

    if (self.m_state == 'roam') then
        self:checkItemStack()
    end
end

-------------------------------------
-- function stopAllActions
-------------------------------------
function Tamer:stopAllActions()
    PARENT.stopAllActions(self)

    if self.m_targetItem then
        self.m_targetItem:makeObtainEffect()
        self.m_targetItem:changeState('dying')
        self.m_targetItem = nil
    end
end

-------------------------------------
-- function isRequiredHighLight
-- @brief 하이라이트가 필요한 상태인지 여부
-------------------------------------
function Tamer:isRequiredHighLight()
    -- 액티브 스킬 연출 중
    if (self.m_world.m_tamer.m_state == 'active') then
        return true

    -- 발동형 스킬 연출 중
    elseif (self.m_world.m_tamer.m_state == 'event') then
        return true

    end

    return false
end