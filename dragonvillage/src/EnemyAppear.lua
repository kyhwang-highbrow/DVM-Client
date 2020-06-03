EnemyAppear = {}

-------------------------------------
-- function MoveTo
-------------------------------------
function EnemyAppear.MoveTo(owner, luaValue1, luaValue2, luaValue3)
    
    -- m_luaValue1 출발 위치
    -- m_luaValue2 도착 위치
    -- m_luaValue3 속도
    local pos1 = getWorldEnemyPos(owner, luaValue1)
    local pos2 = getWorldEnemyPos(owner, luaValue2)
    local speed = luaValue3 or 500

    -- 출발 위치 지정
    owner:setPosition(pos1.x, pos1.y)

    -- 마지막 액션(Enemy를 사라지게함)
    local finish_action = cc.CallFunc:create(function() owner:changeState('dying') end)

    -- 거리를 계산하여 action의 duration을 구함
    local distance = getDistance(pos1.x, pos1.y, pos2.x, pos2.y)
    local duration = distance / speed 

    -- 액션 생성
    local action = cc.MoveTo:create(duration, cc.p(pos2.x, pos2.y))
    local sequence = cc.Sequence:create(action, finish_action)

    -- 액션 실행
    owner.m_rootNode:runAction(sequence)
end




-------------------------------------
-- function BezierTo_a
-------------------------------------
function EnemyAppear.BezierTo_a(owner, luaValue1, luaValue2, luaValue3)
    
    -- m_luaValue1 출발 위치
    -- m_luaValue2 도착 위치
    -- m_luaValue3 속도
    local pos1 = getWorldEnemyPos(owner, luaValue1)
    local pos2 = getWorldEnemyPos(owner, luaValue2)
    local speed = luaValue3 or 500

    -- 출발 위치 지정
    owner:setPosition(pos1.x, pos1.y)

    -- 마지막 액션(Enemy를 사라지게함)
    local finish_action = cc.CallFunc:create(function() owner:changeState('dying') end)

    -- 거리를 계산하여 action의 duration을 구함
    local distance = getDistance(pos1.x, pos1.y, pos2.x, pos2.y)
    local duration = distance / speed 

    -- 베지어 데이터
    local center_x = (pos1.x+pos2.x)/2
    local center_y = (pos1.y+pos2.y)/2
    
    local curveConstant = 200 * 2
    local curveCoefficient = (pos1.y - pos2.y) / (pos1.x - pos2.x)
    
    local bezier1 = {
        cc.p(center_x + curveConstant, center_y + (curveConstant * curveCoefficient)),
        cc.p(pos2.x, pos2.y),
        cc.p(pos2.x, pos2.y),
    }
    
    -- 액션 생성
    local action = cc.BezierTo:create(duration, bezier1)
    local sequence = cc.Sequence:create(action, finish_action)

    -- 액션 실행
    owner.m_rootNode:runAction(sequence)
end



-------------------------------------
-- function BezierTo_b
-------------------------------------
function EnemyAppear.BezierTo_b(owner, luaValue1, luaValue2, luaValue3)
    
    -- m_luaValue1 출발 위치
    -- m_luaValue2 도착 위치
    -- m_luaValue3 속도
    local pos1 = getWorldEnemyPos(owner, luaValue1)
    local pos2 = getWorldEnemyPos(owner, luaValue2)
    local speed = luaValue3 or 500

    -- 출발 위치 지정
    owner:setPosition(pos1.x, pos1.y)

    -- 마지막 액션(Enemy를 사라지게함)
    local finish_action = cc.CallFunc:create(function() owner:changeState('dying') end)

    -- 거리를 계산하여 action의 duration을 구함
    local distance = getDistance(pos1.x, pos1.y, pos2.x, pos2.y)
    local duration = distance / speed 

    -- 베지어 데이터
    local center_x = (pos1.x+pos2.x)/2
    local center_y = (pos1.y+pos2.y)/2
    
    local curveConstant = -200 * 4
    local curveCoefficient = (pos1.y - pos2.y) / (pos1.x - pos2.x)
    
    local bezier1 = {
        cc.p(center_x + curveConstant, center_y - (curveConstant * curveCoefficient)),
        cc.p(pos2.x, pos2.y),
        cc.p(pos2.x, pos2.y),
    }
    
    -- 액션 생성
    local action = cc.BezierTo:create(duration, bezier1)
    local sequence = cc.Sequence:create(action, finish_action)

    -- 액션 실행
    owner.m_rootNode:runAction(sequence)
end

-------------------------------------
-- function Basic
-- @brief 등장 후 죽을때까지 전투
-- @param value1 = 출발 위치
-- @param value2 = 도착 위치
-- @prarm value3 = 등장 시간(duration)
-------------------------------------
function EnemyAppear.Basic(owner, luaValue1, luaValue2, luaValue3)
    -- m_luaValue1 출발 위치
    -- m_luaValue2 도착 위치
    -- m_luaValue3 등장 시간
    local pos1 = getWorldEnemyPos(owner, luaValue1)
    local pos2 = getWorldEnemyPos(owner, luaValue2)
    local duration = luaValue3 or 1

    -- 출발 위치 지정
    owner:setOrgHomePos(pos2.x, pos2.y)
    owner:setHomePos(pos2.x, pos2.y)
    owner:setPosition(pos1.x, pos1.y)
    owner:changeState('move')
	
    -- 마지막 액션(Enemy를 공격상태로 변경)
    local finish_action = cc.CallFunc:create(function()
        owner:changeState('idle')
        owner:setPosition(pos2.x, pos2.y)

        owner:dispatch('enemy_appear_done', {}, owner)
    end)    

    -- 액션 생성
    local action = cc.MoveTo:create(duration, cc.p(pos2.x, pos2.y))
    local ease_in = cc.EaseIn:create(action, 0.8)
    local sequence = cc.Sequence:create(ease_in, finish_action)

    -- 액션 실행
    owner.m_rootNode:runAction(sequence)
end

-------------------------------------
-- function Basic2
-- @brief 등장 후 죽을때까지 전투 + 등장시 등장 이펙트 추가
-- @param value1 = 출발 위치
-- @param value2 = 도착 위치
-- @prarm value3 = 등장 시간(duration)
-------------------------------------
function EnemyAppear.Basic2(owner, luaValue1, luaValue2, luaValue3)
    -- m_luaValue1 출발 위치
    -- m_luaValue2 도착 위치
    -- m_luaValue3 등장 시간
    local pos1 = getWorldEnemyPos(owner, luaValue1)
    local pos2 = getWorldEnemyPos(owner, luaValue2)
    local duration = luaValue3 or 1

    -- 출발 위치 지정
    owner:setOrgHomePos(pos2.x, pos2.y)
    owner:setHomePos(pos2.x, pos2.y)
    owner:setPosition(pos1.x, pos1.y)

    -- 이펙트 재생 후 AI 동작
    local res = 'res/effect/effect_appear/effect_appear.spine'
    local effect = MakeAnimator(res)
    owner.m_rootNode:addChild(effect.m_node)
    effect:changeAni('idle', false)
    local effect_duration = effect:getDuration()

    -- 마지막 액션(Enemy를 공격상태로 변경)
    local finish_action = cc.CallFunc:create(function()
        owner:changeState('idle')
        owner:setPosition(pos2.x, pos2.y)
        effect:release()

        owner:dispatch('enemy_appear_done', {}, owner)
    end)    

    -- 액션 생성
	local delay = cc.DelayTime:create(effect_duration)
    local action = cc.MoveTo:create(duration, cc.p(pos2.x, pos2.y))
    local ease_in = cc.EaseIn:create(action, 0.8)
    local sequence = cc.Sequence:create(delay, ease_in, finish_action)

    -- 액션 실행
    owner.m_rootNode:runAction(sequence)
end

-------------------------------------
-- function AncientRuinDragon
-------------------------------------
function EnemyAppear.AncientRuinDragon(owner, luaValue1, luaValue2, luaValue3)
    -- m_luaValue1 출발 위치
    -- m_luaValue2 도착 위치
    -- m_luaValue3 등장 시간
    local pos1 = getWorldEnemyPos(owner, luaValue1)
    local pos2 = getWorldEnemyPos(owner, luaValue2)
    local duration = luaValue3 or 1
    local world = owner.m_world

    pos1 = {
        x = pos2.x + 2000,
        y = pos2.y
    }

    -- 출발 위치 지정
    owner:setOrgHomePos(pos2.x, pos2.y)
    owner:setHomePos(pos2.x, pos2.y)
    owner:setPosition(pos1.x, pos1.y)
    owner:doAppear(function()
        owner:changeState('idle')
        owner:setPosition(pos2.x, pos2.y)

        owner:dispatch('enemy_appear_done', {}, owner)
    end)

    world.m_mapManager:setSpeed(0)
    world.m_mapManager:setAddMove(pos2.x - pos1.x, 4)
end

-------------------------------------
-- function Burn
-- @brief 등장 후 죽을때까지 전투 + 등장시 등장 이펙트 추가
-- @param value1 = 출발 위치
-- @param value2 = 도착 위치
-- @prarm value3 = 등장 시간(duration)
-------------------------------------
function EnemyAppear.Burn(owner, luaValue1, luaValue2, luaValue3)
    -- m_luaValue1 출발 위치
    -- m_luaValue2 도착 위치
    -- m_luaValue3 등장 시간
    local pos1 = getWorldEnemyPos(owner, luaValue1)
    local pos2 = getWorldEnemyPos(owner, luaValue2)
    local duration = luaValue3 or 1

    -- 출발 위치 지정
    owner:setOrgHomePos(pos2.x, pos2.y)
    owner:setHomePos(pos2.x, pos2.y)
    owner:setPosition(pos1.x, pos1.y)

    -- 이펙트 재생 후 AI 동작
    local res = 'res/effect/effect_burn/effect_burn.vrp'
    local effect = MakeAnimator(res)
    owner.m_rootNode:addChild(effect.m_node)
    effect:changeAni('center_idle', false)
    local effect_duration = effect:getDuration()

    -- 마지막 액션(Enemy를 공격상태로 변경)
    local finish_action = cc.CallFunc:create(function()
        owner:changeState('idle')
        effect:release()
        owner:dispatch('enemy_appear_done', {}, owner)
    end)    

    -- 액션 생성
	local delay = cc.DelayTime:create(effect_duration)
    local action = cc.MoveTo:create(duration, cc.p(pos2.x, pos2.y))
    local ease_in = cc.EaseIn:create(action, 0.8)
    local sequence = cc.Sequence:create(delay, ease_in, finish_action)

    -- 액션 실행
    owner.m_rootNode:runAction(sequence)
end

-------------------------------------
-- function Appear
-- @brief 등장 후 죽을때까지 전투
-- @param value2 = 도착 위치
-------------------------------------
function EnemyAppear.Appear(owner, luaValue1, luaValue2, luaValue3)
    -- m_luaValue2 도착 위치
    local pos2 = getWorldEnemyPos(owner, luaValue2)

    -- 출발 위치 지정
    owner:setOrgHomePos(pos2.x, pos2.y)
    owner:setHomePos(pos2.x, pos2.y)
    owner:setPosition(pos2.x, pos2.y)
    owner:changeState('move')

    -- 이펙트 재생 후 AI 동작
    local res = 'res/effect/effect_appear/effect_appear.spine'
    local effect = MakeAnimator(res)
    owner.m_rootNode:addChild(effect.m_node)
    effect:changeAni('idle', false)
    local duration = effect:getDuration()

    effect:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(function()
        owner:changeState('idle')
        effect:release()

        owner:dispatch('enemy_appear_done', {}, owner)
    end)))
end

-------------------------------------
-- function FadeIn
-- @brief fadein 하며 등장 
-- @param value2 = 도착 위치
-- @prarm value3 = 등장 시간(duration)
-------------------------------------
function EnemyAppear.FadeIn(owner, luaValue1, luaValue2, luaValue3)
    -- m_luaValue2 도착 위치
    local pos2 = getWorldEnemyPos(owner, luaValue2)

    -- 위치 및 알파 세팅
    owner:setOrgHomePos(pos2.x, pos2.y)
    owner:setHomePos(pos2.x, pos2.y)
    owner:setPosition(pos2.x, pos2.y)
	owner.m_animator:setAlpha(0)

	-- 액션
	local fade_in = cc.FadeIn:create(luaValue3)
    local finish_action = cc.CallFunc:create(function()
        owner:changeState('idle')
        owner:dispatch('enemy_appear_done', {}, owner)
    end)    

	owner.m_animator:runAction(cc.Sequence:create(fade_in, finish_action))
end

-------------------------------------
-- function NestDragon
-- @param value1 = 출발 위치
-- @param value2 = 도착 위치
-- @prarm value3 = 등장 시간(duration)
-------------------------------------
function EnemyAppear.NestDragon(owner, luaValue1, luaValue2, luaValue3)
    -- m_luaValue1 출발 위치
    -- m_luaValue2 도착 위치
    -- m_luaValue3 등장 시간
    local pos1 = getWorldEnemyPos(owner, luaValue1)
    local pos2 = getWorldEnemyPos(owner, luaValue2)
    local duration = luaValue3 or 1

    -- 출발 위치 지정
    owner:setOrgHomePos(pos2.x, pos2.y)
    owner:setHomePos(pos2.x, pos2.y)
    owner:setPosition(pos1.x, pos1.y)
    
    local function appearDragon()
        owner:setPosition(pos2.x, pos2.y)

        owner.m_animator:changeAni('startwave_3', false)
        owner.m_animator:addAniHandler(function()
            owner.m_animator:changeAni('idle', true)

            owner:dispatch('enemy_appear_done', {}, owner)
        end)

        --SoundMgr:playEffect('VOICE', 'vo_gdragon_appear')
    end

    owner.m_animator:runAction(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.CallFunc:create(function()
            appearDragon()
        end),
        cc.DelayTime:create(0.6),
        cc.CallFunc:create(function()
            owner.m_world.m_shakeMgr:doShake(50, 50, 1)
        end)
    ))
end

-------------------------------------
-- function NestTree
-- @param value1 = 출발 위치
-- @param value2 = 도착 위치
-- @prarm value3 = 등장 시간(duration)
-------------------------------------
function EnemyAppear.NestTree(owner, luaValue1, luaValue2, luaValue3)
    -- m_luaValue1 출발 위치
    -- m_luaValue2 도착 위치
    -- m_luaValue3 등장 시간
    local pos2 = getWorldEnemyPos(owner, luaValue2)
    local duration = luaValue3 or 1

    -- 출발 위치 지정
    owner:setOrgHomePos(pos2.x, pos2.y)
    owner:setHomePos(pos2.x, pos2.y)
    owner:setPosition(pos2.x, pos2.y)

    owner.m_world:dispatch('nest_tree_appear')

    owner.m_animator:changeAni('boss_appear', false)
    owner.m_animator:addAniHandler(function()
        owner.m_animator:changeAni('idle', true)

        owner:dispatch('enemy_appear_done', {}, owner)
    end)

    owner.m_animator:runAction(cc.Sequence:create(
        cc.DelayTime:create(2.8),
        cc.CallFunc:create(function()
            owner.m_world.m_shakeMgr:doShake(50, 50, 2, false, 0.1)

            --SoundMgr:playEffect('VOICE', 'vo_treant_appear')
        end)
    ))
end

-------------------------------------
-- function SecretGold
-- @param value1 = 출발 위치
-- @param value2 = 도착 위치
-- @prarm value3 = 등장 시간(duration)
-------------------------------------
function EnemyAppear.SecretGold(owner, luaValue1, luaValue2, luaValue3)
    -- m_luaValue1 출발 위치
    -- m_luaValue2 도착 위치
    -- m_luaValue3 등장 시간
    local pos1 = getWorldEnemyPos(owner, luaValue1)
    local pos2 = getWorldEnemyPos(owner, luaValue2)
    local duration = luaValue3 or 1

    -- 출발 위치 지정
    owner:setOrgHomePos(pos2.x, pos2.y)
    owner:setHomePos(pos2.x, pos2.y)
    owner:setPosition(pos1.x, pos1.y)
	
    -- 등장 애니
    owner.m_animator:changeAni('boss_appear', false)
    owner.m_animator:addAniHandler(function()
        owner.m_animator:changeAni('idle', true)
        owner:setPosition(pos2.x, pos2.y)

        owner:dispatch('enemy_appear_done', {}, owner)
    end)


    -- 액션 생성
    local action = cc.EaseIn:create(cc.MoveTo:create(duration, cc.p(pos2.x, pos2.y)), 0.8)
    
    -- 액션 실행
    owner.m_rootNode:runAction(action)
end

-------------------------------------
-- function Colosseum
-- @brief 등장 후 죽을때까지 전투 + 등장시 등장 이펙트 추가
-- @param value1 = 출발 위치
-- @param value2 = 도착 위치
-- @prarm value3 = 등장 시간(duration)
-------------------------------------
function EnemyAppear.Colosseum(owner, luaValue1, luaValue2, luaValue3)
    -- TODO: 콜로세움 등장 연출에 맞춰서 수정
    EnemyAppear.FadeIn(owner, luaValue1, luaValue2, luaValue3)
end