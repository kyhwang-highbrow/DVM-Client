local PARENT = Character

local TAMER_Z_POS = 100
local TAMER_ACTION_TAG__MOVE_Z = 10

-------------------------------------
-- class Tamer
-------------------------------------
Tamer = class(PARENT, {
        -- 기본 정보
        m_tamerID = '',    -- 드래곤의 고유 ID
        m_costumeData = 'StructTamerCostume', -- 코스튬 데이터 추가

        m_barrier = '',

        m_bWaitState = 'boolean',
		m_isUseMovingAfterImage = 'boolean',

        m_lSkill = 'list',

        m_bActiveSKillUsable = 'boolean',
        
		m_roamTimer = '',
        m_baseAnimatorScale = '',

        m_targetItem = 'DropItem',
        m_targetItemStack = '',

        -- 배경에 넣을 오브젝트 
        -- 애니메이션, png 원하는거 다 가능
        m_background = '',
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
	self.m_isUseMovingAfterImage = false

    self.m_lSkill = {}

    self.m_bActiveSKillUsable = true
    
	self.m_roamTimer = 0
    self.m_baseAnimatorScale = 0.5

    self.m_targetItem = nil
    self.m_targetItemStack = {}
end

-------------------------------------
-- function init_tamer
-------------------------------------
function Tamer:init_tamer(t_tamer_data, bLeftFormationend)
    local tamer_id = t_tamer_data['tid']
    local t_tamer = TableTamer():get(tamer_id)

    self.m_charTable = t_tamer
    self.m_attribute = t_tamer['attr']
    self.m_bLeftFormation = bLeftFormationend

	-- 아군 테이머의 4번째 스킬은 자동모드시에만 적용
    if (self.m_bLeftFormation and not g_autoPlaySetting:get('auto_mode')) then
        self:setDragonSkillLevelList(t_tamer_data['skill_lv1'], t_tamer_data['skill_lv2'], t_tamer_data['skill_lv3'])
    else
        self:setDragonSkillLevelList(t_tamer_data['skill_lv1'], t_tamer_data['skill_lv2'], t_tamer_data['skill_lv3'], t_tamer_data['skill_lv4'])
    end

	self:initDragonSkillManager('tamer', t_tamer['tid'], nil, true)
	self:initLogRecorder(t_tamer['tid'])

	self.m_world:addListener('dragon_summon', self)
end

-------------------------------------
-- function initFormation
-------------------------------------
function Tamer:initFormation()
	-- 진영에 따른 처리
	if (self.m_bLeftFormation) then
    else
        self.m_animator:setFlip(true)
    end
end

-------------------------------------
-- function initBarrier
-------------------------------------
function Tamer:initBarrier()
    -- 보호막
    self.m_barrier = MakeAnimator('res/effect/effect_tamer_shield/effect_tamer_shield.vrp')
    self.m_animator.m_node:addChild(self.m_barrier.m_node)
	
	self.m_barrier:changeAni('disappear')
	self.m_barrier:addAniHandler(function()
		self.m_barrier:changeAni('idle', true)
	end)
end

-------------------------------------
-- function initState
-------------------------------------
function Tamer:initState()
    self:addState('appear', Tamer.st_appear, 'i_idle', true)
    self:addState('appear_colosseum', Tamer.st_appear_colosseum, 'summon', false)

    self:addState('idle', Tamer.st_idle, 'i_idle', true) 
    self:addState('roam', Tamer.st_roam, 'i_idle', true)
    self:addState('bring', Tamer.st_bring, 'i_idle', true)

	self:addState('skillAppear', Tamer.st_skillAppear, 'i_idle', false)
    self:addState('skillIdle', Tamer.st_skillIdle, 'skill_2', false)
	
    self:addState('delegate', PARENT.st_delegate, 'i_idle', true)
    self:addState('wait', Tamer.st_wait, 'i_idle', true)
    self:addState('move', PARENT.st_move, 'i_idle', true)

    self:addState('success_pose', Tamer.st_success_pose, 'i_idle', true, PRIORITY.SUCCESS_POSE)
    self:addState('success_move', Tamer.st_success_move, 'i_idle', true, PRIORITY.SUCCESS_POSE)

    self:addState('dying', Tamer.st_dying, 'i_dying', false, PRIORITY.DYING)
    self:addState('dead', Tamer.st_dead, nil, nil, PRIORITY.DEAD)

    self:addState('comeback', Tamer.st_roam, 'i_idle', true)
end

-------------------------------------
-- function onEvent
-------------------------------------
function Tamer:onEvent(event_name, t_event, ...)
end

-------------------------------------
-- function updatePhys
-------------------------------------
function Tamer:updatePhys(dt)
    PARENT.updatePhys(self, dt)

    self:syncAniAndPhys()
end

-------------------------------------
-- function update
-------------------------------------
function Tamer:update(dt)
    -- 잔상
	if (self.m_isUseMovingAfterImage) then
        self:updateMovingAfterImage(dt)
    end

    return PARENT.update(self, dt)
end

-------------------------------------
-- function st_appear
-- @brief 테이머 등장
-------------------------------------
function Tamer.st_appear(owner, dt)
    if (owner.m_stateTimer == 0) then
        if (owner.m_bLeftFormation) then
            owner:setPosition(-300, 0)
            owner:setMove(CRITERIA_RESOLUTION_X / 2 - 80, 0, 700)
        end
    end
end

-------------------------------------
-- function st_appear_colosseum
-- @brief 테이머 등장(콜로세움)
-------------------------------------
function Tamer.st_appear_colosseum(owner, dt)
    if (owner.m_stateTimer == 0) then
    end
end

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

        if (owner.m_background) then
            owner.m_background:setScale(0.5)
        end
    end

    local skill_id = owner:getInterceptableSkillID()
    if (skill_id) then
        -- 스킬 발동
        owner:doAttack(skill_id)

    elseif (owner.m_roamTimer <= 0) then
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
-- function st_dead
-------------------------------------
function Tamer.st_dead(owner, dt)
    if (owner.m_stateTimer == 0) then
        owner:setDead()
    end

    return true
end

-------------------------------------
-- function changeState
-- @param state
-- @param forced
-- @return boolean
-------------------------------------
function Tamer:changeState(state, forced)
    if (state == 'attackDelay') then
        state = 'roam'
    end
    
    local ret = PARENT.changeState(self, state, forced)
    return ret
end

-------------------------------------
-- function getRoamPos
-- @brief 테이머 배회 이동 좌표를 얻음
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

    if (not self.m_bLeftFormation) then
        tar_x = CRITERIA_RESOLUTION_X - tar_x
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

        owner:setAfterImage(true)

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

        -- 테이머 떨어지는 액션
        local action = cc.Sequence:create(
            cc.MoveBy:create(3, cc.p(0, -2000)),
            cc.CallFunc:create(function()
                owner:changeState('dead')
            end)
        )
        owner.m_animator:runAction(action)

        if (owner.m_barrier) then
		    owner.m_barrier:changeAni('disappear', false)
        end
        
        if (owner.m_background) then
            owner.m_background:setVisible(false)
        end
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
        local add_speed = math_random(-2, 2) * 100
        owner:setMove(owner.pos.x + 2500, owner.pos.y, 1500 + add_speed)
        owner:setAfterImage(true)
    end
end

-------------------------------------
-- function updateBasicSkillTimer
-------------------------------------
function Tamer:updateBasicSkillTimer(dt)
    PARENT.updateBasicSkillTimer(self, dt)

    local list = self:getSkillIndivisualInfo('indie_time')
    if (list) then
        -- 기획적으로 indie_time스킬은 1개만을 사용하도록 한다.
        local skill_info = table.getFirst(list)

        -- 스킬 정보가 있을 경우 쿨타임 진행 정보를 확인한다.
        if (skill_info) then
            local max = skill_info:getChanceValue()
            local cur = max - skill_info.m_curChanceValue

            local t_event = { ['cur'] = cur, ['max'] = max, ['run_skill'] = (cur == max) }

            if (self.m_bLeftFormation) then
                self:dispatch('hero_tamer_skill_gauge', t_event)
            else
                self:dispatch('enemy_tamer_skill_gauge', t_event)
            end
        end
    end
end

-------------------------------------
-- function setDamage
-------------------------------------
function Tamer:setDamage(attacker, defender, i_x, i_y, damage, t_info)
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
-- function makeAttackDamageInstance
-- @brief
-------------------------------------
function Tamer:makeAttackDamageInstance()
    local activity_carrier = ActivityCarrier()

	-- 시전자를 지정
	activity_carrier:setActivityOwner(self)

    -- 속성 지정
    activity_carrier.m_attribute = ATTR_NONE
    --activity_carrier.m_attribute = attributeStrToNum(self:getAttribute())

    -- 세부 능력치 지정
	--activity_carrier:setStatuses(self.m_statusCalc)
    activity_carrier:setIgnoreDef(true)

    return activity_carrier
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
    local scale = self.m_baseAnimatorScale * (1 - (0.003 * tar_z))
    local scaleX = scale

    if (self.m_animator.m_bFlip) then
        scaleX = -scaleX
    end

    local scale_action = cc.ScaleTo:create(time, scaleX, scale)
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
-- function setMovingAfterImage
-------------------------------------
function Tamer:setMovingAfterImage(b)
    Dragon.setMovingAfterImage(self, b)
end

-------------------------------------
-- function updateMovingAfterImage
-------------------------------------
function Tamer:updateMovingAfterImage(dt)
    Dragon.updateMovingAfterImage(self, dt)
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
-- function getFellowList
-- @brief 어떤 진형이든 항상 아군을 가져온다.
-------------------------------------
function Tamer:getFellowList()
	if (self.m_bLeftFormation) then 
		return self.m_world:getDragonList()
	else
		return self.m_world:getEnemyList()
	end
end

-------------------------------------
-- function getZOrder
-------------------------------------
function Tamer:getZOrder()
    return WORLD_Z_ORDER.TAMER
end

-------------------------------------
-- function getSkillIndicator
-------------------------------------
function Tamer:getSkillIndicator()
    return nil
end