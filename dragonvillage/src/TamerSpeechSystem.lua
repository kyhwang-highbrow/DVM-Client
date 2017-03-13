-------------------------------------
-- class TamerSpeechSystem
-------------------------------------
TamerSpeechSystem = class(IEventListener:getCloneClass(), {
        m_world = 'GameWrold',

        m_bLockTamerTalkAni = 'boolean',
        m_tamerAnimator = 'Animator',
        m_speechLabel = 'cc.Label',
        m_speechNode = 'cc.Node',
     })

-------------------------------------
-- function init
-------------------------------------
function TamerSpeechSystem:init(world, t_tamer)
    self.m_world = world

    self.m_bLockTamerTalkAni = false
    
    self:initUI()
end

-------------------------------------
-- function initUI
-------------------------------------
function TamerSpeechSystem:initUI()
    local ui = self.m_world.m_inGameUI

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

        self.m_speechNode = cc.Node:create()
        self.m_speechNode:setScale(0.7)
        self.m_speechNode:setVisible(false)
               
        local socketNode = ui.vars['tamerTalkVisual'].m_node:getSocketNode('talk_label')
        socketNode:addChild(self.m_speechLabel, 1)
        socketNode:addChild(self.m_speechNode, 2)
    end
end

-------------------------------------
-- function showSpeech
-------------------------------------
function TamerSpeechSystem:showSpeech(msg, ani, loop, cbEnd)
    local loop = loop
    if loop == nil then loop = true end

    local ui = self.m_world.m_inGameUI
    if (self.m_bLockTamerTalkAni) then return end

    -- 이미 나왔던 대사일 경우 스킵
    if (msg == self.m_speechLabel:getString()) then return end

    -- 대사
    if (msg) then
        self.m_speechNode:setVisible(false)

        ui.vars['tamerTalkVisual']:setColor(cc.c3b(255, 255, 255))
        ui.vars['tamerTalkVisual']:setVisible(true)
        ui.vars['tamerTalkVisual']:setVisual('ingame_tamer_talk', '01')
        ui.vars['tamerTalkVisual']:addAniHandler(function()
            ui.vars['tamerTalkVisual']:setVisible(false)

            -- 대사 종료 후 idle 애니메이션으로
            self.m_tamerAnimator:changeAni('idle', true, true)

            self.m_bLockTamerTalkAni = false

            if cbEnd then cbEnd() end
        end)

        self.m_speechLabel:setString(msg)

        self.m_bLockTamerTalkAni = true
    end

    -- 테이머
    local ani = ani or 'idle'
    self.m_tamerAnimator:changeAni(ani, loop, true)

    if (not loop) then
        self.m_tamerAnimator:addAniHandler(function() self.m_tamerAnimator:changeAni('idle', true) end)
    end
end

-------------------------------------
-- function showSpeechNode
-------------------------------------
function TamerSpeechSystem:showSpeechNode(ani, loop, cbEnd)
    local ani = ani or 'happiness'
    local loop = loop
    if loop == nil then loop = true end

    local ui = self.m_world.m_inGameUI
    
    -- 대사
    self.m_speechNode:setVisible(true)

    ui.vars['tamerTalkVisual']:setColor(cc.c3b(67, 218, 236))
    ui.vars['tamerTalkVisual']:setVisible(true)
    ui.vars['tamerTalkVisual']:setVisual('ingame_tamer_talk', '01')
    ui.vars['tamerTalkVisual']:addAniHandler(function()
        ui.vars['tamerTalkVisual']:setVisible(false)
        self.m_speechLabel:setVisible(true)

        -- 대사 종료 후 idle 애니메이션으로
        self.m_tamerAnimator:changeAni('idle', true, true)

        self.m_bLockTamerTalkAni = false

        if (cbEnd) then cbEnd() end
    end)
    self.m_speechLabel:setVisible(false)

    self.m_bLockTamerTalkAni = true
    
    -- 테이머
    local ani = ani or 'idle'
    self.m_tamerAnimator:changeAni(ani, loop, true)

    if (not loop) then
        self.m_tamerAnimator:addAniHandler(function() self.m_tamerAnimator:changeAni('idle', true) end)
    end
end

-------------------------------------
-- function showDragonSpeech
-------------------------------------
function TamerSpeechSystem:showDragonSpeech(msg, dragon)
    local ui = self.m_world.m_inGameUI
    if (self.m_bLockTamerTalkAni) then return end

    -- 대사
    if (msg) then
        self.m_speechNode:setVisible(false)

        ui.vars['tamerTalkVisual']:setColor(cc.c3b(255, 255, 255))
        ui.vars['tamerTalkVisual']:setVisible(true)
        ui.vars['tamerTalkVisual']:setVisual('ingame_tamer_talk', '01')
        ui.vars['tamerTalkVisual']:addAniHandler(function()
            ui.vars['tamerTalkVisual']:setVisible(false)

            -- 대사 종료 후 idle 애니메이션으로
            self.m_tamerAnimator:changeAni('idle', true, true)

            if cbEnd then cbEnd() end
        end)

        self.m_speechLabel:setString(msg)
    end

    -- 드래곤
    local t_dragon = TableDragon():get(dragon.m_charTable['did'])
    local dragonAnimator = AnimatorHelper:makeDragonAnimator(t_dragon['res'], dragon.m_tDragonInfo['evolution'], t_dragon['attr'])
    dragonAnimator:setPosition(100, -200)
    dragonAnimator:changeAni('idle', true)
    dragonAnimator:setScale(2)
    ui.vars['tamerNode']:addChild(dragonAnimator.m_node)

    dragonAnimator.m_node:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.2, cc.p(100, 200)),
        cc.DelayTime:create(0.5),
        cc.MoveTo:create(0.1, cc.p(100, -200)),
        cc.RemoveSelf:create()
    ))
        
    --[[
    local ani = ani or 'idle'
    self.m_tamerAnimator:changeAni(ani, loop, true)

    if (not loop) then
        self.m_tamerAnimator:addAniHandler(function() self.m_tamerAnimator:changeAni('idle', true) end)
    end
    ]]--
end

-------------------------------------
-- function onEvent
-------------------------------------
function TamerSpeechSystem:onEvent(event_name, t_event, ...)

    -- 드래곤 소환 시
    if (event_name == 'dragon_summon') then
        self:showSpeech(nil, 'summon', false)

    -- 테이머 액티브 스킬 사용시
    elseif (event_name == 'tamer_skill') then
        self:showSpeechNode('summon', false)        

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
        
        if (not self.m_world:hasFriendHero()) then
            self:showSpeech(Str('아.. 안돼 {1}', dragon.m_charTable['t_name']), 'pain')
        end

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
    
    -- 친구 영웅 등장시    
    elseif (event_name == 'friend_dragon_appear') then
        local arg = {...}
        local dragon = arg[1]

        self:showSpeech(Str('안돼... 도와줘! {1}', dragon.m_charTable['t_name']), 'pain')

    -- 드래곤 터치 스킬 사용시
    elseif (event_name == 'hero_touch_skill') then
        local arg = {...}
        local dragon = arg[1]

        --self:showDragonSpeech(Str('{1}!!', dragon.m_charTable['t_name']), dragon)
        self:showDragonSpeech(nil, dragon)

    end
end