local PARENT = ForestCharacter

-------------------------------------
-- class ForestTamer
-------------------------------------
ForestTamer = class(PARENT, {
        m_userData = '',
        m_dragon = '',
        m_ui = '',
        m_idleTimer = 'number', -- 5초동안 정지 상태일 때 'pose_1'을 재생
        m_idleMotionCnt = 'number',
     })

-------------------------------------
-- function init
-------------------------------------
function ForestTamer:init(user_data)
    self.m_objectType = 'tamer'

    self.m_userData = user_data
    self.m_idleTimer = 0
end

-------------------------------------
-- function initAnimator
-------------------------------------
function ForestTamer:initAnimator(file_name)
    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = MakeAnimator(file_name)
    if self.m_animator.m_node then
		self.m_rootNode:addChild(self.m_animator.m_node)
        self.m_animator.m_node:setPositionY(105)
        self.m_animator.m_node:setScale(1)
        self.m_animator.m_node:setMix('idle', 'move', 0.1)
        self.m_animator.m_node:setMix('move', 'idle', 0.1)
    end
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function ForestTamer:initState()
    self:addState('idle', ForestTamer.st_idle, 'idle', true)
    self:addState('move', ForestTamer.st_move, 'move', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function ForestTamer.st_idle(self, dt)
    if (self.m_stateTimer == 0) then
        self.m_idleTimer = self:getRandomIdleTime()
        self.m_idleMotionCnt = 0
    end

    if (self.m_idleTimer ~= nil) then
        self.m_idleTimer = (self.m_idleTimer - dt)
        if (self.m_idleTimer <= 0) then
            self.m_idleTimer = nil

            -- idle 중 모션을 몇 번 했는지 체크
            self.m_idleMotionCnt = (self.m_idleMotionCnt + 1)

            if (self.m_idleMotionCnt % 3 == 0) then
                local sum_random = SumRandom()
                sum_random:addItem(1, 'random_1')
                sum_random:addItem(1, 'random_2')
                sum_random:addItem(1, 'random_3')
                local ani_name = sum_random:getRandomValue()
                self.m_animator:changeAni(ani_name, false)
            else
                self.m_animator:changeAni('pose_1', false)
            end
            self.m_animator:addAniHandler(function()
                self.m_animator:changeAni('idle', true)
                self.m_idleTimer = self:getRandomIdleTime()
            end)
        end
    end
end

-------------------------------------
-- function getRandomIdleTime
-------------------------------------
function ForestTamer:getRandomIdleTime()
    local time = math_random(40, 60) / 10
    return time
end

-------------------------------------
-- function st_move
-------------------------------------
ForestTamer.st_move = PARENT.st_move

-------------------------------------
-- function onMoveStart
-------------------------------------
function ForestTamer:onMoveStart()
    self:dispatch('forest_tamer_move_start')
end

-------------------------------------
-- function onMoveEnd
-------------------------------------
function ForestTamer:onMoveEnd()
    self:dispatch('forest_tamer_move_end')
end

-------------------------------------
-- function refresh
-------------------------------------
function ForestTamer:refresh(struct_user_info)
    self.m_userData = struct_user_info
    -- UI 갱신
    self.m_ui:refreshUI(struct_user_info)
end

-------------------------------------
-- function release
-------------------------------------
function ForestTamer:release()
    if self.m_dragon then
        self.m_dragon:release()
        self.m_dragon = nil
    end

    if self.m_ui then
        self.m_ui:release()
        self.m_ui = nil
    end

    PARENT.release(self)
end




-------------------------------------
-- function onEvent
-------------------------------------
function ForestTamer:onEvent(event_name, t_event, ...)
    cclog('TAMER ## ' .. event_name)
end
