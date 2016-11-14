-------------------------------------
-- class TamerSpeechSystem
-------------------------------------
TamerSpeechSystem = class(IEventListener:getCloneClass(), {
        m_world = 'GameWrold',

        m_tamerAnimator = 'Animator',
        m_speechLabel = 'cc.Label',
     })

-------------------------------------
-- function init
-------------------------------------
function TamerSpeechSystem:init(world, t_tamer)
    self.m_world = world
    
    local ui = world.m_inGameUI

    -- 테이머
    do
        self.m_tamerAnimator = MakeAnimator('res/character/tamer/goni_i/goni_i.spine')
        self.m_tamerAnimator.m_node:setMix('idle', 'summon', 0.1)
        self.m_tamerAnimator.m_node:setMix('summon', 'idle', 0.1)
        self.m_tamerAnimator.m_node:setMix('idle', 'happiness', 0.1)
        self.m_tamerAnimator.m_node:setMix('happiness', 'idle', 0.1)
        self.m_tamerAnimator.m_node:setMix('idle', 'pain', 0.1)
        self.m_tamerAnimator.m_node:setMix('pain', 'idle', 0.1)
        self.m_tamerAnimator.m_node:setMix('happiness', 'pain', 0.1)
        self.m_tamerAnimator.m_node:setMix('pain', 'happiness', 0.1)
        --self.m_tamerAnimator:changeAni('summon', true, true)
        self.m_tamerAnimator:changeAni('idle', true, true)

        --cclog('tamer ani list = ' .. luadump(self.m_tamerAnimator:getVisualList()))
        ui.vars['tamerNode']:addChild(self.m_tamerAnimator.m_node)
    end

    -- 대사
    do
        self.m_speechLabel = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 24, 0, cc.size(340, 100), 1, 1)
        self.m_speechLabel:setAnchorPoint(cc.p(0.5, 0.5))
	    self.m_speechLabel:setDockPoint(cc.p(0, 0))
	    self.m_speechLabel:setColor(cc.c3b(50, 40, 30))
        --self.m_speechLabel:enableShadow(cc.c4b(0,0,0,255), cc.size(-3, 3), 0)

        local socketNode = ui.vars['tamerTalkVisual'].m_node:getSocketNode('talk_label')
        socketNode:addChild(self.m_speechLabel)
    end
end

-------------------------------------
-- function showSpeech
-------------------------------------
function TamerSpeechSystem:showSpeech(msg, ani, loop)
    local loop = loop
    if loop == nil then loop = true end

    local ui = self.m_world.m_inGameUI
    if (not ui.vars['tamerTalkVisual'].m_node:isEndAnimation()) then return end

    -- 대사
    if msg then
        ui.vars['tamerTalkVisual'].m_node:setFrame(0)
        ui.vars['tamerTalkVisual']:setVisible(true)
        ui.vars['tamerTalkVisual']:registerScriptLoopHandler(function()
            ui.vars['tamerTalkVisual']:setVisible(false)

            -- 대사 종료 후 idle 애니메이션으로
            self.m_tamerAnimator:changeAni('idle', true, true)
        end)

        self.m_speechLabel:setString(msg)
    end

    -- 테이머
    local ani = ani or 'idle'
    self.m_tamerAnimator:changeAni(ani, loop, true)

    if not loop then
        self.m_tamerAnimator:addAniHandler(function() self.m_tamerAnimator:changeAni('idle', true) end)
    end
end

-------------------------------------
-- function onEvent
-------------------------------------
function TamerSpeechSystem:onEvent(event_name, ...)

    -- 드래곤 소환 시
    if (event_name == 'dragon_summon') then
        self:showSpeech(nil, 'summon', false)

    -- 게임 시작 시
    elseif (event_name == 'game_start') then
        if (math_random(1, 2) == 1) then
            self:showSpeech(Str('자 시작이다!'), 'idle')
        else
            self:showSpeech(Str('이번에도 잘 부탁해 얘들아!'), 'idle')
        end

    -- 드래곤 사망 5점
    elseif (event_name == 'character_dead') then
        local arg = {...}
        local dragon = arg[1]
        
        self:showSpeech(Str('아.. 안돼 {1}', dragon.m_charTable['t_name']), 'pain')

    -- 웨이브 시작시
    elseif (event_name == 'wave_start') then
        if (math_random(1, 2) == 1) then
            self:showSpeech(Str('곧 전투 시작이야!'), 'idle')
        else
            self:showSpeech(Str('모두 전투 준비!'), 'idle')
        end

    -- 보스 웨이브 시작시
    elseif (event_name == 'boss_wave') then
        if (math_random(1, 2) == 1) then
            self:showSpeech(Str('긴장해! 거대한 녀석이 온다!'), 'idle')
        else
            self:showSpeech(Str('이번엔 모두 조심해야해!'), 'idle')
        end

    -- 스테이지 클리어시
    elseif (event_name == 'stage_clear') then
        self:showSpeech(Str('야호! 모두들 고생했어!'), 'happiness')

    -- 적 스킬로 드래곤 피격시
    elseif (event_name == 'character_damaged_skill') then
        self:showSpeech(Str('큭.. 모두 조심해!'), 'pain')

    -- 드래곤 위기
    elseif (event_name == 'character_weak') then
        local arg = {...}
        local dragon = arg[1]

        if (math_random(1, 2) == 1) then
            self:showSpeech(Str('위험해! {1}', dragon.m_charTable['t_name']), 'pain')
        else
            self:showSpeech(Str('{1} 좀 더 힘내!', dragon.m_charTable['t_name']), 'pain')
        end

    -- 적 스킬 캔슬 시
    elseif (event_name == 'character_casting_cancel') then
        local arg = {...}
        local dragon = arg[1]

        if (math_random(1, 2) == 1) then
            self:showSpeech(Str('잘했어! {1}', dragon.m_charTable['t_name']), 'happiness')
        else
            self:showSpeech(Str('{1} 너무 멋져!', dragon.m_charTable['t_name']), 'happiness')
        end

    -- 스킬 다단히트1
    elseif (event_name == 'skill_combo_1') then
        local arg = {...}
        local dragon = arg[1]

        self:showSpeech(Str('{1} 계속 그렇게 해!', dragon.m_charTable['t_name']), 'happiness')

    -- 스킬 다단히트2
    elseif (event_name == 'skill_combo_2') then
        local arg = {...}
        local dragon = arg[1]

        self:showSpeech(Str('{1}만 믿으면 되겠는걸!', dragon.m_charTable['t_name']), 'happiness')
        
    end
end