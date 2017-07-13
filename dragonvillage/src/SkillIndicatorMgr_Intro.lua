local PARENT = SkillIndicatorMgr

-------------------------------------
-- class SkillIndicatorMgr_Intro
-------------------------------------
SkillIndicatorMgr_Intro = class(PARENT, {
    m_introHero = 'Dragon',

    m_animatorGuide = 'cc.AzVRP',
})

-------------------------------------
-- function init
-------------------------------------
function SkillIndicatorMgr_Intro:init(world)
    self.m_introHero = nil
end

-------------------------------------
-- function onTouchBegan
-------------------------------------
function SkillIndicatorMgr_Intro:onTouchBegan(touch, event)
    local world = self.m_world

    -- 조작 가능 상태일 때에만
    if (not self.m_world:isPossibleControl()) then
        return false
    end

    -- 이미 인디케이터 조작 상태라면 막음 처리
    if (self:isControlling()) then
        return false
    end

    if (not self.m_introHero) then
        return false
    end

    -- 월드상의 터치 위치 얻어옴
    local location = touch:getLocation()
    local node_pos = self.m_touchNode:convertToNodeSpace(location)

    -- 터치된 캐릭터 결정
    local near_distance = nil
    local select_hero = nil

    for i, v in pairs(self.m_world:getDragonList()) do
        local x, y = v:getCenterPos()
	    local distance = math_distance(x, y, node_pos['x'], node_pos['y'])

		if (distance <= 100) then
			if (near_distance == nil) or (distance < near_distance) then
				near_distance = distance
				select_hero = v
			end
		end
    end 

    if (select_hero and select_hero == self.m_introHero) then
        -- 드래곤 클릭
        self.m_firstTouchPos = node_pos
        self.m_firstTouchUIPos = world.m_inGameUI.root:convertToNodeSpace(location)
        
        self.m_touchedHero = select_hero
        self.m_touchedHero.m_skillIndicator:setIndicatorTouchPos(node_pos['x'], node_pos['y'])

        self.m_animatorGuide:setVisible(false)
        
        -- 튤팁 표시
        self:makeSkillToolTip(select_hero)
        self:updateToolTipUI(0, 0, node_pos['x'], node_pos['y'])

        event:stopPropagation()

        return true
    end

    return false
end


-------------------------------------
-- function onTouchEnded
-------------------------------------
function SkillIndicatorMgr_Intro:onTouchEnded(touch, event)
    if (self.m_selectHero) then
        if (not self.m_selectHero.m_skillIndicator:isExistTarget()) then
            -- 대상이 하나도 없을 경우 취소 처리
            self:clear()

            self.m_animatorGuide:setFrame(0)
            self.m_animatorGuide:setVisible(true)
              
        else
            ---------------------------------------------------
            -- 액티브 스킬 발동
            ---------------------------------------------------

            self.m_selectHero:setTemporaryPause(false)

            -- 경직 중이라면 즉시 해제
            self.m_selectHero:setSpasticity(false)

            -- 스킬 쿹타임 시작
            self.m_selectHero:startActiveSkillCoolTime()

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

            if (self.m_animatorGuide) then
                self.m_animatorGuide:release()
                self.m_animatorGuide = nil
            end

            self.m_world.m_gameHighlight:setToForced(false)
        end
    
    elseif (self.m_touchedHero) then
        self.m_touchedHero = nil

        self.m_animatorGuide:setFrame(0)
        self.m_animatorGuide:setVisible(true)

    end

    self:closeSkillToolTip()
end

-------------------------------------
-- function clear
-------------------------------------
function SkillIndicatorMgr_Intro:clear()
    self.m_touchedHero = nil
    
    if (self.m_selectHero) then
        self:setSelectHero(nil)
        self.m_bSlowMode = false
    end
end


-------------------------------------
-- function setSelectHero
-------------------------------------
function SkillIndicatorMgr_Intro:setSelectHero(hero)
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
-- function startIntro
-------------------------------------
function SkillIndicatorMgr_Intro:startIntro(hero)
    self.m_introHero = hero

    local world = self.m_world

    world:setTemporaryPause(true)
    world.m_gameHighlight:setToForced(true)
    world.m_gameHighlight:addForcedHighLightList(self.m_introHero)

    -- 가이드 비주얼
    self.m_animatorGuide = MakeAnimator('res/ui/a2d/tutorial/tutorial.vrp')
    self.m_animatorGuide:changeAni('hand_drag_01', true)
    self.m_animatorGuide:setPosition(self.m_introHero.pos.x, self.m_introHero.pos.y - 50)

    g_gameScene.m_gameIndicatorNode:addChild(self.m_animatorGuide.m_node)
end