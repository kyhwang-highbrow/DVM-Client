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
        m_bPauseMode = 'boolean',
        m_startTimer = 'number',
        m_firstTouchPos = '',
        m_firstTouchUIPos = '',

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
    self.m_bPauseMode = false
    self.m_startTimer = 0
    self.m_firstTouchPos = nil
    self.m_firstTouchUIPos = nil
	
    self.m_uiToolTip = UI_Tooltip_Indicator()
    self.m_uiToolTip:hide()
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
    if (not world:isPossibleControl()) then
        self:clear()
        return false
    end

    -- 이미 인디케이터 조작 상태라면 막음 처리
    if (self:isControlling()) then
        return false
    end

    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()
    local node_pos = self.m_touchNode:convertToNodeSpace(location)
    local t_event = {['touch']=false, ['location']=location}

    -- 터치된 캐릭터 결정
    local near_distance = nil
    local select_hero = nil

    -- 테이머 검사
    if (world.m_tamer) then
        world.m_tamer:dispatch('touch_began', t_event)

        if t_event['touch'] then
            near_distance = 0
            select_hero = world.m_tamer
        end
    end

    -- 드래곤 검사
    if (not select_hero) then
        for i, v in pairs(world:getDragonList()) do
            v:dispatch('touch_began', t_event)

            if t_event['touch'] then
                near_distance = 0
                select_hero = v
                break
            else
                local x, y = v:getCenterPos()
		        local distance = math_distance(x, y, node_pos['x'], node_pos['y'])

		        if (distance <= 100) then
			        if (near_distance == nil) or (distance < near_distance) then
				        near_distance = distance
				        select_hero = v
                        break
			        end
		        end
            end
        end 
    end

    if (select_hero) then
        self.m_firstTouchPos = node_pos
        self.m_firstTouchUIPos = world.m_inGameUI.root:convertToNodeSpace(location)

        if (select_hero:isPossibleSkill()) then
            self.m_touchedHero = select_hero

            if(select_hero.m_skillIndicator) then
                select_hero.m_skillIndicator:setIndicatorTouchPos(node_pos['x'], node_pos['y'])
            end
        end

        -- 튤팁 표시
        self:makeSkillToolTip(select_hero)
        -- 툴팁 y좌표 설정
        --self.m_uiToolTip:setRelativePosY(select_hero.pos.y)

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
        -- 조작 가능 상태일 때에만
    local hero = self.m_touchedHero
        
    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()
    local node_pos = self.m_touchNode:convertToNodeSpace(location)
    local ui_pos = self.m_world.m_inGameUI.root:convertToNodeSpace(location)
    local distance = getDistance(self.m_firstTouchUIPos['x'], self.m_firstTouchUIPos['y'], ui_pos['x'], ui_pos['y'])

    -- 인디케이터 위치 업데이트
    if (hero.m_skillIndicator) then
        hero.m_skillIndicator:setIndicatorTouchPos(node_pos['x'], node_pos['y'])

        if (not self:isControlling() and self.m_world:isPossibleControl()) then
            if (distance >= 50) then
                if (hero:isPossibleSkill()) then
                    self:setSelectHero(hero)
                    event:stopPropagation()
                end
            end
        end
    end

    -- 튤팁 UI X좌표 업데이트
    if (self.m_uiToolTip) then
        self.m_uiToolTip:updateRelativePosX(node_pos['x'])
    end
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function SkillIndicatorMgr:onTouchEnded(touch, event)
    local location = touch:getLocation()

    if (self.m_selectHero) then
        if (self.m_selectHero:isDead()) then
            -- 스킬 사용 주체 대상이 이미 죽었을 경우 취소 처리
            self:clear()

        elseif (not self.m_selectHero.m_skillIndicator:isExistTarget()) then
            -- 대상이 하나도 없을 경우 취소 처리
            self:clear()
              
        else
            ---------------------------------------------------
            -- 액티브 스킬 발동
            ---------------------------------------------------

            -- 경직 중이라면 즉시 해제
            self.m_selectHero:setSpasticity(false)

            local skill_indivisual_info = self.m_selectHero:getSkillIndivisualInfo('active')
            local t_skill = skill_indivisual_info:getSkillTable()

            if t_skill['casting_time'] > 0 then
                self.m_selectHero:changeState('casting')
            else
                self.m_selectHero:changeState('skillAppear')
            end

            -- 월드상의 터치 위치 얻어옴
            local location = touch:getLocation()
            local node_pos = self.m_touchNode:convertToNodeSpace(location)

            self.m_selectHero.m_skillIndicator:setIndicatorTouchPos(node_pos['x'], node_pos['y'])

            self:clear(true)
        end
    
    elseif (self.m_touchedHero) then
        ---------------------------------------------------
        -- 터치 스킬 발동
        ---------------------------------------------------
        if (self.m_touchedHero:isPossibleSkill()) then
            local skill_indivisual_info = self.m_touchedHero:getSkillIndivisualInfo('active')
            local t_skill = skill_indivisual_info:getSkillTable()

            if (self.m_touchedHero.m_charType == 'tamer') then
                local tamer = self.m_touchedHero
                local t_event = {['touch']=false, ['location']=location}

                tamer:dispatch('touch_ended', t_event)

            elseif (self.m_touchedHero.m_skillIndicator) then
                local bPreparedSkill = GameAuto:prepareSkill(self.m_touchedHero, t_skill)

                if (bPreparedSkill) then
                    -- 경직 중이라면 즉시 해제
                    self.m_touchedHero:setSpasticity(false)

                    if t_skill['casting_time'] > 0 then
                        self.m_touchedHero:changeState('casting')
                    else
                        self.m_touchedHero:changeState('skillAppear')
                    end
                end
            end
        end

        self.m_touchedHero = nil
    end

    self:closeSkillToolTip()
end

-------------------------------------
-- function clear
-------------------------------------
function SkillIndicatorMgr:clear(keep_pause)
    self.m_touchedHero = nil
    
    if (self.m_selectHero) then
        if (not keep_pause) then
            self.m_world:setTemporaryPause(false, self.m_selectHero)
            self.m_bPauseMode = false
        end
        self:setSelectHero(nil)
        self.m_bPauseMode = false
    end
end

-------------------------------------
-- function update
-------------------------------------
function SkillIndicatorMgr:update(dt)
    if (not self.m_world:isPossibleControl()) then
        self:clear()
        self:closeSkillToolTip()
        return 
    end

    if (self:isControlling()) then
        if (self.m_selectHero:isDead()) or (not self.m_world:isPossibleControl()) then
            self:clear()
            return
        
        elseif (not self.m_bPauseMode) then
            self.m_world:setTemporaryPause(true, self.m_selectHero)
            self.m_bPauseMode = true
            
        end
    end
end

-------------------------------------
-- function setSelectHero
-------------------------------------
function SkillIndicatorMgr:setSelectHero(hero)
    self.m_startTimer = 0
        
    if (hero) then
        SoundMgr:playEffect('UI', 'ui_drag_ready')

        local active_skill_id = hero:getSkillID('active')
        hero:reserveSkill(active_skill_id)

        hero:changeState('skillPrepare')

        hero.m_skillIndicator:changeSIState(SI_STATE_READY)
        hero.m_skillIndicator:changeSIState(SI_STATE_APPEAR)
        hero.m_skillIndicator:setIndicatorTouchPos(self.m_firstTouchPos['x'], self.m_firstTouchPos['y'])
        hero.m_skillIndicator:update()

        -- 일시정지
        self.m_world:setTemporaryPause(true, hero)
        self.m_bPauseMode = true

        -- 화면 쉐이킹 멈춤
        self.m_world.m_shakeMgr:stopShake()
                
        self.m_selectHero = hero
    else
        if (self.m_selectHero) then
            self.m_selectHero.m_skillIndicator:changeSIState(SI_STATE_DISAPPEAR)
            
            if (self.m_selectHero.m_state == 'skillPrepare') then
                self.m_selectHero:changeState('attackDelay', true)
            end
        end

        self.m_selectHero = nil
    end
end

-------------------------------------
-- function makeSkillToolTip
-------------------------------------
function SkillIndicatorMgr:makeSkillToolTip(dragon)
    if (not dragon:getSkillIndivisualInfo('active')) then return end

	self.m_uiToolTip:init_data(dragon)
	self.m_uiToolTip:displayData()
    self.m_uiToolTip:show()
end

-------------------------------------
-- function closeSkillToolTip
-------------------------------------
function SkillIndicatorMgr:closeSkillToolTip()
	if (not self.m_uiToolTip) then return end
	self.m_uiToolTip:hide()
end

-------------------------------------
-- function isControlling
-------------------------------------
function SkillIndicatorMgr:isControlling()
    return (self.m_selectHero ~= nil)
end