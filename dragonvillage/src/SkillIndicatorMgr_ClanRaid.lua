local PARENT = SkillIndicatorMgr

-------------------------------------
-- class SkillIndicatorMgr_ClanRaid
-------------------------------------
SkillIndicatorMgr_ClanRaid = class(PARENT, {})

-------------------------------------
-- function update
-------------------------------------
function SkillIndicatorMgr_ClanRaid:update(dt)
    if (self:isControlling()) then
        if (self.m_selectHero:isDead()) then
            self:clear()
            self:closeSkillToolTip()
        else
            -- 인디케이터 충돌 정보를 매프레임 체크해야한다...
            self.m_selectHero.m_skillIndicator.m_bDirty = true
        end

    elseif (not self.m_world.m_gameState:isFight()) then
        -- 전투 중이 아닐 경우만 터치 시작시 정보를 초기화
        self:clear()
    end
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