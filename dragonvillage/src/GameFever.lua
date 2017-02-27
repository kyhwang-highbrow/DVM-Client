local GAME_FEVER_STATE_CHARGING = 0
local GAME_FEVER_STATE_APPEAR   = 1
local GAME_FEVER_STATE_LIVE     = 2

-------------------------------------
-- class GameFever
-------------------------------------
GameFever = class(IEventListener:getCloneClass(), IEventDispatcher:getCloneTable(), {
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

        -- buff effect
        m_lFeverEffect = '',        -- 피버시 아군에게 붙을 이펙트 리스트

        -- UI
        m_feverNode = '',
        m_feverLabel = '',
        m_feverStartVisual = '',
        m_feverIdleVisual = '',
        m_feverTutVisual = '',
        m_skillCancelVisual = '',
        m_feverGaugeEndVisual = '',

        m_feverGauge1 = '',
        m_feverGauge2 = '',

        m_feverGaugeEffect = '',

        m_feverButton1 = '',
        m_feverButton2 = '',

        m_notiLabel1 = 'cc.Label',
        m_notiLabel2 = 'cc.Label',

        m_tMissile = 'table',       -- 아군 * 적군 가지수의 미사일 존재 여부를 저장하기 위한 테이블(최적화를 위함)
     })

-------------------------------------
-- function init
-------------------------------------
function GameFever:init(world)
    self.m_world = world
    self.m_bActive = false

    self.m_touchNode = cc.Node:create()
    self.m_touchNode:setVisible(self.m_bActive)
    world.m_feverNode:addChild(self.m_touchNode)

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
    
    self.m_lFeverEffect = {}

    self.m_tMissile = {}
    
    self:initUI()

    self:addListener('fever_start', self.m_world)
    self:addListener('fever_end', self.m_world)
end


-------------------------------------
-- function initUI
-------------------------------------
function GameFever:initUI()
    local ui = self.m_world.m_inGameUI

    self.m_feverNode = ui.vars['feverNode']
    self.m_feverStartVisual = ui.vars['feverStartVisual']
    self.m_feverIdleVisual = ui.vars['feverIdleVisual']
    self.m_feverTutVisual = ui.vars['feverTutVisual']
    self.m_skillCancelVisual = ui.vars['skillCancelVisual']

    self.m_feverGauge1 = ui.vars['feverGauge']
    self.m_feverGauge2 = ui.vars['feverGauge2']

    self.m_feverButton1 = ui.vars['feverBtn1']
    self.m_feverButton2 = ui.vars['feverBtn2']
    
    -- 이미지 폰트 생성
    do
        self.m_feverLabel = cc.Label:createWithBMFont('res/font/fever_gauge.fnt', '')
        self.m_feverLabel:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_feverLabel:setDockPoint(cc.p(0.5, 0.5))
        self.m_feverLabel:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        self.m_feverLabel:setAdditionalKerning(0)
        self.m_feverLabel:setPosition(0, 14)
        self.m_feverNode:addChild(self.m_feverLabel)
    end

    -- 이펙트 생성
    do
        self.m_feverGaugeEffect = MakeAnimator('res/ui/a2d/ingame_fever/ingame_fever.vrp')
        self.m_feverGaugeEffect:setVisual('fever', 'fever_gauge')
        self.m_feverGaugeEffect:setRepeat(true)
        self.m_feverGaugeEffect:setVisible(false)
                
        self.m_feverGaugeEffect.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_feverGaugeEffect.m_node:setDockPoint(cc.p(0.0, 0.5))

        self.m_feverGauge1:addChild(self.m_feverGaugeEffect.m_node)
    end

    -- 게이지 종료시 비주얼 생성
    do
        self.m_feverGaugeEndVisual = MakeAnimator('res/ui/a2d/ingame_fever/ingame_fever.vrp')
        self.m_feverGaugeEndVisual:setVisual('fever', 'fever_gauge_disappear')
        self.m_feverGaugeEndVisual:setRepeat(false)
        self.m_feverGaugeEndVisual:setVisible(false)

        self.m_feverGaugeEndVisual.m_node:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_feverGaugeEndVisual.m_node:setDockPoint(cc.p(0.5, 0.5))

        --self.m_feverButton1:addChild(self.m_feverGaugeEndVisual.m_node)
        ui.vars['feverMenu']:addChild(self.m_feverGaugeEndVisual.m_node)
    end


    self.m_feverGauge1:setPercentage(0)
    self.m_feverGauge2:setPercentage(0)

    self.m_feverButton1:registerScriptTapHandler(function()
        self:dispatch('fever_start')
    end)
    
        
    --self.m_feverNode:setVisible(true)
    self.m_feverNode:setVisible(false)
    self.m_feverTutVisual:setVisible(false)
    self.m_feverTutVisual:setRepeat(true)
    self.m_skillCancelVisual:setVisible(false)

    self.m_feverGauge1:setVisible(true)
    self.m_feverGauge2:setVisible(false)

    self.m_feverButton1:setVisible(false)
    self.m_feverButton2:setVisible(false)
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

        self.m_feverButton1:setVisible(self.m_curPoint >= 100)
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

        -- 현재 카메라에 따른 위치 변경
        local cameraHomePosX, cameraHomePosY = world.m_gameCamera:getHomePos()
        self.m_touchNode:setPosition(cameraHomePosX, cameraHomePosY)
        self.m_colorLayer:setPosition(cameraHomePosX, cameraHomePosY)
        
        -- 피버 모드 시작 연출
        self.m_feverStartVisual:setVisible(true)
        self.m_feverStartVisual:setVisual('fever', 'start')
        self.m_feverStartVisual:registerScriptLoopHandler(function()
            self:changeState(GAME_FEVER_STATE_LIVE)
        end)

        self.m_feverIdleVisual:setVisible(true)
        self.m_feverIdleVisual:setVisual('fever', 'idle_01')
        self.m_feverIdleVisual:setRepeat(false)
    end
end

-------------------------------------
-- function update_live
-------------------------------------
function GameFever:update_live(dt)
    local world = self.m_world
    local enemy_count = #world:getEnemyList()
    
    if (self.m_stateTimer == 0) then
        -- 피버 모드 연출
        self.m_feverStartVisual:setVisible(false)
        self.m_feverIdleVisual:setVisual('fever', 'idle_02')
        self.m_feverIdleVisual:setRepeat(true)
        self.m_feverTutVisual.m_node:setFrame(0)

        -- 피버 모드 터치 입력 활성화
        self.m_touchNode:setVisible(self.m_bActive)

        -- 게이지 연출
        self.m_feverGauge1:setVisible(false)
        self.m_feverGauge2:setVisible(true)
        self.m_feverGauge1:runAction(cc.ProgressTo:create(FEVER_KEEP_TIME, 0)) 
        self.m_feverGauge2:runAction(cc.ProgressTo:create(FEVER_KEEP_TIME, 0)) 

        -- 게이지 변경
        self.m_feverGauge2:setVisible(false)
        self.m_feverGaugeEndVisual.m_node:setFrame(0)
        self.m_feverGaugeEndVisual:setVisible(true)
    end

    -- 적이 모두 죽었거나 제한시간이 다 되었을 경우 종료 처리
    if (enemy_count <= 0) then
        self:onEnd()

    elseif (self.m_stateTimer >= FEVER_KEEP_TIME) then
        self:onEnd()
    end

    -- 버프 이펙트 위치 갱신
    for i, feverEffect in ipairs(self.m_lFeverEffect) do
        local hero = world:getDragonList()[i]
        if (hero and hero.m_bDead == false) then
            feverEffect:setVisible(true)
            feverEffect:setPosition(hero.pos.x, hero.pos.y)
        else
            feverEffect:setVisible(false)
        end
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
    self.m_tMissile = {}
    
    -- 버프 이펙트 생성
    self:makeBuffEffects()

    self.m_feverButton1:setVisible(false)
    self.m_feverButton2:setVisible(true)
    
    self:changeState(GAME_FEVER_STATE_APPEAR)
end

-------------------------------------
-- function onEnd
-------------------------------------
function GameFever:onEnd()
    self.m_bActive = false

    self.m_touchNode:setVisible(self.m_bActive)

    -- 버프 이펙트 삭제
    self:removeBuffEffects()

    for i, hero in ipairs(self.m_world:getDragonList()) do
        if not hero.m_bDead then
            hero.m_animator:setTimeScale(1)
            hero.m_animator:changeAni('idle', true)
        end
    end
    
    self:changeState(GAME_FEVER_STATE_CHARGING)
    self:dispatch('fever_end')
    
    self.m_feverLabel:setString(Str('{1}%', math_floor(self.m_curPoint)))

    self.m_feverGaugeEffect:setPosition(0, 0)

    self.m_feverGauge1:setVisible(true)
    self.m_feverGauge2:setVisible(false)

    self.m_feverButton1:setVisible(false)
    self.m_feverButton2:setVisible(false)

    self.m_feverGaugeEndVisual:setVisible(false)
end

-------------------------------------
-- function makeBuffEffects
-- @brief 버프 이펙트들을 생성
-------------------------------------
function GameFever:makeBuffEffects()
    self.m_lFeverEffect = {}

    for i, hero in ipairs(self.m_world:getDragonList()) do
        if not self.m_lFeverEffect[i] then
            local res = 'res/effect/effect_fever/effect_fever.vrp'
            local feverEffect = MakeAnimator(res)
            feverEffect:setVisible(false)
            feverEffect:changeAni('buff', true)
                    
            self.m_world.m_feverNode:addChild(feverEffect.m_node)

            table.insert(self.m_lFeverEffect, feverEffect)
        end
    end
end

-------------------------------------
-- function removeBuffEffects
-- @brief 버프 이펙트들을 삭제
-------------------------------------
function GameFever:removeBuffEffects()
    for i, feverEffect in ipairs(self.m_lFeverEffect) do
        feverEffect:release()
    end

    self.m_lFeverEffect = {}
end

-------------------------------------
-- function doAttack
-------------------------------------
function GameFever:doAttack()
    if (self.m_state ~= GAME_FEVER_STATE_LIVE) then return end

    local world = self.m_world

	local hero = self:getRandomHero()
    if not hero then return end

    world.m_shakeMgr:shakeBySpeed(math_random(100, 300), math_random(100, 300))

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
    self.m_activityCarrier:setPowerRate(FEVER_ATTACK_DAMAGE_RATE)
    self.m_activityCarrier:setAttackType('fever')
    self.m_activityCarrier:setIgnoreDef(true)
    self.m_activityCarrier.m_attribute = ATTR_NONE

    -- 공격
    hero:animatorShake()
	hero:runAtkCallback(enemy, enemy.pos.x, enemy.pos.y)
	enemy:runDefCallback(self, enemy.pos.x, enemy.pos.y)

    -- 이벤트
    self:dispatch('fever_attack')

    -- 효과음
    SoundMgr:playEffect('EFFECT', 'fever_touch')

    -- 이펙트
    do
        local t_type = { 'c', 'd', 'u' }

        local attr = getRandomAttr()
        local res = 'res/effect/effect_fever/effect_fever.vrp'
        local type = t_type[math_random(1, #t_type)]
    
        local animator
        local aniName = string.format('missile_%s_%s', attr, type)

        local missileKey = string.format('%d_%d_%d_%d_%s', hero.pos.x, hero.pos.y, enemy.pos.x, enemy.pos.y, type)
        
        if self.m_tMissile[missileKey] then
            animator = self.m_tMissile[missileKey]
        else
            animator = MakeAnimator(res)
            animator:setPosition(hero.pos.x, hero.pos.y)
            world.m_feverNode:addChild(animator.m_node)

            local distance = getDistance(hero.pos.x, hero.pos.y, enemy.pos.x, enemy.pos.y)
            animator:setScale(distance / 1440)

            local degree = getDegree(hero.pos.x, hero.pos.y, enemy.pos.x, enemy.pos.y)
            animator:setRotation(degree)
        end
        animator:changeAni(aniName, false)
        
        local duration = animator:getDuration()
        animator:runAction(cc.Sequence:create(cc.DelayTime:create(duration), 
            cc.CallFunc:create(function()
                self.m_tMissile[missileKey] = nil
            end),
        cc.RemoveSelf:create()))

        self.m_tMissile[missileKey] = animator
    end
end

-------------------------------------
-- function getRandomHero
-- @brief 랜덤한 아군을 선택
-------------------------------------
function GameFever:getRandomHero()
    if #self.m_tAttackOrder == 0 then
        for i, hero in ipairs(self.m_world:getDragonList()) do
            if not hero.m_bDead then
                table.insert(self.m_tAttackOrder, hero)
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
    if (self:isActive()) then return end
    if (self.m_realPoint >= 100) then return end
    
    self.m_realPoint = self.m_realPoint + point
    self.m_realPoint = math_min(self.m_realPoint, 100)

    self.m_stepPoint = self.m_realPoint - self.m_curPoint

    -- 획득시마다 게이지 표시
    self.m_feverGauge1:runAction(cc.ProgressTo:create(FEVER_POINT_UPDATE_TIME, self.m_realPoint)) 
    self.m_feverGauge2:runAction(cc.ProgressTo:create(FEVER_POINT_UPDATE_TIME, self.m_realPoint)) 

    -- 이펙트
    do
        self.m_feverGaugeEffect.m_node:stopAllActions()

        local scale = math_pow(1 + (self.m_realPoint / 100) / 2, 2)
        local scale_action = cc.ScaleTo:create(FEVER_POINT_UPDATE_TIME, scale)
        --local move_action = cc.MoveTo:create(FEVER_POINT_UPDATE_TIME, cc.p((720 * self.m_realPoint / 100), 0))
        local move_action = cc.MoveTo:create(FEVER_POINT_UPDATE_TIME, cc.p(
            (720 * self.m_realPoint / 100),
            (30 * self.m_realPoint / 100)
        ))
        
        self.m_feverGaugeEffect:setVisible(true)
        self.m_feverGaugeEffect:runAction(cc.Sequence:create(
            cc.Spawn:create(scale_action, move_action),
            cc.CallFunc:create(function(node) node:setVisible(false) end)
        ))
    end
end

-------------------------------------
-- function getPointFromCastingPercentage
-------------------------------------
function GameFever:getPointFromCastingPercentage(percentage)
    local point = 0

    if percentage >= 90 then     point = PERFECT_SKILL_CANCEL_FEVER_POINT
    elseif percentage >= 70 then point = GREAT_SKILL_CANCEL_FEVER_POINT
    else                         point = GOOD_SKILL_CANCEL_FEVER_POINT
    end

    return point
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
function GameFever:onEvent(event_name, t_event, ...)
    if (event_name == 'hero_basic_skill') then
        local arg = {...}
        local hero = arg[1]

        local point = 1

        self:addFeverPoint(point)
        
    elseif (event_name == 'hero_active_skill') then
        local arg = {...}
        local hero = arg[1]

        local point = 4

        self:addFeverPoint(point)

    elseif (event_name == 'hit_active') then
        local arg = {...}
        local attackerActivityCarrier = arg[2]
        local hit_count = attackerActivityCarrier:getFlag('hit_count') or 0
        
        local point = 2

        if (hit_count < 5) then
            self:addFeverPoint(point)
        end

    elseif (event_name == 'hit_active_buff') then
        local arg = {...}
        local hero = arg[1]

        local point = 3

        self:addFeverPoint(point)
        
    elseif (event_name == 'character_casting_cancel') then
        local arg = {...}
        local castingPercentage = arg[2]

        --local point = self:getPointFromCastingPercentage(castingPercentage)
        local point = 10

        self:addFeverPoint(point)
    end
end