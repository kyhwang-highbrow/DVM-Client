local GAME_FEVER_STATE_CHARGING = 0
local GAME_FEVER_STATE_APPEAR   = 1
local GAME_FEVER_STATE_LIVE     = 2

-------------------------------------
-- class GameFever
-------------------------------------
GameFever = class(IEventListener:getCloneClass(), {
        m_world = 'GameWorld',
        m_touchNode = 'cc.Node',
        m_colorLayer = 'cc.LayerColor',

        m_bActive = 'boolean',

        m_activityCarrier = 'ActivityCarrier',

        m_state = 'number', 
        m_stateTimer = 'number',    -- 현재 state를 지속하고 있는 시간(단위:초)

        m_curPoint = 'number',      -- 현재 피버 게이지값
        m_realPoint = 'number',     -- 실제 피버 게이지값
        m_stepPoint = 'number',     -- 매프레임마다의 피버 게이지값 변화량

        m_tAttackOrder = 'table',   -- 아군 공격 순서

        -- UI
        m_feverNode = '',
        m_feverLabel = '',
        m_feverStartVisual = '',
        m_feverIdleVisual = '',
        m_feverTutVisual = '',
        m_skillCancelVisual = '',

        m_notiLabel1 = 'cc.Label',
        m_notiLabel2 = 'cc.Label',
     })

-------------------------------------
-- function init
-------------------------------------
function GameFever:init(world)
    self.m_world = world
    self.m_bActive = false

    self.m_touchNode = cc.Node:create()
    self.m_touchNode:setVisible(self.m_bActive)
    world.m_worldLayer:addChild(self.m_touchNode)

    self:makeTouchLayer(self.m_touchNode)
    
    -- 암전
    self.m_colorLayer = cc.LayerColor:create()
    self.m_colorLayer:setColor(cc.c3b(0, 0, 0))
    self.m_colorLayer:setOpacity(100)
    self.m_colorLayer:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_colorLayer:setDockPoint(cc.p(0, 0.5))
    self.m_colorLayer:setNormalSize(4000, 2000)
    self.m_colorLayer:setVisible(false)
    world.m_bgNode:addChild(self.m_colorLayer, 1)
    
    -- 집중선 비주얼
    local bgVisual = MakeAnimator('res/effect/effect_fever/effect_fever.vrp')
    bgVisual:changeAni('idle', true)
    bgVisual:setPosition((CRITERIA_RESOLUTION_X / 2), 0)
    self.m_touchNode:addChild(bgVisual.m_node)
    
    self.m_state = GAME_FEVER_STATE_CHARGING
    self.m_stateTimer = 0

    self.m_curPoint = 0
    self.m_realPoint = 0
    self.m_stepPoint = 0
    
    self.m_tAttackOrder = {}

    self:initUI()
end


-------------------------------------
-- function initUI
-------------------------------------
function GameFever:initUI()
    local ui = self.m_world.m_inGameUI

    self.m_feverNode = ui.vars['feverNode']
    self.m_feverLabel = ui.vars['feverLabel']
    self.m_feverStartVisual = ui.vars['feverStartVisual']
    self.m_feverIdleVisual = ui.vars['feverIdleVisual']
    self.m_feverTutVisual = ui.vars['feverTutVisual']
    self.m_skillCancelVisual = ui.vars['skillCancelVisual']
    
    -- 이미지 폰트 생성
    self.m_feverLabel:setVisible(false)
    self.m_feverLabel = cc.Label:createWithBMFont('res/font/fever_gauge.fnt', tostring(999))
    self.m_feverLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.m_feverLabel:setDockPoint(cc.p(0.5, 0.5))
    self.m_feverLabel:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    self.m_feverLabel:setAdditionalKerning(0)
    self.m_feverLabel:setPosition(0, 14)
    self.m_feverNode:addChild(self.m_feverLabel)
    

    -- 피버 포인트 추가 알림을 위한 라벨 생성
    self.m_notiLabel1 = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 34, 3, cc.size(400, 100), 1, 1)
    self.m_notiLabel2 = cc.Label:createWithTTF('', 'res/font/common_font_01.ttf', 40, 3, cc.size(400, 100), 1, 1)
    self.m_notiLabel1:setColor(cc.c3b(255,246,0))
    self.m_notiLabel1:setStrokeType(0)
    self.m_notiLabel1:setStrokeDetailLevel(0)
    self.m_notiLabel1:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -4), 0)
    self.m_notiLabel1:enableOutline(cc.c4b(0, 0, 0, 255), 3)
    self.m_notiLabel1:setSharpTextInCustomStroke(true)
    self.m_notiLabel2:setColor(cc.c3b(255,246,0))
    self.m_notiLabel2:setStrokeType(0)
    self.m_notiLabel2:setStrokeDetailLevel(0)
    self.m_notiLabel2:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -4), 0)
    self.m_notiLabel2:enableOutline(cc.c4b(0, 0, 0, 255), 3)
    self.m_notiLabel2:setSharpTextInCustomStroke(true)

    local socketNode1 = self.m_skillCancelVisual.m_node:getSocketNode('skill_cancel_01')
    socketNode1:addChild(self.m_notiLabel1)
    local socketNode2 = self.m_skillCancelVisual.m_node:getSocketNode('skill_cancel_02')
    socketNode2:addChild(self.m_notiLabel2)

    self.m_feverNode:setVisible(false)
    self.m_feverTutVisual:setVisible(false)
    self.m_feverTutVisual:setRepeat(true)
    self.m_skillCancelVisual:setVisible(false)
end

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function GameFever:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchAllAtOnce:create()
    listener:registerScriptHandler(function(t,e) return self:onTouches(t,e,cc.Handler.EVENT_TOUCHES_BEGAN) end, cc.Handler.EVENT_TOUCHES_BEGAN )
	listener:registerScriptHandler(function(t,e) return self:onTouches(t,e,cc.Handler.EVENT_TOUCHES_MOVED) end, cc.Handler.EVENT_TOUCHES_MOVED )
	listener:registerScriptHandler(function(t,e) return self:onTouches(t,e,cc.Handler.EVENT_TOUCHES_ENDED) end, cc.Handler.EVENT_TOUCHES_ENDED )
	listener:registerScriptHandler(function(t,e) return self:onTouches(t,e,cc.Handler.EVENT_TOUCHES_CANCELLED) end, cc.Handler.EVENT_TOUCHES_CANCELLED )
                
    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouches
-------------------------------------
function GameFever:onTouches(touches, event, type)
    if (self.m_state ~= GAME_FEVER_STATE_LIVE) then return false end

    if type == cc.Handler.EVENT_TOUCHES_BEGAN then
		self:doAttack()
        return true
		
	end

    return false
end

-------------------------------------
-- function update
-------------------------------------
function GameFever:update(dt)
    if (self.m_stateTimer == -1) then
        self.m_stateTimer = 0
    else
        self.m_stateTimer = self.m_stateTimer + dt
    end

    if (self.m_state == GAME_FEVER_STATE_CHARGING) then
        self:update_charging(dt)
        
    elseif (self.m_state == GAME_FEVER_STATE_APPEAR) then
        self:update_appear(dt)

    elseif (self.m_state == GAME_FEVER_STATE_LIVE) then
        self:update_live(dt)

    end

    self.m_colorLayer:setVisible(self.m_bActive)
    --self.m_feverNode:setVisible(self.m_state == GAME_FEVER_STATE_CHARGING or self.m_state == GAME_FEVER_STATE_APPEAR)
    self.m_feverTutVisual:setVisible(self.m_state == GAME_FEVER_STATE_LIVE)
    
    return false
end

-------------------------------------
-- function update_charging
-------------------------------------
function GameFever:update_charging(dt)
    local world = self.m_world

    if (self.m_stateTimer == 0) then
        self.m_feverStartVisual:setVisible(false)
    end

    
    self.m_curPoint = self.m_curPoint + (self.m_stepPoint * dt / FEVER_POINT_UPDATE_TIME)
    if self.m_curPoint >= self.m_realPoint then
        self.m_curPoint = self.m_realPoint
        self.m_stepPoint = 0

        if self.m_curPoint >= 100 then
            world.m_gameState:changeState(GAME_STATE_FIGHT_FEVER)
        end
    end

    self.m_feverLabel:setString(Str('{1}%', math_floor(self.m_curPoint)))
end

-------------------------------------
-- function update_appear
-------------------------------------
function GameFever:update_appear(dt)
    local world = self.m_world

    if (self.m_stateTimer == 0) then
        SoundMgr:playEffect('VOICE', 'vo_tamer_fever')
        SoundMgr:playEffect('EFFECT', 'fever')
        
        -- 피버 모드 시작 연출
        self.m_feverStartVisual:setVisible(true)
        self.m_feverStartVisual:setVisual('fever', 'start')
        self.m_feverStartVisual:registerScriptLoopHandler(function()
            self:changeState(GAME_FEVER_STATE_LIVE)
        end)

        self.m_feverIdleVisual:setVisible(true)
        self.m_feverIdleVisual:setVisual('fever', 'idle_01')
        self.m_feverIdleVisual:setRepeat(false)
        
        -- 버프 이펙트
        for i, dragon in ipairs(world.m_participants) do
            if not dragon.m_bDead then
                dragon:makeFeverEffect()
            end
        end
    end
end

-------------------------------------
-- function update_live
-------------------------------------
function GameFever:update_live(dt)
    local world = self.m_world
    local enemy_count = #world.m_tEnemyList
    local dynamic_wave = #world.m_waveMgr.m_lDynamicWave

    if (self.m_stateTimer == 0) then
        -- 피버 모드 연출
        --self.m_feverNode:setVisible(false)
        self.m_feverStartVisual:setVisible(false)
        self.m_feverIdleVisual:setVisual('fever', 'idle_02')
        self.m_feverIdleVisual:setRepeat(true)
        self.m_feverTutVisual.m_node:setFrame(0)

        -- 피버 모드 터치 입력 활성화
        self.m_touchNode:setVisible(self.m_bActive)
    end

    -- 적이 모두 죽었거나 제한시간이 다 되었을 경우 종료 처리
    if (enemy_count <= 0) and (dynamic_wave <= 0) then
        self:onEnd()

    elseif (self.m_stateTimer >= FEVER_KEEP_TIME) then
        self:onEnd()
    end
end

-------------------------------------
-- function onStart
-------------------------------------
function GameFever:onStart()
    self.m_bActive = true

    self.m_curPoint = 0
    self.m_realPoint = 0
    self.m_stepPoint = 0

    self.m_tAttackOrder = {}
    
    self:changeState(GAME_FEVER_STATE_APPEAR)
end

-------------------------------------
-- function onEnd
-------------------------------------
function GameFever:onEnd()
    self.m_bActive = false

    self.m_touchNode:setVisible(self.m_bActive)

    -- 버프 이펙트 해제
    for i, hero in ipairs(self.m_world.m_participants) do
        if not hero.m_bDead then
            hero:removeFeverEffect()

            hero.m_animator:setTimeScale(1)
            hero.m_animator:changeAni('idle', true)
        end
    end
    
    self:changeState(GAME_FEVER_STATE_CHARGING)
    self.m_world.m_gameState:changeState(GAME_STATE_FIGHT)

    self.m_feverLabel:setString(Str('{1}%', math_floor(self.m_curPoint)))
end

-------------------------------------
-- function doAttack
-------------------------------------
function GameFever:doAttack()
    local world = self.m_world

	ShakeDir2(math_random(100, 300), math_random(100, 300))

    --local hero = world.m_participants[math_random(1, #world.m_participants)]
    local hero = self:getRandomHero()
    if not hero then return end

    hero.m_animator:setTimeScale(3)
    hero.m_animator:changeAni('attack', false)
    hero.m_animator:addAniHandler(function()
        hero.m_animator:setTimeScale(1)
        hero.m_animator:changeAni('idle', true)
    end)

    -- 랜덤한 적군을 선택
    local enemy = world.m_rightFormationMgr.m_globalCharList[math_random(1, #world.m_rightFormationMgr.m_globalCharList)]
    if not enemy then return end

    -- 데미지 설정
    self.m_activityCarrier = hero:makeAttackDamageInstance()
    self.m_activityCarrier.m_attackType = 'fever'
    self.m_activityCarrier.m_bIgnoreDef = true
    self.m_activityCarrier.m_attribute = ATTR_NONE
    self.m_activityCarrier.m_skillCoefficient = FEVER_ATTACK_DAMAGE_RATE or 1

    -- 공격
    hero:animatorShake()
	hero:runAtkCallback(enemy, enemy.pos.x, enemy.pos.y)
	enemy:runDefCallback(self, enemy.pos.x, enemy.pos.y)

    -- 효과음
    SoundMgr:playEffect('EFFECT', 'fever_touch')

    -- 이펙트
    do
        local t_type = { 'c', 'd', 'u' }

        local attr = getRandomAttr()
        local res = 'res/effect/effect_fever/effect_fever.vrp'
        local type = t_type[math_random(1, #t_type)]
    
        local aniName = string.format('missile_%s_%s', attr, type)

        local animator = MakeAnimator(res)
        animator:changeAni(aniName, false)
        animator:setPosition(0, 0)
        hero.m_rootNode:addChild(animator.m_node)

        local distance = getDistance(hero.pos.x, hero.pos.y, enemy.pos.x, enemy.pos.y)
        animator:setScale(distance / 1440)

        local degree = getDegree(hero.pos.x, hero.pos.y, enemy.pos.x, enemy.pos.y)
        animator:setRotation(degree)
        
        local duration = animator:getDuration()
        animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), cc.RemoveSelf:create()))
    end
end

-------------------------------------
-- function getRandomHero
-- @brief 랜덤한 아군을 선택
-------------------------------------
function GameFever:getRandomHero()
    if #self.m_tAttackOrder == 0 then
        for i, dragon in ipairs(self.m_world.m_participants) do
            if not dragon.m_bDead then
                table.insert(self.m_tAttackOrder, dragon)
            end
        end

        if #self.m_tAttackOrder == 0 then return nil end
        self.m_tAttackOrder = randomShuffle(self.m_tAttackOrder)
    end

    local hero = table.remove(self.m_tAttackOrder, 1)
    if hero and hero.m_bDead then
        hero = self:getRandomHero()
    end

    return hero
end

-------------------------------------
-- function changeState
-------------------------------------
function GameFever:changeState(state)
    local prev_state = self.m_state
    self.m_state = state
    self.m_stateTimer = -1

    if prev_state == GAME_FEVER_STATE_LIVE and state == GAME_FEVER_STATE_CHARGING then
        -- 피버모드 종료시 연출
        self.m_feverIdleVisual:setVisible(true)
        self.m_feverIdleVisual:setVisual('fever', 'idle_03')
        self.m_feverIdleVisual:setRepeat(false)
        self.m_feverIdleVisual:registerScriptLoopHandler(function()
            self.m_feverIdleVisual:setVisible(false)
        end)
    end
end

-------------------------------------
-- function addFeverPoint
-------------------------------------
function GameFever:addFeverPoint(point)
    if self:isActive() then return end

    self.m_realPoint = self.m_realPoint + point
    self.m_realPoint = math_min(self.m_realPoint, 100)

    self.m_stepPoint = self.m_realPoint - self.m_curPoint

    -- 획득시마다 게이지 표시
    self.m_feverNode:setVisible(true)
    self.m_feverNode:runAction(cc.Sequence:create(
        cc.FadeIn:create(0.1),
        cc.DelayTime:create(FEVER_POINT_UPDATE_TIME),
        cc.FadeOut:create(0.5),
        cc.CallFunc:create(function(node) node:setVisible(false) end)
    ))
end

-------------------------------------
-- function showNoti
-------------------------------------
function GameFever:showNoti(point)
    self.m_skillCancelVisual.m_node:setFrame(0)
    self.m_skillCancelVisual:setVisible(true)
    self.m_skillCancelVisual:registerScriptLoopHandler(function()
        self.m_skillCancelVisual:setVisible(false)
    end)

    self.m_notiLabel2:setString(Str('+{1}%', point))

    -- 획득 포인트에 따른 연출
    if point >= PERFECT_SKILL_CANCEL_FEVER_POINT then
        self.m_notiLabel1:setString(Str('완벽한 스킬 취소'))
        self.m_notiLabel1:setColor(cc.c3b(255,246,0))
        self.m_notiLabel2:setColor(cc.c3b(255,246,0))
    elseif point >= GREAT_SKILL_CANCEL_FEVER_POINT then
        self.m_notiLabel1:setString(Str('적절한 스킬 취소'))
        self.m_notiLabel1:setColor(cc.c3b(0,222,255))
        self.m_notiLabel2:setColor(cc.c3b(0,222,255))
    else
        self.m_notiLabel1:setString(Str('스킬 취소'))
        self.m_notiLabel1:setColor(cc.c3b(255,255,255))
        self.m_notiLabel2:setColor(cc.c3b(255,255,255))
    end
end

-------------------------------------
-- function isActive
-------------------------------------
function GameFever:isActive()
    return self.m_bActive
end

-------------------------------------
-- function onEvent
-------------------------------------
function GameFever:onEvent(event_name, ...)
    if (event_name == 'character_casting_cancel') then
        local arg = {...}
        local castingPercentage = arg[2]

        local point = 0

        if castingPercentage >= 90 then     point = PERFECT_SKILL_CANCEL_FEVER_POINT
        elseif castingPercentage >= 70 then point = GREAT_SKILL_CANCEL_FEVER_POINT
        else                                point = GOOD_SKILL_CANCEL_FEVER_POINT
        end

        self:addFeverPoint(point)
        --self:showNoti(point)
    end
end