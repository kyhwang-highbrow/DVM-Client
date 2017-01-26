local PARENT = TamerSpeechSystem

-------------------------------------
-- class TamerSpeechSystemColosseum
-------------------------------------
TamerSpeechSystemColosseum = class(PARENT, {
    m_enemyTamerAnimator = 'Animator',
     })

-------------------------------------
-- function initUI
-------------------------------------
function TamerSpeechSystemColosseum:initUI()
    TamerSpeechSystem.initUI(self)

    local ui = self.m_world.m_inGameUI
    
    -- 적군 테이머
    do
        self.m_enemyTamerAnimator = MakeAnimator('res/character/tamer/goni_i/goni_i.spine')
        self.m_enemyTamerAnimator.m_node:setMix('idle', 'summon', 0.1)
        self.m_enemyTamerAnimator.m_node:setMix('summon', 'idle', 0.1)
        self.m_enemyTamerAnimator.m_node:setMix('idle', 'happiness', 0.1)
        self.m_enemyTamerAnimator.m_node:setMix('happiness', 'idle', 0.1)
        self.m_enemyTamerAnimator.m_node:setMix('idle', 'pain', 0.1)
        self.m_enemyTamerAnimator.m_node:setMix('pain', 'idle', 0.1)
        self.m_enemyTamerAnimator.m_node:setMix('happiness', 'pain', 0.1)
        self.m_enemyTamerAnimator.m_node:setMix('pain', 'happiness', 0.1)
        --self.m_enemyTamerAnimator:setFlip(true)
        self.m_enemyTamerAnimator:changeAni('idle', true, true)

        ui.vars['tamerNode2']:addChild(self.m_enemyTamerAnimator.m_node)
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function TamerSpeechSystemColosseum:onEvent(event_name, t_event, ...)
    -- 콜로세움에선 대사를 표시하지 않음
end