-------------------------------------
-- class ObjectGold
-------------------------------------
ObjectGold = class({
        m_world = 'GameWorld',
        m_animator = 'Animator',
        m_goldIdx = 'number',
        m_bOptained = 'boolean',
     })

-------------------------------------
-- function init
-- @param file_name
-- @param body
-------------------------------------
function ObjectGold:init(world, x, y)
    self.m_world = world
    
    local animator = MakeAnimator('res/item/object_gold/object_gold.spine')
    self.m_animator = animator
    animator:setPosition(x, y)

    local scale = 1.4

    -- 애니메이션 'start'재생 후 'idle' 반복
    animator.m_node:setMix('srart', 'idle', 0.1)
    animator.m_node:setMix('idle', 'srart', 0.1)
    animator:changeAni('srart', false)
    animator:addAniHandler(function() animator:changeAni('idle', true) end)

    -- 시작 시점 크기 30%
    animator:setScale(0.3 * scale)

    -- Action 생성
    local bezier
    if (math_random(1, 2) == 1) then
        bezier = {
            cc.p(x, y),
            cc.p(x + math_random(0, 50), y + math_random(50, 100)),
            cc.p(x + math_random(0, 100), y - math_random(-50, 50))
        }
    else
        bezier = {
            cc.p(x, y),
            cc.p(x - math_random(0, 50), y + math_random(50, 100)),
            cc.p(x - math_random(0, 100), y - math_random(-50, 50))
        }
    end
    local last_pos = bezier[3]

    -- 종료 시점 크기 95% ~ 105%
    local gold_scale = (math_random(95, 105) / 100) * scale
    
    -- 드롭, 딜레이 액션
    local time = math_random(20, 60) / 100
    local spawn1 = cc.Spawn:create(cc.BezierTo:create(time, bezier), cc.ScaleTo:create(time, gold_scale, gold_scale))
    animator:runAction(cc.Sequence:create(spawn1, cc.DelayTime:create(5), cc.CallFunc:create(function() self:action2() end)))

    self.m_bOptained = false
end

-------------------------------------
-- function action2
-------------------------------------
function ObjectGold:action2()

    if self.m_bOptained then
        return
    end

    self.m_world:removeDropGold(self)

    local time_scale = 4

    self.m_animator:changeAni('srart', false)
    local duration = (self.m_animator:getDuration() / time_scale)
    self.m_animator:setTimeScale(time_scale)
    local x, y = self.m_animator.m_node:getPosition()
    self.m_animator:runAction(cc.Sequence:create(cc.MoveTo:create(duration, cc.p(x, y + 100)), cc.RemoveSelf:create()))
    self.m_animator:runAction(cc.FadeOut:create(duration))

    --[[ 테이머 아이콘으로 빨려들어가는 연출은 사용하지 않음
    local x, y = self.m_animator.m_node:getPosition()

    -- 현재 월드의 scale을 얻어옴
    local world_scale = self.m_world.m_worldScale

    -- 절대위치에 scale을 적용
    local tar_x = (CRITERIA_RESOLUTION_X - 40) / world_scale
    local tar_y = -(CRITERIA_RESOLUTION_Y/2 - 40) / world_scale

    local distance = getDistance(x, y, tar_x, tar_y)

    local duration = distance / 1500
    self.m_animator:runAction(cc.Sequence:create(cc.MoveTo:create(duration, cc.p(tar_x, tar_y)), cc.RemoveSelf:create()))
    --]]

    self.m_world:obtainGold(1)
    self.m_bOptained = true
end