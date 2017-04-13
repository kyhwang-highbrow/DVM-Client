-- 1) 즉시시전
-- - 캐릭터를 가볍게 (0.9초 이내) 터치하면 즉시시전 모드로 변경
-- - 즉시시전은 정해진 AI에 따라서 시전 됨
-- - 자동스킬 옵션을 사용하면 모든 스킬은 즉시시전 룰로 동작

-- 2) 조작시전
-- - 캐릭터 터치를 1초간 유지하거나 터치를 유지하고 20픽셀 이상 드래그 하면 조작시전 모드로 변경
-- - 조작시전 모드 진입 시 화면이 슬로우모드로 진행 됨과 동시에 시전자를 제외하고 화면이 암전됨
-- - 슬로우 모드 상태가 되면 캐릭터의 스킬 속성에 맞춘 인디케이터 출력
-- - 유저가 직접 조작 하여 스킬 사용

-- 스킬 조작계
-- 1. 직선형
-- - 스킬 시전 시 직선의 인디케이터 출력
-- - 인디케이터를 좌, 우로 움직이면 직선의 길이가 줄어들거나 길어짐
-- - 인디게이터를 상, 하로 움직이면 시전자를 중심으로 위, 아래로 이동이 이루어짐
-- - 직선인디케이터에 범위에 들어오는 적들은 암전에서 제외되어 타겟팅 됨을 알려줌

-- 2. 범위형
-- - 스킬 시전 시 이동 가능 범위와 스킬 범위를 나타내는 도형 출력
-- - 인디케이터를 드래그 조작을 통해 자신이 원하는 위치로 이동가능
-- - 인디케이터 범위 안에 들어오는 적들은 암전에서 제외되어 타겟팅 됨을 알려줌

-- 3. 단일형
-- - 스킬 시전 시 현재 타겟팅 된 적을 알려주는 도형 출력
-- - 인디케이터를 드래고 조작을 통해 자신이 원하는 적에게 이동
-- - 인디케이터에 지정된 적은 암전에서 제외되어 타겟팅 됨을 알려줌

local SKILL_INDICATOR_FADE_OUT_DURATION = 0.5
local DARK_LAYER_OPACITY = 200


-------------------------------------
-- class SkillIndicatorMgr
-------------------------------------
SkillIndicatorMgr = class({
        m_world = 'GameWorld',
        
        m_touchNode = 'cc.Node',
        m_touchedHero = 'Hero',
        m_selectHero = 'Hero',
        m_bSlowMode = 'boolean',
        m_startTimer = 'number',
        m_firstTouchPos = '',
        m_firstTouchUIPos = '',
        m_targetList = 'table',
		m_uiToolTip = 'UI',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicatorMgr:init(world)
    self.m_world = world
    
    self.m_touchNode = cc.Node:create()
    world.m_worldLayer:addChild(self.m_touchNode)
    self:makeTouchLayer(self.m_touchNode)

    self.m_touchedHero = nil
    self.m_selectHero = nil
    self.m_bSlowMode = false
    self.m_startTimer = 0
    self.m_firstTouchPos = nil
    self.m_firstTouchUIPos = nil
	self.m_targetList = {}

    self.m_uiToolTip = UI_Tooltip_Indicator()
    self.m_uiToolTip:setVisible(false)
end

-------------------------------------
-- function makeTouchLayer
-------------------------------------
function SkillIndicatorMgr:makeTouchLayer(target_node)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event) return self:onTouchBegan(touch, event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event) return self:onTouchMoved(touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(function(touch, event) return self:onTouchEnded(touch, event) end, cc.Handler.EVENT_TOUCH_CANCELLED)
                
    local eventDispatcher = target_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, target_node)
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function SkillIndicatorMgr:onTouchBegan(touch, event)
    local world = self.m_world

    -- 조작 가능 상태일 때에만
    if (not self.m_world:isPossibleControl()) then
        return false
    end

    -- 이미 인디케이터 조작 상태라면 막음 처리
    if (self:isControlling()) then
        return false
    end

    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()
    local node_pos = self.m_touchNode:convertToNodeSpace(location)

    -- 터치된 캐릭터 결정
    local near_distance = nil
    local select_hero = nil
    for i, v in pairs(self.m_world:getDragonList()) do

        local t_event = {['touch']=false, ['location']=location}
        v:dispatch('touch_began', t_event)
        if t_event['touch'] then
            near_distance = 0
            select_hero = v
        else
            local x, y = v:getCenterPos()
		    local distance = math_distance(x, y, node_pos['x'], node_pos['y'])

		    if (distance <= 100) then
			    if (near_distance == nil) or (distance < near_distance) then
				    near_distance = distance
				    select_hero = v
			    end
		    end
        end
    end 

    if select_hero then
        -- 드래곤 클릭
        self.m_firstTouchPos = node_pos
        self.m_firstTouchUIPos = world.m_inGameUI.root:convertToNodeSpace(location)
        
        self.m_touchedHero = select_hero

        self.m_touchedHero.m_skillIndicator:setIndicatorTouchPos(node_pos['x'], node_pos['y'])

        event:stopPropagation()

        return true
    end

    return false
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicatorMgr:onTouchMoved(touch, event)
    if (not self.m_touchedHero) then return end
    
    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()
    local node_pos = self.m_touchNode:convertToNodeSpace(location)

    self.m_touchedHero.m_skillIndicator:setIndicatorTouchPos(node_pos['x'], node_pos['y'])
    
    if (self.m_bSlowMode == false) then
        local ui_pos = self.m_world.m_inGameUI.root:convertToNodeSpace(location)
        local distance = getDistance(self.m_firstTouchUIPos['x'], self.m_firstTouchUIPos['y'], ui_pos['x'], ui_pos['y'])
        if (distance >= 50) then
            if (self.m_touchedHero:isPossibleSkill()) then
                self.m_bSlowMode = true

                self:setSelectHero(self.m_touchedHero)
                event:stopPropagation()
            end
        end
    end
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function SkillIndicatorMgr:onTouchEnded(touch, event)
    if (self.m_selectHero) then
        if (self.m_selectHero.m_bDead) then
            self:clear(true)    
        else
            ---------------------------------------------------
            -- 액티브 스킬 발동
            ---------------------------------------------------

            -- 경직 중이라면 즉시 해제
            self.m_selectHero:setSpasticity(false)

            -- 스킬 쿹타임 초기상태로
            self.m_selectHero:resetActiveSkillCool()

            local active_skill_id = self.m_selectHero:getSkillID('active')
            local t_skill = TableDragonSkill():get(active_skill_id)

            if t_skill['casting_time'] > 0 then
                self.m_selectHero:changeState('casting')
            else
                self.m_selectHero:changeState('skillAppear')
            end

            -- 월드상의 터치 위치 얻어옴
            local location = touch:getLocation()
            local node_pos = self.m_touchNode:convertToNodeSpace(location)

            self.m_selectHero.m_skillIndicator:setIndicatorTouchPos(node_pos['x'], node_pos['y'])

            self:clear()
        end
    
    elseif (self.m_touchedHero) then
        ---------------------------------------------------
        -- 터치 스킬 발동
        ---------------------------------------------------
    end

    self.m_touchedHero = nil
end

-------------------------------------
-- function clear
-------------------------------------
function SkillIndicatorMgr:clear(bAll)
    self.m_touchedHero = nil
    self.m_targetList = {}

    if (self.m_selectHero) then
        self.m_selectHero.m_skillIndicator:changeSIState(SI_STATE_DISAPPEAR)
        self.m_world:setTemporaryPause(false, self.m_selectHero)
        self:setSelectHero(nil)
        self.m_bSlowMode = false
    end
end

-------------------------------------
-- function update
-------------------------------------
function SkillIndicatorMgr:update(dt)
    if (self.m_selectHero) then
        if (self.m_selectHero.m_bDead) or (not self.m_world:isPossibleControl()) then
            self:clear(true)
            return
        end
    end

    -- TODO : 누르고 있을 경우 일정시간 뒤 인디케이터 활성화
    --[[
    elseif (self.m_touchedHero) then
        if (self.m_bSlowMode == false) then
            self.m_startTimer = self.m_startTimer + dt
            if (0.5 < self.m_startTimer) then
                self.m_bSlowMode = true

                self:setSelectHero(self.m_touchedHero)
            end
        end
    end
    ]]--
end

-------------------------------------
-- function setSelectHero
-------------------------------------
function SkillIndicatorMgr:setSelectHero(hero)
    self.m_startTimer = 0
    self.m_targetList = {}
    
    if (hero) then
        SoundMgr:playEffect('EFFECT', 'skill_touch')

        local active_skill_id = hero:getSkillID('active')
        hero:reserveSkill(active_skill_id)

        hero:changeState('skillPrepare')

        hero.m_skillIndicator:changeSIState(SI_STATE_READY)
        hero.m_skillIndicator:changeSIState(SI_STATE_APPEAR)
        hero.m_skillIndicator:setIndicatorTouchPos(self.m_firstTouchPos['x'], self.m_firstTouchPos['y'])
        hero.m_skillIndicator:update()

        -- 일시정지
        self.m_world:setTemporaryPause(true, hero)

        -- 화면 쉐이킹 멈춤
        self.m_world.m_shakeMgr:stopShake()
                
        self.m_selectHero = hero
    else
        self.m_selectHero = nil

    end
end

-------------------------------------
-- function addHighlightList
-------------------------------------
function SkillIndicatorMgr:addTarget(char, zorder)
    if (not self:isControlling()) then return end

    self.m_targetList[char] = true
end

-------------------------------------
-- function removeHighlightList
-------------------------------------
function SkillIndicatorMgr:removeTarget(char)
    self.m_targetList[char] = nil
end

-------------------------------------
-- function makeSkillToolTip
-------------------------------------
function SkillIndicatorMgr:makeSkillToolTip(dragon)
	-- 드래곤만 툴팁을 띄울수 있다
	if (dragon.m_charType ~= 'dragon') then return end 

	self.m_uiToolTip:init_data(dragon)
	self.m_uiToolTip:displayData()
    self.m_uiToolTip:setVisible(true)
end

-------------------------------------
-- function closeSkillToolTip
-------------------------------------
function SkillIndicatorMgr:closeSkillToolTip()
	if (not self.m_uiToolTip) then return end
	self.m_uiToolTip:setVisible(false)
end

-------------------------------------
-- function updateToolTipUI
-------------------------------------
function SkillIndicatorMgr:updateToolTipUI(hero_pos_x, hero_pos_y, touch_pos_x, touch_pos_y)
	if (not self.m_uiToolTip) then return end
	
	local x = 0 
	local y = 0
	
	if (hero_pos_y >= 0)  then 
		y = 20
	else
		y = 500
	end

	if (touch_pos_x > 640) then
		x = 20
	else
		x = 650
	end
	self.m_uiToolTip.root:setPosition(x, y)
end

-------------------------------------
-- function isControlling
-------------------------------------
function SkillIndicatorMgr:isControlling()
    return (self.m_selectHero ~= nil)
end