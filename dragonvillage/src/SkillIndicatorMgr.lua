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

local SKILL_INDICATOR_SLOW = 0.1
local SKILL_INDICATOR_FADE_OUT_DURATION = 0.5
local DARK_LAYER_OPACITY = 200


-------------------------------------
-- class SkillIndicatorMgr
-------------------------------------
SkillIndicatorMgr = class({
        m_world = 'GameWorld',
        m_darkLayer = '',
        m_touchNode = 'cc.Node',
        m_selectHero = 'Hero',
        m_bSlowMode = 'boolean',
        m_startTimer = 'number',
        m_firstTouchPos = '',
        m_lHighlightList = '',
		m_uiToolTip = 'UI',
    })

-------------------------------------
-- function init
-------------------------------------
function SkillIndicatorMgr:init(world, dark_layer)
    self.m_world = world
    self.m_darkLayer = dark_layer

    self.m_touchNode = cc.Node:create()
    world.m_worldLayer:addChild(self.m_touchNode)
    self:makeTouchLayer(self.m_touchNode)

    self.m_selectHero = nil
    self.m_bSlowMode = false
    self.m_startTimer = 0
    self.m_firstTouchPos = nil
    self.m_lHighlightList = {}
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

    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()
    local node_pos = self.m_touchNode:convertToNodeSpace(location)

    -- 터치된 캐릭터 결정
    local near_distance = nil
    local select_hero = nil
    for i, v in pairs(self.m_world.m_participants) do
        local x, y = v:getCenterPos()
        local distance = math_distance(x, y, node_pos['x'], node_pos['y'])

        if (distance <= 100) then
            if (near_distance == nil) or (distance < near_distance) then
                near_distance = distance
                select_hero = v
            end
        end
    end 

    if select_hero then
        -- 드래곤 클릭
        if select_hero:isEndActiveSkillCoolTime() then
            SoundMgr:playEffect('EFFECT', 'skill_touch')
            self:setSelectHero(select_hero)
        
            self:changeDrakLayerColor(DARK_LAYER_OPACITY, SKILL_INDICATOR_FADE_OUT_DURATION)

            self.m_firstTouchPos = node_pos

            select_hero.m_skillIndicator:changeSIState(SI_STATE_READY)

            self:addHighlightList(select_hero, 5)
            event:stopPropagation()

            self.m_selectHero.m_skillIndicator.m_indicatorTouchPosX = node_pos['x']
            self.m_selectHero.m_skillIndicator.m_indicatorTouchPosY = node_pos['y']
            return true
        end
    end

    return false
end

-------------------------------------
-- function onTouchMoved
-------------------------------------
function SkillIndicatorMgr:onTouchMoved(touch, event)
    if not self.m_selectHero then return end

    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()
    local node_pos = self.m_touchNode:convertToNodeSpace(location)

    if (self.m_bSlowMode == false) then
        local distance = getDistance(self.m_firstTouchPos['x'], self.m_firstTouchPos['y'], node_pos['x'], node_pos['y'])
        if (distance >= 50) then
            self.m_bSlowMode = true
            g_currScene:setTimeScale(SKILL_INDICATOR_SLOW)
            self:changeDrakLayerColor(DARK_LAYER_OPACITY)

            self.m_selectHero.m_skillIndicator:changeSIState(SI_STATE_APPEAR)
        end
    end

    self.m_selectHero.m_skillIndicator.m_indicatorTouchPosX = node_pos['x']
    self.m_selectHero.m_skillIndicator.m_indicatorTouchPosY = node_pos['y']
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function SkillIndicatorMgr:onTouchEnded(touch, event)
    if self.m_selectHero and self.m_selectHero.m_bDead == false then
        -- 경직 중이라면 즉시 해제
        self.m_selectHero:setSpasticity(false)

        self.m_selectHero:resetActiveSkillCoolTime()

        local active_skill_id = self.m_selectHero:getSkillID('active')
        local t_skill = TABLE:get('dragon_skill')[active_skill_id]

        if t_skill['casting_time'] > 0 then
            self.m_selectHero:changeState('casting')
        else
            self.m_selectHero:changeState('skillAttack')
        end

        self:clear()
    end
end

-------------------------------------
-- function clear
-------------------------------------
function SkillIndicatorMgr:clear()
    if self.m_selectHero then
        self.m_selectHero.m_skillIndicator:changeSIState(SI_STATE_DISAPPEAR)
        self.m_selectHero.m_animator:setTimeScale(1)
        self:setSelectHero(nil)
        g_currScene:setTimeScale(1)
        self.m_bSlowMode = false
        self:changeDrakLayerColor(255)
        self:clearHighlightList()
    end
end

-------------------------------------
-- function update
-------------------------------------
function SkillIndicatorMgr:update(dt)
    if (self.m_selectHero) then
        if (self.m_selectHero.m_bDead) or (not self.m_world:isPossibleControl()) then
            self:clear()

        elseif (self.m_bSlowMode == false) then
            self.m_startTimer = self.m_startTimer + dt
            if (0.5 < self.m_startTimer) then
                self.m_bSlowMode = true
                g_currScene:setTimeScale(SKILL_INDICATOR_SLOW)
                self:changeDrakLayerColor(DARK_LAYER_OPACITY)

                self.m_selectHero.m_skillIndicator:changeSIState(SI_STATE_APPEAR)
            end
        end
    end
    
end

-------------------------------------
-- function setSelectHero
-------------------------------------
function SkillIndicatorMgr:setSelectHero(hero)
    self.m_startTimer = 0
    self.m_selectHero = hero

    if hero then
        local active_skill_id = hero:getSkillID('active')
        hero:reserveSkill(active_skill_id)

        hero:changeState('skillPrepare')
    end
end


-------------------------------------
-- function changeDrakLayerColor
-------------------------------------
function SkillIndicatorMgr:changeDrakLayerColor(opacity, duration)
    local dark_layer = self.m_darkLayer

    dark_layer:stopAllActions()

    if (duration) and (duration ~= 0) then
        if (opacity==255) then
            dark_layer:setVisible(true)
            local action = cc.FadeTo:create(duration, opacity)
            local sequence = cc.Sequence:create(action, cc.Hide:create())
            dark_layer:runAction(sequence)
        else
            dark_layer:setVisible(true)
            dark_layer:setOpacity(0)
            dark_layer:runAction( cc.FadeTo:create(duration, opacity) )
        end
    else
        dark_layer:setOpacity(opacity)

        if (opacity==255) then
            dark_layer:setVisible(false)
        else
            dark_layer:setVisible(true)
        end
    end
end

-------------------------------------
-- function addHighlightList
-------------------------------------
function SkillIndicatorMgr:addHighlightList(char, zorder)
    if (char.m_bDead == true) then
        return
    end

    local node = char.m_rootNode

    if (not node) or (self.m_lHighlightList[char]) then
        return
    end

    local t_data = {}
    t_data['parent'] = node:getParent()
    t_data['zorder'] = node:getLocalZOrder()
    self.m_lHighlightList[char] = t_data

    node:retain()
    node:removeFromParent(false)
    g_gameScene.m_gameHighlightNode:addChild(node, zorder or 0)
    node:release()

    -- UI노드
    t_data['ui_parent'] = char.m_hpNode:getParent()
    t_data['ui_zorder'] = char.m_hpNode:getLocalZOrder()
    char.m_hpNode:retain()
    char.m_hpNode:removeFromParent(false)
    g_gameScene.m_gameHighlightNode:addChild(char.m_hpNode, t_data['ui_zorder'])
    char.m_hpNode:release()

    t_data['ui_casting_parent'] = char.m_castingNode:getParent()
    t_data['ui_casting_zorder'] = char.m_castingNode:getLocalZOrder()
    char.m_castingNode:retain()
    char.m_castingNode:removeFromParent(false)
    g_gameScene.m_gameHighlightNode:addChild(char.m_castingNode, t_data['ui_casting_zorder'])
    char.m_castingNode:release()
end

-------------------------------------
-- function removeHighlightList
-------------------------------------
function SkillIndicatorMgr:removeHighlightList(char)
    if (not self.m_lHighlightList[char]) then
        return
    end

    char:removeTargetEffect()
    local t_data = self.m_lHighlightList[char]

    if (char.m_bDead == true) then
        self.m_lHighlightList[char] = nil
    else
        local node = char.m_rootNode
        node:retain()
        node:removeFromParent(false)
        t_data['parent']:addChild(node, t_data['zorder'])
        node:release()

        -- UI노드
        local node = char.m_hpNode
        node:retain()
        node:removeFromParent(false)
        t_data['ui_parent']:addChild(node, t_data['ui_zorder'])
        node:release()

        local node = char.m_castingNode
        node:retain()
        node:removeFromParent(false)
        t_data['ui_casting_parent']:addChild(node, t_data['ui_casting_zorder'])
        node:release()

        self.m_lHighlightList[char] = nil
    end
end

-------------------------------------
-- function clearHighlightList
-------------------------------------
function SkillIndicatorMgr:clearHighlightList()
    for i,_ in pairs(self.m_lHighlightList) do
        self:removeHighlightList(i)
    end
end

-------------------------------------
-- function makeSkillToolTip
-------------------------------------
function SkillIndicatorMgr:makeSkillToolTip(character)
	-- 드래곤만 툴팁을 띄울수 있다
	if (character.m_charType ~= 'dragon') then return end 

	local ui_tooltip = UI_Tooltip_Indicator(0, 0, character)
	self.m_uiToolTip = ui_tooltip
	self.m_uiToolTip:displayData()
end

-------------------------------------
-- function closeSkillToolTip
-------------------------------------
function SkillIndicatorMgr:closeSkillToolTip()
	if (not self.m_uiToolTip) then return end
	self.m_uiToolTip:close()
	self.m_uiToolTip = nil 
end

-------------------------------------
-- function makeSkillToolTip
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