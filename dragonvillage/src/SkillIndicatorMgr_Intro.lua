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
    local t_event = {['touch']=false, ['location']=location}

    -- 터치된 캐릭터 결정
    local near_distance = nil
    local select_hero = nil

    for i, v in pairs(self.m_world:getDragonList()) do
        v:dispatch('touch_began', t_event)
        
        if (t_event['touch']) then
            near_distance = 0
            select_hero = v
            break
        end
    end 

    if (select_hero and select_hero == self.m_introHero) then
        if (select_hero:isPossibleActiveSkill()) then
            -- 드래곤 클릭
            self.m_firstTouchPos = node_pos
            self.m_firstTouchUIPos = world.m_inGameUI.root:convertToNodeSpace(location)
        
            self.m_touchedHero = select_hero
            self.m_touchedHero.m_skillIndicator:setIndicatorTouchPos(node_pos['x'], node_pos['y'])
        end

        if (self.m_animatorGuide) then
            self.m_animatorGuide:setVisible(false)
        end
        
        -- 튤팁 표시
        self:makeSkillToolTip(select_hero)

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
            self:clear(true)

            if (self.m_animatorGuide) then
                self.m_animatorGuide:setFrame(0)
                self.m_animatorGuide:setVisible(true)
            end
              
        else
            -- 스마트 드래곤의 힐 스킬은 무조건 번개고룡을 포함시킨다
            if (self.m_selectHero:getCharId() == 120431) then
                local indicator = self.m_selectHero.m_skillIndicator
                local is_exist = false

                for _, v in ipairs(indicator.m_highlightList) do
                    if (v:getCharId() == 120223) then
                        is_exist = true
                        break
                    end
                end

                if (not is_exist) then
                    cclog('add collision')
                    -- 번개고룡이 대상에 없을 경우 강제로 세팅
                    local target = self.m_world:getDragonList()[4]
                    local target_x, target_y = target:getCenterPos()
                    local collision_data = StructCollisionData(target, 0, 0, target_x, target_y)

                    table.insert(indicator.m_highlightList, target)
                    table.insert(indicator.m_collisionList, collision_data)
                end
            end

            ---------------------------------------------------
            -- 액티브 스킬 발동
            ---------------------------------------------------

            -- 월드상의 터치 위치 얻어옴
            local unit = self.m_selectHero
            local location = touch:getLocation()
            local node_pos = self.m_touchNode:convertToNodeSpace(location)

            self:clear(true)

            self.m_world.m_gameActiveSkillMgr:addWork(unit, node_pos['x'], node_pos['y'])

            if (self.m_animatorGuide) then
                self.m_animatorGuide:release()
                self.m_animatorGuide = nil

                self.m_introHero = nil
            end

            self.m_world.m_gameHighlight:setToForced(false)
        end
    
    elseif (self.m_touchedHero) then
        self.m_touchedHero = nil

        if (self.m_animatorGuide) then
            self.m_animatorGuide:setFrame(0)
            self.m_animatorGuide:setVisible(true)
        end

    end

    self:closeSkillToolTip()
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
    --world.m_gameHighlight:addForcedHighLightList(self.m_introHero)

    -- 가이드 비주얼
    if (self.m_animatorGuide) then
        self.m_animatorGuide:removeFromParent(true)
    end
    
    self.m_animatorGuide = MakeAnimator('res/ui/a2d/tutorial/tutorial.vrp')
    self.m_animatorGuide:changeAni('hand_drag_01', true)
    
    g_gameScene.m_inGameUI:bindPanelGuide(self.m_introHero, self.m_animatorGuide.m_node)
end