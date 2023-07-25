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
-- function repeatTintToRuneOpt
-- @brief 룬 강화 시 가능한 옵션 수치 반짝거리는 액션
-------------------------------------
function cca.repeatTintToRuneOpt(duration, tar_r, tar_g, tar_b)
	return cc.RepeatForever:create(
		cc.Sequence:create(
			cc.TintTo:create(duration / 2, 255, 165, 0),
			cc.TintTo:create(duration / 2, tar_r, tar_g, tar_b)
		)
	)
end

-------------------------------------
-- function repeatFadeInOutRuneOpt
-- @brief 룬 강화 시 가능한 옵션 수치 fade in fade out 액션
-------------------------------------
function cca.repeatFadeInOutRuneOpt(duration)
	return cc.RepeatForever:create(
		cc.EaseInOut:create(
            cc.Sequence:create(
			    cc.FadeOut:create(duration / 2),
			    cc.FadeIn:create(duration / 2)
		    )
        , 1.4)
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
function cca.buttonShakeAction(level, delay_time)
    local level = level or 1
    local delay_time = delay_time or 0.5
    local angle = 5 * level
    
    local start_action = cc.RotateTo:create(0.05, angle)
    local end_action = cc.EaseElasticOut:create(cc.RotateTo:create(0.5 * 2, 0), 0.1)
    local delay = cc.DelayTime:create(delay_time)

    local sequence = cc.Sequence:create(delay, start_action, end_action)

    return cc.RepeatForever:create(sequence)
end

-------------------------------------
-- function buttonAppearShakeAction
-------------------------------------
function cca.buttonAppearShakeAction(level, delay_time)
    local level = level or 1
    local delay_time = delay_time or 0.5
    local angle = 5 * level
    
    local start_action = cc.RotateTo:create(0.05, angle)
    local end_action = cc.EaseElasticOut:create(cc.RotateTo:create(0.5 * 2, 0), 0.1)
    local delay = cc.DelayTime:create(delay_time)

    local sequence = cc.Sequence:create(delay, start_action, end_action)

    local move_action = cc.MoveTo:create(0.2, cc.p(0, 0))
    local scale_action = cc.ScaleTo:create(0.5, 0)
    local disappear = cc.Spawn:create(move_action, scale_action)
    

    local r_move_action = cc.MoveTo:create(0.2, cc.p(50, 50))
    local r_scale_action = cc.ScaleTo:create(0.2, 0.5)
    local appear = cc.Spawn:create(r_move_action, r_scale_action)
    
    local seq_action = cc.Sequence:create(sequence, sequence, disappear, sequence, sequence, appear)
    return cc.RepeatForever:create(seq_action)
end

-------------------------------------
-- function uiImpossibleAction
-------------------------------------
function cca.uiImpossibleAction(node, level)
    local level = level or 1
    local angle = 5 * level
    
    local start_action = cc.RotateTo:create(0.05, angle)
    local end_action = cc.EaseElasticOut:create(cc.RotateTo:create(0.5 * 2, 0), 0.1)
    local sequence = cc.Sequence:create(start_action, end_action)

    cca.runAction(node, sequence)
end

-------------------------------------
-- function flash
-- @brief 깜빡깜빡
-------------------------------------
function cca.flash()
    return cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 50), cc.FadeTo:create(0.5, 255)))
end

-------------------------------------
-- function pickMePickMe
-- @brief 나를 골라줘! 하는 느낌의 무한 반복 점프 액션
-------------------------------------
function cca.pickMePickMe(node, move_y)
	local jump_cnt = 3
	local duration = jump_cnt * 0.3
    local move_y = move_y or 50

	local jump_action = cc.JumpBy:create(duration, cc.p(0, 0), move_y, jump_cnt)
	local delay = cc.DelayTime:create(1)
	local sequence = cc.Sequence:create(jump_action, delay)

    cca.runAction(node, cc.RepeatForever:create(sequence))
end

-------------------------------------
-- function pickMeBig
-- @brief 나를 골라줘! 초반에만 세게 점프, 다음부터는 pickMePickMe와 동일, 룬연마 패키지고라에서 사용 중
-------------------------------------
function cca.pickMeBig(node, move_y, ori_y)
	 node:stopAllActions()
     node:setPositionY(ori_y)

    local jump_cnt = 3
	local duration = jump_cnt * 0.3
    local move_y = move_y or 50

    local big_jump_action = cc.JumpBy:create(duration, cc.p(0, 0), move_y*10, 3)

    local callback = cc.CallFunc:create(function()
		cca.pickMePickMe(node, move_y)
	end)

	local jump_action = cc.JumpBy:create(duration, cc.p(0, 0), move_y*3, jump_cnt)
	local delay = cc.DelayTime:create(0.5)
	local sequence = cc.Sequence:create(big_jump_action, delay, callback)

    cca.runAction(node, sequence)
end

-------------------------------------
-- function getBrrrAction
-- @brief 부르르르 떠는 액션
-------------------------------------
function cca.getBrrrAction(cnt)
    local brrr = cc.MoveBy:create(0.05, cc.p(10, 0))
	local sequence_brrr = cc.Sequence:create(brrr, brrr:reverse())

    return cc.Repeat:create(sequence_brrr, cnt)
end

-------------------------------------
-- function getBrrr2Action
-- @brief 부르르르 떠는 액션
-------------------------------------
function cca.getBrrr2Action(node, cnt, amp)
    local func

    func = function ()
        if cnt == 0 then
            return
        end

        local amp = amp or 5
        local x = math_random(0, amp * 2) - amp
        local y = math_random(0, amp * 2) - amp
        
        cnt = cnt - 1
        
        local brrr = cc.MoveBy:create(0.05, cc.p(x, y))
        local sequence_brrr = cc.Sequence:create(brrr, brrr:reverse(), cc.CallFunc:create(func))
        
        node:runAction(sequence_brrr)
    end
    
    node:runAction(cc.CallFunc:create(func))
end

-------------------------------------
-- function repeatScaleInOut
-- @brief 룬 강화 시 가능한 옵션 수치 fade in fade out 액션
-------------------------------------
function cca.repeatScaleInOut(duration, scale_origin ,scale_percent)
    local scale_to = scale_origin * scale_percent
	return cc.RepeatForever:create(
		cc.EaseInOut:create(
            cc.Sequence:create(
			    cc.ScaleTo:create(duration/2, scale_to),
			    cc.ScaleTo:create(duration/2, scale_origin)
		    )
        , 1.4)
	)    
end

-------------------------------------
-- function actGetObject
-- @brief 마이홈에서 재화를 획득하는 모습을 따라한 액션 부르르 떤 후에 베지어 이동
-- @comment 톡 또르르르 부르르르 슈웅
-------------------------------------
function cca.actGetObject(node, height, tar_pos, finish_cb)
    -- 톡 또르르르
    local duration = 0.75
    local toktorrr = cc.Spawn:create(
        cc.EaseBounceOut:create(cc.MoveBy:create(duration, cc.p(0, -height))),
        cc.MoveBy:create(duration, cc.p(height/2, 0))
    )

    -- 느낌을 살리기 위해 잠시 대기
    local delay = cc.DelayTime:create(0.15)

	-- 부르르르
	local repeat_brrr = cca.getBrrrAction(7)

	-- 슈웅
	local pos_x, pos_y = node:getPosition()
           
    pos_x = pos_x + height/2 -- 톡 또르르르 이동에 대한 보정
    pos_y = pos_y + -height

    local dist_x = math_abs(tar_pos.x - pos_x)
    local duration = 0.3 + (dist_x/1280 * 0.5)
    local move_act

    -- 너무 가까우면 직선 이동
    if (dist_x < 200) then
        move_act = cca.makeBasicEaseMove(duration, tar_pos.x, tar_pos.y)

    -- 아니면 베지어 이동
    else
	    local bezier = getBezier(tar_pos.x, tar_pos.y, pos_x, pos_y, 1) -- -1은 아래를 향한 곡선
	    move_act = cc.BezierBy:create(duration, bezier, true)
    end
    
    -- 콜백 추가
    local callback = cc.CallFunc:create(function()
        if (finish_cb) then
            finish_cb()
        end
    end)

    local remove = cc.RemoveSelf:create()

    cca.runAction(node, cc.Sequence:create(toktorrr, delay, repeat_brrr, move_act, callback, remove))
end

-------------------------------------
-- function fadeInDelayOut
-- @brief 
-------------------------------------
function cca.fadeInDelayOut(node, in_time, delay_time, out_time, forever)
	doAllChildren(node, function(child) child:setCascadeOpacityEnabled(true) end)

    node:setOpacity(0)
    local fadein = cc.FadeIn:create(in_time) 
    local delay = cc.DelayTime:create(delay_time)
	local fadeout = cc.FadeOut:create(out_time)

    if (forever) then
        cca.runAction(node, cc.RepeatForever:create(cc.Sequence:create(fadein, delay, fadeout)))
    else
	    cca.runAction(node, cc.Sequence:create(fadein, delay, fadeout))
    end
end

-------------------------------------
-- function fadeOutAndRemoveChild
-- @brief fade out 후에 자식들을 삭제하고 opcity를 원복
-------------------------------------
function cca.fadeOutAndRemoveChild(node, duration)
	doAllChildren(node, function(child) child:setCascadeOpacityEnabled(true) end)

	local fadeout = cc.FadeOut:create(duration)
	local callback = cc.CallFunc:create(function()
		node:removeAllChildren(true)
		node:setOpacity(255)
	end)

	cca.runAction(node, cc.Sequence:create(fadeout, callback))
end

-------------------------------------
-- function fadeOutAndRemoveSelf
-- @brief fade out 후에 자기 자신을 삭제
-------------------------------------
function cca.fadeOutAndRemoveSelf(node, duration)
	local fadeout = cc.FadeOut:create(duration)
	local remove = cc.RemoveSelf:create()

	cca.runAction(node, cc.Sequence:create(fadeout, fadeout))
end

-------------------------------------
-- function scaleOutAndRemoveSelf
-- @brief scale out 후에 자기 자신을 삭제
-------------------------------------
function cca.scaleOutAndRemoveSelf(node, duration)
	local fadeout = cc.ScaleTo:create(duration, 0)
	local remove = cc.RemoveSelf:create()

	cca.runAction(node, cc.Sequence:create(fadeout, fadeout))
end

-------------------------------------
-- function stampShakeAction
-------------------------------------
function cca.stampShakeAction(node, appear_sacle, appear_duration, updown_scale, angle, target_scale)
    local appear_sacle = appear_sacle or 5
    local appear_duration = appear_duration or 0.3
    local updown_scale = updown_scale or 0.05
    local angle = angle or 360 * 2
    local target_scale = target_scale or 1

    node:setScale(appear_sacle)
    node:setOpacity(0)

    local act1 = cc.FadeIn:create(appear_duration)
    local act2 = cc.ScaleTo:create(appear_duration, 1 - updown_scale)
    local rotate = cc.RotateTo:create(appear_duration, angle)
    local act3 = cc.Spawn:create(act1, act2, rotate)
    local act4 = cc.ScaleTo:create(0.1, target_scale + updown_scale)
    local act5 = cc.ScaleTo:create(0.1, target_scale)
    local action = cc.Sequence:create(act3, act4, act5)

    cca.runAction(node, action)
end

-------------------------------------
-- function stampShakeActionLabel
-------------------------------------
function cca.stampShakeActionLabel(node, appear_scale, appear_duration, updown_scale, angle, target_scale)
    local appear_scale = appear_scale or 5
    local appear_duration = appear_duration or 0.3
    local updown_scaleX = updown_scale or 0.05
    local updown_scaleY = updown_scale or 0.05
    local angle = angle or 360 * 2
    local target_scaleX = target_scale or 1
    local target_scaleY = target_scale or 1
    --local scaleRateX, scaleRateY = Translate:getFontScaleRate()
    --updown_scaleX = updown_scaleX * scaleRateX
    --updown_scaleY = updown_scaleY * scaleRateY
    --target_scaleX = target_scaleX * scaleRateX
    --target_scaleY = target_scaleY * scaleRateY

    node:setScale(appear_scale)
    node:setOpacity(0)

    local act1 = cc.FadeIn:create(appear_duration)
    local act2 = cc.ScaleTo:create(appear_duration, (1 - updown_scaleX), (1 - updown_scaleY))
    local rotate = cc.RotateTo:create(appear_duration, angle)
    local act3 = cc.Spawn:create(act1, act2, rotate)
    local act4 = cc.ScaleTo:create(0.1, (target_scaleX + updown_scaleX), (target_scaleY + updown_scaleY))
    local act5 = cc.ScaleTo:create(0.1, target_scaleX, target_scaleY)
    local action = cc.Sequence:create(act3, act4, act5)
    
    cca.runAction(node, action)
end

-------------------------------------
-- function fruitReact
-- @brief 이름을 짓기 힘든데... 친밀도의 과일 등장 액션
-------------------------------------
function cca.fruitReact(node, idx_factor)
	node:setScale(0)

	local i = idx_factor or math_random(6)
	local delay = cc.DelayTime:create((i-1) * 0.025)
	local elastic = cc.EaseElasticOut:create(cc.ScaleTo:create(1, 1, 1), 0.3)
	local action = cc.Sequence:create(delay, elastic)
	cca.runAction(node, action)
end

-------------------------------------
-- function fruitReact_MasterySkillIcon
-- @brief 이름을 짓기 힘든데... 마스터리 스킬 아이콘
-------------------------------------
function cca.fruitReact_MasterySkillIcon(node, idx_factor)
    node:stopAllActions()
	node:setScale(0.5)

	local i = idx_factor or math_random(6)
	local delay = cc.DelayTime:create((i-1) * 0.01)
	local elastic = cc.EaseElasticOut:create(cc.ScaleTo:create(0.6, 1, 1), 0.8)
	local action = cc.Sequence:create(delay, elastic)
	cca.runAction(node, action)
end

-------------------------------------
-- function dropping
-- @brief 떨어져서 바닥에 바운스 하는 액션
-------------------------------------
function cca.dropping(node, move_y, idx)
	local pos_x, pos_y = node:getPosition()
	node:setPositionY(pos_y + move_y)

	local i = idx or math_random(2)
	local delay = cc.DelayTime:create((i-1) * 0.025)
	local bounce = cc.EaseBounceOut:create(cc.MoveBy:create(1, cc.p(0, -move_y)))
	local action = cc.Sequence:create(delay, bounce)

	cca.runAction(node, action)
end

-------------------------------------
-- function filpCard
-- @brief 카드 뒤집기 액션, front, back : cc.Srpite
-------------------------------------
function cca.filpCard(front, back, duration, flip_cnt)
    local flip_cnt = flip_cnt or 1
    local camera = cc.OrbitCamera:create(duration/2, 1, 0, 0, 90 * 1, 0, 0)

    local hide = function()
        front:setVisible(false)
    end

    local func = function()
        local _camera = cc.OrbitCamera:create(duration/2, 1, 0, 270, 90 * 1, 0, 0)

        local _show = function()
            back:setVisible(true)
        end

        local _func = function()
            if (flip_cnt < 1) then
                cca.filpCard(back, front, duration, flip_cnt + 1)
            end
        end
        
        local _action = cc.Sequence:create(cc.CallFunc:create(_show), _camera, cc.CallFunc:create(_func))

        back:runAction(_action)
    end

    local action =  cc.Sequence:create(camera, cc.CallFunc:create(hide), cc.CallFunc:create(func))
    front:runAction(action)
end

-------------------------------------
-- function stampShakeActionLabel_action
-------------------------------------
function cca.stampShakeActionLabel_action(node, appear_scale, appear_duration, updown_scale, angle, target_scale )
    local appear_scale = appear_scale or 5
    local appear_duration = appear_duration or 0.3
    local updown_scaleX = updown_scale or 0.05
    local updown_scaleY = updown_scale or 0.05
    local angle = angle or 360 * 2
    local target_scaleX = target_scale or 1
    local target_scaleY = target_scale or 1
    --local scaleRateX, scaleRateY = Translate:getFontScaleRate()
    --updown_scaleX = updown_scaleX * scaleRateX
    --updown_scaleY = updown_scaleY * scaleRateY
    --target_scaleX = target_scaleX * scaleRateX
    --target_scaleY = target_scaleY * scaleRateY

    node:setScale(appear_scale)
    node:setOpacity(0)

    local act1 = cc.FadeIn:create(appear_duration)
    local act2 = cc.ScaleTo:create(appear_duration, (1 - updown_scaleX), (1 - updown_scaleY))
    local rotate = cc.RotateTo:create(appear_duration, angle)
    local act3 = cc.Spawn:create(act1, act2, rotate)
    local act4 = cc.ScaleTo:create(0.1, (target_scaleX + updown_scaleX), (target_scaleY + updown_scaleY))
    local act5 = cc.ScaleTo:create(0.1, target_scaleX, target_scaleY)
    local action = cc.Sequence:create(act3, act4, act5)
    
    return action
end