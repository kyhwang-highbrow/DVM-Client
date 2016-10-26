local PARENT = class(Entity, IEventDispatcher:getCloneTable(), IDragonSkillManager:getCloneTable())

-------------------------------------
-- class Tamer
-------------------------------------
Tamer = class(PARENT, {
		m_charType = 'tamer',
		m_charTable = 'table'
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function Tamer:init(file_name, body, t_charTable, ...)
	self.m_charType = 'tamer'
	self.m_charTable = t_charTable
end

-------------------------------------
-- function initAnimatorTamer
-------------------------------------
function Tamer:initAnimatorTamer(file_name)
    -- Animator 삭제
    if self.m_animator then
        if self.m_animator.m_node then
            self.m_animator.m_node:removeFromParent(true)
            self.m_animator.m_node = nil
        end
        self.m_animator = nil
    end

    -- Animator 생성
    self.m_animator = AnimatorHelper:makeTamerAnimator(file_name)
    if self.m_animator.m_node then
        self.m_rootNode:addChild(self.m_animator.m_node)
    end
end

Tamer.st_dying = PARENT.st_dying
Tamer.st_dead = PARENT.st_dead

-------------------------------------
-- function initState
-------------------------------------
function Tamer:initState()
    self:addState('idle', Tamer.st_idle, 'idle', true)
    
	self:addState('comeback', PARENT.st_comeback, 'idle', true)

    self:addState('dying', Tamer.st_dying, 'idle', false, 9)
    self:addState('dead', Tamer.st_dead, nil, nil, 10)

    -- 테이머만 고유하게 사용
    self:addState('started_directing', Tamer.st_started_directing, 'idle', true) -- move 애니메이션이 없음
    self:addState('started_directing2', Tamer.st_started_directing2, 'summon', false) -- charging

    -- success
    self:addState('success_pose', Hero.st_success_pose, 'pose_1', false)
    self:addState('success_move', Hero.st_success_move, 'idle', true)
end

-------------------------------------
-- function st_started_directing
-------------------------------------
function Tamer.st_started_directing(owner, dt)

    if (owner.m_stateTimer == 0) then

        local start_x = -100
        local start_y = -200
        local end_x = 200
        local speed = 300
        local duration = math_abs(end_x - start_x) / speed

        -- 왼쪽에서 테이머가 등장하여 화면 중앙까지 달려나감 (저공비행)
        owner:setPosition(start_x, start_y)
        owner:setSpeed(0)

        local move_1 = cc.MoveTo:create(duration, cc.p(end_x, start_y))
        local func = cc.CallFunc:create(function() owner:dispatch('tamer_appear') end)
        local func2 = cc.CallFunc:create(function() owner:changeState('started_directing2') end)
		local delay = cc.DelayTime:create(1.0)
        local move_2 = cc.MoveTo:create(duration * 2, cc.p(start_x, start_y))

		-- sequence
        local sequence = cc.Sequence:create(
            cc.EaseInOut:create(move_1, 2),
            func,
            func2,
			delay,
            cc.EaseInOut:create(move_2, 1.5)
			)

        -- 액션 실행
        owner:runAction(sequence)
    else

        -- 위치 동기화
        local x, y = owner.m_rootNode:getPosition()
        if (owner.pos.x ~= x) or (owner.pos.y ~= y) then
            owner:setPosition(x, y)
        end
    end
end

-------------------------------------
-- function st_started_directing2
-------------------------------------
function Tamer.st_started_directing2(owner, dt)

    if (owner.m_stateTimer == 0) then
        SoundMgr:playEffect('EFFECT', 't_ready')

        local func1 = function()
            owner.m_animator:changeAni('summon') -- 'attack1'
        end

        local func2 = function()
            owner:dispatch('tamer_appear_done')
            owner.m_animator:changeAni('idle', true)
        end

        --owner:aniHandlerChain(func1, func2)

        owner:aniHandlerChain(func2)
    end
end
