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

        m_deleteTimer = '',

        m_lTarget = 'table',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function MissileLua:init(file_name, body, ...)
    self.m_deleteTimer = 2
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
        if (not owner.m_beforePosX) then
            owner.m_beforePosX = owner.pos.x
        end
        is_change_pos = true
    end

    if owner.m_beforePosY ~= y then
        if (not owner.m_beforePosY) then
            owner.m_beforePosY = owner.pos.y
        end
        is_change_pos = true
    end

    owner:setPosition(x, y)

    if is_change_pos then
        --local degree = getDegree(owner.m_beforePosX, owner.m_beforePosY, owner.pos.x, owner.pos.y)
        local degree = getDegree(owner.m_beforePosX, owner.m_beforePosY, x, y)
        owner:setRotation(degree)

        owner.m_beforePosX = x
        owner.m_beforePosY = y
    else
        if (owner.m_stateTimer > owner.m_deleteTimer) then
            if (not owner.m_target) then
                owner:changeState('dying')
            end
        end
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
    local bezierForward = cc.BezierBy:create(1, bezier, true)
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
        target_x, target_y = owner.m_target:getCenterPos()
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

    local duration = 0.5
    local loop = 1
    
	local target_x = (pos_x - 640)
    local target_y = (pos_y - 50)
    
    if (owner.m_target) then
        target_x, target_y = owner.m_target:getCenterPos()
    end

	-- table에서 받아오는 값
	local height = owner.m_value1
	local explosion_res = owner.m_value2
	local explosion_size = owner.m_value3
	local delay_time = owner.m_value4

	-- 폭발 콜백
	local cbFunction = cc.CallFunc:create(function()
		-- size 혹은 res 가 없다면 폭발을 시키지 않음
		if (not explosion_size) or (not explosion_res) then
			owner:changeState('dying')
			return 
		end

		-- 리소스가 없는것은 테이블상 오류일 가능성이 크므로 진행
		if (explosion_res == '') then
			explosion_res = nil
		end

		local attr = owner.m_owner:getAttributeForRes()

		local missile = owner.m_world.m_missileFactory:makeInstantMissile(explosion_res, 'center_idle', target_x, target_y, explosion_size, owner, {attr_name = attr})

        -- 스킬 스케일을 시전자와 맞추기
        --if (missile.m_animator and owner.m_owner and owner.m_owner.m_originScale ~= owner.m_owner.m_rootNode:getScale()) then
        --   local scale_rate = owner.m_owner.m_rootNode:getScale() / owner.m_owner.m_originScale * 0.4
        --    missile_scale = missile.m_animator:getScale() * scale_rate
        --    missile.m_animator:setScale(missile_scale)
        --end

		owner:changeState('dying')	
	end)

	local delay_action = cc.DelayTime:create(delay_time)
    local jump_action = cc.JumpTo:create(duration, cc.p(target_x, target_y), height, loop)
    owner.m_rootNode:runAction(cc.Sequence:create(delay_action, jump_action, cbFunction))
end

-------------------------------------
-- function lua_curve
-------------------------------------
function MissileLua.lua_curve(owner)
    local pos_x = owner.pos.x
    local pos_y = owner.pos.y

    
	local target_x = (pos_x - 640)
    local target_y = (pos_y - 50)
    
    if (owner.m_target) then
        target_x, target_y = owner.m_target:getCenterPos()
    end

	-- 받아오는 값
	local height = owner.m_value1
	local jump_duration = owner.m_value2
	local delay_time = owner.m_value3
    local attack_cb_func = owner.m_value5
    local loop = 1

	-- 도착하면 탄을 없앤다
	local cbFunction = cc.CallFunc:create(function()
        if (attack_cb_func) then
            attack_cb_func()
        end

		owner:changeState('dying')	
	end)

	local delay_action = cc.DelayTime:create(delay_time)
    local jump_action = cc.JumpTo:create(jump_duration, cc.p(target_x, target_y), height, loop, true)
    owner.m_rootNode:runAction(cc.Sequence:create(delay_action, jump_action, cbFunction))
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
    
    -- 베지어 곡선 끝난 이후 상대좌표로 직선 운동할 위치
    -- 직선 운동하는 탄막은 베지어 곡선 마지막 두 점의 각도로 이동한다. // 상하 LEAF_STRAIGHT_ANGLE도로 픽스
    local std_dist = 1000
    if (not owner.m_owner.m_bLeftFormation) then
        std_dist = -1000
    end

	local straight_angle = g_constant:get('SKILL', 'LEAF_STRAIGHT_ANGLE')
    local degree = getDegree(pos_x, pos_y, tar_x, tar_y) - (straight_angle * course)
    local rad = math_rad(degree)
    local linear_y = std_dist * math.tan(rad)
    local goForwardPoint = cc.p(std_dist, linear_y)
    
    -- Action List
    local delayTime = cc.DelayTime:create(delay)
    local bezierForward = cc.BezierBy:create(duration, bezier, true)
    local goForward = cc.MoveBy:create(duration, goForwardPoint)
    local finish_action = cc.CallFunc:create(function() owner:changeState('dying') end)
    
    local sequence = cc.Sequence:create(delayTime, bezierForward, goForward, finish_action)
    owner.m_rootNode:runAction(sequence)
end

-------------------------------------
-- function lua_bounce
-------------------------------------
function MissileLua.lua_bounce(owner)
	-- 위치 좌표 및 타겟 좌표 세팅
    local pos_x = owner.pos.x
    local pos_y = owner.pos.y

    local target_x = (pos_x - 640)
    local target_y = (pos_y - 50)
	
	-- 필요한 변수 선언
	local duration = 0.7
	local loop = 1
	local height = owner.m_value1
	local count = 0
	local max_count = math_min(owner.m_value2, #owner.m_lTarget)
	local attr = owner.m_owner:getAttributeForRes()
	local after_effect_res = string.gsub('res/effect/effect_hit_physical_@/effect_hit_physical_@.json', '@', attr)

	-- 바운스 느낌을 살리기 위한 스케일 수치 하드코딩
	local scale_action_duration = 0.05
	local scale_rate_x = 1.25
	local scale_rate_y = 0.25

	-- 공통으로 사용될 액션 미리 정의
	local scale_action = cc.ScaleBy:create(scale_action_duration, scale_rate_x, scale_rate_y)
	local scale_action2 = cc.ScaleBy:create(scale_action_duration, 1/scale_rate_x, 1/scale_rate_y)
	local after_effect = cc.CallFunc:create(function()
        local world = owner.m_owner.m_world
        world:addInstantEffect(after_effect_res, 'idle', target_x, target_y)

        -- 피격 처리
        owner:runAtkCallback(owner.m_target, target_x, target_y)

        owner.m_target:runDefCallback(owner, owner.m_target.pos.x, owner.m_target.pos.y)
	end)

	-- 재귀 호출을 위한 편법
	local doWork
    doWork = function()
		-- 탈출 조건
		if (count >= max_count) or (#owner.m_lTarget == 0) then 
			owner:changeState('dying')
		end

        owner.m_target = table.remove(owner.m_lTarget, 1)

        if (owner.m_target) then
            target_x, target_y = owner.m_target:getCenterPos()

        elseif (count > 0) then
            -- 타겟을 찾지 못하여도 탈출
			owner:changeState('dying')
            return
		end

        local jump_action = cc.JumpTo:create(duration, cc.p(target_x, target_y), height, loop)
		owner.m_rootNode:runAction(cc.Sequence:create(jump_action, after_effect, scale_action, scale_action2, cc.CallFunc:create(doWork)))
        
		count = count + 1
	end
	
	-- START
    doWork()
end

-------------------------------------
-- function lua_arrange_curve
-- @brief 특정 위치로 이동 후 공격 시작하는 곡선탄
-------------------------------------
function MissileLua.lua_arrange_curve(owner)
    local pos_x = owner.pos.x
    local pos_y = owner.pos.y

	local target_x = (pos_x - 640)
    local target_y = (pos_y - 50)

	-- 받아오는 값
	local height = owner.m_value1
	local jump_duration = owner.m_value2
	local delay_time = owner.m_value3
	local arrange_pos = owner.m_value4
	local attack_cb_func = owner.m_value5
    local loop = 1

	-- 초기 액션
	local arrange_action = cc.MoveBy:create(0.1, arrange_pos)
	local delay_action = cc.DelayTime:create(delay_time)

	-- 딜레이후 새롭게 타겟 찾아 공격 액션 실행
	local set_target_function = cc.CallFunc:create(function() 
	    if (owner.m_target) then
            target_x, target_y = owner.m_target:getCenterPos()

		    local jump_action = cc.JumpTo:create(jump_duration, cc.p(target_x, target_y), height, loop, true)
			local after_delay_action = cc.DelayTime:create(0.02)  -- 도착후 바로 삭제하면 충돌인식이 되지않아 임의로 설정
			-- 도착하면 탄을 없앤다
			local cb_function = cc.CallFunc:create(function()
				attack_cb_func()
				owner:changeState('dying')
			end)

			-- 실행
			owner.m_rootNode:runAction(cc.Sequence:create(jump_action, after_delay_action, cb_function))
		end
	end)

	-- 실행
    owner.m_rootNode:runAction(cc.Sequence:create(arrange_action, delay_action, set_target_function))
end

-------------------------------------
-- function MissileLua.lua_arrange_release
-- @brief 특정 위치로 이동 후 공격 시작하는 곡선탄, 동시 발사처리
-------------------------------------

function MissileLua.lua_arrange_release(owner)
    local pos_x = owner.pos.x
    local pos_y = owner.pos.y

	local target_x = (pos_x - 640)
    local target_y = (pos_y - 50)

	-- 받아오는 값
	local height = owner.m_value1
	local jump_duration = owner.m_value2
	local delay_time = owner.m_value3
	local arrange_pos = owner.m_value4
	local attack_cb_func = owner.m_value5
    local loop = 1

	-- 초기 액션
	local arrange_action = cc.MoveBy:create(0.0, arrange_pos)
	local delay_action = cc.DelayTime:create(delay_time)


	-- 딜레이후 새롭게 타겟 찾아 공격 액션 실행
	local set_target_function = cc.CallFunc:create(function() 
	    if (owner.m_target) then
            target_x, target_y = owner.m_target:getCenterPos()

		    local jump_action = cc.JumpTo:create(jump_duration, cc.p(target_x, target_y), height, loop, true)
			local after_delay_action = cc.DelayTime:create(0.02)  -- 도착후 바로 삭제하면 충돌인식이 되지않아 임의로 설정
			-- 도착하면 탄을 없앤다
			local cb_function = cc.CallFunc:create(function()
				attack_cb_func()
				owner:changeState('dying')
			end)

			-- 실행
			owner.m_rootNode:runAction(cc.Sequence:create(jump_action, after_delay_action, cb_function))
		end
	end)

	-- 실행
    owner.m_rootNode:runAction(cc.Sequence:create(arrange_action, delay_action, set_target_function))
end