local PARENT = SkillIndicatorMgr

-------------------------------------
-- class SkillIndicatorMgr_ClanRaid
-------------------------------------
SkillIndicatorMgr_ClanRaid = class(PARENT, {})

-------------------------------------
-- function update
-------------------------------------
function SkillIndicatorMgr_ClanRaid:update(dt)
    if (not self.m_world.m_gameState:isFight()) then
        self:clear()
        self:closeSkillToolTip()
        return
    end

    if (self:isControlling()) then
        if (self.m_selectHero:isDead()) then
            self:clear()
            self:closeSkillToolTip()
            return                
        end
    end
end

-------------------------------------
-- function onTouchEnded
-------------------------------------
function SkillIndicatorMgr_ClanRaid:onTouchEnded(touch, event)
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
            local active_skill_id = self.m_selectHero:getSkillID('active')
            self.m_selectHero:reserveSkill(active_skill_id)

            -- 경직 중이라면 즉시 해제
            self.m_selectHero:setSpasticity(false)
            self.m_selectHero:changeState('skillAppear')
            
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
        if (self.m_touchedHero:isPossibleActiveSkill()) then
            local skill_indivisual_info = self.m_touchedHero:getSkillIndivisualInfo('active')
            local t_skill = skill_indivisual_info:getSkillTable()

            if (self.m_touchedHero.m_charType == 'tamer') then
                local tamer = self.m_touchedHero
                local t_event = {['touch']=false, ['location']=location}

                tamer:dispatch('touch_ended', t_event)

            elseif (self.m_touchedHero.m_skillIndicator) then
                local bPreparedSkill = self.m_world.m_heroAuto:prepareSkill(self.m_touchedHero, t_skill)
                if (bPreparedSkill) then
                    -- 경직 중이라면 즉시 해제
                    self.m_touchedHero:setSpasticity(false)
                    self.m_touchedHero:changeState('skillAppear')
                end
            end
        end

        self.m_touchedHero = nil
    end

    self:closeSkillToolTip()
end

-------------------------------------
-- function setSelectHero
-------------------------------------
function SkillIndicatorMgr_ClanRaid:setSelectHero(hero)
    self.m_startTimer = 0
        
    if (hero) then
        SoundMgr:playEffect('UI', 'ui_drag_ready')

        hero.m_skillIndicator:changeSIState(SI_STATE_READY)
        hero.m_skillIndicator:changeSIState(SI_STATE_APPEAR)
        hero.m_skillIndicator:setIndicatorTouchPos(self.m_firstTouchPos['x'], self.m_firstTouchPos['y'])
        hero.m_skillIndicator:update()

        self.m_selectHero = hero
    else
        if (self.m_selectHero) then
            self.m_selectHero.m_skillIndicator:changeSIState(SI_STATE_DISAPPEAR)
            self.m_selectHero = nil
        end
    end
end