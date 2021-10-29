local PARENT = ForestCharacter

-------------------------------------
-- class ForestDragon
-------------------------------------
ForestDragon = class(PARENT, {
        -- 드래곤 정보
        m_dragonID = 'number',
		m_flv = 'number',
        m_structDragon = 'StructDragonObject',

        -- 드래곤 행동 제어
        m_moveTerm = 'number',

        -- 대사 관련
        m_talkingNode = 'cc.Node',

        -- 만족도 관련
        m_isHappy = 'bool',
        m_happyAnimator = 'Animator',
     })

ForestDragon.OFFSET_Y = 150
ForestDragon.OFFSET_Y_TOUCH = ForestDragon.OFFSET_Y + 75
ForestDragon.OFFSET_Y_HAPPY = ForestDragon.OFFSET_Y + 150
ForestDragon.OFFSET_Y_MAX = 1000 -- jump의 상한선으로 사용

-------------------------------------
-- local vars
-------------------------------------
local INTERVER_MIN = 900
local INTERVER_MAX = 1500
local L_SPEED = {50, 100, 150}

-------------------------------------
-- function init
-------------------------------------
function ForestDragon:init(struct_dragon_object)
    self.m_objectType = 'dragon'

    -- 드래곤 기본 정보
    self.m_structDragon = struct_dragon_object
    self.m_dragonID = struct_dragon_object:getDid()
	self.m_flv = struct_dragon_object:getFlv()
    
    -- 이동 관련 정보
    self.m_moveTerm = (math_random(INTERVER_MIN, INTERVER_MAX)/100)

    -- 리소스 생성
    local evolution = struct_dragon_object:getEvolution()
    local res = TableDragon:getDragonRes(self.m_dragonID, evolution)
    self:initAnimator(res)

	-- TalkingNode 생성
	self.m_talkingNode = cc.Node:create()
	self.m_rootNode:addChild(self.m_talkingNode, 2)

    self.m_stateTimer = self.m_moveTerm

    -- 만족도 최초 체크
    if (Timer:getServerTime() > self.m_structDragon.happy_at) then
        self.m_isHappy = true
        self:happyFull()
    end
end

-------------------------------------
-- function initAnimator
-------------------------------------
function ForestDragon:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeDragonAnimatorByTransform(self.m_structDragon)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node, 1)
        self.m_animator:setPositionY(ForestDragon.OFFSET_Y)

        -- 드래곤 크기를 줄여준다.
        self.m_animator:setScale(0.5)

        -- 좌우 플립 랜덤
        if (math_random(2) == 1) then
            self.m_animator:setFlip(true)
        end
    end
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function ForestDragon:initState()
    self:addState('idle', ForestDragon.st_idle, 'idle', true)
    self:addState('move', ForestDragon.st_move, 'idle', true)

    self:addState('pose', ForestDragon.st_pose, 'pose_1', true)
    self:addState('backflip', ForestDragon.st_backflip, 'idle', true)
    self:addState('skydive', ForestDragon.st_skydive, 'idle', true)
    
    self:addState('touched', ForestDragon.st_touched, 'idle', true)
    self:addState('touched_end', ForestDragon.st_touched_end, 'idle', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
ForestDragon.st_idle = PARENT.st_idle

-------------------------------------
-- function st_move
-------------------------------------
ForestDragon.st_move = PARENT.st_move

-------------------------------------
-- function st_pose
-------------------------------------
function ForestDragon.st_pose(self, dt)
    if (self.m_stateTimer == 0) then
        self.m_animator:addAniHandler(function()
            self:onActionEnd()
            self:changeState('idle')
        end)
    end
end

-------------------------------------
-- function st_backflip
-- @brief 공중 돌기
-------------------------------------
function ForestDragon.st_backflip(self, dt)
    if (self.m_stateTimer == 0) then
        -- 필요한 변수        
        local ani_node = self.m_animator.m_node
        local cur_x, cur_y = ani_node:getPosition()
        local dt_y = 150
        local duration = 0.5
        local cnt = math_random(3, 5)

        -- 액션 생성
        local jump_up = cca.makeBasicEaseMove(duration, cur_x, cur_y + dt_y)
        local rotate = cc.RotateTo:create(0.2 * cnt, 360 * cnt)
        local jump_down = cca.makeBasicEaseMove(duration, cur_x, cur_y)
        local cb_action = cc.CallFunc:create(function()
            self:onActionEnd()
            self:changeState('idle')
        end)

        local sequence = cc.Sequence:create(jump_up, rotate, jump_down, cb_action)
        
        -- run
        cca.runAction(ani_node, sequence)
    end

    -- 이벤트 구조체 생성
    local struct_event = StructForestEvent()
    struct_event:setObject(self)

    -- 점프 이벤트 dispatch
    self:dispatch('forest_dragon_jump', struct_event)
end

-------------------------------------
-- function st_skydive
-- @brief 공중 점프
-------------------------------------
function ForestDragon.st_skydive(self, dt)
    if (self.m_stateTimer == 0) then
        -- 필요한 변수        
        local ani_node = self.m_animator.m_node
        local cur_x, cur_y = ani_node:getPosition()
        local dt_y = ForestDragon.OFFSET_Y_MAX
        local duration = 0.8

        -- 액션 생성
        local brrr = cca.getBrrrAction(10)
        local jump_up = cca.makeBasicEaseMove(duration, cur_x, cur_y + dt_y)
        local jump_down = cca.makeBasicEaseMove(duration, cur_x, cur_y)
        local cb_action = cc.CallFunc:create(function()
            self:onActionEnd()
            self:changeState('idle')
        end)

        local sequence = cc.Sequence:create(brrr, jump_up, jump_down, cb_action)
        
        -- run
        cca.runAction(ani_node, sequence)
    end

    -- 이벤트 구조체 생성
    local struct_event = StructForestEvent()
    struct_event:setObject(self)

    -- 점프 이벤트 dispatch
    self:dispatch('forest_dragon_jump', struct_event)
end

-------------------------------------
-- function st_touched
-- @brief 드래곤을 집음
-------------------------------------
function ForestDragon.st_touched(self, dt)
    if (self.m_stateTimer == 0) then
        -- 변수 생성
        local ani_node = self.m_animator.m_node

        -- 드래곤 좌표를 올려줌
        local move = cca.makeBasicEaseMove(0.2, 0, ForestDragon.OFFSET_Y_TOUCH)
        
        -- 아둥바둥 실행
        local cb_action = cc.CallFunc:create(function()
            local duration = 0.2
            local angle = 30

            local rotate_1 = cc.RotateTo:create(duration, angle)
            local rotate_2 = cc.RotateTo:create(duration, -angle)
            local sequence = cc.Sequence:create(rotate_1, rotate_2)
            local repeat_action = cc.RepeatForever:create(sequence)

            cca.runAction(ani_node, repeat_action)
        end)

        -- run
        local is_stop_action = true
        cca.runAction(ani_node, cc.Sequence:create(move, cb_action), is_stop_action)
    end

    -- 이벤트 구조체 생성
    local struct_event = StructForestEvent()
    struct_event:setObject(self)
    struct_event:setPosition(self:getPosition())

    -- 이동 이벤트 dispatch
    self:dispatch('forest_character_move', struct_event)

    -- 점프 이벤트 dispatch
    self:dispatch('forest_dragon_jump', struct_event)

    self:setForestZOrder()
end

-------------------------------------
-- function st_touched_end
-- @brief 드래곤을 놓아줌
-------------------------------------
function ForestDragon.st_touched_end(self, dt)
    if (self.m_stateTimer == 0) then
        -- 필요한 변수        
        local ani_node = self.m_animator.m_node
        local cur_x, cur_y = ani_node:getPosition()
        local duration = 0.5

        -- 액션 생성
        local jump_down = cca.makeBasicEaseMove(duration, cur_x, ForestDragon.OFFSET_Y)
        local cb_action = cc.CallFunc:create(function()
            self:onActionEnd()
            self:changeState('idle')
        end)

        local sequence = cc.Sequence:create(jump_down, cb_action)
        
        -- 각도 원상태로 돌림
        ani_node:setRotation(0)

        -- run
        local is_stop_action = true
        cca.runAction(ani_node, sequence, is_stop_action)
    end

    -- 이벤트 구조체 생성
    local struct_event = StructForestEvent()
    struct_event:setObject(self)
    struct_event:setPosition(self:getPosition())

    -- 이동 이벤트 dispatch
    self:dispatch('forest_character_move', struct_event)

    -- 점프 이벤트 dispatch
    self:dispatch('forest_dragon_jump', struct_event)

    self:setForestZOrder()
end

-------------------------------------
-- function onActionEnd
-- @brief 어떤 동작을 한 뒤 랜덤 행동
-------------------------------------
function ForestDragon:onActionEnd() 
    -- 1/3 pose
    if (math_random(1, 3) == 1) then
        self:changeState('pose')
        return
    end

    -- 1/3 backflip
    if (math_random(1, 3) == 1) then
        self:changeState('backflip')
        return
    end

    self:showEmotionEffect()
end

-------------------------------------
-- function onMoveEnd
-------------------------------------
function ForestDragon:onMoveEnd()
    self:onActionEnd()
end

-------------------------------------
-- function update
-------------------------------------
function ForestDragon:update(dt)
	PARENT.update(self, dt)

    if (self.m_state == 'touched') then
        return
    end
    if (self.m_state == 'touched_end') then
        return
    end

    if (self.m_stateTimer > self.m_moveTerm) then
        self:doForestAction()

        -- 만족도 유저에게 보이는게 아니므로 3~5초 정도 간격마다 계산해서 연산량을 줄인다.
        if (not self.m_isHappy) then
            if self.m_structDragon.happy_at then
                if (Timer:getServerTime() > self.m_structDragon.happy_at) then
                    self.m_isHappy = true
                    self:happyFull()
                end
            end
        end

        self.m_stateTimer = self.m_stateTimer - self.m_moveTerm
    end

end

-------------------------------------
-- function onEvent
-------------------------------------
function ForestDragon:onEvent(event_name, t_event, ...)
    cclog('DRAGON ## ' .. event_name)
end

-------------------------------------
-- function happyFull
-- @brief 만족도가 찼을 경우의 연출을 한다.
-------------------------------------
function ForestDragon:happyFull()
    if (not self.m_happyAnimator) then
        local animator = MakeAnimator('res/ui/a2d/dragon_forest/dragon_forest.vrp')
        animator:changeAni('heart_idle', true)
        animator:setPosition(0, ForestDragon.OFFSET_Y_HAPPY)
        self.m_rootNode:addChild(animator.m_node, 3)

        self.m_happyAnimator = animator
    else
        self.m_happyAnimator:changeAni('heart_idle', true)
        self.m_happyAnimator:setVisible(true)
    end
end

-------------------------------------
-- function isHappy
-------------------------------------
function ForestDragon:isHappy()
    return self.m_isHappy
end

-------------------------------------
-- function getHappy
-- @brief 개별 드래곤이 터치되었을 때 만족도가 찼는지 체크를 하여 수령 할 수 있도록 한다.
-------------------------------------
function ForestDragon:getHappy()
    if (not self.m_isHappy) then
        return false
    end

    self.m_isHappy = false

    -- 서버 통신
    local doid = self.m_structDragon['id']
    local curr_happy = ServerData_Forest:getInstance():getHappy()
    local function finish_cb(ret)
        local last_ui = UIManager:getLastUI()
        -- 현재 UI가 UI_Forest가 아니면 리턴
        if (last_ui.m_uiName ~= 'UI_Forest') then return end

        -- 만족도 하트 흡수 연출
        self.m_happyAnimator:changeAni('heart_tap', false)
        self.m_happyAnimator:addAniHandler(function()
            self.m_happyAnimator:setVisible(false)
        end)
        
        SoundMgr:playEffect('SFX', 'sfx_heal')

        -- 드래곤 만족도 연출 이벤트
        local struct_event = StructForestEvent()
        struct_event:setObject(self)
        struct_event:setPosition(self:getPosition())
        struct_event:setHappy(curr_happy)
        struct_event:setResponse(ret)
        self:dispatch('forest_dragon_happy', struct_event)

        -- 하트 회수 후의 행동
        self:changeState('pose')
        self:speakHeart()
    end
    ServerData_Forest:getInstance():request_dragonHappy(doid, finish_cb)
    
    return true
end

-------------------------------------
-- function speakHeart
-------------------------------------
function ForestDragon:speakHeart()
	local case_type = 'forest_heart'

	-- 감성 말풍선 실동작
	self.m_talkingNode:removeAllChildren()
	SensitivityHelper:doActionBubbleText(self.m_talkingNode, self.m_dragonID, self.m_flv, case_type)
end

-------------------------------------
-- function doForestAction
-------------------------------------
function ForestDragon:doForestAction()
    -- 자유 이동
    local speed = table.getRandom(L_SPEED)
    local struct_event = StructForestEvent()
    struct_event:setObject(self)
    struct_event:setPosition(self:getPosition())
    struct_event:setSpeed(speed)
    self:dispatch('forest_dragon_move_free', struct_event)
end


local PARENT_ForestDragon = ForestDragon

-------------------------------------
-- class ForestDragon_Simple
-------------------------------------
ForestDragon_Simple = class(PARENT_ForestDragon, {
     })

-------------------------------------
-- function init
-------------------------------------
function ForestDragon_Simple:init(struct_dragon_object)
    PARENT:init(struct_dragon_object)
    -- 이동 관련 정보
    self.m_moveTerm = (math_random(INTERVER_MIN, INTERVER_MAX)/100) / 3
end

-------------------------------------
-- function update
-- @brief 하트는 보여줄 필요가 없음 
-------------------------------------
function ForestDragon_Simple:update(dt)
	PARENT.update(self, dt)

    if (self.m_state == 'touched') then
        return
    end
    if (self.m_state == 'touched_end') then
        return
    end

    if (self.m_stateTimer > self.m_moveTerm) then
        self:doForestAction()

        self.m_stateTimer = self.m_stateTimer - self.m_moveTerm
    end

end

-------------------------------------
-- function setForestZOrder
-- @brief 
-------------------------------------
function ForestDragon_Simple:setForestZOrder()
    -- DoNothing
end

-------------------------------------
-- function getHappy
-- @brief 
-------------------------------------
function ForestDragon_Simple:getHappy()

end

-------------------------------------
-- function happyFull
-- @brief 만족도가 찼을 경우의 연출을 한다.
-------------------------------------
function ForestDragon_Simple:happyFull()

end