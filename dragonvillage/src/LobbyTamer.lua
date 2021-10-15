local PARENT = LobbyCharacter

-------------------------------------
-- class LobbyTamer
-------------------------------------
LobbyTamer = class(PARENT, {
        m_userData = '',
        m_dragon = '',
        m_ui = '',
        m_idleTimer = 'number', -- 5초동안 정지 상태일 때 'pose_1'을 재생
        m_idleMotionCnt = 'number',
     })

LobbyTamer.MOVE_ACTION = 100

-------------------------------------
-- function init
-------------------------------------
function LobbyTamer:init(user_data)
    self.m_userData = user_data
    self.m_idleTimer = 0

    if (user_data.m_lastArenaTier == 'legend') then
        -- Ranker Animator 생성
        self.m_backgroundAnimator = MakeAnimator('res/effect/effect_tamer_ranker_01/effect_tamer_ranker_01.vrp')--AnimatorHelper:makeTamerAnimator(file_name)
        if self.m_backgroundAnimator.m_node then
		    self.m_rootNode:addChild(self.m_backgroundAnimator.m_node, 1)
            self.m_backgroundAnimator.m_node:setPositionX(55)
            self.m_backgroundAnimator.m_node:setPositionY(125)
            self.m_backgroundAnimator.m_node:setScale(1.3)
        end
    end
end

-------------------------------------
-- function initAnimator
-------------------------------------
function LobbyTamer:initAnimator(file_name)
    local curr_animation
    local curr_flip
    if self.m_animator then
        curr_animation = self.m_animator.m_currAnimation
        curr_flip = self.m_animator.m_bFlip
    end

    -- Animator 삭제
    self:releaseAnimator()

    -- Animator 생성
    self.m_animator = MakeAnimator(file_name)--AnimatorHelper:makeTamerAnimator(file_name)
    if self.m_animator.m_node then
		self.m_rootNode:addChild(self.m_animator.m_node, 2)
        self.m_animator.m_node:setPositionY(105)
        self.m_animator.m_node:setScale(1)
        self.m_animator.m_node:setMix('idle', 'move', 0.1)
        self.m_animator.m_node:setMix('move', 'idle', 0.1)

        if curr_animation and curr_flip then
            self.m_animator:changeAni(curr_animation, true)
            self.m_animator:setFlip(curr_flip)
        end
    end
end

-------------------------------------
-- function initState
-- @brief 상태(state)별 동작 함수 추가
-------------------------------------
function LobbyTamer:initState()
    self:addState('idle', LobbyTamer.st_idle, 'idle', true)
    self:addState('move', LobbyTamer.st_move, 'move', true)
end

-------------------------------------
-- function st_idle
-------------------------------------
function LobbyTamer.st_idle(self, dt)
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
function LobbyTamer:getRandomIdleTime()
    local time = math_random(40, 60) / 10
    return time
end

-------------------------------------
-- function st_move
-------------------------------------
LobbyTamer.st_move = LobbyCharacter.st_move

-------------------------------------
-- function onMoveEnd
-------------------------------------
function LobbyTamer:onMoveEnd()
    self:changeState('idle')
    return true
end

-------------------------------------
-- function setMove
-------------------------------------
function LobbyTamer:setMove(x, y, speed)
    PARENT.setMove(self, x, y, speed)
end

-------------------------------------
-- function refresh
-------------------------------------
function LobbyTamer:refresh(struct_user_info)
    self.m_userData = struct_user_info
    -- UI 갱신
    self.m_ui:refreshUI(struct_user_info)
end

-------------------------------------
-- function release
-------------------------------------
function LobbyTamer:release()
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