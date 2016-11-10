-------------------------------------
-- class MissileLua
-------------------------------------
MissileLua = class(Missile, {
        m_beforePosX = '',
        m_beforePosY = '',

        m_value1 = '',
        m_value2 = '',
        m_value3 = '',
        m_value4 = '',
        m_value5 = '',

        m_target = 'Character',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileLua:init(file_name, body, ...)
end

-------------------------------------
-- function initState
-------------------------------------
function MissileLua:initState()
    self:addState('move', MissileLua.st_move, 'move', true)
    self:addState('dying', function(owner, dt) return true end, nil, nil, 10)
    self:changeState('move')
end

-------------------------------------
-- function st_move
-------------------------------------
function MissileLua.st_move(owner, dt)
    local x, y = owner.m_rootNode:getPosition()

    local is_change_pos = false

    if owner.m_beforePosX ~= x then
        owner.m_beforePosX = owner.pos.x
        is_change_pos = true
    end

    if owner.m_beforePosY ~= y then
        owner.m_beforePosY = owner.pos.y
        is_change_pos = true
    end

    owner:setPosition(x, y)

    if is_change_pos then
        local degree = getDegree(owner.m_beforePosX, owner.m_beforePosY, owner.pos.x, owner.pos.y)
        owner:setRotation(degree)
    end
end


-------------------------------------
-- function lua_test1
-------------------------------------
function MissileLua.lua_test1(owner)
    local pos_x = owner.pos.x
    local pos_y = owner.pos.y

    local finish_action = cc.CallFunc:create(function() owner:changeState('dying') end)

    -- 도착하고 싶은 절대 좌표
    local tar_x = 1000
    local tar_y = 0

    
    -- 베지어 액션은 상대좌표를 사용함
    local bezier = {
        cc.p(-100, 100),
        cc.p(500, 0 + 200),
        cc.p(tar_x-pos_x, tar_y-pos_y),
    }
    local bezierForward = cc.BezierBy:create(1, bezier)
    local sequence = cc.Sequence:create(bezierForward, finish_action)
    owner.m_rootNode:runAction(sequence)
end

-------------------------------------
-- function lua_test2
-------------------------------------
function MissileLua.lua_test2(owner)
    local pos_x = owner.pos.x
    local pos_y = owner.pos.y

    local finish_action = cc.CallFunc:create(function() owner:changeState('dying') end)

    -- MoveTo에서는 절대좌표 사용
    local action = cc.MoveTo:create(1, cc.p(pos_x + 600, pos_y + 100))
    local ease_in = cc.EaseIn:create(action, 0.5)

    local action2 = cc.MoveTo:create(1, cc.p(pos_x, pos_y-100))
    local ease_in2 = cc.EaseIn:create(action2, 0.5)

    local action3 = cc.MoveTo:create(1, cc.p(pos_x + 1000, pos_y-100))
    local ease_in3 = cc.EaseIn:create(action3, 0.5)

    local sequence = cc.Sequence:create(ease_in, ease_in2, ease_in3, finish_action)
    owner.m_rootNode:runAction(sequence)
end



-------------------------------------
-- function lua_test3
-- @member m_value1 = target
-------------------------------------
function MissileLua.lua_test3(owner)
    local pos_x = owner.pos.x
    local pos_y = owner.pos.y

    local target = owner.m_value1

    local finish_action = cc.CallFunc:create(function()
        target:undergoAttack(owner, target, target.pos.x, target.pos.y)
        owner:changeState('dying')
    end)

    local target_x = target.pos.x
    local target_y = target.pos.y

    local distance = getDistance(pos_x, pos_y, target_x, target_y)
    local duration = distance / 1000

    -- MoveTo에서는 절대좌표 사용
    local action = cc.MoveTo:create(duration, cc.p(target_x, target_y))
    local ease_in = cc.EaseIn:create(action, 0.5)

    local sequence = cc.Sequence:create(ease_in, finish_action)
    owner.m_rootNode:runAction(sequence)
end

-------------------------------------
-- function lua_bombard
-- @member m_value1 = 폭발 리소스
-------------------------------------
function MissileLua.lua_bombard(owner)
    local pos_x = owner.pos.x
    local pos_y = owner.pos.y

    local duration = 0.7
    local target_x = (pos_x - 640)
    local target_y = (pos_y - 50)
    local hight = 200
    local loop = 1

    if (owner.m_target) then
        target_x = owner.m_target.pos.x
        target_y = owner.m_target.pos.y
    end

    local action = cc.JumpTo:create(duration, cc.p(target_x, target_y), hight, loop)

    local function finish_func()
        local res = owner.m_value1
        local attr_name = attributeNumToStr(owner.m_activityCarrier.m_attribute)
        owner.m_world.m_missileFactory:makeInstantMissile(res, 'idle', target_x, target_y, 150, owner, {attr_name=attr_name})

        owner:changeState('dying')
    end

    local sequence = cc.Sequence:create(action, cc.CallFunc:create(finish_func))
    owner.m_rootNode:runAction(sequence)
end

-------------------------------------
-- function lua_angle
-------------------------------------
function MissileLua.lua_angle(owner)
    local pos_x = owner.pos.x
    local pos_y = owner.pos.y

    local duration = 0.7
    local target_x = (pos_x - 640)
    local target_y = (pos_y - 50)
    
	-- table에서 받아오는 값
	local height = owner.m_value1

	-- 폭발 콜백
	local cbFunction = cc.CallFunc:create(owner.m_value2)

    local loop = 1
    if (owner.m_target) then
        target_x = owner.m_target.m_homePosX
        target_y = owner.m_target.m_homePosY
    end

    local action = cc.JumpTo:create(duration, cc.p(target_x, target_y), height, loop)
    owner.m_rootNode:runAction(cc.Sequence:create(action, cbFunction))
end

-------------------------------------
-- function lua_bezier
-- @param m_value1 = target
-- @param m_value2 = dircetion
-- @param m_value3 = delay
-------------------------------------
function MissileLua.lua_bezier(owner)
    local pos_x = owner['pos']['x']
    local pos_y = owner['pos']['y']

    local target = owner['m_value1']
    local dircetion = owner['m_value2']
    local delay = owner['m_value3']
    local duration = 0.7

    -- 도착하고 싶은 절대 좌표
    local tar_x = target['x']
    local tar_y = target['y']
    
    -- 꺽이는 방향 및 정도
    local course = dircetion == 'top' and 1 or -1
    
    -- 베지어 좌표
    local bezier = getBezier(tar_x, tar_y, pos_x, pos_y, course)
    
    -- 베지어 좌표 마지막 두 점의 각도
	--[[
	local t_bezier_pos = getBezierPosList(tar_x, tar_y, pos_x, pos_y, course)
    local last = t_bezier_pos[#t_bezier_pos]
    local last_1 = t_bezier_pos[#t_bezier_pos-1]
    local last_degree = getDegree(last.x, last.y, last_1.x, last_1.y)
	]]
    -- 베지어 곡선 끝난 이후 상대좌표로 직선 운동할 위치
    -- 직선 운동하는 탄막은 베지어 곡선 마지막 두 점의 각도로 이동한다. // 상하 30도로 픽스
    local std_dist = 1000
    local degree = getDegree(pos_x, pos_y, tar_x, tar_y) + 30 * course
    local rad = math_rad(degree)
    local linear_y = std_dist * math.tan(rad)
    local goForwardPoint = cc.p(std_dist, linear_y)
    
    -- Action List
    local delayTime = cc.DelayTime:create(delay)
    local bezierForward = cc.BezierBy:create(duration, bezier)
    local goForward = cc.MoveBy:create(duration, goForwardPoint)
    local finish_action = cc.CallFunc:create(function() owner:changeState('dying') end)
    
    local sequence = cc.Sequence:create(delayTime, bezierForward, goForward, finish_action)
    owner.m_rootNode:runAction(sequence)
end

-------------------------------------
-- function lua_bounce
-------------------------------------
function MissileLua.lua_bounce(owner)
    local pos_x = owner.pos.x
    local pos_y = owner.pos.y

    local target_x = (pos_x - 640)
    local target_y = (pos_y - 50)
	
	if (owner.m_target) then
        target_x = owner.m_target.m_homePosX
        target_y = owner.m_target.m_homePosY
    end

	local l_target = owner.m_owner.m_world.m_tEnemyList
    
	local duration = 0.7
	local loop = 1
	local height = owner.m_value1
	local count = 2
	local max_count = math_min(owner.m_value2, #l_target)
	
	local scale_action_duration = 0.05
	local scale_rate_x = 1.25
	local scale_rate_y = 0.25

	local scale_action = cc.ScaleBy:create(scale_action_duration, scale_rate_x, scale_rate_y)
	local scale_action2 = cc.ScaleBy:create(scale_action_duration, 1/scale_rate_x, 1/scale_rate_y)

	-- 재귀 호출을 위한 편법
	local cbFunction2 = nil
	local cbFunction = 	cc.CallFunc:create(function()
		-- 탈출 조건
		if (count >= max_count) then 
			owner:changeState('dying')
		end
		if l_target[count] then 
			target_x = l_target[count].m_homePosX
			target_y = l_target[count].m_homePosY
			local jump_action = cc.JumpTo:create(duration, cc.p(target_x, target_y), height, loop)
			owner.m_rootNode:runAction(cc.Sequence:create(jump_action, scale_action, scale_action2, cbFunction2))
		end
		count = count + 1
	end)
	cbFunction2 = cbFunction

	-- START
	local jump_action = cc.JumpTo:create(duration, cc.p(target_x, target_y), height, loop)
	owner.m_rootNode:runAction(cc.Sequence:create(jump_action, scale_action, scale_action2, cbFunction))
end