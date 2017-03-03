cca = {}

-------------------------------------
-- function widthTo
-- @param node
-- @param duration  지속 시간
-- @param width     변경할 width
-------------------------------------
function cca.widthTo(node, duration, width)
    local curr_width, curr_height = node:getNormalSize()

    local func = function(value)
        node:setNormalSize(value, curr_height)
    end

    local tween = cc.ActionTweenForLua:create(duration, curr_width, width, func)
    return tween
end

-------------------------------------
-- function stopAction
-- @brief 액션을 정지
-------------------------------------
function cca.stopAction(node, stop_action)
    local _action = node:getActionByTag(stop_action)
    if _action then
        node:stopAction(_action)
    end
end

-------------------------------------
-- function runAction
-- @brief 액션을 실행
-------------------------------------
function cca.runAction(node, action, stop_action)
    -- 모든 Action을 중지할 경우
    if (stop_action == true) then
        node:stopAllActions()
    end

    -- 특정 Tag의 Action을 중지할 경우
    local tag = nil
    if (type(stop_action) == 'number') then
        local _action = node:getActionByTag(stop_action)
        if _action then
            node:stopAction(_action)
        end
        tag = stop_action
    end

    if tag then
        action:setTag(tag)
    end

    node:runAction(action)
end

-------------------------------------
-- function reserveFunc
-- @brief 액션을 실행 (일정시간 후 함수 호출)
-------------------------------------
function cca.reserveFunc(node, duration, func)
    local action = cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(func))
    node:runAction(action)
end

-------------------------------------
-- function reserveFuncWithTag
-- @brief 액션을 실행 (일정시간 후 함수 호출)
-------------------------------------
function cca.reserveFuncWithTag(node, duration, func, tag)
    local action = cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(func))
    action:setTag(tag)
    node:runAction(action)
end


-------------------------------------
-- function getRipple3D
-------------------------------------
function cca.getRipple3D(strength, duration)
    local strength = tonumber(strength) or 1
	local length, wave, amp

	if (strength == 1) then 
		length, wave, amp = 128, 16, 128
	elseif (strength == 2) then 
		length, wave, amp = 128, 8, 64
	elseif (strength == 3) then 
		length, wave, amp = 64, 16, 128
	elseif (strength == 4) then 
		length, wave, amp = 16, 8, 64
	elseif (strength == 5) then 
		length, wave, amp = 16, 4, 128
	end

	local scr_size = cc.Director:getInstance():getWinSize()
    return cc.Ripple3D:create(duration, {width = length, height = length}, {x = scr_size.width/2, y = scr_size.height/2}, scr_size.height - 200, wave, amp)
end

-------------------------------------
-- function getShaky3D
-- @strength 클수록 자글자글해진다
-------------------------------------
function cca.getShaky3D(strength, duration)
	local strength = tonumber(strength) or 3
	local length, range
	
	if (strength == 1) then
		length, range = 8, 4 
	elseif (strength == 2) then 
		length, range = 16, 8
	elseif (strength == 3) then 
		length, range = 32, 16 
	elseif (strength == 4) then 
		length, range = 64, 32
	elseif (strength >= 5) then 
		length, range = 128, 64
    else
        error('cca.getShaky3D wrong strength(' .. strength .. ')')
	end

    return cc.Shaky3D:create(duration, {width = length, height = length}, range, false)
end

-------------------------------------
-- function repeatTintTo
-------------------------------------
function cca.repeatTintTo(duration, tar_r, tar_g, tar_b)
	return cc.RepeatForever:create(
		cc.Sequence:create(
			cc.TintTo:create(duration, tar_r, tar_g, tar_b),
			cc.TintTo:create(duration-1, 255, 255, 255)
		)
	)
end

-------------------------------------
-- function repeatTintToMoreDark
-------------------------------------
function cca.repeatTintToMoreDark(duration, tar_r, tar_g, tar_b)
	return cc.RepeatForever:create(
		cc.Sequence:create(
			cc.TintTo:create(duration, tar_r, tar_g, tar_b),
			cc.TintTo:create(duration-1, 200, 200, 200)
		)
	)
end

-------------------------------------
-- function makeBasicEaseMove
-------------------------------------
function cca.makeBasicEaseMove(duration, x, y)
    local move_to = cc.MoveTo:create(duration, cc.p(x, y))
    local action = cc.EaseInOut:create(move_to, 2)
    return action
end

-------------------------------------
-- function uiReaction
-------------------------------------
function cca.uiReaction(node, scale_x, scale_y, action_scale)
    local scale_x = (scale_x or 1)
    local scale_y = (scale_y or scale_x)
    local action_scale = (action_scale or 0.9)

    node:setScale(scale_x * action_scale, scale_y * action_scale)
    local action = cc.EaseElasticOut:create(cc.ScaleTo:create(0.3, scale_x, scale_y), 0.3)
    cca.runAction(node, action, nil)
end

-------------------------------------
-- function uiReactionSlow
-------------------------------------
function cca.uiReactionSlow(node, scale_x, scale_y, action_scale)
    local scale_x = (scale_x or 1)
    local scale_y = (scale_y or scale_x)
    local action_scale = (action_scale or 0.9)

    node:setScale(scale_x * action_scale, scale_y * action_scale)
    local action = cc.EaseElasticOut:create(cc.ScaleTo:create(1, scale_x, scale_y), 0.3)
    cca.runAction(node, action, nil)
end

-------------------------------------
-- function uiPointingAction
-- @brief 손가락 등이 반복적으로 움직이며 특정 물체를 가리키도록 보이는 액션
-- @param direction 움직일 방향 - top_bottom, left_right
-- @param length 움직일 거리
-------------------------------------
function cca.uiPointingAction(node, direction, length)
    local direction = direction or 'top_bottom'
    local length = length or 10
	local time = 0.25
	
	-- 방향에 따른 위치 좌표
	local pos
	if (direction == 'top_bottom') then
		pos = cc.p(o, length)
	elseif (direction == 'left_right') then
		pos = cc.p(length, 0)
	else
		error('cca.uiPointingAction(node, direction, length) : direction 틀림 : ' .. direction)
	end

	-- 액션 선언
	local delay = cc.DelayTime:create(1.0)
	local move = cc.MoveBy:create(time, pos)
    local reverse = cc.EaseInOut:create(move:reverse(), 2.0)
	local sequence = cc.Sequence:create(delay, move, reverse, move, reverse)
	local repeat_forever = cc.RepeatForever:create(sequence)
	
	-- 실행
    cca.runAction(node, repeat_forever, nil)
end

-------------------------------------
-- function buttonShakeAction
-------------------------------------
function cca.buttonShakeAction(level)
    local level = level or 1
    local angle = 5 * level
    
    local start_action = cc.RotateTo:create(0.05, angle)
    local end_action = cc.EaseElasticOut:create(cc.RotateTo:create(0.5 * 2, 0), 0.1)
    local delay = cc.DelayTime:create(0.5)

    local sequence = cc.Sequence:create(delay, start_action, end_action)

    return cc.RepeatForever:create(sequence)
end