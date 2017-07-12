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
        if (select_hero:isPossibleSkill()) then
            -- 드래곤 클릭
            self.m_firstTouchPos = node_pos
            self.m_firstTouchUIPos = world.m_inGameUI.root:convertToNodeSpace(location)
        
            self.m_touchedHero = select_hero
            self.m_touchedHero.m_skillIndicator:setIndicatorTouchPos(node_pos['x'], node_pos['y'])
        end

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
    local is_used_skill = false

    if (self.m_selectHero) then
        if (self.m_selectHero.m_bDead) then
            -- 스킬 사용 주체 대상이 이미 죽었을 경우 취소 처리
            self:clear(true)

        elseif (not self.m_selectHero.m_skillIndicator:isExistTarget()) then
            -- 대상이 하나도 없을 경우 취소 처리
            self:clear(true)
              
        else
            ---------------------------------------------------
            -- 액티브 스킬 발동
            ---------------------------------------------------

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

            is_used_skill = true
        end
    
    elseif (self.m_touchedHero) then
        --[[
        ---------------------------------------------------
        -- 터치 스킬 발동
        ---------------------------------------------------
        if (self.m_touchedHero:isPossibleSkill()) then
            local active_skill_id = self.m_touchedHero:getSkillID('active')
            local t_skill = TableDragonSkill():get(active_skill_id)
            
            self.m_world.m_gameAutoHero:doSkill(self.m_touchedHero, t_skill)

            is_used_skill = true
        end
        ]]--
        self.m_touchedHero = nil
    end

    self:closeSkillToolTip()

    if (is_used_skill) then
        self.m_animatorGuide:release()

        self.m_world.m_gameHighlight:setToForced(false)
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
    self.m_animatorGuide:changeAni('hand_03', true)
    self.m_animatorGuide:setPosition(self.m_introHero.pos.x, self.m_introHero.pos.y - 20)

    g_gameScene.m_gameIndicatorNode:addChild(self.m_animatorGuide.m_node)
end