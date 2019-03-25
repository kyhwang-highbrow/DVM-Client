local PARENT = StatusEffect

-------------------------------------
-- class StatusEffect_ClanRaidBoss
-------------------------------------
StatusEffect_ClanRaidBoss = class(PARENT, {
        m_animatorTimer = 'Animator',
    })


-------------------------------------
-- function updateTimer
-------------------------------------
function StatusEffect_ClanRaidBoss:updateTimer(dt)

    -- 2019.03.25 
    -- 클랜던전 보스 '폭주' 스킬에 지속시간 숫자로 표시하는 애니메이션 추가
    -- statuseffect의 m_animator는 본래의 weakpoint 애니메이션
    -- (추가)m_animatorTimer는 스킬 지속시간 숫자로 표시하는 애니메이션

    -- 남은 시간
    if (not self:isInfinity()) then
        local before_sec = math_floor(self.m_latestTimer)
        self.m_latestTimer = self.m_latestTimer - dt
        self.m_latestTimer = math_max(self.m_latestTimer, 0)
        local after_sec = math_floor(self.m_latestTimer)
        
        if (not self.m_animatorTimer) then
            self.m_animatorTimer = MakeAnimator(self.m_res)
            self.m_rootNode:addChild(self.m_animatorTimer.m_node)
        
            local ani_name = string.format('timer_%.2d', after_sec)

            self.m_animatorTimer:changeAni(ani_name, false)
        elseif (after_sec < before_sec) then
            local ani_name = string.format('timer_%.2d', after_sec)
            self.m_animatorTimer:changeAni(ani_name, false)
        end
    end

    -- 트리거 함수별 마지막 호출 이후 지난 시간
    for k, v in pairs(self.m_lTriggerFuncTimer) do
        self.m_lTriggerFuncTimer[k] = v + dt
    end
end
