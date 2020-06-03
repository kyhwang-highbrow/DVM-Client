-------------------------------------
-- class EffectGuard
-------------------------------------
EffectGuard = class({
    m_rootNode = 'cc.Node',
    m_effectLink = '',

    m_defenderPos = 'Character',
    m_guarderPos = 'Character',
})

-------------------------------------
-- function init
-------------------------------------
function EffectGuard:init(world, res, defender, guarder)
    self.m_defenderPos = defender.pos
    self.m_guarderPos = guarder.pos

    self.m_rootNode = cc.Node:create()
    world:addChild2(self.m_rootNode, DEPTH_GUARD_EFFECT)

    self.m_effectLink = EffectLink(res, 'bar_hit', 'shield_hit', 'barrier_hit', 512, 256, false)
    if (self.m_effectLink) then
        self.m_rootNode:addChild(self.m_effectLink.m_node)
    end

    local duration = 0.5
    local cb_end = function() self:release() end
    
    self.m_rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.CallFunc:create(cb_end), cc.RemoveSelf:create()))
    self.m_rootNode:scheduleUpdateWithPriorityLua(function(dt)
        -- 연결 이펙트 나와 대상의 월드 좌표로 계산하여 조정
        if (self.m_effectLink) then
	        EffectLink_refresh(self.m_effectLink, self.m_defenderPos['x'], self.m_defenderPos['y'], self.m_guarderPos['x'], self.m_guarderPos['y'])
        end
    end, 0)
end

-------------------------------------
-- function release
-------------------------------------
function EffectGuard:release()
    self.m_rootNode:unscheduleUpdate()

    self.m_effectLink:release()
    self.m_effectLink = nil
end


-------------------------------------
-- function MakeEffectGuard
-------------------------------------
function MakeEffectGuard(world, defender, guarder)
    local effect = EffectGuard(world, 'res/effect/effect_damage_reflect/effect_damage_reflect.vrp', defender, guarder)
    return effect
end