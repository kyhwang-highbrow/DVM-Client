local PARENT = ForestCharacter

-------------------------------------
-- class ForestDragon
-------------------------------------
ForestDragon = class(PARENT, {
        m_dragonID = 'number',
		m_flv = 'number',
        m_structDragon = 'StructDragonObject',

        m_moveTerm = 'number',
        m_moveType = 'string',

        m_talkingNode = 'cc.Node',
     })

ForestDragon.OFFSET_Y = 150
ForestDragon.OFFSET_Y_TOUCH = 300
ForestDragon.OFFSET_Y_MAX = 1000 -- jump의 상한선으로 사용

-------------------------------------
-- function init
-------------------------------------
function ForestDragon:init(struct_dragon_object)
    self.m_objectType = 'dragon'

    self.m_structDragon = struct_dragon_object
    self.m_dragonID = struct_dragon_object:getDid()
	self.m_flv = struct_dragon_object:getFlv()
    
    self.m_moveTerm = (math_random(300, 500)/100)
    self.m_moveType = TableDragonPhrase:getForestMoveType(self.m_dragonID)

    local evolution = struct_dragon_object:getEvolution()
    local res = TableDragon:getDragonRes(self.m_dragonID, evolution)
    self:initAnimator(res)

	-- TalkingNode 생성
	self.m_talkingNode = cc.Node:create()
	self.m_rootNode:addChild(self.m_talkingNode, 2)
end

-------------------------------------
-- function initAnimator
-------------------------------------
function ForestDragon:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeDragonAnimator(file_name)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node, 1)
        self.m_animator:setPositionY(ForestDragon.OFFSET_Y)

		local scale
		if (string.find(file_name, 'common_')) then
			scale = 1
		else
			scale = 0.5
		end
		self.m_animator.m_node:setScale(scale)
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
        local duration = 0.2
        local angle = 30

        -- 액션 생성
        local rotate_1 = cc.RotateTo:create(duration, angle)
        local rotate_2 = cc.RotateTo:create(duration, -angle)
        local sequence = cc.Sequence:create(rotate_1, rotate_2)
        local repeat_action = cc.RepeatForever:create(sequence)
        
        -- 드래곤 좌표를 올려줌
        ani_node:setPositionY(ForestDragon.OFFSET_Y_TOUCH)

        -- run
        local is_stop_action = true
        cca.runAction(ani_node, repeat_action, is_stop_action)
    end

    -- 이벤트 구조체 생성
    local struct_event = StructForestEvent()
    struct_event:setObject(self)
    struct_event:setPosition(self.m_rootNode:getPosition())

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
    struct_event:setPosition(self.m_rootNode:getPosition())

    -- 이동 이벤트 dispatch
    self:dispatch('forest_character_move', struct_event)

    -- 점프 이벤트 dispatch
    self:dispatch('forest_dragon_jump', struct_event)

    self:setForestZOrder()
end

-------------------------------------
-- function onActionEnd
-- @brief 어떤 동작을 한 뒤에 대사 또는 이모티콘을 랜덤하게 출력 한다.
-------------------------------------
function ForestDragon:onActionEnd()
    local case = math_random(0, 1)
    if (case == 0) then
        self:showEmotionEffect()
    else
        self:speechSomething()
    end
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

    if (self.m_state == 'toched') then
        return
    end
    if (self.m_state == 'toched_end') then
        return
    end

    if (self.m_stateTimer > self.m_moveTerm) then
        --self:doRandomAction()
        self:doForestAction()

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
-- function speechSomething
-------------------------------------
function ForestDragon:speechSomething()
	local case_type = 'lobby_'

	-- 감성 말풍선 실동작
	self.m_talkingNode:removeAllChildren()
	SensitivityHelper:doActionBubbleText(self.m_talkingNode, self.m_dragonID, self.m_flv, case_type)
end

-------------------------------------
-- function doRandomAction
-------------------------------------
function ForestDragon:doRandomAction()
    local case = math_random(1, 100)
    
    -- 일반 자유 이동
    if (case < 50) then
        local struct_event = StructForestEvent()
        struct_event:setObject(self)
        struct_event:setPosition(self.m_rootNode:getPosition())

        self:dispatch('forest_dragon_move_free', struct_event)
    
    -- 테이머 접근
    elseif (case < 60) then
        local struct_event = StructForestEvent()
        struct_event:setObject(self)
        struct_event:setPosition(self.m_rootNode:getPosition())

        self:dispatch('forest_dragon_move_tamer', struct_event)

    -- 포즈~
    elseif (case < 80) then
        self:changeState('pose')

    -- 제비돌기
    elseif (case < 90) then
        self:changeState('backflip')

    -- 하늘 점프
    else
        self:changeState('skydive')

    end
    
end

local T_SPEED =
{
    ['slow'] = 100,
    ['normal'] = 200,
    ['fast'] = 400,
}

local T_STUFF =
{
    ['box'] = 'chest',
    ['table'] = 'table',
    ['book'] = 'bookshelf',
    ['water'] = 'well',
    ['nest'] = 'nest',
}

-------------------------------------
-- function doForestAction
-------------------------------------
function ForestDragon:doForestAction()
    local move_type = self.m_moveType
    
    -- 1/3 pose 취함
    if (math_random(1, 3) == 1) then
        self:changeState('pose')
        return
    end

    -- object 타입의 경우 1/2 확률로 자유 이동
    if (string.find(move_type, 'object_')) then
        if (math_random(1, 2) == 1) then
            move_type = 'fly_normal'
        end
    end

    -- 자유 이동
    if (string.find(move_type, 'fly_')) then
        local speed = T_SPEED[string.gsub(move_type, 'fly_', '')]

        local struct_event = StructForestEvent()
        struct_event:setObject(self)
        struct_event:setSpeed(speed)

        self:dispatch('forest_dragon_move_free', struct_event)

    -- 물체 앞에서 이동
    elseif (string.find(move_type, 'object_')) then
        local stuff = T_STUFF[string.gsub(move_type, 'object_', '')]

        local struct_event = StructForestEvent()
        struct_event:setObject(self)
        struct_event:setStuff(stuff)

        self:dispatch('forest_dragon_move_stuff', struct_event)

    -- 정지
    elseif (move_type == 'stop') then
        self:changeState('pose')

    end
end
